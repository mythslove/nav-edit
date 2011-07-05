package com.view
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class ResElement extends Sprite
	{
		public var targetClass:Class;
		public var targetName:String;
		public function ResElement(c:Class,name:String)
		{
			targetClass = c;
			targetName = name;
			
			var img:DisplayObject = new c;
			img.width  = 50;
			img.height = 50;
			
			var shape:Shape = drawBg(50,50);
			var text:TextField = new TextField;
			text.text = name;
			text.mouseEnabled = false;
			

			img.x =   img.width*.5;
			img.y =   img.height*.5;
			
			this.addChild(shape);
			this.addChild(img);
			this.addChild(text);
			
			this.mouseChildren = false;
		}
		/**
		 *  画地面背景 
		 * 
		 */		
		private function drawBg(w:int,h:int):Shape
		{
			var shape:Shape = new Shape;
			
			with(shape.graphics)
			{
				lineStyle(1,0x000000);
				lineTo(w,0);
				lineTo(w,h);
				lineTo(0,h);
				lineTo(0,0);
				endFill();
			}
			return shape;
		}
	}
}