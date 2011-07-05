package com.view
{
	import com.map.MapManager;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.UIComponent;

	public class ResView extends UIComponent
	{
		private var w:int = 50;
		private var h:int = 50;
		public var resData:Array;
		public var currentTarget:ResElement;
		
		public function ResView()
		{
			resData 	= [];
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,click);
		}
		/**
		 * 点击操作 
		 * @param e
		 * 
		 */		
		private function click(e:MouseEvent):void
		{
			if(e.target is ResElement)
			{
				if(currentTarget)
					currentTarget.filters = null;
				currentTarget = ResElement(e.target);
				currentTarget.filters = [new GlowFilter(0x223344,1.0,7.0)];
				
				if(Application.application.mapUI!=null)
					Application.application.mapUI.selectEffect = currentTarget;
			}
			else
			{
				if(currentTarget)
				{
					currentTarget.filters = null;
					currentTarget = null;
				}
				if(Application.application.mapUI!=null)
					Application.application.mapUI.selectEffect = null;
			}
		}
		/**
		 * 增加资源 
		 * @param obj{ name , graphicObj}
		 * 
		 */		
		public function addRes(graphicObj:Class,name:String):void
		{
			if(graphicObj ==null) return ;
			
			 var i:int = resData.length;
             var element:ResElement = new ResElement(graphicObj,name);
			 element.x  = (i%5)*w;
			 element.y  = int(i/5)*h;
			 this.addChild(element);
			 
			 resData[i]=element;


			
		}
		
		public function delRes():void
		{
			
		}
		public function refrushView():void
		{
			var l:int = resData.length;
			for(var i:int =0;i<l;i++)
			{
				var img:DisplayObject = DisplayObject(resData[i].graphic);
				var bg:Shape =  Shape(resData[i].bg);
				bg.x = img.x = int(i%5)*w;
				bg.y = img.y = int(i/5)*h;
				
				this.addChild(bg);
				this.addChild(img);
			}
		}
	}
}