package org.blch.findPath
{
	import flash.geom.Point;
	
	import org.blch.geom.Line2D;
	import org.blch.geom.LineArray;
	import org.blch.geom.Polygon;
	import org.blch.geom.Vector2f;
	import org.blch.util.GeomUtils;

	public class LineCrossBlock
	{
		public var crossBlockPolygonV:Vector.<Polygon>;
		private var poly:Polygon;
		private var lineV:Array;
		private var addList:Object;
		private var flag:Boolean;
		public function LineCrossBlock()
		{
			
		}
		public function processLine(outPath:Array):void{
			if(outPath == null){
				return;
			}
			var line:Line2D;
			addList = new Object;
			for(var i:int;i<outPath.length-1;i++){
				line = new Line2D(outPath[i],outPath[i+1]);
				if(line.pointA.x < line.pointB.x){
					flag = true;
				}else{
					flag = false;
				}
				var lineAry:Array= new Array;
				for(var j:int=0;j<crossBlockPolygonV.length;j++){
					if(crossBlockPolygonV[j].circle.isCross(line)){
						var p1:Vector2f = new Vector2f;
						var p2:Vector2f = new Vector2f;
						GeomUtils.getCricleIntersection(line,crossBlockPolygonV[j].circle,p1,p2);
						if((p1.x > line.pointA.x && p1.x > line.pointB.x) || (p1.x < line.pointA.x && p1.x < line.pointB.x) ){
							continue;
						}
						//trace(crossBlockPolygonV[j].circle.center.x,crossBlockPolygonV[j].circle.center.y);
						var lines:Line2D = new Line2D(p1,p2);
						poly = crossBlockPolygonV[j];
						lineV = new Array;
						if(poly.getRatelition(lines)){
							getNEWline(lines);
						}
						if(lineV.length > 0){
							lineV.splice(0,0,p1);
							var obj:Object = new Object;
							obj.dis = crossBlockPolygonV[j].circle.center.x;
							obj.v = lineV
							lineAry.push(obj);
						}
					}
				}
				if(lineAry.length){
					//lineAry.sort(compare);
					if(flag){
						lineAry.sortOn("dis",Array.DESCENDING | Array.NUMERIC);
					}else{
						lineAry.sortOn("dis",Array.NUMERIC);
					}
					addList[String(i)] = lineAry;
				}
				
			}
			
			for(i=0;i<outPath.length-1;i++){
				var ary:Array = addList[String(i)];
				if(ary){
					for(j=0;j<ary.length;j++){
						for(var k:int=0;k<ary[j].v.length;k++){
							outPath.splice(i+1,0,ary[j].v[k]);
						}
						i += ary[j].length;
					}
				}
			}
		}
		
		private function compare(ary1:Object,ary2:Object):Boolean{
			if(flag){
				return ary1.dis < ary2.dis;
			}else{
				return ary1.dis > ary2.dis;
			}
		}
		
		private function getNEWline(l:Line2D):void{
			var leftary:Array = new Array;
			var rightary:Array = new Array;
			for(var i:int;i<poly.vertexNmu;i++){
				var obj:Object = new Object;
				obj.l = (l.signedDistance(poly.vertexV[i]));
				//trace(obj.l)
				obj.v = poly.vertexV[i];
				if(obj.l > 0 ){
					leftary.push(obj);
				}else{
					obj.l = -obj.l;
					rightary.push(obj);
				}
			}
			
			/*for(i=0;i<poly2.vertexNmu;i++){
				obj = new Object;
				obj.l = (l.signedDistance(poly2.vertexV[i]));
				obj.v = poly2.vertexV[i];
				if(obj.l > 0 ){
					leftary.push(obj);
				}else{
					obj.l = -obj.l;
					rightary.push(obj);
				}
			}*/
			
			if(leftary.length == 0 || rightary.length == 0){
				return;
			}
			
			var leftMax:Object = getMaxFromArry(leftary);
			var rightMax:Object = getMaxFromArry(rightary);
			
			if(leftMax.l < rightMax.l){
				var l1:Line2D = new Line2D(l.pointA,leftMax.v);
				var l2:Line2D = new Line2D(leftMax.v,l.pointB);
				
				var la1:LineArray = new LineArray(l1,leftary,LineArray.LEFT);
				var la2:LineArray = new LineArray(l2,leftary,LineArray.LEFT);
				
			}else{
				l1 = new Line2D(l.pointA,rightMax.v);
				l2 = new Line2D(rightMax.v,l.pointB);
				
				la1 = new LineArray(l1,rightary,LineArray.RIGHT);
				la2 = new LineArray(l2,rightary,LineArray.RIGHT);
			}
			iteratLine(la1);
			iteratLine(la2);
		}
		
		private function iteratLine(lineAry:LineArray):void{
			var line:Line2D = lineAry.line;
			var ary:Array = lineAry.v;
			var resultAry:Array = new Array;
			for(var i:int;i<ary.length;i++){
				var obj:Object = new Object;
				obj.l = int(line.signedDistance(ary[i].v));
				obj.v = ary[i].v;
				if(lineAry.dircet == LineArray.LEFT){
					if(obj.l > 0 ){
						resultAry.push(obj);
					}
				}else if(lineAry.dircet == LineArray.RIGHT){
					if(obj.l < 0){
						obj.l = -obj.l;
						resultAry.push(obj);
					}
				}
			}
			if(resultAry.length == 0){
				lineV.push(lineAry.line.pointB);
				return;
			}
			
			var maxObject:Object = getMaxFromArry(resultAry);
			
			var l1:Line2D = new Line2D(line.pointA,maxObject.v);
			var l2:Line2D = new Line2D(maxObject.v,line.pointB);
			
			var la1:LineArray = new LineArray(l1,resultAry,lineAry.dircet);
			iteratLine(la1);
			var la2:LineArray = new LineArray(l2,resultAry,lineAry.dircet);
			iteratLine(la2);
			
		}
		
		private function getMaxFromArry(ary:Array):Object{
			var obj:Object;
			if(ary.length>=1){
				obj = ary[0];
			}else{
				return null;
			}
			for(var i:int = 1;i<ary.length;i++){
				if(obj.l < ary[i].l){
					obj = ary[i];
				}
			}
			return obj;	
		}
		
		
	}
}