package org.blch.geom
{
	public class LineArray
	{
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		
		public var line:Line2D;
		public var v:Array;
		public var dircet:String;
		public function LineArray(line:Line2D,v:Array,dircet:String)
		{
			this.line = line;
			this.v = v;
			this.dircet = dircet;
		}
	}
}