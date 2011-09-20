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
		private var blockDic:Object;
		private var circleMouse:Shape;
		private var courseRadius:int;
		
		public var resultData:Array;
		
		private var model:ModelLocator = ModelLocator.getInstance();
		public function TileMapManager() 
		{
			init();
		}
		private function init():void{
			blockDic = new Object;
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			//this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
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
			initData();
		}
		private function initData():void{
			resultData = new Array;
			var w:int = mapWidth/64 + 1;
			var h:int = mapHeight/32 + 1;
			for(var i:int=0;i<w;i++){
				resultData[i] = new Array;
				for(var j:int=0;j<h;j++){
					resultData[i][j] = 0;
				}
			}
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
			setCourse();
		}
		private function onMouseUp(event:MouseEvent):void{
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			removeCourse();
		}
		private function onMouseMove(event:MouseEvent):void{
			drawCircleTail(this.mouseX,this.mouseY);
			circleMouse.x = this.mouseX;
			circleMouse.y = this.mouseY;
		}
		private function setCourse():void{
			circleMouse = new Shape;
			this.addChild(circleMouse);
			courseRadius = 70;
			//circleMouse.graphics.lineStyle(0x0000ff,1);
			circleMouse.graphics.beginFill(0x0000ff,0.5);
			circleMouse.graphics.drawCircle(0,0,courseRadius);
			circleMouse.graphics.endFill();
		}
		private function removeCourse():void{
			this.removeChild(circleMouse);
		}
		private function drawCircleTail(px:int,py:int):void{
			var p:Point = Util.getTilePoint(px,py);
			var pxp:Point = Util.getPixelPoint(p.x,p.y);
			
			for(var i:int=p.x-3;i<p.x+3;i++){
				for(var j:int=p.y-3;j<p.y+3;j++){
					var dp:Point = Util.getPixelPoint(i,j);
					var dis:Number = Point.distance(dp,pxp);
					if(dis < courseRadius){
						drawTail(i,j);
					}
				}
			}
		}
		private function drawTail(tx:int,ty:int):void{
			if(resultData[tx][ty] == 1){
				return;
			}
			resultData[tx][ty] = 1;
			
			var p:Point = Util.getPixelPoint(tx,ty);
			
			blockS.graphics.moveTo(p.x,p.y-16);
			blockS.graphics.lineTo(p.x+32,p.y);
			blockS.graphics.lineTo(p.x,p.y+16)
			blockS.graphics.lineTo(p.x-32,p.y);
			
		}
		
		
	}
}