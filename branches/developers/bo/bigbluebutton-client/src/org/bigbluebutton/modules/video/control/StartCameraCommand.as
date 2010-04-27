package org.bigbluebutton.modules.video.control
{
	import org.bigbluebutton.modules.video.model.MediaProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartCameraCommand extends SimpleCommand implements ICommand
	{	
		override public function execute(notification:INotification):void
		{
			if (facade.hasProxy(MediaProxy.NAME)) {
				var p:MediaProxy = facade.retrieveProxy(MediaProxy.NAME) as MediaProxy;
				LogUtil.debug('Starting camera ' + notification.getBody() as String);
				p.startCamera(notification.getBody() as String);
			}
		}		
	}
}