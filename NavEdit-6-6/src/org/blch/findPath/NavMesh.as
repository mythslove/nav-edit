/*
* @author 白连忱 
* date Jan 25, 2010
*/
package org.blch.findPath
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.blch.geom.Line2D;
	import org.blch.geom.PathPoint;
	import org.blch.geom.PointClassification;
	import org.blch.geom.Vector2f;
	import org.blch.util.Heap;
	
	/**
	 * NavMesh
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class NavMesh extends Sprite
	{
		public static const EPSILON:Number = 0.000000;	//精度
		
		// Path finding session ID. This Identifies each pathfinding session
		// so we do not need to clear out old data in the cells from previous sessions.
		private static var pathSessionId:int = 0;	
		
		private var m_CellVector:Vector.<Cell>;
		
		private var openList:Heap;
		private var closeList:Array;
		public var g:Graphics;
		public function NavMesh(cellVector:Vector.<Cell>)
		{
			m_CellVector = cellVector;
			g = this.graphics;
			//
			openList = new Heap(m_CellVector.length, function(a:PathPoint, b:PathPoint):int { return b.f - a.f;});
			closeList = new Array();
		}
		
		public function getCell(index:int):Cell {
			return m_CellVector[index];
		}
		
		/**
		 * 找出给定点所在的三角型
		 * @param Point
		 * @return 
		 */		
		public function findClosestCell(pt:Vector2f):Cell {
			for each (var pCell:Cell in m_CellVector) {
				if (pCell.isPointIn(pt)) {
					return pCell;
				}
			}
			return null;
		}
		
		public function findPath(startPointPx:Point, endPointPx:Point):Array {
			
			var stime:int = getTimer();
			
			pathSessionId++;
			
			var startPos:Vector2f = new Vector2f(startPointPx.x, startPointPx.y);
			var endPos:Vector2f = new Vector2f(endPointPx.x, endPointPx.y);
			var startCell:Cell = findClosestCell(startPos);
			var endCell:Cell = findClosestCell(endPos);
			if (startCell == null || endCell == null) {
				trace("没有路径。");
				return null;
			}
			
			var outPath:Array;
			
			if (startCell == endCell) {
				outPath = [startPointPx, endPointPx];
			} else {
				outPath = buildPath(startCell, startPos, endCell, endPos);
			}
			
			trace("寻路时间：", getTimer()-stime);
			trace(outPath);
			//画路径线
			if (outPath != null && outPath.length > 1) {
				this.graphics.lineStyle(2, 0xffff00);
				this.graphics.moveTo(outPath[0].x, outPath[0].y);
				for (var m:int=1; m<outPath.length; m++) {
					this.graphics.lineTo(outPath[m].x, outPath[m].y);
				}
			}
			
			return outPath;
		}
		
		/**
		 * 计算F的估价值
		 *@param startPos 起始点
		 *@param endPos 终点
		 *@return F值
		 **/
		public function countFValue(startPos:Vector2f,endPos:Vector2f):int{
			
			var sX:int = startPos.x;
			
			var sY:int = startPos.y;
			
			var eX:int = endPos.x;
			
			var eY:int = endPos.y;
			
			if(sX == eX&&sY == eY) return 0;
			
			else {
				
				var disX:int = Math.abs(sX-eX);
				
				var disY:int = Math.abs(sY-eY);
				
				return Math.sqrt(disX*disX+disY*disY);
			}
		}
		
		/**
		 * 计算F的估价值
		 *@param startPos 起始点
		 *@param adjacentTmp 当前三角形
		 *@return F值
		 **/
		public function contFValue(startPos:Vector2f,adjacentTmp:Cell):int{
			
			var result:int = 0;
			
			adjacentTmp.countPoint = startPos
			
			if(adjacentTmp==null) return result;
			
			var aF:int = countFValue(startPos,adjacentTmp.pointA);
			
			var bF:int = countFValue(startPos,adjacentTmp.pointB);
			
			var cF:int = countFValue(startPos,adjacentTmp.pointC);
			
			if(aF>bF){
				
				adjacentTmp.countPoint = adjacentTmp.pointB;
				
				result = bF;
				 
			}else {
				
				adjacentTmp.countPoint = adjacentTmp.pointA;
				
				result = aF;
			}
			
			if(result>cF){
				
				adjacentTmp.countPoint = adjacentTmp.pointC;
				
				result = cF;
			} 
			
			//g.drawCircle(adjacentTmp.countPoint.x,adjacentTmp.countPoint.y,4);
			//g.lineTo(adjacentTmp.countPoint.x,adjacentTmp.countPoint.y);
			return result;
		
		}
		
		/**
		 * 计算F的估价值
		 *@param startPos 起始点
		 *@param adjacentTmp 当前三角形
		 *@return F值
		 **/
		public function contFValue1(startPos:Vector2f,adjacentTmp:Cell,backPoint:Vector2f):int{
			
			var result:int = 0;
			
			var aF:int = countFValue(startPos,adjacentTmp.pointA);
			
			var bF:int = countFValue(startPos,adjacentTmp.pointB);
			
			var cF:int = countFValue(startPos,adjacentTmp.pointC);
			
			if(aF>bF){
				
				backPoint = adjacentTmp.pointB;
				 
				result = bF;
				 
			}else {
				
				backPoint = adjacentTmp.pointA;
				
				result = aF;
			}
			
			if(result>cF){

				backPoint = adjacentTmp.pointC;
				
				result = cF;
			} 
			
			//g.drawCircle(adjacentTmp.countPoint.x,adjacentTmp.countPoint.y,4);
			//g.lineTo(adjacentTmp.countPoint.x,adjacentTmp.countPoint.y);
			return result;
		
		}
		
		
		
		/**
		 * 构建路径
		 * @param startCell
		 * @param startPos
		 * @param endCell
		 * @param endPos
		 * @return Point路径数组
		 */		
		private var beginCell:Cell;
		public function buildPath(startCell:Cell, startPos:Vector2f, 
								  endCell:Cell, endPos:Vector2f):Array {
			openList.clear();
			closeList.length = 0;
			g.clear();
			g.lineStyle(8, 0x000000,0.3);
			
			//初始化上次计算估价值的终点为目标点
			endCell.countPoint = endPos;
			endCell.pathPointOne = new PathPoint(endPos,0,0,endCell,null);
			endCell.pathPointTwo = new PathPoint(endPos,0,0,endCell,null);
			openList.put(endCell.pathPointOne);
			endCell.f = 0;
			endCell.h = 0;
			endCell.isOpen = false;
			endCell.parent = null;
			endCell.sessionId = pathSessionId;
			beginCell = endCell;
			
			var foundPath:Boolean = false;		//是否找到路径
			var currNode:Cell;				//当前节点
			var adjacentTmp:Cell = null;	//当前节点的邻接三角型
			
			while (openList.size > 0) {
//				trace(openList.size);
				// 1. 把当前节点从开放列表删除, 加入到封闭列表
				var p:PathPoint = openList.pop()
				currNode = p.cell;
				closeList.push(p);
//				trace(openList.size);
//				trace("*****", currNode);
				
				//路径是在同一个三角形内
				if (currNode == startCell) {
					foundPath = true;
					break;
				}
				
				// 2. 对当前节点相邻的每一个节点依次执行以下步骤:
				//所有邻接三角型
//				trace(currNode, currNode.index, currNode.links);
				var adjacentId:int;
				for (var i:int=0; i<3; i++) {
					adjacentId = currNode.links[i];
					// 3. 如果该相邻节点不可通行或者该相邻节点已经在封闭列表中,
					//    则什么操作也不执行,继续检验下一个节点;
					if (adjacentId < 0) {						//不能通过
						continue;
					} else {
						adjacentTmp = m_CellVector[adjacentId];
						adjacentTmp.id = adjacentId;
						//trace('当前id' + adjacentId)
					}
					
					if (adjacentTmp != null) {
						if (adjacentTmp.sessionId != pathSessionId) {
							// 4. 如果该相邻节点不在开放列表中,则将该节点添加到开放列表中, 
							//    并将该相邻节点的父节点设为当前节点,同时保存该相邻节点的G和F值;
							adjacentTmp.sessionId = pathSessionId;
							adjacentTmp.parent = currNode;
							adjacentTmp.isOpen = true;					
							
//							adjacentTmp.f = currNode.f + adjacentTmp.m_WallDistance[Math.abs(i - currNode.m_ArrivalWall)];
							
							getPathPoint(currNode,adjacentTmp,startPos);
							//修改估价函数为起始点到顶点间最小的函数		
				//			adjacentTmp.f = currNode.f + contFValue(currNode.countPoint,adjacentTmp);
							
							//H和F值
				//			adjacentTmp.computeH(startPos,adjacentTmp.countPoint);
							
							
							//g.moveTo(currNode.countPoint.x,currNode.countPoint.y);
							//g.lineTo(adjacentTmp.countPoint.x,adjacentTmp.countPoint.y);
							//放入开放列表并排序
							openList.put(adjacentTmp.pathPointOne);
							openList.put(adjacentTmp.pathPointTwo);
							
							// remember the side this caller is entering from
							adjacentTmp.setAndGetArrivalWall(currNode.index);
						} else {
							// 5. 如果该相邻节点在开放列表中, 
							//    则判断若经由当前节点到达该相邻节点的G值是否小于原来保存的G值,
							//    若小于,则将该相邻节点的父节点设为当前节点,并重新设置该相邻节点的G和F值
							if (adjacentTmp.isOpen) {//已经在openList中
//							currNode.f + adjacentTmp.m_WallDistance[Math.abs(i - currNode.m_ArrivalWall)]

//								var curTmp = Cell(this.clone(adjacentTmp));
								/*var back:Vector2f = null;
								
								var result:int = contFValue1(currNode.countPoint,adjacentTmp,back);
								
								var curH = adjacentTmp.computeH(startPos,back);
								
								if (currNode.f +result+curH < adjacentTmp.f+adjacentTmp.h) {
									adjacentTmp.f = currNode.f;
									
									adjacentTmp.h = curH;
									adjacentTmp.parent = currNode;
									
									adjacentTmp.setAndGetArrivalWall(currNode.index);
								}*/
								var result1:PathPoint = setMinPoint(currNode.pathPointOne,adjacentTmp,startPos,1,true);
								var result2:PathPoint = setMinPoint(currNode.pathPointTwo,adjacentTmp,startPos,2,true);
								
								var r3:PathPoint = adjacentTmp.pathPointOne;
								var r4:PathPoint = adjacentTmp.pathPointTwo;
								var ary:Array = [result1,result2,r3,r4];
								//ary.push();
								ary.sortOn("f",Array.NUMERIC);
								
								adjacentTmp.pathPointOne = ary[0];
								adjacentTmp.pathPointTwo = ary[1];
								
								
							} else {//已在closeList中
								adjacentTmp = null;
								continue;
							}
						}
					}
				}
			}
			
			//由网格路径生成Point数组路径
			if (foundPath) {
//				trace(closeList);
				return getPath(startPos, endPos);
			} else {
				return null;
			}
		}
		public function getPathPoint(currNode:Cell,adjacentTmp:Cell,startPos:Vector2f):void{
			var first:Vector2f;
			var second:Vector2f;
			if(currNode == beginCell){
				for(var i:int=0;i<3;i++){
					for(var j:int=0;j<3;j++){
						if(currNode.getVertex(i).equal(adjacentTmp.getVertex(j))){
							if(first){
								second = adjacentTmp.getVertex(j);
								break;
							}else{
								first = adjacentTmp.getVertex(j);
							}
						}
					}
				}
				
				adjacentTmp.pathPointOne = new PathPoint(first,getDis(first,currNode.countPoint),
					getDis(first,startPos),adjacentTmp,currNode.pathPointOne);
				adjacentTmp.pathPointTwo = new PathPoint(second,getDis(second,currNode.countPoint),
					getDis(second,startPos),adjacentTmp,currNode.pathPointTwo);
				
			}else{
				setMinPoint(currNode.pathPointOne,adjacentTmp,startPos,1);
				setMinPoint(currNode.pathPointTwo,adjacentTmp,startPos,2);
			}
			
			
		}
		public function setMinPoint(currPoint:PathPoint,adjacentTmp:Cell,startPos:Vector2f,flag:int,compare:Boolean=false):PathPoint{
			var p:Vector2f = currPoint.p;
			
			var result:int = 0;
			var resultpaht:PathPoint;
			
			var aF:int = countFValue(p,adjacentTmp.pointA);
			var bF:int = countFValue(p,adjacentTmp.pointB);
			var cF:int = countFValue(p,adjacentTmp.pointC);
			
			
			if(aF>bF){
				if(bF > cF){
					//c
					resultpaht = new PathPoint(adjacentTmp.pointC,currPoint.g + cF,
						getDis(adjacentTmp.pointC,startPos),adjacentTmp,currPoint);
				}else{
					//b
					resultpaht = new PathPoint(adjacentTmp.pointB,currPoint.g + bF,
						getDis(adjacentTmp.pointB,startPos),adjacentTmp,currPoint);
				}
			}else {
				if(aF > cF){
					//c
					resultpaht = new PathPoint(adjacentTmp.pointC,currPoint.g + cF,
						getDis(adjacentTmp.pointC,startPos),adjacentTmp,currPoint);
				}else{
					//a
					resultpaht = new PathPoint(adjacentTmp.pointA,currPoint.g + aF,
						getDis(adjacentTmp.pointA,startPos),adjacentTmp,currPoint);
				}
			}
			if(!compare){
				if(flag == 1){
					adjacentTmp.pathPointOne = resultpaht;
				}else if(flag == 2){
					adjacentTmp.pathPointTwo = resultpaht;
				}
			}
			return resultpaht;
		}
		
		private function getDis(f:*,s:*):Number{
			var xx:Number = f.x-s.x;
			var yy:Number = f.y-s.y;
			return Math.sqrt(xx*xx+yy*yy);
		}
		
		private function resetCell():void{
			
		}
		/**
		 * 路径经过的网格
		 * @return 
		 */		
		private function getCellPath():Vector.<Cell> {
			var pth:Vector.<Cell> = new Vector.<Cell>();
			
			var p:PathPoint = closeList[closeList.length-1]
			var st:Cell = p.cell;
			pth.push(st);
						
			while (p.parent != null) {
//				trace("&&&&&", st.parent);
				
				/*this.graphics.beginFill(0x0000ff, 0.2);
				p.cell.draw(this.graphics);
				this.graphics.endFill();*/
				
				pth.push(p.parent.cell);
				p = p.parent;
			}
			
			/*this.graphics.beginFill(0x0000ff, 0.2);
			st.draw(this.graphics);
			this.graphics.endFill();
			
			trace(pth);*/
			return pth;
		}
		
		
		
		/**
		 * 根据经过的三角形返回路径点(下一个拐角点法)
		 * @param start 
		 * @param end 
		 * @return Point数组
		 */		
		private function getPath(start:Vector2f, end:Vector2f):Array {
			var timers:int = getTimer();
			var cellPath:Vector.<Cell> = getCellPath();
			//没有路径
			if (cellPath == null || cellPath.length == 0) {
				return null;
			}
			
			//保存最终的路径（Point数组）
			var pathArr:Array = new Array();
			
			//开始点
			pathArr.push(start.toPoint());	
			//起点与终点在同一三角形中
			if (cellPath.length == 1) {		
				pathArr.push(end.toPoint());	//结束点
				return pathArr;
			}
			
			//获取路点
			var wayPoint:WayPoint = new WayPoint(cellPath[0], start);
			while (!wayPoint.position.equals(end)) {
				wayPoint = this.getFurthestWayPoint(wayPoint, cellPath, end);
				changeCell(cellPath,wayPoint);
				pathArr.push(wayPoint.position);
			}
			trace("优化时间" + (getTimer() - timers))
			//			pathArr.push(end.toPoint());
			return pathArr;
			/*var cellPath:Vector.<Cell> = getCellPath();
			if (cellPath == null || cellPath.length == 0) {
				return null;
			}
			
			var pathArr:Array = new Array();
			var waypathArr:Array = new Array();
			
			pathArr.push(start.toPoint());	
			if (cellPath.length == 1) {		
				pathArr.push(end.toPoint());	//结束点
				return pathArr;
			}
			
			var wayPoint:WayPoint = new WayPoint(cellPath[0], start);
			wayPoint.active = true;
			waypathArr.push(wayPoint);
			while (true) {
				wayPoint = this.getFurthestWayPoint(wayPoint, cellPath, end);
				if(waypathArr[waypathArr.length-1].active){
					waypathArr.push(wayPoint);
				}else{
					fixedWayPoint(waypathArr[waypathArr.length-2],waypathArr[waypathArr.length-1],wayPoint,cellPath);
					wayPoint = waypathArr[waypathArr.length-1];
					wayPoint.active = true;
				}
				if(wayPoint.position.equals(end)){
					break;
				}
			}
			
			for(var i:int=0;i<waypathArr.length;i++){
				pathArr.push(waypathArr[i].position);
			}
			pathArr.push(end.toPoint());
			return pathArr;*/
		}
		public function changeCell(cellPath:Vector.<Cell>,wayPoint:WayPoint):void{
			for(var i:int=0;i<cellPath.length;i++){
				if(cellPath[i].pointA.x == wayPoint.position.x && cellPath[i].pointA.y == wayPoint.position.y ){
					wayPoint.cell = cellPath[i+1];
					return;
				}
				if(cellPath[i].pointB.x == wayPoint.position.x && cellPath[i].pointB.y == wayPoint.position.y ){
					wayPoint.cell = cellPath[i+1];
					return;
				}
				if(cellPath[i].pointC.x == wayPoint.position.x && cellPath[i].pointC.y == wayPoint.position.y ){
					wayPoint.cell = cellPath[i+1];
					return;
				}
			}
		}
		private function fixedWayPoint(first:WayPoint,second:WayPoint,third:WayPoint,cellPath:Vector.<Cell>):void{
			var line1:Vector2f = new Vector2f(second.position.x - first.position.x,second.position.y - first.position.y).normalize();
			trace("____________",line1.x,line1.y)
			var line2:Vector2f = new Vector2f(second.position.x - third.position.x,second.position.y - third.position.y).normalize();
			trace("____________",line2.x,line2.y)
			second.position = second.position.add(line1.add(line2).normalize().mult(50));
			second.cell = findCell(second.position,cellPath);
		}
		public function findCell(pt:Vector2f,cellPath:Vector.<Cell>):Cell {
			for each (var pCell:Cell in cellPath) {
				if (pCell.isPointIn(pt)) {
					return pCell;
				}
			}
			return null;
		}
		private function getHalfAngle(p1:WayPoint,p2:WayPoint,p3:WayPoint):void{
			
		}
		/**
		 * 下一个拐点
		 * @param wayPoint 当前所在路点
		 * @param cellPath 网格路径
		 * @param end 终点
		 * @return 
		 */		
		private function getFurthestWayPoint(wayPoint:WayPoint, cellPath:Vector.<Cell>, end:Vector2f):WayPoint {
			var startPt:Vector2f = wayPoint.position;	//当前所在路径点
			var cell:Cell = wayPoint.cell;
			var lastCell:Cell = cell;
			var startIndex:int = cellPath.indexOf(cell);	//开始路点所在的网格索引
			var outSide:Line2D = cell.sides[cell.m_ArrivalWall];	//路径线在网格中的穿出边
			var lastPtA:Vector2f = outSide.getPointA();
			var lastPtB:Vector2f = outSide.getPointB();
			var lastLineA:Line2D = new Line2D(startPt, lastPtA);
			var lastLineB:Line2D = new Line2D(startPt, lastPtB);
			var testPtA:Vector2f, testPtB:Vector2f;		//要测试的点
			for (var i:int=startIndex+1; i<cellPath.length; i++) {
				cell = cellPath[i];
				outSide = cell.sides[cell.m_ArrivalWall];
				if (i == cellPath.length-1) {
					testPtA = end;
					testPtB = end;
				} else {
					testPtA = outSide.getPointA();
					testPtB = outSide.getPointB(); 
					//var nomor:Vector2f = testPtB.subtract(testPtA).normalize().mult(10);
					//testPtA = testPtA.add(nomor);
					//testPtB = testPtB.subtract(nomor);
				}
				
				if (!lastPtA.equals(testPtA)) {
					if (lastLineB.classifyPoint(testPtA, EPSILON) == PointClassification.RIGHT_SIDE) {
						//路点
						//return new WayPoint(lastCell, lastLineB.signedDistanceAdd(lastPtB,false));
						return new WayPoint(lastCell, lastPtB);
					} else {
						if (lastLineA.classifyPoint(testPtA, EPSILON) != PointClassification.LEFT_SIDE) {
							lastPtA = testPtA;
							lastCell = cell;
							//重设直线
							lastLineA.setPointB(lastPtA);
//							lastLineB.setPointB(lastPtB);
						}
					}
				}
				
				if (!lastPtB.equals(testPtB)) { 
					if (lastLineA.classifyPoint(testPtB, EPSILON) == PointClassification.LEFT_SIDE) {
						//路径点
						//return new WayPoint(lastCell, lastLineA.signedDistanceAdd(lastPtA,true));
						return new WayPoint(lastCell, lastPtA);
					} else {
						if (lastLineB.classifyPoint(testPtB, EPSILON) != PointClassification.RIGHT_SIDE) {
							lastPtB = testPtB;
							lastCell = cell;
							//重设直线
//							lastLineA.setPointB(lastPtA);
							lastLineB.setPointB(lastPtB);
						}
					}
				}
			}
			return new WayPoint(cellPath[cellPath.length-1], end);	//终点
		}
		public function resortPoint(beginPoint:Vector2f,endPoint:Vector2f,middleList:Array):void{
			var flagX:int = endPoint.x - beginPoint.x;
			var flagY:int = endPoint.y - beginPoint.y;
			var sortFlag:Object;
			if(flagX == 0){
				if(flagY > 0){
					sortFlag = Array.NUMERIC;
				}else{
					sortFlag = Array.DESCENDING | Array.NUMERIC;
				}
				middleList.sortOn("y",sortFlag);
			}else{
				if(flagX > 0){
					sortFlag = Array.NUMERIC;
				}else{
					sortFlag = Array.DESCENDING | Array.NUMERIC;
				}
				middleList.sortOn("x",sortFlag);
			}
		}
		public function clone(source:Object):*
            {
                registerClassAlias("org.blch.findPath::Cell",Cell);
                var myBA:ByteArray = new ByteArray();
                myBA.writeObject(source);
                myBA.position = 0;
                return(myBA.readObject());
            } 

		
//		/**
//		 * 射线法
//		 * @param start
//		 * @param end
//		 * @return 
//		 */		
//		private function getPath(start:Vector2f, end:Vector2f):Array {
//			var pathArr:Array = new Array();
//			var cellPath:Vector.<Cell> = getCellPath();
//			//没有路径
//			if (cellPath == null || cellPath.length == 0) {
//				return null;
//			}
//			
//			//开始点
//			pathArr.push(start.toPoint());	
//			
//			if (cellPath.length == 1) {		//起点与终点在同一三角形中
//				pathArr.push(end.toPoint());	//结束点
//				return pathArr;
//			}
//			trace("ssss", start, end);
//			
//			var wayPoint:WayPoint = new WayPoint(cellPath[0], start);
//			while (true) {
//				trace("wayPoint.position", wayPoint.position);
//				wayPoint = this.getFurthestWayPoint(wayPoint, cellPath, start, end);
//				pathArr.push(wayPoint.position.toPoint());
//				trace("====", wayPoint.position, end);
//if (wayPoint.position.equals(end)) {
//	break;
//}
//			}
//			
////			pathArr.push(end.toPoint());
//			return pathArr;
//		}
//		
//		// : GetFurthestVisibleWayPoint
//		// ----------------------------------------------------------------------------------------
//		//
//		// Find the furthest visible waypoint from the VantagePoint provided. This
//		// is used to
//		// smooth out irregular paths.
//		//
//		// -------------------------------------------------------------------------------------://
////		private var nextWayCellIndex:Cell;
//		public function getFurthestWayPoint(currWayPoint:WayPoint, cellPath:Vector.<Cell>,
//											start:Vector2f, end:Vector2f):WayPoint {
//			if (currWayPoint.cell == cellPath[cellPath.length-1]) {
//				return new WayPoint(cellPath[cellPath.length-1], end);
//			}
//
//			var i:int = cellPath.indexOf(currWayPoint.cell);
//			
////			var visibleWaypoint:WayPoint = currWayPoint;
////			var visibleCell:Cell = visibleWaypoint.cell;
////			var visiblePosition:Vector2f = visibleWaypoint.position;
//			var testCell:Cell = cellPath[++i];
//			var testPosition:Vector2f;
//			while (true) {
//				trace("getFurthestWayPoint", i);
//				if (i == cellPath.length-1) {
//					testPosition = end;
//				} else {
//					testPosition = testCell.m_WallMidpoint[testCell.m_ArrivalWall];
//				}
//				
//				if (!lineOfSightTest(currWayPoint.cell, currWayPoint.position, testPosition)) {
//					//				System.out.println(" WAY IND was:" + i);
//					if (start.equals(currWayPoint.position)) {
//						return new WayPoint(currWayPoint.cell, currWayPoint.cell.m_WallMidpoint[currWayPoint.cell.m_ArrivalWall]);
//					} else {
//						return new WayPoint(testCell, testPosition);
//					}
//				}
////				visibleCell = testCell;
////				visiblePosition = testPosition;
//				
//				if (i == cellPath.length-1) {
//					break;
//				}
//				testCell = cellPath[++i];
//			}
//			//		System.out.println(" WAY IND was:" + i);
//			// the last
//			return new WayPoint(testCell, testPosition);
//		}
//		
//		// : LineOfSightTest
//		// ----------------------------------------------------------------------------------------
//		//
//		// Test to see if two points on the mesh can view each other
//		//
//		// -------------------------------------------------------------------------------------://
//		// FIXME EndCell is the last visible cell?
//		private function lineOfSightTest(startCell:Cell, startPos:Vector2f, endPos:Vector2f):Boolean {
//			var motionPath:Line2D = new Line2D(startPos, endPos);
//			
////			var testCell:Cell = startCell;
//			var result:ClassifyResult = startCell.classifyPathToCell(motionPath);
//			while (result.result == PathResult.EXITING_CELL) {
//				trace("lineOfSightTest", result.cellIndex);
//				if (result.cellIndex == -1)// hit a wall, so the point is not visible
//					return false;
//				result = m_CellVector[result.cellIndex].classifyPathToCell(motionPath);
//			}
//			
//			return (result.result == PathResult.ENDING_CELL);
////			return result;
//		}
	}
}