package  
{
	import flash.external.ExternalInterface;
	
	import playerio.PartnerPay;
	import playerio.PlayerIOError;
	
	public class PartnerPayWrapper 
	{
		private static var main:Main;
		
		private static function getCurrentPartner(id:uint):String
		{
			// Get object
			var obj:PartnerPay = main.objectStorage[id];
			
			// Process
			return obj.currentPartner;
		}
		
		private static function setTag(partnerId:String, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:PartnerPay = main.objectStorage[id];
			
			// Process
			obj.setTag(partnerId, function():void
			{
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, -1, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private static function trigger(key:String, count:uint, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:PartnerPay = main.objectStorage[id];
			
			// Process
			obj.trigger(key, count, function():void
			{
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, -1, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		public static function init(mainReference:Main):void
		{
			main = mainReference;
			
			ExternalInterface.addCallback("getCurrentPartner", getCurrentPartner);
			ExternalInterface.addCallback("setTag", setTag);
			ExternalInterface.addCallback("trigger", trigger);
		}
	}
}