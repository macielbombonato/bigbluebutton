package org.bigbluebutton.modules.deskShare.controller
{
	import org.bigbluebutton.modules.deskShare.DeskShareEndpointMediator;
	import org.bigbluebutton.modules.deskShare.DeskShareModuleConstants;
	import org.bigbluebutton.modules.deskShare.DeskShareModuleMediator;
	import org.bigbluebutton.modules.deskShare.model.business.DeskShareProxy;
	import org.bigbluebutton.modules.deskShare.view.DeskShareWindowMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void{
			var module:DeskShareModule = notification.getBody() as DeskShareModule;
			
			facade.registerMediator(new DeskShareModuleMediator(module));
			facade.registerMediator(new DeskShareEndpointMediator(module));
			facade.registerMediator(new DeskShareWindowMediator(module));
			facade.registerProxy(new DeskShareProxy(module));
			sendNotification(DeskShareModuleConstants.CONNECTED);
		}
	}
}