package org.blch.geom
{
	import org.blch.findPath.Cell;

	public class PathPoint
	{
		public var p:Vector2f;
		public var f:int;
		public var g:int;
		public var h:int;
		public var parent:PathPoint;
		public var cell:Cell;
		public function PathPoint(p:Vector2f,g:int,h:int,cell:Cell,parent:PathPoint)
		{
			this.p = p;
			this.g = g;
			this.h = h;
			this.f = g+h;
			this.parent = parent;
			this.cell = cell;
		}
	}
}