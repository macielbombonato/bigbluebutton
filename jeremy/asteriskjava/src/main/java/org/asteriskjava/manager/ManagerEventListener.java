/*
 *  Copyright 2004-2006 Stefan Reuter
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package org.asteriskjava.manager;

import java.util.EventListener;

import org.asteriskjava.manager.event.ManagerEvent;


/**
 * An interface to listen for events received from an Asterisk server.
 * 
 * @see org.asteriskjava.manager.event.ManagerEvent
 * @author srt
 * @version $Id: ManagerEventListener.java 938 2007-12-31 03:23:38Z srt $
 */
public interface ManagerEventListener extends EventListener
{
    /**
     * This method is called when an event is received.
     * 
     * @param event the event that has been received
     */
    void onManagerEvent(ManagerEvent event);
}
