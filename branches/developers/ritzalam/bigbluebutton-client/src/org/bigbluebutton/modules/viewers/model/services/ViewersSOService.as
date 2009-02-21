package org.bigbluebutton.modules.viewers.model.services
{
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	import org.bigbluebutton.modules.viewers.ViewersModuleConstants;
	import org.bigbluebutton.modules.viewers.model.business.IViewers;
	import org.bigbluebutton.modules.viewers.model.vo.Status;
	import org.bigbluebutton.modules.viewers.model.vo.User;

	public class ViewersSOService implements IViewersService
	{
		public static const NAME:String = "ViewersSOService";
		public static const LOGNAME:String = "[ViewersSOService]";
		
		private var _participantsSO : SharedObject;
		private static const SO_NAME : String = "participantsSO";
		private static const STATUS:String = "_STATUS";
		
		private var netConnectionDelegate: NetConnectionDelegate;
		
		private var _participants:IViewers;
		private var _uri:String;
		private var _connectionSuccessListener:Function;
		private var _connectionFailedListener:Function;
		private var _connectionStatusListener:Function;
		private var _messageSender:Function;
				
		public function ViewersSOService(uri:String, participants:IViewers)
		{			
			_uri = uri;
			_participants = participants;
			netConnectionDelegate = new NetConnectionDelegate(uri);			
			netConnectionDelegate.addConnectionSuccessListener(connectionSuccessListener);
			netConnectionDelegate.addConnectionFailedListener(connectionFailedListener);
		}
		
		public function connect(uri:String, username:String, role:String, conference:String, mode:String, room:String):void {
			netConnectionDelegate.connect(_uri, username, role, conference, mode, room);
		}
			
		public function disconnect():void {
			leave();
			netConnectionDelegate.disconnect();
		}

		public function addMessageSender(msgSender:Function):void {
			_messageSender = msgSender;
		}
		
		private function sendMessage(msg:String, body:Object=null):void {
			if (_messageSender != null) _messageSender(msg, body);
		}
		
		private function connectionSuccessListener(connected:Boolean, user:Object=null, failReason:String=""):void {
			if (connected) {
				LogUtil.debug(LOGNAME + ":Connected to the Viewers application " + user.userid);
				_participants.me.userid = user.userid;
				join();
			} else {
				leave();
				LogUtil.debug(LOGNAME + ":Disconnected from the Viewers application");
				notifyConnectionStatusListener(false, failReason);
			}
		}
		
		private function connectionFailedListener(reason:String):void {
			notifyConnectionStatusListener(false, reason);
		}
		
	    private function join() : void
		{
			_participantsSO = SharedObject.getRemote(SO_NAME, _uri, false);
			_participantsSO.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_participantsSO.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_participantsSO.client = this;
			_participantsSO.connect(netConnectionDelegate.connection);
			LogUtil.debug(LOGNAME + ":ViewersModules is connected to Shared object");
			queryForParticipants();
		}
		
		private function queryForParticipants():void {
			var nc:NetConnection = netConnectionDelegate.connection;
			nc.call(
				"participants.getParticipants",// Remote function name
				new Responder(
	        		// participants - On successful result
					function(result:Object):void { 
						LogUtil.debug("Successfully queried participants: " + result.count); 
						if (result.count > 0) {
							for(var p:Object in result.participants) 
							{
								participantJoined(result.participants[p]);
							}							
						}	
						notifyConnectionStatusListener(true);
					},	
					// status - On error occurred
					function(status:Object):void { 
						LogUtil.error("Error occurred:"); 
						for (var x:Object in status) { 
							LogUtil.error(x + " : " + status[x]); 
							} 
						notifyConnectionStatusListener(false, "Failed to join the conference.");
					}
				)//new Responder
			); //_netConnection.call
		}
		
	    private function leave():void
	    {
	    	if (_participantsSO != null) _participantsSO.close();
	    }

		public function addConnectionStatusListener(connectionListener:Function):void {
			_connectionStatusListener = connectionListener;
		}
		
		public function participantLeft(user:Object):void { 
			_participants.removeParticipant(Number(user));
		}
		
		public function participantJoined(joinedUser:Object):void { 
			var user:User = new User();
			user.userid = Number(joinedUser.userid);
			user.name = joinedUser.username;	
			user.role = joinedUser.role;						
			user.status = joinedUser.status;	
								
			LogUtil.info("Joined as [" + user.userid + "," + user.name + "," + user.role + "]");
			_participants.addUser(user);
		}
/*
		public function newStatus(userid:Number, status:Status):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				aUser.addStatus(status);
				LogUtil.debug(LOGNAME + 'setting newStatus ' + status.name);
				_participantsSO.setProperty(userid.toString() + STATUS, aUser.status.source);
				_participantsSO.setDirty(userid.toString() + STATUS);
				//_participantsSO.send("addStatusCallback", userid, status);
			}
		}

		private function addStatusCallback(userid:Number, status:Status):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				aUser.addStatus(status);				
			}
		}
		
		public function changeStatus(userid:Number, status:Status):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				LogUtil.debug(LOGNAME + 'setting changeStatus ' + status.name);
				aUser.changeStatus(status);
				_participantsSO.setProperty(userid.toString() + STATUS, aUser.status.source);
				_participantsSO.setDirty(userid.toString() + STATUS);
				//_participantsSO.send("changeStatusCallback", userid, status);
			}
		}
		
		public function changeStatusCallback(userid:Number, status:Status):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				aUser.changeStatus(status);
			}
		}

		public function removeStatus(userid:Number, statusName:String):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				LogUtil.debug(LOGNAME + 'setting removeStatus ' + statusName);
				aUser.removeStatus(statusName);
				_participantsSO.setProperty(userid.toString() + STATUS, aUser.status.source);
				_participantsSO.setDirty(userid.toString() + STATUS);
				//_participantsSO.send("removeStatusCallback", userid, statusName);
			}
		}

		public function removeStatusCallback(userid:Number, statusName:String):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				aUser.removeStatus(statusName);
			}
		}
		
		public function iAmPresenter(userid:Number, presenter:Boolean):void {
			var aUser:User = _participants.getParticipant(userid);			
			if (aUser != null) {
				LogUtil.debug(LOGNAME + 'iampresenter ' + userid);
				aUser.presenter = presenter;
				_participantsSO.setProperty(userid.toString(), aUser);
				_participantsSO.setDirty(userid.toString());
			}
		}
*/						
		public function assignPresenter(userid:Number, assignedBy:Number):void {
	
			var nc:NetConnection = netConnectionDelegate.connection;
			nc.call(
				"participants.assignPresenter",// Remote function name
				new Responder(
	        		// participants - On successful result
					function(result:Boolean):void { 
						 
						if (result) {
							LogUtil.debug("Successfully assigned presenter to: " + userid);							
						}	
					},	
					// status - On error occurred
					function(status:Object):void { 
						LogUtil.error("Error occurred:"); 
						for (var x:Object in status) { 
							LogUtil.error(x + " : " + status[x]); 
							} 
					}
				), //new Responder
				userid,
				assignedBy
			); //_netConnection.call
		}
/*		
		public function assignPresenterCallback(userid:Number, assignedBy:Number):void {
			sendMessage(ViewersModuleConstants.ASSIGN_PRESENTER, {assignedTo:userid, assignedBy:assignedBy});
		}
		
		public function queryPresenter():void {
		
		}

		public function addStream(userid:Number, streamName:String):void {
			var aUser : User = _participants.getParticipant(userid);						
			if (aUser != null) {
				// This sets the users stream
				aUser.hasStream = true;
				aUser.streamName = streamName;
				_participantsSO.setProperty(userid.toString(), aUser);
				_participantsSO.setDirty(userid.toString());
				
				LogUtil.debug(LOGNAME + "Conference::addStream::found =[" + userid + "," 
						+ aUser.hasStream + "," + aUser.streamName + "]");				
			}
		}
		
		public function removeStream(userid:Number, streamName:String):void {
			var aUser : User = _participants.getParticipant(userid);						
			if (aUser != null) {
				// This sets the users stream
				aUser.hasStream = false;
				aUser.streamName = "";
				_participantsSO.setProperty(userid.toString(), aUser);
				_participantsSO.setDirty(userid.toString());
				
				LogUtil.debug(LOGNAME + "Conference::removeStream::found =[" + userid + "," 
						+ aUser.hasStream + "," + aUser.streamName + "]");				
			}
		}
*/		

		private function notifyConnectionStatusListener(connected:Boolean, reason:String = null):void {
			if (_connectionStatusListener != null) {
				_connectionStatusListener(connected, reason);
			}
		}

		private function netStatusHandler ( event : NetStatusEvent ) : void
		{
			var statusCode : String = event.info.code;
			
			switch ( statusCode ) 
			{
				case "NetConnection.Connect.Success" :
					LogUtil.debug(LOGNAME + ":Connection Success");		
					notifyConnectionStatusListener(true);			
					break;
			
				case "NetConnection.Connect.Failed" :			
					LogUtil.debug(LOGNAME + ":Connection to viewers application failed");
					notifyConnectionStatusListener(false);
					break;
					
				case "NetConnection.Connect.Closed" :									
					LogUtil.debug(LOGNAME + ":Connection to viewers application closed");
					notifyConnectionStatusListener(false);
					break;
					
				case "NetConnection.Connect.InvalidApp" :				
					LogUtil.debug(LOGNAME + ":Viewers application not found on server");
					notifyConnectionStatusListener(false);
					break;
					
				case "NetConnection.Connect.AppShutDown" :
					LogUtil.debug(LOGNAME + ":Viewers application has been shutdown");
					notifyConnectionStatusListener(false);
					break;
					
				case "NetConnection.Connect.Rejected" :
					LogUtil.debug(LOGNAME + ":No permissions to connect to the viewers application" );
					notifyConnectionStatusListener(false);
					break;
					
				default :
				   LogUtil.debug(LOGNAME + ":default - " + event.info.code );
				   notifyConnectionStatusListener(false);
				   break;
			}
		}
			
		private function asyncErrorHandler ( event : AsyncErrorEvent ) : void
		{
			LogUtil.debug(LOGNAME + "participantsSO asyncErrorHandler " + event.error);
			notifyConnectionStatusListener(false);
		}
		
		public function get connection():NetConnection
		{
			return netConnectionDelegate.connection;
		}
	}
}