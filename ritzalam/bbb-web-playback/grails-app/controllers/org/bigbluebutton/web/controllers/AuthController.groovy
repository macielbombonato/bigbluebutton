package org.bigbluebutton.web.controllers

import org.jsecurity.authc.AuthenticationException
import org.jsecurity.authc.UsernamePasswordToken
import org.jsecurity.SecurityUtils
import org.jsecurity.session.Session
import org.jsecurity.subject.Subject
import org.bigbluebutton.web.domain.User

class AuthController {

    def jsecSecurityManager

    def index = { redirect(action: 'login', params: params) }

    def login = {
        return [ username: params.username, rememberMe: (params.rememberMe != null), targetUri: params.targetUri ]
    }

    def signIn = {
        def authToken = new UsernamePasswordToken(params.username, params.password)

        // Support for "remember me"
        if (params.rememberMe) {
            authToken.rememberMe = true
        }

        try{
            // Perform the actual login. An AuthenticationException
            // will be thrown if the username is unrecognised or the
            // password is incorrect.
            this.jsecSecurityManager.login(authToken)

			// Store the username in the session
			Subject currentUser = SecurityUtils.getSubject(); 
			Session jsecSession = currentUser.getSession();  
   			jsecSession.setAttribute( "username", params.username );  
			User user = User.findByUsername(params.username)
			jsecSession.setAttribute( "userid", user.id );
			
			session["username"] = params.username
			session["userid"] = user.id
			log.debug "$params.username has signedin."
			
            // If a controller redirected to this page, redirect back
            // to it. Otherwise redirect to the root URI.
            def targetUri = params.targetUri ?: "/"
            redirect(uri: targetUri)
        }
        catch (AuthenticationException ex){
            // Authentication failed, so display the appropriate message
            // on the login page.
            log.debug "Authentication failure for user '${params.username}'."
            flash.message = message(code: "login.failed")

            // Keep the username and "remember me" setting so that the
            // user doesn't have to enter them again.
            def m = [ username: params.username ]
            if (params.rememberMe) {
                m['rememberMe'] = true
            }

            // Remember the target URI too.
            if (params.targetUri) {
                m['targetUri'] = params.targetUri
            }

            // Now redirect back to the login page.
            redirect(action: 'login', params: m)
        }
    }

    def signOut = {
        // Log the user out of the application.
        SecurityUtils.subject?.logout()
        session.invalidate()
        // For now, redirect back to the home page.
        redirect(uri: '/')
    }

    def unauthorized = {
        render 'You do not have permission to access this page.'
    }
}
