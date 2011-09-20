package util
{
	import flash.geom.Point;
	public class Util
	{	  
		private static const tileWidth:int = 64;
		private static const tileHeight:int = 32;
		private static const htileWidth:int = 32;
		private static const htileHeight:int = 16;
		private static const htileArea:int = 512;//优化 tileWidth = 64 tileHeight = 32 /4 = 512
		public static function getPixelPoint(tx:int, ty:int):Point
		{
			//偶数行tile中心
			var tileCenter:int = (tx * tileWidth) + htileWidth;
			// x象素  如果为奇数行加半个宽
			var xPixel:int = tileCenter + (ty&1) * htileWidth;
			
			// y象素
			var yPixel:int = (ty + 1) * htileHeight;
			
			return new Point(xPixel, yPixel);
		}
		
		public static function getTilePoint(px:int, py:int):Point
		{
			var xtile:int = 0;	//网格的x坐标
			var ytile:int = 0;	//网格的y坐标
	
	        var cx:int, cy:int, rx:int, ry:int;
	        cx = ((px / tileWidth)>>0) * tileWidth + htileWidth;	//计算出当前X所在的以tileWidth为宽的矩形的中心的X坐标
	        cy = ((py / tileHeight)>>0) * tileHeight + htileHeight;//计算出当前Y所在的以tileHeight为高的矩形的中心的Y坐标
	
	        rx = (px - cx) * htileHeight;
	        ry = (py - cy) * htileWidth;
	 
	        var temp:int = (rx<0?rx*-1:rx)+(ry<0?ry*-1:ry);
	        if ( temp<= htileArea) 
	        {
				xtile = (px / tileWidth)>>0;
				ytile = ((py / tileHeight)>>0)*2;
	        }
	        else
	        {
				px = px - htileWidth;
				xtile = ((px / tileWidth)>>0) + 1;
				
				py = py - htileHeight;
				ytile = ((py / tileHeight)>>0)*2 +1;
			}

			return new Point(xtile - (ytile&1), ytile); 
		}
		
	}
}