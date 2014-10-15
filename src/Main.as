package 
{
	import flash.system.Security;
	import flash.utils.ByteArray;
	import playerio.Message;
	
	import playerio.Connection;
	import playerio.ErrorLog;
	import playerio.GameFS;
	import playerio.Multiplayer;
	import playerio.RoomInfo;
	
	import flash.display.Sprite;
	
	import flash.external.ExternalInterface;
	
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	/**
	 * ...
	 * @author Niels
	 */
	public class Main extends Sprite
	{
		private var objectStorage:Object = { };
		private var lastObjectId:uint = 0;
		
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
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, [ id, client.connectUserId, bigDB_id, errorLog_id, gameFS_id, multiplayer_id, payVault_id ], false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private function getURL(id:uint, path:String):String
		{
			// Get object
			var obj:GameFS = objectStorage[id];
			
			// Process
			return obj.getURL(path);
		}
		
		private function writeError(error:String, details:String, stacktrace:String, extraData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:ErrorLog = objectStorage[id];
			
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
		
		private function getDevelopmentServer(id:uint):String
		{
			// Get object
			var obj:Multiplayer = objectStorage[id];
			
			// Process
			return obj.developmentServer;
		}
		
		private function setDevelopmentServer(id:uint, value:String):void
		{
			// Get object
			var obj:Multiplayer = objectStorage[id];
			
			// Process
			obj.developmentServer = value;
		}
		
		private function createRoom(roomId:String, roomType:String, visible:Boolean, roomData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.createRoom(roomId, roomType, visible, roomData, function(connection:Connection):void
			{
				// Get new id and increase
				var id:uint = lastObjectId++;
				
				// Store object
				objectStorage[id] = connection;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, id, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private function createJoinRoom(roomId:String, roomType:String, visible:Boolean, roomData:Object, joinData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.createJoinRoom(roomId, roomType, visible, roomData, joinData, function(connection:Connection):void
			{
				// Get new id and increase
				var id:uint = lastObjectId++;
				
				// Store object
				objectStorage[id] = connection;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, id, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private function joinRoom(roomId:String, joinData:Object, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = objectStorage[id];
			
			// Callback subids:
			//					0 = success
			//					1 = fail
			
			// Process
			obj.joinRoom(roomId, joinData, function(connection:Connection):void
			{
				// Get new id and increase
				var id:uint = lastObjectId++;
				
				// Store object
				objectStorage[id] = connection;
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, id, false);
			},
			function(error:PlayerIOError):void
			{
				// Return to JS world with passing information of the error
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ error.name, error.message, error.errorID ], false);
			});
		}
		
		private function listRooms(roomType:String, searchCriteria:Object, resultLimit:uint, resultOffset:uint, id:uint, callbackId:uint):void
		{
			// Get object
			var obj:Multiplayer = objectStorage[id];
			
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
					
					// Construct an object
					var obj:Object = { data: info.data, id: info.id, onlineUsers: info.onlineUsers, roomType: info.roomType, serverType: info.serverType };
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
		
		private function getIsConnected(id:uint):Boolean
		{
			// Get object
			var obj:Connection = objectStorage[id];
			
			// Process
			return obj.connected;
		}
		
		private function disconnect(id:uint):void
		{
			// Get object
			var obj:Connection = objectStorage[id];
			
			// Process
			obj.disconnect();
		}
		
		private function sendMessage(id:uint, type:String, data:Array):void
		{
			// Get object
			var obj:Connection = objectStorage[id];
			
			// Create PIO message
			var msg:Message = obj.createMessage(type);
			
			// For some reason I can't add the whole array in one go...
			for (var i:uint = 0; i < data.length; i++)
			{
				msg.add(data[i]);
			}
			
			// And... send!
			obj.sendMessage(msg);
		}
		
		private function initConnection(id:uint, callbackId:uint):void 
		{
			// Get object
			var obj:Connection = objectStorage[id];
			
			// Callback subids:
			//					0 = disconnect
			//					1 = message
			
			// Add callbacks
			obj.addDisconnectHandler(function():void
			{
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 0, -1, false);
			});
			
			// The trick here is to accept message as an object
			// this is so we can copy the data because it doesn't restrict us to the public type
			// we can get access to the (hidden) clone property as specified on the documentation of PIO
			obj.addMessageHandler("*", function(message:Object):void
			{
				// We need to send the type, type array and data to the client
				var type:String = message.type;
				var data:Array = null;
				var types:Array = null;
				
				// Copy time
				if (message.length > 0)
				{
					// Clone
					var dataContainer:DataContainer = new DataContainer(message.length);
					message.clone(dataContainer);
					
					// Get the (cloned) data
					data = dataContainer.data;
					types = new Array(message.length);
					
					// Fix up types
					for (var i:uint = 0; i < message.length; i++)
					{
						if (data[i] is int)
							types[i] = PlayerIOMessageType.INT;
						else if (data[i] is uint)
							types[i] = PlayerIOMessageType.UINT;
						else if (data[i] is String)
							types[i] = PlayerIOMessageType.STRING;
						else if (data[i] is ByteArray)
						{
							types[i] = PlayerIOMessageType.BYTEARRAY;
							
							// We also need to fix the data itself here
							var arr:ByteArray = data[i];
							var temp:Array = new Array(arr.length);
							for (var j:uint = 0; j < arr.length; j++)
							{
								temp[j] = arr[j];
							}
							
							// Set
							data[i] = temp;
						}
						else if (data[i] is Boolean)
							types[i] = PlayerIOMessageType.BOOL;
						else
							types[i] = PlayerIOMessageType.NUMBER;
					}
				}
				
				// Return to JS world
				ExternalInterface.call("PlayerIO._execCallbacks", callbackId, 1, [ type, types, data ], true);
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
			
			// GameFS class
			ExternalInterface.addCallback("getURL", getURL);
			
			// ErrorLog class
			ExternalInterface.addCallback("writeError", writeError);
			
			// Multiplayer class
			ExternalInterface.addCallback("getDevelopmentServer", getDevelopmentServer);
			ExternalInterface.addCallback("setDevelopmentServer", setDevelopmentServer);
			ExternalInterface.addCallback("createRoom", createRoom);
			ExternalInterface.addCallback("createJoinRoom", createJoinRoom);
			ExternalInterface.addCallback("joinRoom", joinRoom);
			ExternalInterface.addCallback("listRooms", listRooms);
			
			// Connection class
			ExternalInterface.addCallback("getIsConnected", getIsConnected);
			ExternalInterface.addCallback("disconnect", disconnect);
			ExternalInterface.addCallback("sendMessage", sendMessage);
			ExternalInterface.addCallback("initConnection", initConnection);
		}
	}
}