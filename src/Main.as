package 
{
	import flash.system.Security;
	
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	import flash.display.Sprite;
	
	import flash.external.ExternalInterface;
	
	public class Main extends Sprite
	{
		// Should be accessible in other classes
		public var objectStorage:Object = { };
		public var lastObjectId:uint = 0;
		
		private function connect(gameid:String, connectionid:String, userid:String, auth:String, partnerId:String, callbackId:int):void
		{
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			PlayerIO.connect(stage, gameid, connectionid, userid, auth, partnerId, function(client:Client):void
			{
				// Get new id and increase
				var id:uint = lastObjectId++;
				
				// Store object
				objectStorage[id] = client;
				
				// Store child objects
				// - client.bigDB
				// - client.errorLog
				// - client.gameFS
				// - client.multiplayer
				// - client.payVault
				
				var bigDB_id:uint = lastObjectId++;
				objectStorage[bigDB_id] = client.bigDB;
				var errorLog_id:uint = lastObjectId++;
				objectStorage[errorLog_id] = client.errorLog;
				var gameFS_id:uint = lastObjectId++;
				objectStorage[gameFS_id] = client.gameFS;
				var multiplayer_id:uint = lastObjectId++;
				objectStorage[multiplayer_id] = client.multiplayer;
				var payVault_id:uint = lastObjectId++;
				objectStorage[payVault_id] = client.payVault;
				var partnerPay_id:uint = lastObjectId++;
				objectStorage[partnerPay_id] = client.partnerPay;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, [ id, client.connectUserId, bigDB_id, errorLog_id, gameFS_id, multiplayer_id, payVault_id, partnerPay_id ], false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		public function Main():void 
		{
			// Allow
			Security.allowDomain("*");
			
			// Do we even have access to ExternalInterface?
			if (!ExternalInterface.available)
			{
				// Oh no!
				return;
			}
			
			// PlayerIO class
			ExternalInterface.addCallback("connect", connect);
			
			// Initialize other wrapper functions
			GameFSWrapper.init(this);
			ErrorLogWrapper.init(this);
			PartnerPayWrapper.init(this);
			ConnectionWrapper.init(this);
			MultiplayerWrapper.init(this);
		}
	}
}