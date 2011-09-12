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
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import models.ModelLocator;
	
	import mx.core.UIComponent;
	import mx.graphics.codec.JPEGEncoder;
	
	import org.blch.findPath.Cell;
	import org.blch.findPath.NavMesh;
	import org.blch.geom.Delaunay;
	import org.blch.geom.Line2D;
	import org.blch.geom.PointClassification;
	import org.blch.geom.Polygon;
	import org.blch.geom.Triangle;
	import org.blch.geom.Vector2f;
	
	import spark.components.mediaClasses.VolumeBar;
	
	import view.TenCourse;
	
	public class MapManager extends UIComponent
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
		private var poly0:Polygon;
		private var course:TenCourse;
		private var polygonV:Vector.<Polygon>;
		private var blockPolygonV:Vector.<Polygon>;
		private var crossBlockPolygonV:Vector.<Polygon>;
		private var triangleV:Vector.<Triangle>; 	//生成的Delaunay三角形
		private var cellV:Vector.<Cell>;
		private var murl:String = "CJ305";
		
		private var drawPath:Vector.<Vector2f> = new Vector.<Vector2f>();
		private var model:ModelLocator = ModelLocator.getInstance();
		public function MapManager() 
		{
			/* var docs:File = File.documentsDirectory;
			basicurl = docs.nativePath; */
			init();
		}
		private function init():void{
			this.addEventListener(MouseEvent.CLICK,onClick);
			polygonV = new Vector.<Polygon>();
			blockPolygonV = new Vector.<Polygon>();
			crossBlockPolygonV = new Vector.<Polygon>;
		}
		private function initCourse():void{
			course = new TenCourse();
			this.addChild(course);
			this.parent.addEventListener(MouseEvent.MOUSE_MOVE,onstageMove);
		}
		private function onstageMove(event:MouseEvent):void{
			course.x = this.mouseX;
			course.y = this.mouseY;
		}
		private function onClick(event:MouseEvent):void{
			if(model.step == 1){
				addEdgeBug(event);
			}else if(model.step == 2){
				addBlock(event);
			}else if(model.step == 3){
				addCrossBlock(event);
			}
		}
		private function addBlock(event:MouseEvent):void{
			if(model.addState != 0){
				return;
			}
			var vt:Vector2f = new Vector2f(event.localX,event.localY);
			blockS.graphics.lineStyle(3,0x00ff00,1);
			if (drawPath.length == 0) {
				blockS.graphics.moveTo(event.localX,event.localY);
				drawPath.push(vt);
				blockS.graphics.drawCircle(event.localX,event.localY,3);
			} else {
				if (vt.distanceSquared(drawPath[0]) < 100) {
					vt = drawPath[0];
					var pl:Polygon = new Polygon(drawPath.length, drawPath);
					drawPath = new Vector.<Vector2f>();
					blockS.graphics.lineTo(event.localX,event.localY);
					pl.rw();
					blockPolygonV.push(pl);
					blockContainer.addChild(pl);
					blockS.graphics.clear();
					pl.addEventListener("removePol",removePolygon);
					pl.setDrawColor(0x00ff00,0x7d00dd,0x7d00dd);
					pl.draw(true);
				} else {
					drawPath.push(vt);
					blockS.graphics.lineTo(event.localX,event.localY);
					blockS.graphics.drawCircle(event.localX,event.localY,3);
				}
			}
		}
		
		private function addCrossBlock(event:MouseEvent):void{
			if(model.addState != 0){
				return;
			}
			var vt:Vector2f = new Vector2f(event.localX,event.localY);
			blockS.graphics.lineStyle(3,0x00ff00,1);
			if (drawPath.length == 0) {
				blockS.graphics.moveTo(event.localX,event.localY);
				drawPath.push(vt);
				blockS.graphics.drawCircle(event.localX,event.localY,3);
			} else {
				if (vt.distanceSquared(drawPath[0]) < 100) {
					vt = drawPath[0];
					var pl:Polygon = new Polygon(drawPath.length, drawPath);
					drawPath = new Vector.<Vector2f>();
					blockS.graphics.lineTo(event.localX,event.localY);
					pl.rw();
					crossBlockPolygonV.push(pl);
					blockContainer.addChild(pl);
					blockS.graphics.clear();
					pl.addEventListener("removePol",removePolygon);
					pl.setDrawColor(0x00ff00,0x17a0e7,0x7d00dd);
					pl.draw(true);
					pl.drawCircle();
				} else {
					drawPath.push(vt);
					blockS.graphics.lineTo(event.localX,event.localY);
					blockS.graphics.drawCircle(event.localX,event.localY,3);
				}
			}
		}
		private function addEdgeBug(event:MouseEvent):void{
			if(model.addState != 0){
				return;
			}
			var vt:Vector2f = new Vector2f(event.localX,event.localY);
			lineS.graphics.lineStyle(3,0xffff00,1);
			if (drawPath.length == 0) {
				lineS.graphics.moveTo(event.localX,event.localY);
				drawPath.push(vt);
				lineS.graphics.drawCircle(event.localX,event.localY,3);
			} else {
				if (vt.distanceSquared(drawPath[0]) < 100) {
					vt = drawPath[0];
					var pl:Polygon = new Polygon(drawPath.length, drawPath);
					drawPath = new Vector.<Vector2f>();
					lineS.graphics.lineTo(event.localX,event.localY);
					if(isInMain(pl)){
						pl.cw();
						polygonV.push(pl);
						container.addChild(pl);
						lineS.graphics.clear();
						pl.addEventListener("removePol",removePolygon);
						pl.draw(true);
					}else{
						pl.rw();
						var pol:Polygon = poly0.reduce(pl);
						if(pol != null){
							container.removeChild(poly0);
							poly0.removeEventListener(Event.CHANGE,edagChange);
							poly0 = pol;
							container.addChild(poly0);
							poly0.ismain = true;
							poly0.addEventListener(Event.CHANGE,edagChange);
							lineS.graphics.clear();
							drawThis();
							polygonV[0] = poly0;
						}
					}
					
				} else {
					drawPath.push(vt);
					lineS.graphics.lineTo(event.localX,event.localY);
					lineS.graphics.drawCircle(event.localX,event.localY,3);
				}
			}
		}
		private function initV0():void{
			var v0:Vector.<Vector2f> = new Vector.<Vector2f>();
			v0.push(new Vector2f(0, 0));
			v0.push(new Vector2f(mapWidth, 0));
			v0.push(new Vector2f(mapWidth, mapHeight));
			v0.push(new Vector2f(0, mapHeight));
			poly0 = new Polygon(v0.length, v0);
			poly0.ismain = true;
			poly0.addEventListener(Event.CHANGE,edagChange);
			container.addChild(poly0);
			polygonV.push(poly0);
			//poly0.draw(lineShpae.graphics);
			drawThis();
		}
		private function edagChange(event:Event):void{
			drawThis();
		}
		private function removePolygon(event:Event):void{
			var p:Polygon = event.target as Polygon;
			if(p.parent == container){
				var index:int = polygonV.indexOf(p);
				polygonV.splice(index,1);
				container.removeChild(p);
			}else if(p.parent == blockContainer){
				index = blockPolygonV.indexOf(p);
				blockPolygonV.splice(index,1);
				blockContainer.removeChild(p);
			}
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
			blockS.graphics.lineStyle(3,0x00ff00,1);
			
			pathShape = new Sprite;
			this.addChild(pathShape);
			
			container = new Sprite;
			this.addChild(container);
			
			blockContainer = new Sprite;
			this.addChild(blockContainer);
			
			//initV0();
			
			initCourse();
			
			//loadmapdata();
		}
		private function onStartDrag(event:MouseEvent):void{
			this.startDrag();
		}
		private function onStopDrag(event:MouseEvent):void{
			this.stopDrag();
		}
		private function drawThis():void{
			shape.graphics.clear();
			shape.graphics.beginFill(0xff0000,0.5);
			shape.graphics.drawRect(-100,-100,mapWidth+200,mapHeight+200);
			//shape.graphics.drawRect(0,0,mapWidth,mapHeight);
			shape.graphics.moveTo(poly0.vertexV[0].x,poly0.vertexV[0].y);
			for(var i:int=1;i<poly0.vertexNmu;i++){
				shape.graphics.lineTo(poly0.vertexV[i].x,poly0.vertexV[i].y);
			}
			shape.graphics.lineTo(poly0.vertexV[0].x,poly0.vertexV[0].y);
			shape.graphics.endFill();
			this.width = mapWidth+200;
			this.height = mapHeight+200;
		}
		private function isInMain(p:Polygon):Boolean{
			var v:Vector.<Vector2f> = p.vertexV;
			for(var i:int=0;i<v.length;i++){
				if(poly0.isPointInByV2f(v[i]) == false){
					return false;
				}
			}
			return true;
		}
		public function buildTriangle():void {
			//outConvexPoint();
			//contractRound();
			//return;
			//合并
			//this.unionAll();
			
			//init();
			var time:int = getTimer();
			var d:Delaunay = new Delaunay();
			triangleV = d.createDelaunay(polygonV);
			
			trace("生成三角形耗时" + String(getTimer() - time) );
			
			lineShpae.graphics.lineStyle(1, 0xff0000);
			for each (var t:Triangle in triangleV) {
				t.draw(lineShpae.graphics);
			}
			
			trace("一共生成三角形：" + triangleV.length);
			//构建寻路数据
			cellV = new Vector.<Cell>();
			var trg:Triangle;
			var cell:Cell;
			for (var j:int=0; j<triangleV.length; j++) {
				trg = triangleV[j];
				cell = new Cell(trg.getVertex(0), trg.getVertex(1), trg.getVertex(2));
				cell.index = j;
				cellV.push(cell);
				
				cell.drawIndex(this);
			}
			linkCells(cellV);
			for(j=0; j<cellV.length; j++){
				cell = cellV[j];
				drawLink(cell);
			}
			//this.addChild(wangS);
			
			var file:File;
			var fs:FileStream = new FileStream();
			var str:String;
			
			
			file = new File(basicurl + "/" + murl + ".mapedit")// File.documentsDirectory.resolvePath("navMap/" + murl + ".mapedit");
			fs.open(file,FileMode.WRITE);
			var pol:Polygon;
			str = polygonV[0].writeFile();
			for(i=1;i<polygonV.length;i++){
				pol = polygonV[i];
				str += "//" + pol.writeFile();
			}
			var blockStr:String = blockPolygonV[0].writeFile();
			for(i=1;i<blockPolygonV.length;i++){
				pol = blockPolygonV[i];
				blockStr += "//" + pol.writeFile();
			}
			model.mapname = murl;
			model.mapWidth = mapWidth;
			model.mapHeight = mapHeight;
			model.picw = picW;
			model.picH = picH;
			str = "<map name='" + model.mapname + "' mapwidth='" + 
				model.mapWidth + "' mapheight='" + model.mapHeight + "' picw='" + 
				model.picw + "' pich='" + model.picH + "' mapdata='" + str + "' blockdata='" + blockStr + "'/>"
			
			fs.writeUTFBytes(str);
			fs.close();
			
			file = new File(basicurl + "/" + murl + ".navmap")// File.documentsDirectory.resolvePath("navMap/" + murl + ".navmap");
			fs.open(file,FileMode.WRITE);
			var mapdataStr:String = '';
			for(var i:int=0;i<triangleV.length;i++){
				trg = triangleV[i];
				mapdataStr += trg.writeFile();
				for(j=0;j<blockPolygonV.length;j++){
					pol = blockPolygonV[j];
					if(isInsert(trg,pol)){
						mapdataStr += "," + j;
					}
				}
				mapdataStr += "|";
				//mapdataStr += trg.getVertex(0).writeFile() +  trg.getVertex(1).writeFile() +  trg.getVertex(2).writeFile();
			}
			mapdataStr = mapdataStr.substr(0,mapdataStr.length-1);
			
			
			str = "<map name='" + model.mapname + "' mapwidth='" + 
				model.mapWidth + "' mapheight='" + model.mapHeight + "' picw='" + 
				model.picw + "' pich='" + model.picH + "' mapdata='" + mapdataStr + "' blockdata='" + blockStr +"'/>"
			fs.writeUTFBytes(str);
			fs.close();
			
			file = new File(basicurl + "/" + murl + "-sky-mesh.jpg")// File.documentsDirectory.resolvePath("navMap/" + murl + ".navmap");
			fs.open(file,FileMode.WRITE);
			var sxy:Number = 1;
			var bitmap:BitmapData = new BitmapData(model.mapWidth*sxy,model.mapHeight*sxy,true,0);
			var ma:Matrix = new Matrix()
			ma.scale(sxy,sxy);
			bitmap.draw(wangS,ma);
			/*var byte:ByteArray = new JPEGEncoder(50).encode(bitmap);
			fs.writeBytes(byte);
			fs.close();*/
			
			this.removeEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.CLICK,setFindPath);
			//this.addEventListener(MouseEvent.MOUSE_MOVE,setFindPathMove);
		}
		private var wangS:Sprite = new Sprite;
		private function drawLink(currNode:Cell):void{
			wangS.graphics.lineStyle(3,0xff0000);
			var adjacentId:int;
			var lineCell:Cell;
			for (var i:int=0; i<3; i++) {
				adjacentId = currNode.links[i];
				trace(adjacentId)
				if (adjacentId < 0) {						//不能通过
					continue;
				} else {
					lineCell = cellV[adjacentId];
					var p1:Point = currNode.getCenter();
					var p2:Point;
					if(lineCell){
						p2 = lineCell.getCenter();
						wangS.graphics.moveTo(p1.x,p1.y);
						wangS.graphics.lineTo(p2.x,p2.y);
					}
				}
			}
		}
		private function isInsert(trg:Triangle,pol:Polygon):Boolean{
			var PolV:Array = pol.getAllLine();
			for(var i:int=0;i<3;i++){
				var l:Line2D = trg.getSide(i);
				var insertAry:Array = getInsert(l,PolV);
				if(insertAry.length > 0){
					return true;
				}
			}
			return false;
		}
		public function getInsert(line:Line2D,lineAry:Array):Array{
			var ary:Array = new Array;
			for(var i:int;i<lineAry.length;i++){
				var p:Vector2f = new Vector2f();
				var testLine:Line2D = lineAry[i];
				trace("测试线段" + "(" + testLine.pointA.x + "," + testLine.pointA.y + ")>>>(" + testLine.pointB.x + "," + testLine.pointB.y + ")");
				var result:int = line.intersection(testLine,p)
				trace("result " + result);
				if(result==2){
					p.x = int(p.x);
					p.y = int(p.y);
					ary.push(p);
				}
			}
			return ary;
		}
		
		private function outConvexPoint():void{
			var ary:Vector.<Vector2f> = Polygon(polygonV[0]).vertexV;
			trace("原来的点数" + ary.length);
			var v2f:Vector2f;
			var line:Line2D;
			var newAry:Array = new Array;
			for(var i:int=0;i<ary.length-2;i++){
				line = new Line2D(ary[i],ary[i+1]);
				if(line.classifyPoint(ary[i+2]) == PointClassification.LEFT_SIDE){
					var l2:Line2D = new Line2D(ary[i+1],ary[i+2]);
					var v1:Vector2f = line.getVector2f().normalize();
					var v2:Vector2f = l2.getVector2f().normalize();
					var v3:Vector2f = v1.subtract(v2).normalize().mult(30).add(ary[i+1]);
					newAry.push(v3);
					trace("凸点");
				}else{
					newAry.push(ary[i+1]);
				}
			}
			
			line = new Line2D(ary[ary.length-2],ary[ary.length-1]);
			if(line.classifyPoint(ary[0]) == PointClassification.RIGHT_SIDE){
				l2 = new Line2D(ary[ary.length-1],ary[0]);
				v1 = line.getVector2f().normalize();
				v2 = l2.getVector2f().normalize();
				v3 = v1.subtract(v2).normalize().mult(20).add(ary[ary.length-1]);
				newAry.push(v3);
				trace("凸点-1");
			}else{
				newAry.push(ary[ary.length-1]);
			}
			
			line = new Line2D(ary[ary.length-1],ary[0]);
			if(line.classifyPoint(ary[1]) == PointClassification.RIGHT_SIDE){
				l2 = new Line2D(ary[0],ary[1]);
				v1 = line.getVector2f().normalize();
				v2 = l2.getVector2f().normalize();
				v3 = v1.subtract(v2).normalize().mult(20).add(ary[0]);
				newAry.push(v3);
				trace("凸点0");
			}else{
				newAry.push(ary[0]);
			}
			
			
			lineShpae.graphics.lineStyle(2,0x000000);
			lineShpae.graphics.moveTo(newAry[0].x,newAry[0].y);
			for(i=1;i<newAry.length;i++){
				lineShpae.graphics.lineTo(newAry[i].x,newAry[i].y);
			}
			lineShpae.graphics.lineTo(newAry[0].x,newAry[0].y);
			
		}
		private function contractRound():void{
			var ary:Vector.<Vector2f> = Polygon(polygonV[0]).vertexV;
			trace("原来的点数" + ary.length);
			var v2f:Vector2f;
			var line:Line2D;
			var newAry:Array = new Array;
			var pAry:Array = new Array;
			for(var i:int=0;i<ary.length-1;i++){
				line = new Line2D(ary[i],ary[i+1]).getParallel();
				newAry.push(line);
			}
			line = new Line2D(ary[ary.length-1],ary[0]).getParallel();
			newAry.push(line);
			
			for(i=0;i<newAry.length-1;i++){
				v2f = new Vector2f();
				Line2D(newAry[i]).intersection(newAry[i+1],v2f);
				var angle:Number = Line2D(newAry[i]).getAngle(newAry[i+1]);
				/* if(angle < -0.2){
					var v1:Vector2f = Line2D(newAry[i]).getVector2f().normalize();
					var v2:Vector2f = Line2D(newAry[i+1]).getVector2f().normalize();
					var v3:Vector2f = v2.subtract(v1).mult(-50*angle);
					if(Line2D(newAry[i]).classifyPoint(Line2D(newAry[i+1]).pointB,0) == PointClassification.RIGHT_SIDE){
						v2f = v2f.subtract(v3);
					}else{
						v2f = v2f.add(v3);
					}
				} */
				pAry.push(v2f);
			}
			Line2D(newAry[newAry.length-1]).intersection(newAry[0],v2f);
			pAry.push(v2f);
			trace("新的的点数" + pAry.length);
			lineShpae.graphics.lineStyle(2,0x000000);
			lineShpae.graphics.moveTo(pAry[0].x,pAry[0].y);
			for(i=1;i<pAry.length;i++){
				lineShpae.graphics.lineTo(pAry[i].x,pAry[i].y);
			}
			lineShpae.graphics.lineTo(pAry[0].x,pAry[0].y);
		}
		private function loadmapdata():void{
			var file:File = new File(basicurl + "/" + murl + ".mapedit");
			if(file.exists){
				var urlloader:URLLoader = new URLLoader;
				urlloader.addEventListener(Event.COMPLETE,dataOnComplete);
				urlloader.load(new URLRequest(file.url));
			}else{
				initV0();
			}
		}
		private function dataOnComplete(event:Event):void{
			var xml:XML = XML(event.target.data);
			this.mapHeight = int(xml.@mapheight);
			this.mapWidth = int(xml.@mapwidth);
			this.picW = int(xml.@picw);
			this.picH = int(xml.@pich);
			createBg(picW,picH);
			var str:String = String(xml.@mapdata);
			addBlockBydata(xml.@blockdata);
			var ary:Array = str.split("//");
			for(var i:int=0;i<ary.length;i++){
				var pol:Polygon;
				var pointAry:Array = String(ary[i]).split("|");
				var v0:Vector.<Vector2f> = new Vector.<Vector2f>();
				for(var j:int=0;j<pointAry.length;j++){
					var pAry:Array = String(pointAry[j]).split(",");
					v0.push(new Vector2f(pAry[0], pAry[1]));
				}
				pol = new Polygon(v0.length, v0);
				container.addChild(pol);
				pol.addEventListener(Event.CHANGE,edagChange);
				pol.addEventListener("removePol",removePolygon);
				polygonV.push(pol);
				if(i != 0){
					pol.draw(true);
				}
				
			}
			poly0 = polygonV[0]
			poly0.ismain = true;
			drawThis();
		}
		private function addBlockBydata(str:String):void{
			if(str == null){
				return;
			}
			var ary:Array = str.split("//");
			for(var i:int=0;i<ary.length;i++){
				var pol:Polygon;
				var pointAry:Array = String(ary[i]).split("|");
				var v0:Vector.<Vector2f> = new Vector.<Vector2f>();
				for(var j:int=0;j<pointAry.length;j++){
					var pAry:Array = String(pointAry[j]).split(",");
					v0.push(new Vector2f(pAry[0], pAry[1]));
				}
				pol = new Polygon(v0.length, v0);
				blockContainer.addChild(pol);
				pol.addEventListener(Event.CHANGE,edagChange);
				pol.addEventListener("removePol",removePolygon);
				blockPolygonV.push(pol);
				pol.setDrawColor(0x00ff00,0x7d00dd,0x7d00dd);
				pol.draw(true);
			}
		}
		/**
		 * 搜索单元网格的邻接网格，并保存链接数据到网格中，以提供给寻路用
		 * @param pv
		 */		
		public function linkCells(pv:Vector.<Cell>):void {
			for each (var pCellA:Cell in pv) {
				for each (var pCellB:Cell in pv) {
					if (pCellA != pCellB) {
						pCellA.checkAndLink(pCellB);
					}
				}
			}
		}
		
		private var startPtSign:Boolean = false;
		private var startPt:Point;
		private var endPt:Point;
		private function setFindPath(e:MouseEvent):void {
			/*if (startPtSign) {
				endPt = new Point(e.localX, e.localY);
				startPtSign = false;
				
				pathShape.graphics.beginFill(0xff0000);
				pathShape.graphics.drawCircle(endPt.x, endPt.y, 3);
				pathShape.graphics.endFill();
				
				if(pathShape.numChildren){
					pathShape.removeChildAt(0);
				}
				
				var nav:NavMesh = new NavMesh(cellV);
				pathShape.addChild(nav);
				nav.findPath(startPt, endPt);
			} else {
				startPt = new Point(e.localX, e.localY);9
				startPtSign = true;
				
				pathShape.graphics.beginFill(0x00ff00);
				pathShape.graphics.drawCircle(startPt.x, startPt.y, 3);
				pathShape.graphics.endFill();
			}*/
			startPt = new Point(e.localX, e.localY);
			startPtSign = true;
			
			pathShape.graphics.beginFill(0x00ff00);
			pathShape.graphics.drawCircle(startPt.x, startPt.y, 3);
			pathShape.graphics.endFill();
		}
		private function setFindPathMove(e:MouseEvent):void{
			if (startPtSign) {
				endPt = new Point(e.localX, e.localY);
				//startPtSign = false;
				
				pathShape.graphics.beginFill(0xff0000);
				pathShape.graphics.drawCircle(endPt.x, endPt.y, 3);
				pathShape.graphics.endFill();
				
				if(pathShape.numChildren){
					pathShape.removeChildAt(0);
				}
				
				var nav:NavMesh = new NavMesh(cellV);
				pathShape.addChild(nav);
				nav.findPath(startPt, endPt);
			} 
		}
		
	}
}