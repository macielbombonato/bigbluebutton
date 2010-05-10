package org.bigbluebutton.conference.service.presentation

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.red5.logging.Red5LoggerFactory

import net.jcip.annotations.ThreadSafe
import java.util.concurrent.ConcurrentHashMap
/**
 * This encapsulates access to Room and messages. This class must be threadsafe.
 */
@ThreadSafe
public class PresentationRoomsManager {
	private static Logger log = Red5LoggerFactory.getLogger( PresentationRoomsManager.class, "bigbluebutton" );
	
	private final Map <String, PresentationRoom> rooms
	
	public PresentationRoomsManager() {
		log.debug("In PresentationRoomsManager constructor")	
		rooms = new ConcurrentHashMap<String, PresentationRoom>()
	}
	
	public void addRoom(PresentationRoom room) {
		log.debug("In RoomsManager adding room ${room.name}")
		rooms.put(room.name, room)
	}
	
	public void removeRoom(String name) {
		log.debug("In RoomsManager remove room ${name}")
		rooms.remove(name)
	}
		
	public boolean hasRoom(String name) {
		log.debug("In RoomsManager has Room ${name}")
		return ((HashMap)rooms).containsKey(name)
	}
	
	
	/**
	 * Keeping getRoom private so that all access to ChatRoom goes through here.
	 */
	private PresentationRoom getRoom(String name) {
		log.debug("In RoomsManager get room ${name}")
		rooms.get(name)
	}
		
	public void addRoomListener(String roomName, IPresentationRoomListener listener) {
		PresentationRoom r = getRoom(roomName)
		if (r != null) {
			r.addRoomListener(listener)
			return
		}
		log.warn("Adding listener to a non-existing room ${roomName}")
	}
	
	public void removeRoomListener(IPresentationRoomListener listener) {
		PresentationRoom r = getRoom(roomName)
		if (r != null) {
			r.removeRoomListener(listener)
			return
		}	
		log.warn("Removing listener from a non-existing room ${roomName}")
	}
	
	def sendUpdateMessage = {message ->
		def room = message['room']
		PresentationRoom r = getRoom(room)
		if (r != null) {
			r.sendUpdateMessage(message)
			return
		}	
		log.warn("Sending update message to a non-existing room $room")			
	}
	
	def getCurrentPresenter = {room ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			return r.getCurrentPresenter()
			
		}	
		log.warn("Getting presenter from a non-existing room $room")	
	}
	
	def getSharingPresentation = {room ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			return r.sharing			
		}	
		log.warn("Getting sharing from a non-existing room $room")	
	}
	
	def assignPresenter = {room, presenter ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			r.assignPresenter(presenter)
			return
		}	
		log.warn("Assigning presenter to a non-existing room $room")	
	}
	
	def gotoSlide = {room, slide ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			log.debug("Request to go to slide $slide for room $room")
			r.gotoSlide(slide)
			return
		}	
		log.warn("Changing slide on a non-existing room $room")	
	}
	
	def sharePresentation = {room, presentationName, share ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			log.debug("Request share presentation $presentationName $share for room $room")
			r.sharePresentation(presentationName, share)
			return
		}	
		log.warn("Sharing presentation on a non-existing room $room")	
	}
	
	def getCurrentSlide = {room ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			return r.getCurrentSlide()
		}	
		log.warn("Getting slide on a non-existing room $room")	
	}
	
	def getCurrentPresentation = {room ->
		PresentationRoom r = getRoom(room)
		if (r != null) {
			return r.getCurrentPresentation()
		}	
		log.warn("Getting current presentation on a non-existing room $room")	
	}
}