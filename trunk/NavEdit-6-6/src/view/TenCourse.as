package view
{
	import flash.display.Shape;
	
	public class TenCourse extends Shape
	{
		public function TenCourse()
		{
			var l:int = 1000;
			this.graphics.lineStyle(1,0x000000);
			this.graphics.moveTo(-l,-l/2);
			this.graphics.lineTo(l,l/2);
			this.graphics.moveTo(l,-l/2);
			this.graphics.lineTo(-l,l/2);
		}
	}
}