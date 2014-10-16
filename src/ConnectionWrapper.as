package  
{
	import flash.external.ExternalInterface;
	
	import flash.utils.ByteArray;
	
	import playerio.Message;
	import playerio.Connection;
	import playerio.PlayerIOError;
	
	public class ConnectionWrapper 
	{
		private static var main:Main;
		
		private static function getIsConnected(id:uint):Boolean
		{
			// Get object
			var obj:Connection = main.objectStorage[id];
			
			// Process
			return obj.connected;
		}
		
		private static function disconnect(id:uint):void
		{
			// Get object
			var obj:Connection = main.objectStorage[id];
			
			// Process
			obj.disconnect();
		}
		
		private static function sendMessage(id:uint, type:String, data:Array):void
		{
			// Get object
			var obj:Connection = main.objectStorage[id];
			
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
		
		private static function initConnection(id:uint, callbackId:uint):void 
		{
			// Get object
			var obj:Connection = main.objectStorage[id];
			
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
		
		public static function init(mainReference:Main):void
		{
			main = mainReference;
			
			ExternalInterface.addCallback("getIsConnected", getIsConnected);
			ExternalInterface.addCallback("disconnect", disconnect);
			ExternalInterface.addCallback("sendMessage", sendMessage);
			ExternalInterface.addCallback("initConnection", initConnection);
		}
	}
}