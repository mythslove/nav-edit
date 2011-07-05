package com.background
{
	/**
	 * 生成背景层
	 * */

	import com.res.ResManager;
	import com.res.ResVO;
	
	import flash.display.Bitmap;
	
	import mx.core.UIComponent;
	
	public class BackgroundLayer extends UIComponent
	{
		private var _bitmap:Bitmap;
		public var _w:int;
		public var _h:int;
		private var spW:int;
		private var spH:int;
		//private var path:String;
		public function BackgroundLayer()
		{
			super();
		}
		/***
		 * param w:图片x轴方向图片数
		 * param h:图片y轴方向图片数
		 * param spW:每块小图片宽度
		 * param spH:每块小图片的高度
		 * param str:图片路径
		 * */
		public function createBackground(w:int,h:int,spW:int,spH:int,str:String):void
		{
			this.spW = spW;
			this.spH = spH;
			_w = w;
			_h = h;
			loadPic(str);
		}
		 /**
		 *  加载背景图
		 * */
		 private function loadPic(path:String):void
		 {
		 	var index:int = 0;
		 	for(var j:int = 0;j<_w;j++)
		 	{
		 	  for(var i:int = 0;i<_h;i++)
		 	  {
		 	     /*var resload:ResLoad = new ResLoad();
		 	     resload._x = j*spW;
		 	     resload._y = i*spH;
		 	     resload.loadPic(path+"/"+i+'_'+j+".jpg");
		 	     resload.addEventListener(LoadEvent.load_success,complete);*/
				  ResManager.getInstance().loadRes({url:path+"/"+i+'_'+j+".jpg",fun:complete,type:ResManager.OTHER_RES,level:1,
					  params:{x:j*spW,y:i*spH}});
		 	  }
		 	}
		 }
		 private function complete(res:ResVO):void
		 {
			 var bmp:Bitmap = Bitmap(res.graphicObj);
			 bmp.x = res.params.x;
			 bmp.y = res.params.y;
		 	this.addChild(bmp);
		 }
	}
}