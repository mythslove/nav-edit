package org.blch.util
{
	import org.blch.geom.Circle;
	import org.blch.geom.Line2D;
	import org.blch.geom.Vector2f;

	public class GeomUtils
	{
		public function GeomUtils()
		{
		}
		public static function getCircleFormPoint(a:Vector2f,b:Vector2f,c:Vector2f):Circle{
			var A:Number = Math.sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y)) 
			var B:Number = Math.sqrt((a.x-c.x)*(a.x-c.x)+(a.y-c.y)*(a.y-c.y))
			var C:Number = Math.sqrt((b.x-c.x)*(b.x-c.x)+(b.y-c.y)*(b.y-c.y))
			var y:Number = (A+B+C)/2
			var x:Number = Math.sqrt(y*(y-A)*(y-B)*(y-C))
			var r:Number =A*B*C/(4*x)
			var circle:Circle = new Circle();
			
			var x0:Number = ((b.y-a.y)*(c.y*c.y-a.y*a.y+c.x*c.x-a.x*a.x)-(c.y-a.y)*(b.y*b.y-a.y*a.y+b.x*b.x-a.x*a.x))/(2*(c.x-a.x)*(b.y-a.y)-2*((b.x-a.x)*(c.y-a.y))); 
			var y0:Number = ((b.x-a.x)*(c.x*c.x-a.x*a.x+c.y*c.y-a.y*a.y)-(c.x-a.x)*(b.x*b.x-a.x*a.x+b.y*b.y-a.y*a.y))/(2*(c.y-a.y)*(b.x-a.x)-2*((b.y-a.y)*(c.x-a.x)));
			
			circle.center = new Vector2f(x0,y0);
			
			circle.radius = r;
			return circle;
		}
		
		public static function getCricleFromTwo(a:Vector2f,b:Vector2f):Circle{
			var circle:Circle = new Circle();
			var x0:Number = (a.x + b.x)/2;
			var y0:Number = (a.y + b.y)/2;
				
			circle.center = new Vector2f(x0,y0);
			circle.radius = getDistance(a,b)/2;
			return circle;
		}
		
		public static function getCricleIntersection(line:Line2D,circle:Circle,point1:Vector2f,point2:Vector2f):void{
			var p1:Vector2f = line.pointA;
			var p2:Vector2f = line.pointB;
			
			var k:Number = (p2.y-p1.y)/(p2.x-p1.x);
			var b:Number = p1.y - k*p1.x;
			var c:Number = b - circle.center.y
			
			var A:Number = k*k + 1;
			var B:Number = 2*k*c- 2*circle.center.x;
			var C:Number = c*c + circle.center.x*circle.center.x-circle.radius*circle.radius;
			
			var x1:Number = (-B+Math.sqrt(B*B-4*A*C))/2/A;
			var y1:Number = k*x1+b;
			
			var x2:Number = (-B-Math.sqrt(B*B-4*A*C))/2/A;
			var y2:Number = k*x2+b;
			
			if(line.pointA.x > line.pointB.x){
				point1.x = x2;
				point1.y = y2;
				
				point2.x = x1;
				point2.y = y1;
			}else{
				point1.x = x1;
				point1.y = y1;
				
				point2.x = x2;
				point2.y = y2;
			}
		}
		
		public static function getDistance(a:Vector2f,b:Vector2f):Number{
			var detlX:Number = a.x - b.x;
			var detlY:Number = a.y - b.y;
			var dis:Number = Math.sqrt(detlX*detlX + detlY*detlY);
			return dis;
		}
		
	}
}