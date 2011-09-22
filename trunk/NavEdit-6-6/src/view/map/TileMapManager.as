package view.map
{
	import __AS3__.vec.Vector;
	
	import com.background.BackgroundLayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
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
	import flash.geom.Rectangle;
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
		private var blockBitmap:Bitmap;
		private var blockBitmapdata:BitmapData;
		private var pathShape:Sprite;
		private var container:Sprite;
		private var blockContainer:Sprite;
		private var course:TenCourse;
		private var murl:String = "CJ305";
		private var blockDic:Object;
		private var circleMouse:Shape;
		private var courseRadius:int;
		
		private var greenBitmapdata:BitmapData;
		private var buleBitmapdata:BitmapData;
		private var alphaBitmapdata:BitmapData;
		private var alphaReversBitmapdata:BitmapData
		
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
			
			greenBitmapdata = new BitmapData(64,32,true,0x7f00ff00);
			buleBitmapdata = new BitmapData(64,32,true,0x7f0000ff);
			alphaBitmapdata = new BitmapData(64,32,true,0);
			alphaReversBitmapdata = new BitmapData(64,32,true,0);
			
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0xff0000);
			shape.graphics.moveTo(32,0);
			shape.graphics.lineTo(64,16);
			shape.graphics.lineTo(32,32);
			shape.graphics.lineTo(0,16);
			shape.graphics.lineTo(32,0);
			shape.graphics.endFill();
			alphaReversBitmapdata.draw(shape);
			
			shape.graphics.clear();
			
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawRect(0,0,64,32);
			shape.graphics.moveTo(32,0);
			shape.graphics.lineTo(64,16);
			shape.graphics.lineTo(32,32);
			shape.graphics.lineTo(0,16);
			shape.graphics.lineTo(32,0);
			shape.graphics.endFill();
			alphaBitmapdata.draw(shape);
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
			
			blockBitmapdata = new BitmapData(mapWidth,mapHeight,true,0);
			blockBitmap = new Bitmap(blockBitmapdata);
			this.addChild(blockBitmap);
			
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
			if(tx < 0 || ty < 0 ){
				return;
			}
			if(model.tailStep == -1){
				return;
			}
			var p:Point = Util.getPixelPoint(tx,ty);
			p.x -= 32;
			p.y -= 16;
			
			if(model.tailStep == 1){
				if(resultData[tx][ty] == 1){
					return;
				}
				resultData[tx][ty] = 1;
				addGreenTail(p);
			}else if(model.tailStep == 2){
				if(resultData[tx][ty] == 2){
					return;
				}
				resultData[tx][ty] = 2;
				addBlueTail(p);
			}else if(model.tailStep == 3){
				if(resultData[tx][ty] == 0){
					return;
				}
				resultData[tx][ty] = 0;
				removeTail(p);
			}
			
		}
		private function addGreenTail(p:Point):void{
			var rec:Rectangle = new Rectangle(0,0,64,32);
			blockBitmapdata.copyPixels(greenBitmapdata,rec,p,alphaReversBitmapdata,new Point,true);
		}
		private function addBlueTail(p:Point):void{
			var rec:Rectangle = new Rectangle(0,0,64,32);
			blockBitmapdata.copyPixels(buleBitmapdata,rec,p,alphaReversBitmapdata,new Point,true);
		}
		private function removeTail(p:Point):void{
			var rec:Rectangle = new Rectangle(0,0,64,32);
			blockBitmapdata.copyChannel(alphaBitmapdata,rec,p,BitmapDataChannel.ALPHA,BitmapDataChannel.ALPHA);
			blockBitmapdata.threshold(blockBitmapdata,rec,new Point,"<=",0xff000000,0);
		}
		
		private function save():void{
			var file:File;
			var fs:FileStream = new FileStream();
			var str:String;
			
			file = new File(basicurl + "/" + murl + ".tailEdit")// File.documentsDirectory.resolvePath("navMap/" + murl + ".mapedit");
			fs.open(file,FileMode.WRITE);
			
			var la:int = resultData[0].length;
			
			for(var i:int;i<resultData.length;i++){
				for(var j:int=0;j<la;j++){
					str+=resultData[i][j];
				}
			}
			
			model.mapname = murl;
			model.mapWidth = mapWidth;
			model.mapHeight = mapHeight;
			model.picw = picW;
			model.picH = picH;
			str = "<map name='" + model.mapname + "' mapwidth='" + 
				model.mapWidth + "' mapheight='" + model.mapHeight + "' picw='" + 
				model.picw + "' pich='" + model.picH + "' mapdata='" + str + "'/>"
			
			fs.writeUTFBytes(str);
			fs.close();
		}
		
		
	}
}