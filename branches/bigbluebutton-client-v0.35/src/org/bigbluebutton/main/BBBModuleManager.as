package org.bigbluebutton.main
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.ModuleEvent;
	import mx.modules.ModuleLoader;
	
	import org.bigbluebutton.main.model.ModuleDescriptor;
	import org.bigbluebutton.modules.chat.ChatModule;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class BBBModuleManager extends Mediator implements IMediator
	{
		public static const NAME:String = "BBBModuleManager";
		public static const FILE_PATH:String = "org/bigbluebutton/common/modules.xml";
		
		public var modules:ArrayList;
		private var urlLoader:URLLoader;
		private var modulesList:Array;
		
		public function BBBModuleManager()
		{
			super(NAME);
			modules = new ArrayList();
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, handleComplete);
		}
		
		override public function initializeNotifier(key:String):void{
			super.initializeNotifier(key);
			urlLoader.load(new URLRequest(FILE_PATH));
		}
		
		override public function listNotificationInterests():Array{
			return [
					MainApplicationFacade.START_ALL_MODULES
					];
		}
		
		override public function handleNotification(notification:INotification):void{
			switch(notification.getName()){
				case MainApplicationFacade.START_ALL_MODULES:
				trace("The modules: " + modulesList);
					var m:ModuleDescriptor = modulesList["ChatModule"];
					
					loadModule(m.url);
					// for (var i:Number = 0; i<this.modulesList.length ; i++){
//					for (var i:Number = 0; i<1 ; i++){
//						//Alert.show(modulesList[i]);
//						loadModule(this.modulesList[i]);
//					}
					break;
			}
		}
		
		private function handleComplete(e:Event):void{
			try{
				parse(new XML(e.target.data));
			} catch(error:TypeError){
				Alert.show(error.message);
			}
		}
		
		private function parse(xml:XML):void{
			var list:XMLList = xml.module;
			var item:XML;
			this.modulesList = new Array();
			for each(item in list){
				trace("Available Modules: " + item.@name + " at " + item.@swfpath);
				var mod:ModuleDescriptor = new ModuleDescriptor(item.@name, item.@swfpath);
				this.modulesList[item.@name] = mod;
			}
		}
		
		private function loadModule(path:String):void{
			
			var loader:ModuleLoader = new ModuleLoader();
			modules.addItem(loader);
			loader.addEventListener(ModuleEvent.READY, moduleReady);
			trace("Loading module " + path);
			loader.url = path;
			loader.loadModule();
		}
		
		private function moduleReady(e:ModuleEvent):void{
			
			var loader:ModuleLoader = e.target as ModuleLoader;
			var iModule:* = loader.child as ChatModule;
			if (iModule != null){
				//var bbbModule:BigBlueButtonModule = iModule as BigBlueButtonModule;	
				trace("Adding module: " + iModule.getID());
				sendNotification(MainApplicationFacade.ADD_MODULE, iModule);
				sendNotification(MainApplicationFacade.MODULES_STARTED);
			} else{
				Alert.show("Module could not be initialized");
			}
			
			this.modulesList.pop();
			//All modules have started, send notification.
			if (this.modulesList.length == 0){
				sendNotification(MainApplicationFacade.MODULES_STARTED);
			}
		}

	}
}