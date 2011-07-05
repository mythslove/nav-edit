package com.res
{
	import flash.events.Event;
	
	public class QueueEvent extends Event
	{
		public static const LOAD_SUCCESS_EVENT:String = "LOAD_SUCCESS_EVENT";
		public var completeObject:Object;
		public function QueueEvent(type:String)
		{
			super(type);
		}

	}
}