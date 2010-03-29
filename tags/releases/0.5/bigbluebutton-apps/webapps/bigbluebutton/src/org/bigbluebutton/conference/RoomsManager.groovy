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
package org.bigbluebutton.conference

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.red5.logging.Red5LoggerFactory

import net.jcip.annotations.ThreadSafe
import java.util.concurrent.ConcurrentHashMap
/**
 * This encapsulates access to Room and Participant. This class must be threadsafe.
 */
@ThreadSafe
public class RoomsManager {
	private static Logger log = Red5LoggerFactory.getLogger(RoomsManager.class, "bigbluebutton")
	
	private final Map <String, Room> rooms
	
	public RoomsManager() {
		log.debug("In RoomsManager constructor")	
		rooms = new ConcurrentHashMap<String, Room>()
	}
	
	public void addRoom(Room room) {
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
	
	public int numberOfRooms() {
		return rooms.size()
	}
	
	/**
	 * Keeping getRoom private so that all access to Room goes through here.
	 */
	private Room getRoom(String name) {
		log.debug("In RoomsManager get room ${name}")
		rooms.get(name)
	}
	
	public Map getParticipants(String roomName) {
		Room r = getRoom(roomName)
		if (r != null) {
			return r.getParticipants()
		}
		log.warn("Getting participants from a non-existing room ${roomName}")
		return null
	}
	
	public void addRoomListener(String roomName, IRoomListener listener) {
		Room r = getRoom(roomName)
		if (r != null) {
			r.addRoomListener(listener)
			return
		}
		log.warn("Adding listener to a non-existing room ${roomName}")
	}
	
	public void removeRoomListener(IRoomListener listener) {
		Room r = getRoom(roomName)
		if (r != null) {
			r.removeRoomListener(listener)
			return
		}	
		log.warn("Removing listener from a non-existing room ${roomName}")
	}
	
	public void addParticipant(String roomName, Participant participant) {
		Room r = getRoom(roomName)
		if (r != null) {
			r.addParticipant(participant)
			return
		}
		log.warn("Adding participant to a non-existing room ${roomName}")
	}
	
	public void removeParticipant(String roomName, Long userid) {
		Room r = getRoom(roomName)
		if (r != null) {
			r.removeParticipant(userid)
			return
		}
		log.warn("Removing listener from a non-existing room ${roomName}")
	}
	
	public void changeParticipantStatus(String roomName, Long userid, String status, Object value) {
		Room r = getRoom(roomName)
		if (r != null) {
			r.changeParticipantStatus(userid, status, value)
			return
		}		
		log.warn("Changing participant status on a non-existing room ${roomName}")
	}
}