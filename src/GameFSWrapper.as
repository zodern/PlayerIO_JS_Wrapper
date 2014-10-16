package  
{
	import flash.external.ExternalInterface;
	
	import playerio.GameFS;
	
	public class GameFSWrapper 
	{
		private static var main:Main;
		
		private static function getURL(id:uint, path:String):String
		{
			// Get object
			var obj:GameFS = main.objectStorage[id];
			
			// Process
			return obj.getURL(path);
		}
		
		public static function init(mainReference:Main):void
		{
			main = mainReference;
			
			ExternalInterface.addCallback("getURL", getURL);
		}
	}
}