/*
* @author 白连忱 
* date Jan 22, 2010
*/
package org.blch.geom
{
	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import models.ModelLocator;
	
	import mx.controls.Alert;
	
	import org.blch.util.GeomUtils;
	
	/**
	 * Polygon
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class Polygon extends Sprite
	{
		public var vertexNmu:int;				//顶点数
		public var vertexV:Vector.<Vector2f>;	//顶点列表
		
		private var rect:Rectangle;		//矩形包围盒
		public var ismain:Boolean;
		
		private var blockColor:uint = 0xff0000;
		private var lineColor:uint = 0x0000ff;
		private var pointColor:uint = 0x0000ff;
		
		public var circle:Circle;
		private var circleShape:Shape;
		
		public function Polygon(vertexNmu:int, vertexV:Vector.<Vector2f>)
		{
			this.vertexNmu = vertexNmu;
			this.vertexV = vertexV;
			addEvent();
			addPoints();
			draw();
			circleShape = new Shape;
			this.addChild(circleShape);
			this.addEventListener(MouseEvent.CLICK,onClick)
		}
		private function addPoints():void{
			var v2f:Vector2f;
			for (var i:int=0; i<vertexV.length; i++) {
				v2f = vertexV[i] as Vector2f;
				this.addChild(v2f.sprite);
				trace("*****",v2f.sprite.x,v2f.sprite.y);
			}
		}
		private function addEvent():void{
			var v2f:Vector2f;
			for (var i:int=0; i<vertexV.length; i++) {
				v2f = vertexV[i] as Vector2f;
				v2f.addEventListener(Event.CHANGE,v2fChange);
				v2f.addEventListener(Event.REMOVED,v2fRemove);
			}
		}
		private function onClick(event:MouseEvent):void{
			if(ModelLocator.getInstance().addState == 1){
				isONedag(this.parent.mouseX,this.parent.mouseY);
				trace(this.parent.mouseX,this.parent.mouseY);
			}
		}
		private function v2fChange(event:Event = null):void{
			if(ismain){
				this.dispatchEvent(new Event(Event.CHANGE));
				this.draw(false);
			}else{
				this.draw(true);
			}
			
		}
		private function v2fRemove(event:Event):void{
			if(vertexNmu == 3){
				if(this.ismain){
					Alert.show("操作失败！");
					return;
				}else{
					this.dispatchEvent(new Event("removePol"));
				}
			}
			var index:int = this.vertexV.indexOf(event.target);
			this.vertexV.splice(index,1);
			this.vertexNmu--;
			v2fChange();
			
			var sp:Sprite = Vector2f(event.target).sprite
			if(sp.parent){
				sp.parent.removeChild(sp);
			}
		}
		private function isONedag(xpos:Number,ypos:Number):void{
			var v2f:Vector2f;
			v2f = new Vector2f(xpos,ypos)
			for(var i:int=0;i<this.vertexNmu-1;i++){
				var line2d:Line2D = new Line2D(this.vertexV[i],this.vertexV[i+1]);
				if(line2d.classifyPoint(v2f,2) == PointClassification.ON_LINE){
					this.vertexV.splice(i+1,0,v2f);
					v2fChange();
					this.addChild(v2f.sprite);
					vertexNmu++;
					v2f.addEventListener(Event.CHANGE,v2fChange);
					v2f.addEventListener(Event.REMOVED,v2fRemove);
					trace("online");
					return;
				}
			}
			line2d = new Line2D(this.vertexV[i],this.vertexV[0]);
			if(line2d.classifyPoint(v2f,2) == PointClassification.ON_LINE){
				this.vertexV.push(v2f);
				vertexNmu++;
				v2fChange();
				this.addChild(v2f.sprite);
				v2f.addEventListener(Event.CHANGE,v2fChange);
				v2f.addEventListener(Event.REMOVED,v2fRemove);
				trace("online")
			}
		}
		/**
		 * 是否是简单多边形
		 * @return 
		 */		
		public function isSimplicity():Boolean {
			// 边数组
			var edges:Vector.<Line2D> = new Vector.<Line2D>();
			var len:int = vertexV.length-1;
			for (var i:int=0; i<len; i++) {
				edges.push(new Line2D(vertexV[i], vertexV[i+1]));
			}
			edges.push(new Line2D(vertexV[len], vertexV[0]));
			
			// 是否有内交点
			var itsPt:Vector2f = new Vector2f();	//返回的交点
			for each (var testLine:Line2D in edges) {
				for (var j:int=0; j<edges.length; j++) {
					if (!testLine.equals(edges[j])) {
						if (testLine.intersection(edges[j], itsPt) == LineClassification.SEGMENTS_INTERSECT) {
							//交点是两个线段的端点
							if ( itsPt.equals(testLine.getPointA()) || itsPt.equals(testLine.getPointB())
								|| itsPt.equals(edges[j].getPointA()) || itsPt.equals(edges[j].getPointB()) ) {
								trace("");
							} else {
								return false;
							}
						}
					}
				}
			}
			
			return true;
		}
		
		/**
		 * 将多边形的顶点按顺时针排序
		 */		
		public function cw():void {
			if (this.isCW() == false) {	//如果为逆时针顺序， 反转为顺时针
				this.vertexV.reverse();	//反转数组
			}
		}
		public function rw():void{
			if (this.isCW() == true) {	
				this.vertexV.reverse();	
			}
		}
		/**
		 * clockwise
		 * @return true -- clockwise; false -- counter-clockwise
		 */		
		public function isCW():Boolean {
			if (vertexV == null || vertexV.length < 0) return false;
			
			//最上（y最小）最左（x最小）点， 肯定是一个凸点
			//寻找最上点
			var topPt:Vector2f = this.vertexV[0];
			var topPtId:int = 0;	//点的索引
			for (var i:int=1; i<vertexV.length; i++) {
				if (topPt.y > vertexV[i].y) {
					topPt = vertexV[i];
					topPtId = i;
				} else if (topPt.y == vertexV[i].y) { //y相等时取x最小
					if (topPt.x > vertexV[i].x) {
						topPt = vertexV[i];
						topPtId = i;
					}
				}
			}
			
			//凸点的邻点
			var lastId:int = topPtId-1>=0 ? topPtId-1 : vertexV.length-1;
			var nextId:int = topPtId+1>=vertexV.length ? 0 : topPtId+1;
			var last:Vector2f = vertexV[lastId];
			var next:Vector2f = vertexV[nextId];
			
			//判断
			var r:Number = multiply(last, next, topPt);
			if (r < 0) {
				return true;
//			} else if (r == 0) {
			//三点共线情况不存在，若三点共线则说明必有一点的y（斜线）或x（水平线）小于topPt
			}
			
			return false;
		}
		
		/**
		 * r=multiply(sp,ep,op),得到(sp-op)*(ep-op)的叉积 
		 * r>0:ep在矢量opsp的逆时针方向； 
		 * r=0：opspep三点共线； 
		 * r<0:ep在矢量opsp的顺时针方向 
		 * @param sp 
		 * @param ep 
		 * @param op 
		 * @return 
		 */		
		private function multiply(sp:Vector2f, ep:Vector2f, op:Vector2f):Number { 
			return((sp.x-op.x)*(ep.y-op.y)-(ep.x-op.x)*(sp.y-op.y)); 
		} 
		
		/**
		 * 返回矩形包围盒
		 * @return 
		 */		
		public function rectangle():Rectangle {
			if (vertexV == null || vertexV.length < 0) return null;
			
			if (rect != null) return rect;
			
			var lx:Number = vertexV[0].x;
			var rx:Number = vertexV[0].x;
			var ty:Number = vertexV[0].y;
			var by:Number = vertexV[0].y;
			
			var v:Vector2f;
			for (var i:int=1; i<vertexV.length; i++) {
				v = vertexV[i];
				if (v.x < lx) {
					lx = v.x;
				}
				if (v.x > rx) {
					rx = v.x;
				}
				if (v.y < ty) {
					ty = v.y;
				}
				if (v.y > by) {
					by = v.y;
				}
			}
			
			rect = new Rectangle(lx, rx-lx, ty, by-ty);
			return rect;
		}
		
		/**
		 * 合并两个多边形(Weiler-Athenton算法)
		 * @param polygon
		 * @return 
		 * 			null--两个多边形不相交，合并前后两个多边形不变
		 * 			Polygon--一个新的多边形
		 */		
		public function union(polygon:Polygon):Vector.<Polygon> {
			//包围盒不相交
			if (rectangle().intersection(polygon.rectangle()) == false) {
				return null;
			}
			//所有顶点和交点
			var cv0:Vector.<Node> = new Vector.<Node>();//主多边形
			var cv1:Vector.<Node> = new Vector.<Node>();//合并多边形
			//初始化
			preProcess(cv0,cv1,polygon);
			
			//插入交点
			var insCnt:int = this.intersectPoint(cv0, cv1);

			if (insCnt > 0) {
				//顺时针序
				return linkToPolygon(cv0, cv1);
			} else {
				return null;
			}
			return null;
		}
		public function reduce(polygon:Polygon):Polygon {
			//包围盒不相交
			if (rectangle().intersection(polygon.rectangle()) == false) {
				return null;
			}
			//所有顶点和交点
			var cv0:Vector.<Node> = new Vector.<Node>();//主多边形
			var cv1:Vector.<Node> = new Vector.<Node>();//合并多边形
			//初始化
			preProcess(cv0,cv1,polygon);
			
			//插入交点
			var insCnt:int = this.intersectPoint(cv0, cv1);
			addNext(cv0);
			addNext(cv1);
			if (insCnt == 2) {
				//顺时针序
				return linkToPolygona(cv0, cv1);
			} else {
				return null;
			}
			return null;
		}
		private function preProcess(cv0:Vector.<Node>,cv1:Vector.<Node>,polygon:Polygon):void{
			//初始化
			var node:Node;
			for (var i:int=0; i<this.vertexV.length; i++) {
				node = new Node(this.vertexV[i], false, true);
				if (i > 0) {
					cv0[i-1].next = node;
				}
				cv0.push(node);
			}
			for (var j:int=0; j<polygon.vertexV.length; j++) {
				node = new Node(polygon.vertexV[j], false, false);
				if (j > 0) {
					cv1[j-1].next = node;
				}
				cv1.push(node);
			}
		}
		private function addNext(cv:Vector.<Node>):void{
			for(var i:int=0;i<cv.length;i++){
				if(cv[i].next == null){
					cv[i].next = cv[0];
				}
			}
		}
		public function isPointIn(testPoint:Node):Boolean {
			var polygonV:Vector.<Polygon> = new Vector.<Polygon>;
			polygonV.push(this);
			var d:Delaunay = new Delaunay();
			var triangleV:Vector.<Triangle>  = d.createDelaunay(polygonV);
			for(var i:int=0; i<triangleV.length; i++){
				if(Triangle(triangleV[i]).isPointIn(testPoint.v)){
					return true;
				}
			}
			return false;
		}
		public function isPointInByV2f(testPoint:Vector2f):Boolean {
			var polygonV:Vector.<Polygon> = new Vector.<Polygon>;
			polygonV.push(this);
			var d:Delaunay = new Delaunay();
			var triangleV:Vector.<Triangle>  = d.createDelaunay(polygonV);
			for(var i:int=0; i<triangleV.length; i++){
				if(Triangle(triangleV[i]).isPointIn(testPoint)){
					return true;
				}
			}
			return false;
		}
		/**
		 * 生成多边形，顺时针序； 生成的内部孔洞多边形为逆时针序
		 * @param cv0
		 * @param cv1
		 * @return 合并后的结果多边形数组(可能有多个多边形)
		 */		
		private function linkToPolygon(cv0:Vector.<Node>, cv1:Vector.<Node>):Vector.<Polygon> {
			trace("linkToPolygon***linkToPolygon");
			//保存合并后的多边形数组
			var rtV:Vector.<Polygon> = new Vector.<Polygon>();
			
			//1. 选取任一没有被跟踪过的交点为始点，将其输出到结果多边形顶点表中．
			for each (var testNode:Node in cv0) {
				if (testNode.i == true && testNode.p == false) {
//					trace("测试点0", testNode);
					var rcNodes:Vector.<Vector2f> = new Vector.<Vector2f>();
					while (testNode != null) {
//						trace("测试点1", testNode);
						
						testNode.p = true;
						
						// 如果是交点
						if (testNode.i == true) {
							testNode.other.p = true;
							
							if (testNode.o == false) {		//该交点为进点（跟踪裁剪多边形边界）
								if (testNode.isMain == true) {		//当前点在主多边形中
									testNode = testNode.other;		//切换到裁剪多边形中
								}
							} else {					//该交点为出点（跟踪主多边形边界）
								if (testNode.isMain == false) {		//当前点在裁剪多边形中
									testNode = testNode.other;		//切换到主多边形中
								}
							}
						}
						
						rcNodes.push(testNode.v);  		////// 如果是多边形顶点，将其输出到结果多边形顶点表中
						
						if (testNode.next == null) {	//末尾点返回到开始点
							if (testNode.isMain) {
								testNode = cv0[0];
							} else {
								testNode = cv1[0];
							}
						} else {
							testNode = testNode.next;
						}
						
						//与首点相同，生成一个多边形
						if (testNode.v.equals(rcNodes[0])) break;
					}
					//提取
					rtV.push(new Polygon(rcNodes.length, rcNodes));
				}
			}
			
			trace("rtV", rtV);
			return rtV;
		}
		
		private function linkToPolygona(cv0:Vector.<Node>, cv1:Vector.<Node>):Polygon {
			trace("linkToPolygon***linkToPolygon");
			//保存合并后的多边形数组
			var rcNodes:Vector.<Vector2f> = new Vector.<Vector2f>();
			for each (var testNode:Node in cv1) {
				if (testNode.i == true) {
					if(!isPointIn(testNode.next)){
						continue;
					}else{
						rcNodes.push(testNode.v);
						testNode = testNode.next;
						while(true){
							trace(123)
							rcNodes.push(testNode.v);
							if(testNode.i){
								if(testNode.isMain){
									rcNodes.pop();
									var pol:Polygon = new Polygon(rcNodes.length, rcNodes);
									//trace(pol.toString());
									return pol;
								}
								testNode = testNode.other;
								testNode = testNode.next;
							}else{
								if(testNode.next == null){
									trace("----")
								}
								testNode = testNode.next;
							}
						}
					}
					
				}
			}
			return new Polygon(rcNodes.length, rcNodes);
		}
		
		/**
		 * 生成交点，并按顺时针序插入到顶点表中
		 * @param cv0 （in/out）主多边形顶点表，并返回插入交点后的顶点表              
		 * @param cv1 （in/out）合并多边形顶点表，并返回插入交点后的顶点表
		 * @return 交点数
		 */		
		private function intersectPoint(cv0:Vector.<Node>, cv1:Vector.<Node>):int {
			var insCnt:int = 0;		//交点数
			
			var findEnd:Boolean = false;
			var startNode0:Node = cv0[0];
			var startNode1:Node;
			var line0:Line2D;
			var line1:Line2D;
			var ins:Vector2f;
			var hasIns:Boolean;
			var result:int;		//进出点判断结果
			while (startNode0 != null) {		//主多边形
				if (startNode0.next == null) {  //最后一个点，跟首点相连
					line0 = new Line2D(startNode0.v, cv0[0].v);
				} else {
					line0 = new Line2D(startNode0.v, startNode0.next.v);
				}
				
				startNode1 = cv1[0];
				hasIns = false;
				
				while (startNode1 != null) {		//合并多边形
					if (startNode1.next == null) {
						line1 = new Line2D(startNode1.v, cv1[0].v);
					} else {
						line1 = new Line2D(startNode1.v, startNode1.next.v);
					}
					ins = new Vector2f();	//接受返回的交点
					//有交点
					if (line0.intersection(line1, ins) == LineClassification.SEGMENTS_INTERSECT) {
						//忽略交点已在顶点列表中的
						if (this.getNodeIndex(cv0, ins) == -1) {
							insCnt++;
							
							///////// 插入交点
							var node0:Node = new Node(ins, true, true);
							var node1:Node = new Node(ins, true, false);
							cv0.push(node0);
							cv1.push(node1);
							//双向引用
							node0.other = node1;
							node1.other = node0;
							//插入
							node0.next = startNode0.next;
							startNode0.next = node0;
							node1.next = startNode1.next;
							startNode1.next = node1;
							//出点
							if (line0.classifyPoint(line1.getPointB()) == PointClassification.RIGHT_SIDE) {
								node0.o = true;
								node1.o = true;
							}
							//TODO 线段重合
//							trace("交点****", node0);
							
							hasIns = true;		//有交点
							
							//有交点，返回重新处理
							break;
						}
					}
					startNode1 = startNode1.next;
				}
				//如果没有交点继续处理下一个边，否则重新处理该点与插入的交点所形成的线段
				if (hasIns == false) {
					startNode0 = startNode0.next;
				}
			}
			return insCnt;
		}
		
		/**
		 * 取得节点的索引(合并多边形用)
		 * @param cv
		 * @param node
		 * @return 
		 */		
		private function getNodeIndex(cv:Vector.<Node>, node:Vector2f):int {
			for (var i:int=0; i<cv.length; i++) {
				if (cv[i].v.equals(node)) {
					return i;
				}
			}
			return -1;
		}
		//private var graph:Graphics;
		public function setDrawColor(blockColor:uint,lineColor:uint,pointColor:uint):void{
			this.blockColor = blockColor;
			this.lineColor = lineColor;
			this.pointColor = pointColor;
		}
		public function draw(block:Boolean=false):void {
			var g:Graphics = this.graphics;
			g.clear();
			if(block){
				g.beginFill(blockColor, .3);
			}
			
			g.lineStyle(2,lineColor);
			g.moveTo(vertexV[0].x, vertexV[0].y);
			
			for (var i:int=1; i<vertexV.length; i++) {
				g.lineTo(vertexV[i].x, vertexV[i].y);
			}
			
			g.lineTo(vertexV[0].x, vertexV[0].y);
			g.endFill();
		}
		
		public function drawCircle():void{
			circle = getMinCricle()//GeomUtils.getCircleFormPoint(vertexV[0],vertexV[1],vertexV[2]);
			circleShape.graphics.lineStyle(2,0x00ffff);
			circleShape.graphics.drawCircle(circle.center.x,circle.center.y,circle.radius);
		}
		private function getMinCricle():Circle{
			var circleAry:Array = new Array;
			var circle:Circle;
			for(var i:int=0;i<vertexV.length;i++){
				for(var j:int=i;j<vertexV.length;j++){
					for(var k:int=0;k<vertexV.length;k++){
						if(k==i || k==j){
							continue;
						}
						circle = GeomUtils.getCircleFormPoint(vertexV[i],vertexV[j],vertexV[k]);
						var flag:Boolean = true
						for(var h:int=0;h<vertexV.length;h++){
							if(h != i && h != j && h != k){
								if(!circle.isInCircle(vertexV[h])){
									flag = false;
								}
							}
						}
						if(flag)
							circleAry.push(circle);
					}
				}
			}
			
			for(i=0;i<vertexV.length;i++){
				for(j=i;j<vertexV.length;j++){
					if(i == j){
						continue;
					}
					circle = GeomUtils.getCricleFromTwo(vertexV[i],vertexV[j]);
					flag = true
					for(h=0;h<vertexV.length;h++){
						if(h != i && h != j){
							if(!circle.isInCircle(vertexV[h])){
								flag = false;
							}
						}
					}
					if(flag)
						circleAry.push(circle);
				}
			}
			
			circle = circleAry[0];
			for(i=0;i<circleAry.length;i++){
				//trace("test：" + circleAry[i].radius)
				if(circle.radius > circleAry[i].radius){
					circle = circleAry[i];
				}
			}
			//trace("result：" + circle.radius)
			return circle;
		}
		override public function toString():String {
			var rs:String =  "Polygon:";
			for (var i:int=0; i<this.vertexV.length; i++) {
				rs += " -> "+vertexV[i];
			}
			return rs;
		}
		public function getAllLine():Array{
			var ary:Array = new Array;
			for(var i:int=0;i<vertexV.length-1;i++){
				ary.push(new Line2D(vertexV[i],vertexV[i+1]));
			}
			ary.push(new Line2D(vertexV[vertexV.length-1],vertexV[0]));
			return ary;
		}
		public function writeFile():String{
			var rs:String =  int(vertexV[0].x) + "," + int(vertexV[0].y);
			for (var i:int=1; i<this.vertexV.length; i++) {
				rs += "|" + int(vertexV[i].x) + "," + int(vertexV[i].y);
			}
			return rs;
		}
		public function writeCircleFile():String{
			var rs:String =  writeFile() + ">" + int(circle.center.x) + "," + int(circle.center.y) + "," + int(circle.radius);
			return rs;
		}
		private var allLine:Array;
		public function getRatelition(testline:Line2D):Boolean{
			if(allLine == null){
				allLine = getAllLine();
			}
			var thisline:Line2D;
			var num:int;
			for(var i:int;i<allLine.length;i++){
				thisline = allLine[i];
				var p:Vector2f = new Vector2f;
				if(thisline.intersection(testline,p) == LineClassification.SEGMENTS_INTERSECT){
					if(!(p.equal(testline.pointA) || p.equal(testline.pointB))){
						return true;
					}else{
						num++
					}
				}
			}
			if(num >= 4){
				//return true; 
			}
			return false;
		}
		/*public function writeCircleFile():String{
			var rs:String =  int(vertexV[0].x) + "," + int(vertexV[0].y);
			for (var i:int=1; i<this.vertexV.length; i++) {
				rs += "|" + int(vertexV[i].x) + "," + int(vertexV[i].y);
			}
			rs += "*" + circle.center.x + "," + circle.center.y + "," + circle.radius;
			return rs;
		}*/
	}
}


import org.blch.geom.Vector2f;
/**
 * 顶点(合并多边形用)
 * @author blc
 */
class Node {
//	/** 原数组中的索引 */
//	public var index:int;
	/** 坐标点 */
	public var v:Vector2f;		//点
	/** 是否是交点 */
	public var i:Boolean;
	/** 是否已处理过 */
	public var p:Boolean = false;	
	/** 进点--false； 出点--true */
	public var o:Boolean = false;
	/** 交点的双向引用 */
	public var other:Node;	
	/** 点是否在主多边形中*/
	public var isMain:Boolean;
	
	/** 多边形的下一个点 */
	public var next:Node;
	
	public function Node(pt:Vector2f, isInters:Boolean, main:Boolean):void {
		this.v = pt;
		this.i = isInters;
		this.isMain = main;
	}
	
	public function toString():String {
		return v.toString() + "-->交点：" + i + "出点：" + o + "主：" + isMain + "处理：" + p;
	}
	
//	public function equals(node:Node):Boolean {
//		return v.equals(node.v);
//	}
}