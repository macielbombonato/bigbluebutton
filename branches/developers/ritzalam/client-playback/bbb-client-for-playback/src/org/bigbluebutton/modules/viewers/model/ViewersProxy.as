package org.bigbluebutton.modules.viewers.model
{
	import flash.net.NetConnection;
	
	import mx.collections.ArrayCollection;
	
	import org.bigbluebutton.modules.viewers.ViewersModuleConstants;
	import org.bigbluebutton.modules.viewers.model.business.Conference;
	import org.bigbluebutton.modules.viewers.model.business.IViewers;
	import org.bigbluebutton.modules.viewers.model.services.IViewersService;
	import org.bigbluebutton.modules.viewers.model.services.JoinService;
	import org.bigbluebutton.modules.viewers.model.services.ViewersSOService;
	import org.bigbluebutton.modules.viewers.model.vo.Status;
	import org.bigbluebutton.modules.viewers.model.vo.User;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ViewersProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ViewersProxy";
		private var module:ViewersModule;		
		private var _viewersService:IViewersService;
		private var _participants:IViewers = null;
		private var joinService:JoinService;
		
		private var isPresenter:Boolean = false;
				
		public function ViewersProxy(module:ViewersModule)
		{
			super(NAME);
			this.module = module;
		}
		
		override public function getProxyName():String
		{
			return NAME;
		}
		
		public function connect():void {
			_viewersService = new ViewersSOService(module, _participants);
			_viewersService.addConnectionStatusListener(connectionStatusListener);
			_viewersService.addMessageSender(messageSender);
			LogUtil.debug(NAME + '::' + module.username + "," + module.role);
			_viewersService.connect(module.username, module.role, module.conference, module.mode, module.room);		
		}

		public function join():void {
			LogUtil.debug(NAME + "::joning in ");
			joinService = new JoinService();
			joinService.addJoinResultListener(joinListener);
			joinService.load(module.host);

		}
		
		private function joinListener(success:Boolean, result:Object):void {
			if (success) {
				LogUtil.debug(NAME + '::Sending ViewersModuleConstants.JOIN_SUCCESS' + result.role);
				_participants = new Conference();
				_participants.me.name = result.username;
				_participants.me.role = result.role;
				_participants.me.room = result.room;
				_participants.me.authToken = result.authToken;
				
				module.conference = result.conference;
				module.username = _participants.me.name;
				module.role = _participants.me.role;
				module.room = _participants.me.room;
				module.authToken = _participants.me.authToken;
				module.mode = result.mode;
				module.voicebridge = result.voicebridge;
				
				connect();
			} else {
				LogUtil.debug(NAME + '::Sending ViewersModuleConstants.JOIN_FAILED');
				sendNotification(ViewersModuleConstants.JOIN_FAILED, result);
			}
		}
		
		public function stop():void {
			_viewersService.disconnect();
		}
		
		public function get me():User {
			return _participants.me;
		}
		
		public function isModerator():Boolean {
			if (me.role == "MODERATOR") {
				return true;
			}
			
			return false;
		}
		
		public function get participants():ArrayCollection {
			return _participants.users;
		}
		
		public function assignPresenter(assignTo:Number):void {
			_viewersService.assignPresenter(assignTo, me.userid);
		}
		
		public function addStream(userid:Number, streamName:String):void {
			_viewersService.addStream(userid, streamName);
		}
		
		public function removeStream(userid:Number, streamName:String):void {			
			_viewersService.removeStream(userid, streamName);
		}
		
		public function raiseHand(raise:Boolean):void {
			var userid:Number = _participants.me.userid;
			_viewersService.raiseHand(userid, raise);
		}
		
		public function lowerHand(userid:Number):void {
			_viewersService.raiseHand(userid, false);
		}
		
		public function queryPresenter():void {
//			_viewersService.queryPresenter();
		}
		
		private function connectionStatusListener(connected:Boolean, reason:String = null):void {
			if (connected) {
				// Set the module.userid, _participants.me.userid in the ViewersSOService.
				module.userid = _participants.me.userid;
				sendNotification(ViewersModuleConstants.LOGGED_IN);
			} else {
				_participants = null;
				if (reason == null) reason = ViewersModuleConstants.UNKNOWN_REASON;
				sendNotification(ViewersModuleConstants.LOGGED_OUT, reason);
			}
		}
		
		private function messageSender(msg:String, body:Object=null):void {
			switch (msg) {
				case ViewersModuleConstants.ASSIGN_PRESENTER:
					if (me.userid == body.assignedTo) {
						// I've been assigned as presenter.
						LogUtil.debug('I have become presenter');
						isPresenter = true;
						var newStatus:Status = new Status("presenter", body.assignedBy);
//						_viewersService.iAmPresenter(me.userid, true);
						var presenterInfo:Object = {presenterId:body.assignedTo, presenterName:me.name, assignedBy:body.assignedBy}
						sendNotification(msg, presenterInfo);
					} else {
						// Somebody else has become presenter.
						if (isPresenter) {
							LogUtil.debug('Somebody else has become presenter.');
//							_viewersService.iAmPresenter(me.userid, false);
						}
						isPresenter = false;
						sendNotification(ViewersModuleConstants.BECOME_VIEWER, body);					
					}
					break;
				default:
					sendNotification(msg, body);
			} 
		}		
		
		public function get connection():NetConnection
		{
			return _viewersService.connection;
		}
	}
}