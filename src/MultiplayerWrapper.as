package  
{
	import flash.external.ExternalInterface;
	
	import playerio.Multiplayer;
	import playerio.Connection;
	import playerio.RoomInfo;
	import playerio.PlayerIOError;
	
	public class MultiplayerWrapper 
	{
		private static var main:Main;
		
		private static function getDevelopmentServer(id:uint):String
		{
			// Get object
			var obj:Multiplayer = main.objectStorage[id];
			
			// Process
			return obj.developmentServer;
		}
		
		private static function setDevelopmentServer(id:uint, value:String):void
		{
			// Get object
			var obj:Multiplayer = main.objectStorage[id];
			
			// Process
			obj.developmentServer = value;
		}
		
		private static function createRoom(roomId:String, roomType:String, visible:Boolean, roomData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = main.objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.createRoom(roomId, roomType, visible, roomData, function(connection:Connection):void
			{
				// Get new id and increase
				var id:uint = main.lastObjectId++;
				
				// Store object
				main.objectStorage[id] = connection;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, id, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private static function createJoinRoom(roomId:String, roomType:String, visible:Boolean, roomData:Object, joinData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = main.objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.createJoinRoom(roomId, roomType, visible, roomData, joinData, function(connection:Connection):void
			{
				// Get new id and increase
				var id:uint = main.lastObjectId++;
				
				// Store object
				main.objectStorage[id] = connection;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, id, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private static function joinRoom(roomId:String, joinData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = main.objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.joinRoom(roomId, joinData, function(connection:Connection):void
			{
				// Get new id and increase
				var id:uint = main.lastObjectId++;
				
				// Store object
				main.objectStorage[id] = connection;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, id, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private static function listRooms(roomType:String, searchCriteria:Object, resultLimit:uint, resultOffset:uint, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = main.objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.listRooms(roomType, searchCriteria, resultLimit, resultOffset, function(rooms:Array):void
			{
				// Prepare object for JS
				var JSRooms:Array = new Array(rooms.length);
				for (var i:uint = 0; i < rooms.length; i++)
				{
					// Get the RoomInfo
					var info:RoomInfo = rooms[i];
					
					// Construct an array that holds the information
					var obj:Array = [ info.data, info.id, info.onlineUsers, info.roomType, info.serverType ];
					JSRooms[i] = obj;
				}
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, JSRooms, false);
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
			
			ExternalInterface.addCallback("getDevelopmentServer", getDevelopmentServer);
			ExternalInterface.addCallback("setDevelopmentServer", setDevelopmentServer);
			ExternalInterface.addCallback("createRoom", createRoom);
			ExternalInterface.addCallback("createJoinRoom", createJoinRoom);
			ExternalInterface.addCallback("joinRoom", joinRoom);
			ExternalInterface.addCallback("listRooms", listRooms);
		}
	}
}