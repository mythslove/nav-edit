package view.map
{
	import __AS3__.vec.Vector;
	
	import com.background.BackgroundLayer;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import models.ModelLocator;
	
	import mx.core.UIComponent;
	import mx.graphics.codec.JPEGEncoder;
	
	import org.blch.findPath.Cell;
	import org.blch.findPath.LineCrossBlock;
	import org.blch.findPath.NavMesh;
	import org.blch.geom.Delaunay;
	import org.blch.geom.Line2D;
	import org.blch.geom.PointClassification;
	import org.blch.geom.Polygon;
	import org.blch.geom.Triangle;
	import org.blch.geom.Vector2f;
	
	import spark.components.mediaClasses.VolumeBar;
	
	import util.Util;
	
	import view.TenCourse;
	
	public class TileMapManager extends UIComponent
	{
		private var bg:BackgroundLayer;
		private var basicurl:String;
		private var mapWidth:int = 3000;
		private var mapHeight:int = 1800;
		private var picW:int = 300;
		private var picH:int = 300;
		private var shape:Shape;
		private var lineShpae:Shape;
		private var lineS:Shape;
		private var blockS:Shape;
		private var pathShape:Sprite;
		private var container:Sprite;
		private var blockContainer:Sprite;
		private var course:TenCourse;
		private var murl:String = "CJ305";
		private var lineCrossBlock:LineCrossBlock;
		
		private var model:ModelLocator = ModelLocator.getInstance();
		public function TileMapManager() 
		{
			init();
		}
		private function init():void{
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		public function setMapInfo(baseUrl:String,fileName:String):void{
			this.basicurl = baseUrl;
			this.murl = fileName;
			loadmapdata();
		}
		public function createBg(spW:int=300,spH:int=300):void
		{
			bg = new BackgroundLayer();
			
			var picw:Number = Math.ceil(Number(mapWidth/spW));
			var pich:Number = Math.ceil(Number(mapHeight/spH));
			
			//var url:String = basicurl;
			
			bg.createBackground(picw,pich,spW,spH,basicurl+"/images");
			this.addChild(bg); 
			
			this.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,onStartDrag);
			this.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,onStopDrag);
			
			shape = new Shape;
			this.addChild(shape);
			
			lineShpae = new Shape;
			this.addChild(lineShpae);
			
			lineS = new Shape;
			this.addChild(lineS);
			lineS.graphics.lineStyle(3,0xffff00,1);
			
			blockS = new Shape;
			this.addChild(blockS);
			blockS.graphics.beginFill(0x00ff00,0.5)
			
			pathShape = new Sprite;
			this.addChild(pathShape);
			
			container = new Sprite;
			this.addChild(container);
			
			blockContainer = new Sprite;
			this.addChild(blockContainer);
			
		}
		private function onStartDrag(event:MouseEvent):void{
			this.startDrag();
		}
		private function onStopDrag(event:MouseEvent):void{
			this.stopDrag();
		}
		
		public function buildTriangle():void {
			
		}
		
		private function loadmapdata():void{
			var file:File = new File(basicurl + "/" + murl + ".mapedit");
			if(file.exists){
				var urlloader:URLLoader = new URLLoader;
				urlloader.addEventListener(Event.COMPLETE,dataOnComplete);
				urlloader.load(new URLRequest(file.url));
			}
		}
		private function dataOnComplete(event:Event):void{
			var xml:XML = XML(event.target.data);
			this.mapHeight = int(xml.@mapheight);
			this.mapWidth = int(xml.@mapwidth);
			this.picW = int(xml.@picw);
			this.picH = int(xml.@pich);
			createBg(picW,picH);
			drawBg();
		}
		private function drawBg():void{
			shape.graphics.lineStyle(1,0xff0000,0.5);
			var l:int = mapWidth*2/64;
			for(var i:int=0;i<l;i++){
				drawLeftLine(64*i-32);
			}
			l = mapWidth/64;
			for(i=-l;i<l;i++){
				drawRightLine(64*i-32);
			}
			
		}
		private function drawLeftLine(x:int):void{
			var bx:int = x;
			var by:int;
			var ex:int = x-mapHeight*2;
			var ey:int = mapHeight;
			
			if(bx > mapWidth){
				by = (bx - mapWidth)/2
				bx = mapWidth;
			}
			
			if(ex<0){
				ey = mapHeight+ex/2;
				ex = 0;
			}
						
			shape.graphics.moveTo(bx,by);
			shape.graphics.lineTo(ex,ey);
		}
		private function drawRightLine(x:int):void{
			var bx:int = x;
			var by:int;
			var ex:int = x+mapHeight*2;
			var ey:int = mapHeight;
			
			if(bx < 0){
				by = -bx/2;
				bx = 0;
			}
			
			if(ex > mapWidth){
				ey = mapHeight - (ex - mapWidth)/2;
				ex = mapWidth;
			}
			shape.graphics.moveTo(bx,by);
			shape.graphics.lineTo(ex,ey);
		}
		
		private function onClick(event:MouseEvent):void{
			
		}
		private function onMouseDown(event:MouseEvent):void{
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		private function onMouseUp(event:MouseEvent):void{
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		private function onMouseMove(event:MouseEvent):void{
			drawTail(this.mouseX,this.mouseY)
		}
		private function drawTail(px:int,py:int):void{

			var p:Point = Util.getTilePoint(px,py);
			p = Util.getPixelPoint(p.x,p.y);
			
			blockS.graphics.moveTo(p.x,p.y-16);
			blockS.graphics.lineTo(p.x+32,p.y);
			blockS.graphics.lineTo(p.x,p.y+16)
			blockS.graphics.lineTo(p.x-32,p.y);
			
		}
		
		
	}
}