package com.res
{
	import flash.utils.Dictionary;
	
	public class Hash
	{
		public var hash:Dictionary;
		private var _length:int;
		private var index:int;
		public function Hash()
		{
			hash = new Dictionary();
		}
		public function has(name:String):Boolean
		{
			return hash.hasOwnProperty(name);
		}
		public function put(obj:Object,name:String):void
		{
			_length++;
			hash[name] = obj;
		}
		public function take(name:String):Object
		{
			  return hash[name];
		}
		public function remove(name:String):Boolean
		{
			if(has(name))
			{
				delete hash[name];
				_length--;
				return true;
			}
			return false;
		}
		public function get length():int
		{
			return _length;
		}
		public function ChildAll():Array
		{
			var arr:Array = [];
			for each(var obj:Object in hash)
			{
				arr.push(obj);
			}
			return arr;
		}
		public function get hashMap():Dictionary
		{
			return hash;
		}
		public function destroyHash():void
		{
			
		}
		
	}
}