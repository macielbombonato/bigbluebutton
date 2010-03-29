
package org.bigbluebutton.conference.service.voice

import java.util.Map
import org.bigbluebutton.conference.service.archive.record.IEventRecorder
import org.bigbluebutton.conference.service.archive.record.IRecorder
import org.bigbluebutton.conference.Participant
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.red5.logging.Red5LoggerFactory

public class VoiceEventRecorder implements IEventRecorder, IVoiceRoomListener {
	private static Logger log = Red5LoggerFactory.getLogger( VoiceEventRecorder.class, "bigbluebutton" )
	
	IRecorder recorder
	private ISharedObject so
	def APP_NAME = 'VOICE'
	
	def acceptRecorder(IRecorder recorder){
		log.debug("Accepting IRecorder")
		this.recorder = recorder
	}
	
	def getName() {
		return APP_NAME
	}
	
	def recordEvent(Map event){
		recorder.recordEvent(event)
	}
	
	public VoiceEventRecorder(ISharedObject so) {
		this.so = so 
	}
	
	def joined(user, name, muted, talking){
		log.debug("Participant $name joining")
		// Just send the name to represent callerId number for now
		so.sendMessage("userJoin", [user, name, name, muted, talking])
		
		/* Comment out for now (ralam 4/17/2009)
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)
		xml.event(name:'joined', date:new Date().time, application:APP_NAME) {
			participant(id:user, name:name, muted:muted, talking:talking)
		}
		recorder.recordXmlEvent(writer.toString())
		*/
		
		Map event = new HashMap()
		event.put("date", new Date().time)
		event.put("application", APP_NAME)
		event.put("event", "joined")
		event.put('participant', user)
		event.put('name', name)
		event.put('muted', muted)
		event.put('talking', talking)
		recordEvent(event)	
	}
	
	def left(user){
		log.debug("Participant $user leaving")
		so.sendMessage("userLeft", [user])

		/* Comment out for now (ralam 4/17/2009)
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)
		xml.event(name:'left', date:new Date().time, application:APP_NAME) {
			participant(id:user)
		}
		recorder.recordXmlEvent(writer.toString())
		*/
		
		Map event = new HashMap()
		event.put("date", new Date().time)
		event.put("application", APP_NAME)
		event.put("event", "left")
		event.put('participant', user)
		recordEvent(event)
	}
	
	def mute(user, muted){
		log.debug("Participant $user mute $muted")
		so.sendMessage("userMute", [user, muted])

		/* Comment out for now (ralam 4/17/2009)
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)
		xml.event(name:'mute', date:new Date().time, application:APP_NAME) {
			participant(id:user, mute:muted)
		}
		recorder.recordXmlEvent(writer.toString())
		*/
		
		Map event = new HashMap()
		event.put("date", new Date().time)
		event.put("application", APP_NAME)
		event.put("event", "mute")
		event.put('participant', user)
		event.put('mute', mute)
		recordEvent(event)
	}
	
	def talk(user, talking){
		log.debug("Participant $user talk $talking")
		so.sendMessage("userTalk", [user, talking])

		/* Comment out for now (ralam 4/17/2009)
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)
		xml.event(name:'talk', date:new Date().time, application:APP_NAME) {
			'participant'(id:user, talk:talking)
		}
		recorder.recordXmlEvent(writer.toString())
		*/
		
		Map event = new HashMap()
		event.put("date", new Date().time)
		event.put("application", APP_NAME)
		event.put("event", "talk")
		event.put('participant', user)
		event.put('talk', talk)
		recordEvent(event)
	}
}