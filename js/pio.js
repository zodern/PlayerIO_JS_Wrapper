"use strict";

// ================================= //
// ====== Message types of PIO ===== //
// ================================= //
var PlayerIOMessageType =
{
	STRING:		0,
	INT:		1,
	UINT:		2,
	BOOL:		3,
	NUMBER:		4,
	BYTEARRAY:	5
};

var PlayerIOMessageTypeName =
{
	0: "String",
	1: "Int",
	2: "Uint",
	3: "Boolean",
	4: "Number",
	5: "ByteArray"
};

// ================================= //
// ==== PartnerPay system of PIO === //
// ================================= //
var PartnerPay = function(partnerPayId)
{
	// Internal
	this._id = partnerPayId;

	// Public
	var self = this;
	Object.defineProperty(this, "currentPartner",
	{
		get: function()
		{
			return PlayerIO._element.getCurrentPartner(self._id);
		}
	});
};

PartnerPay.prototype.setTag = function(partnerId, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.setTag(args[0], args[1], args[2]);
	},
	function(data)
	{
		callback();
	}, errorhandler, this._id, [ partnerId ]);
};

PartnerPay.prototype.trigger = function(key, count, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.trigger(args[0], args[1], args[2], args[3]);
	},
	function(data)
	{
		callback();
	}, errorhandler, this._id, [ key, count ]);
};

// ================================= //
// ===== RoomInfo system of PIO ==== //
// ================================= //
var RoomInfo = function()
{
	// Public
	this.id = "";
	this.serverType = "";
	this.roomType = "";
	this.onlineUsers = 0;
	this.data = {};

	// I suppose that this.initData == this.data
	// (verify this?)
	var self = this;
	Object.defineProperty(this, "initData",
	{
		get: function()
		{
			return self.data;
		}
	});
};

RoomInfo.prototype.toString = function()
{
	var returnString = "";
	returnString += "[playerio.RoomInfo]\n";
	returnString += "id:\t\t\t\t" + this.id + "\n";
	returnString += "roomType:\t\t" + this.roomType + "\n";
	returnString += "onlineUsers:\t" + this.onlineUsers + "\n";
	returnString += "initData\t\tId\t\t\t\t\t\tValue\n";

	for(var key in this.initData)
	{
		var data = this.initData[key];

		// Since a tab in the console = 8 chars, that means we need to divide the length by eight
		// Division by eight is a bitshift to right by three because 2³ = 8
		// It can be no more than six because that's the "distance" between "Id" and "Value"
		var padding = "";
		for(var i = 0; i < key.length >> 3 && i < 6; i++)
			padding += "\t";

		// Append
		returnString += "\t\t\t\t" + key + padding + data + "\n";
	}

	return returnString;
};

// ================================= //
// ====== Error system of PIO ====== //
// ================================= //
var PlayerIOError = function(message, id)
{
	// Public
	this.name = "Error";
	this.message = message;
	this.errorID = id;
};

PlayerIOError.prototype.toString = function()
{
	return this.message;
};

// ================================= //
// ===== Message system of PIO ===== //
// ================================= //
var Message = function(name) {
	// Internal
	this._types = [];
	this._data = [];

	// Public
	this.type = name;
	this.length = 0;
};

// Internal function to add data to the message
Message.prototype._add = function(type, value)
{
	this._types.push(type);
	this._data.push(value);
	this.length++;
};

Message.prototype.addBoolean = function(value)
{
	// If the value is not a bool, we convert is using a double !
	// because !object = false and !true = false, we will get the bool value using !!value
	this._add(PlayerIOMessageType.BOOL, value);
};

Message.prototype.addString = function(value)
{
	// Convert to string if not a string yet
	this._add(PlayerIOMessageType.STRING, "" + value);
};

Message.prototype.addNumber = function(value)
{
	this._add(PlayerIOMessageType.NUMBER, value);
};

Message.prototype.addInt = function(value)
{
	this._add(PlayerIOMessageType.INT, value);
};

Message.prototype.addUInt = function(value)
{
	this._add(PlayerIOMessageType.UINT, value);
};

Message.prototype.addByteArray = function(value)
{
	this._add(PlayerIOMessageType.BYTEARRAY, value);
};

// Internal function for getting data with checks
Message.prototype._get = function(index, expectedType)
{
	// First check if the index is within bounds
	if(index < 0 || index >= this._data.length)
		return;

	// Now check if the value at the given index is the expected type
	var type = this._types[index];
	if(type != expectedType)
	{
		console.error("The value at the index " + index + " is not a " + PlayerIOMessageTypeName[expectedType]);
		return;
	}

	// Everything okay
	return this._data[index];
};

Message.prototype.getBoolean = function(index)
{
	return this._get(index, PlayerIOMessageType.BOOL);
};

Message.prototype.getString = function(index)
{
	return this._get(index, PlayerIOMessageType.STRING);
};

Message.prototype.getNumber = function(index)
{
	return this._get(index, PlayerIOMessageType.NUMBER);
};

Message.prototype.getInt = function(index)
{
	return this._get(index, PlayerIOMessageType.INT);
};

Message.prototype.getUInt = function(index)
{
	return this._get(index, PlayerIOMessageType.UINT);
};

Message.prototype.getByteArray = function(index)
{
	return this._get(index, PlayerIOMessageType.ByteArray);
};

Message.prototype.add = function()
{
	for(var i = 0, l = arguments.length; i < l; i++)
	{
		var arg = arguments[i];
		switch(typeof(arg))
		{
			case "string":
				this.addString(arg);
				break;

			case "number":
				// If the remainder of division by one is not zero, it means it's a floating point value
				if(arg % 1 != 0)
				{
					this.addNumber(arg);
				}
				else
				{
					// UINT of INT ?
					if(arg >= 0 && arg <= 4294967295)
					{
						// It's a UINT because it's in the range of a UINT
						this.addUInt(arg);
					}
					else
					{
						// If it's not a UINT or floating point number, then it means it's an INT
						this.addInt(arg);
					}
				}

				break;

			case "object":
				if(arg.length != undefined)
				{
					this.addByteArray(arg);
					break;
				}

				// If we get here, it means it's not a ByteArray
				// now it will just go to the "default" label

			default:
				console.error("Unknown type: " + typeof(arg));
				return;
		}
	}
};

// ================================= //
// === Connection system of PIO ==== //
// ================================= //
var Connection = function(connectionId)
{
	// Internal
	this._id = connectionId;
	this._messageHandlers = [];
	this._disconnectHandlers = [];

	// Public
	var self = this;
	Object.defineProperty(this, "connected",
	{
		get: function()
		{
			return PlayerIO._element.getIsConnected(self._id);
		}
	});

	// Init
	this._init();
};

// Internal initialize function
Connection.prototype._init = function()
{
	// Find id and increase
	var id = PlayerIO._lastCallbackId++;

	// Reference to connection
	var self = this;

	// Handler for disconnection
	var disconnectHandler = function()
	{
		for(var i = 0, l = self._disconnectHandlers.length; i < l; i++)
		{
			self._disconnectHandlers[i]();
		}
	};

	// Handler for messages
	var messageHandler = function(data)
	{
		// Get needed data
		var type = data[0];
		var types = (data[1]) ? data[1] : [];
		var data = (data[2]) ? data[2] : [];

		// Construct clientside message here
		var msg = new Message(type);
		msg._types = types;
		msg._data = data;
		msg.length = data.length;

		// Pass the message to the handlers
		for(var i = 0, l = self._messageHandlers.length; i < l; i++)
		{
			// Get pair
			var pair = self._messageHandlers[i];

			// Match?
			if(pair[0] == type || pair[0] == "*")
			{
				pair[1](msg);
			}
		}
	};

	// Push those callbacks
	PlayerIO._callbacks[id] = [ disconnectHandler, messageHandler ];

	// Register handlers
	PlayerIO._element.initConnection(this._id, id);
};

Connection.prototype.disconnect = function()
{
	PlayerIO._element.disconnect(this._id);
};

Connection.prototype.createMessage = function(type)
{
	// Create arguments
	var l = arguments.length;
	var args = new Array(l - 1);
	for(var i = 1; i < l; i++)
		args[i - 1] = arguments[i];

	// Create the message
	var msg = new Message(type);

	// Add the data to the message
	msg.add.apply(msg, args);

	// Done
	return msg;
};

Connection.prototype.sendMessage = function(message)
{
	// Quick check
	if(!message)
		return;

	// Get the data and type arrays and also the type
	var type = message.type;
	var data = message._data;

	// Call PIO
	PlayerIO._element.sendMessage(this._id, type, data);
};

Connection.prototype.send = function(type)
{
	// Create the message
	var msg = this.createMessage.apply(this, arguments);

	// And send it of course!
	this.sendMessage(msg);
};

Connection.prototype.addDisconnectHandler = function(handler)
{
	// Add!
	this._disconnectHandlers.push(handler);
};

Connection.prototype.removeDisconnectHandler = function(handler)
{
	// Get the index
	var index = this._disconnectHandlers.indexOf(handler);

	// Not found?
	if(index == -1)
		return;

	// Remove!
	this._disconnectHandlers.splice(index, 1);
};

Connection.prototype.addMessageHandler = function(type, handler)
{
	// Construct pair
	var pair = [ type, handler ];

	// Add!
	this._messageHandlers.push(pair);
};

Connection.prototype.removeMessageHandler = function(type, handler)
{
	// First, search for the type
	var i = 0;
	var found = false;
	for(var l = this._messageHandlers.length; i < l; i++)
	{
		// Get pair
		var pair = this._messageHandlers[i];

		// Match?
		if(pair[0] == type)
		{
			// Is it the same handler?
			if(pair[1] == handler)
			{
				found = true;
				break;
			}
		}
	}

	// Found?
	if(!found)
		return;

	// Remove!
	this._messageHandlers.splice(i, 1);
};

// ================================= //
// === Multiplayer system of PIO === //
// ================================= //
var Multiplayer = function(multiplayerId)
{
	// Internal
	this._id = multiplayerId;

	// Public
	var self = this;
	Object.defineProperty(this, "developmentServer",
	{
		get: function()
		{
			return PlayerIO._element.getDevelopmentServer(self._id);
		},

		set: function(value)
		{
			PlayerIO._element.setDevelopmentServer(self._id, value);
		}
	});
};

Multiplayer.prototype.createRoom = function(roomId, roomType, visible, roomData, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.createRoom(args[0], args[1], args[2], args[3], args[4], args[5]);
	},
	function(connectionId)
	{
		// Create new connection
		var connection = new Connection(connectionId);

		// Pass the connection to the callback
		callback(connection);
	}, errorhandler, this._id, [ roomId, roomType, visible, roomData ]);
};

Multiplayer.prototype.createJoinRoom = function(roomId, roomType, visible, roomData, joinData, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.createJoinRoom(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
	},
	function(connectionId)
	{
		// Create new connection
		var connection = new Connection(connectionId);

		// Pass the connection to the callback
		callback(connection);
	}, errorhandler, this._id, [ roomId, roomType, visible, roomData, joinData ]);
};

Multiplayer.prototype.joinRoom = function(roomId, joinData, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.joinRoom(args[0], args[1], args[2], args[3]);
	},
	function(connectionId)
	{
		// Create new connection
		var connection = new Connection(connectionId);

		// Pass the connection to the callback
		callback(connection);
	}, errorhandler, this._id, [ roomId, joinData ]);
};

Multiplayer.prototype.listRooms = function(roomType, searchCriteria, resultLimit, resultOffset, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.listRooms(args[0], args[1], args[2], args[3], args[4], args[5]);
	},
	function(data)
	{
		// Prepare an array for us
		var callbackData = new Array(data.length);

		// Flash gives us an array of arrays of data per room
		for(var i = 0, l = data.length; i < l; i++)
		{
			// Get the info
			var roomInformation = data[i];

			// roomInformation[0] = .data
			// 	              [1] = .id
			//	              [2] = .onlineUsers
			//	              [3] = .roomType
			//	              [4] = .serverType

			// Reconstruct the data using the RoomInfo class
			var info = new RoomInfo();
			info.data = roomInformation[0];
			info.id = roomInformation[1];
			info.onlineUsers = roomInformation[2];
			info.roomType = roomInformation[3];
			info.serverType = roomInformation[4];

			// Add it to the array
			callbackData.push(info);
		}

		// And callback!
		callback(callbackData);
	}, errorhandler, this._id, [ roomType, searchCriteria, resultLimit, resultOffset ]);
};

// ================================= //
// ===== gameFS system of PIO ====== //
// ================================= //
var GameFS = function(gameFSId)
{
	// Internal
	this._id = gameFSId;
};

GameFS.prototype.getURL = function(path)
{
	return PlayerIO._element.getURL(this._id, path);
};

// ================================= //
// ==== ErrorLog system of PIO ===== //
// ================================= //
var ErrorLog = function(errorLogId)
{
	// Internal
	this._id = errorLogId;
};

ErrorLog.prototype.writeError = function(error, details, stacktrace, extraData, callback, errorhandler)
{
	PlayerIO._sendWithCallback(function(args)
	{
		PlayerIO._element.writeError(args[0], args[1], args[2], args[3], args[4], args[5]);
	},
	function(data)
	{
		callback();
	}, errorhandler, this._id, [ error, details, stacktrace, extraData ]);
};

// ================================= //
// ===== Client system of PIO ====== //
// ================================= //

var Client = function(clientId, connectUserId, bigDB_id, errorLog_id, gameFS_id, multiplayer_id, payVault_id, partnerPay_id)
{
	// Internal
	this._id = clientId;
	this._bigDB_id = bigDB_id;
	this._errorLog_id = errorLog_id;
	this._gameFS_id = gameFS_id;
	this._multiplayer_id = multiplayer_id;
	this._payVault_id = payVault_id;
	this._partnerPay_id = partnerPay_id;

	// Public
	this.connectUserId = connectUserId;
	this.bigDB = null;
	this.errorLog = null;
	this.gameFS = null;
	this.multiplayer = null;
	this.payVault = null;
	this.partnerPay = null;

	// Init
	this._init();
};

// Internal initialize function
Client.prototype._init = function()
{
	this.gameFS = new GameFS(this._gameFS_id);
	this.errorLog = new ErrorLog(this._errorLog_id);
	this.multiplayer = new Multiplayer(this._multiplayer_id);
	this.partnerPay = new PartnerPay(this._partnerPay_id);
};

// ================================= //
// ======== PIO Class itself ======= //
// ================================= //
var PlayerIO =
{
	_element: null,
	_callbacks: {}, // We use an object so we can remove an element without changing its id
	_lastCallbackId: 0,

	// This function basically executes the callback based on a unique id
	_execCallbacks: function(id, subid, data, keep)
	{
		// We have a pair (array) of possible callbacks (eg. successCallback and errorCallback)
		// The callback type is indicated in subid
		var pair = this._callbacks[id];

		// Call and pass data!
		pair[subid](data);

		// But hey, we can clean it up now (if requested)!
		if(!keep)
			delete pair[subid];
	},

	// This function is for sending data to the wrapper with a callback
	_sendWithCallback: function(call, success, errorhandler, oid, args)
	{
		// Check
		if(!this._element) {
			console.error("You must call PlayerIO.initJS first!");
			return;
		}

		// Find id and increase
		var id = PlayerIO._lastCallbackId++;

		// Create callbacks
		var successCallback = function(data)
		{
			success(data);
		};

		var errorCallback = function(data)
		{
			// Check
			if(!errorhandler)
				return;

			// Get message and errorcode
			//var error = { "name": data[0], "message": data[1], "errorID": data[2] };
			var error = new PlayerIOError(data[1], data[2]);
			error.name = data[0];
			errorhandler(error);
		};

		// Push those callbacks
		PlayerIO._callbacks[id] = [ successCallback, errorCallback ];

		// Pass the call
		args.push(oid);
		args.push(id);

		// You can't do this apparently, so we're going to use a workaround
		//PlayerIO._element[name].apply(null, args);

		call(args);
	},

	initJS: function(element)
	{
		// Check
		if(!element.connect)
		{
			console.error("Not a valid PlayerIO wrapper element!");
			return;
		}

		// Okay
		this._element = element;
	},

	connect: function(gameId, connectionId, userId, auth, partnerId, callback, errorhandler)
	{
		PlayerIO._sendWithCallback(function(args)
		{
			PlayerIO._element.connect(args[0], args[1], args[2], args[3], args[4], args[5]);
		},
		function(data)
		{
			// Create client instance
			var client = new Client(data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]);
			// 0 = client id
			// 1 = connectUserId
			// 2 = bigDB id
			// 3 = errorLog id
			// 4 = gameFS id
			// 5 = multiplayer id
			// 6 = payVault id
			// 7 = partnerPay id

			// Callback
			callback(client);
		}, errorhandler, this._id, [ gameId, connectionId, userId, auth, partnerId ]);
	}
};
