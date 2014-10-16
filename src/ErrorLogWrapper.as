package  
{
	import flash.external.ExternalInterface;
	
	import playerio.ErrorLog;
	import playerio.PlayerIOError;
	
	public class ErrorLogWrapper 
	{
		private static var main:Main;
		
		private static function writeError(error:String, details:String, stacktrace:String, extraData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:ErrorLog = main.objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.writeError(error, details, stacktrace, extraData, function():void
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
			
			ExternalInterface.addCallback("writeError", writeError);
		}
	}
}