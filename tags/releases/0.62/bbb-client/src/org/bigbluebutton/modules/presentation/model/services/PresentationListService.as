/*
 * BigBlueButton - http://www.bigbluebutton.org
 * 
 * Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.
 * 
 * BigBlueButton is free software; you can redistribute it and/or modify it under the 
 * terms of the GNU Lesser General Public License as published by the Free Software 
 * Foundation; either version 3 of the License, or (at your option) any later 
 * version. 
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along 
 * with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.
 *
 * $Id: $
 */
package org.bigbluebutton.modules.presentation.model.services
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	
	import org.bigbluebutton.modules.presentation.model.business.IPresentationSlides;
	        	
	/**
	 * This class directly communicates with an HTTP service in order to send and recives files (slides
	 * in this case)
	 * <p>
	 * This class extends the Proxy class of the pureMVC framework
	 * @author dev_team@bigbluebutton.org
	 * 
	 */	        	
	public class PresentationListService implements IResponder
	{  
		private var service : HTTPService;
		private var _slides:IPresentationSlides;
		private var urlLoader:URLLoader;
		private var _loadListener:Function;
		
		public function PresentationListService()
		{
			service = new HTTPService();
		}
		
		/**
		 * Load slides from an HTTP service. Response is received in the Responder class' onResult method 
		 * @param url
		 * 
		 */		
		public function load(url:String, slides:IPresentationSlides) : void
		{
			_slides = slides;
			service.url = url;			
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, handleComplete);	
			urlLoader.load(new URLRequest(url));
			
		}

		public function addLoadPresentationListener(listener:Function):void {
			_loadListener = listener;
		}
		
		private function handleComplete(e:Event):void{
			LogUtil.debug("Loading complete");
			parse(new XML(e.target.data));				
		}
		
		public function parse(xml:XML):void{
			var list:XMLList = xml.presentation.slide;
			var item:XML;
			
			// Make sure we start with a clean set.
			_slides.clear();			
			
			for each(item in list){
				//LogUtil.debug("Available Modules: " + item.name + " at ");
				_slides.add(item.source);
			}		
			
			//LogUtil.debug("number of slide=" + _slides.size());
			if (_slides.size() > 0) {
				if (_loadListener != null) {
					_loadListener(true);
				}
			} else {
				_loadListener(false);
			}
				
		}

		/**
		 * This is the response event. It is called when the PresentationService class sends a request to
		 * the server. This class then responds with this event 
		 * @param event
		 * 
		 */		
		public function result(event : Object):void
		{
			var xml:XML = new XML(event.result);
			var list:XMLList = xml.presentations;
			var item:XML;
						
			for each(item in list){
				LogUtil.debug("Available Modules: " + item.toXMLString() + " at " + item.text());
				
			}	
		}

		/**
		 * Event is called in case the call the to server wasn't successful. This method then gets called
		 * instead of the result() method above 
		 * @param event
		 * 
		 */
		public function fault(event : Object):void
		{
			LogUtil.debug("Got fault [" + event.fault.toString() + "]");		
		}		
	}
}