package org.blch.geom
{
	public class Circle
	{
		public var center:Vector2f;
		public var radius:Number;
		public function Circle(cx:Number=0,cy:Number=0,r:Number=0)
		{
			center = new Vector2f(cx,cy);
			radius = r;
		}
		public function isInCircle(testV:Vector2f):Boolean{
			var detlX:Number = testV.x - center.x;
			var detlY:Number = testV.y - center.y;
			var dis:Number = Math.sqrt(detlX*detlX + detlY*detlY);
			return dis<radius;
		}
		public function isCross(line:Line2D):Boolean{
			var dis:Number = Math.abs(line.signedDistance(center));
			return dis < radius;
		}
	}
}