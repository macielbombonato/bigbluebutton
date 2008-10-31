package org.bigbluebutton.common.messaging
{
	public class EndpointMessageConstants
	{	
		public static const MODULE_READY:String = 'MODULE_READY';	
		public static const MODULE_STARTED:String = 'MODULE_STARTED';
		public static const MODULE_STOPPED:String = 'MODULE_STOPPED';
		
		public static const CONF_INFO_QUERY:String = 'CONF_INFO_QUERY';
		public static const CONF_INFO_QUERY_REPLY:String = 'CONF_INFO_QUERY_REPLY';

		public static const FROM_MAIN_APP:String = 'FROM_MAIN_APP';
		public static const TO_MAIN_APP:String = 'TO_MAIN_APP';
		
		public static const FROM_CHAT_MODULE:String = 'FROM_CHAT_MODULE';
		public static const TO_CHAT_MODULE:String = 'TO_CHAT_MODULE';
		
		public static const FROM_VIEWERS_MODULE:String = 'FROM_VIEWERS_MODULE';
		public static const TO_VIEWERS_MODULE:String = 'TO_VIEWERS_MODULE';
		
		public static const OPEN_WINDOW:String = 'OPEN_WINDOW';
		public static const CLOSE_WINDOW:String = 'CLOSE_WINDOW';
		public static const ADD_WINDOW:String = 'ADD_WINDOW';
		public static const REMOVE_WINDOW:String = 'REMOVE_WINDOW';

		public static const USER_LOGIN:String = 'USER_LOGIN';
		public static const USER_LOGGED_IN:String = 'USER_LOGGED_IN'
		public static const USER_LOGOUT:String = 'USER_LOGOUT';
		public static const USER_LOGGED_OUT:String = 'USER_LOGGED_OUT';
	}
}