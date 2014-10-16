package  
{
	public class DataContainer 
	{
		public var data:Array;
		
		private var size:uint;
		private var pointer:uint;
		
		public function DataContainer(size:uint)
		{
			this.size = size;
			this.pointer = 0;
			this.data = new Array(size);
		}
		
		// Used by clone
		public function Add(data:*):void
		{
			this.data[pointer] = data;
			pointer++;
		}
	}
}