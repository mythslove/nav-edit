package util
{
	import cmodule.aircall.CLibInit;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
		    
	public class PicIncise extends EventDispatcher
	{
		private var ui:UIComponent
		private var sWidth:int;
		private var sHeight:int;
		private var maps:Array;
		private var loader:Loader;
		private var savePath:String;
		private var fileName:String;
		
		public var sStep:int;
		public var length:int;
		public var mapWidth:int;
		public var mapHeight:int;
		
		
		
		public function PicIncise()
		{
			maps = new Array;
		}
		public function cutPic(url:String,width:int,height:int,savePath:String,fileName:String):void
		{	
			this.sWidth   = width;
			this.sHeight  = height;
			this.savePath = savePath;
			this.fileName = fileName;
			
		    loader = new Loader;
		    loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
		    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,completeHandler);
		    
		    loader.load(new URLRequest(url));
		    
		 } 
		 
		/**
       * 
       * 加载图片完成处理
       * */
        private function completeHandler(e:Event):void 
        {
           var sBmd:BitmapData = Bitmap(e.target.content).bitmapData;
           
            this.mapWidth = loader.width;
            this.mapHeight = loader.height;
            
            sStep  = Math.ceil(loader.width/sWidth);   
            length = Math.ceil(loader.height/sHeight);
            
            for (var j:int = 0; j<length; j++) 
            {
                var arr:Array = new Array();
                for (var i:int = 0; i<sStep; i++) 
                {
                    var bmd:BitmapData = new BitmapData(sWidth,sHeight,true,0xFFFFFFFF);             
                    bmd.copyPixels(sBmd,new Rectangle(sWidth*i, sHeight*j, sWidth, sHeight),new Point(0,0)); 
                   /*  ma.tx = -sWidth*i;
                    ma.ty = -sHeight*j;
                    bmd.draw(sBmd,ma,null, null, null, false); */
                    
                    
                    arr.push(bmd);
                }
                maps.push(arr);
            }
           // sBmd.dispose();
	        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
	        //e.target.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	        loader = null;
	        save();
	        savemapdata();
        }
		private function savemapdata():void{
			var file:File = File.documentsDirectory.resolvePath(savePath + "/" + this.fileName + ".mapedit");
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.WRITE);
			var pointData:String = "0,0|"+ this.mapWidth + ",0|"
									+this.mapWidth + "," + this.mapHeight + "|0," + this.mapHeight;
			var str:String = "<map name='" + this.fileName + "' mapwidth='" + 
				this.mapWidth + "' mapheight='" + this.mapHeight + "' picw='" + 
				this.sWidth + "' pich='" + this.sHeight + "' mapdata='" + pointData + "'/>"
			fs.writeUTFBytes(str);
			fs.close();
		}
		  private function save():void
		  {
		  	 var t1:int = getTimer();
			 var file:File = File.documentsDirectory.resolvePath(savePath + "/images");
			 file.createDirectory();
			 /// init alchemy object
			var jpeginit:CLibInit = new CLibInit(); // get library
			var jpeglib:Object = jpeginit.init(); 
			var imgEncoded:ByteArray = new ByteArray();
			var ba:ByteArray ;
			 for(var i:int = 0;i<length;i++)
			 {
			 	for(var j:int = 0;j<sStep;j++)
			 	{
			 		 var picName:String = i+'_'+j+".jpg";
					 var _file:File = file.resolvePath(picName);
						
					 ba = maps[i][j].getPixels( maps[i][j].rect);
					 ba.position = 0;
					 
                     jpeglib.encode(ba, imgEncoded, maps[i][j].width, maps[i][j].height,90);
					
					 var filestream:FileStream = new FileStream;
					 filestream.open(_file, FileMode.WRITE);
					 filestream.writeBytes(imgEncoded);
				 }
			 }
			 this.dispatchEvent(new Event("success"));
			 trace("保存文件时间:"+(getTimer()-t1));
		   }
		   private function encodeComplete():void
		   {
               trace("Encoding complete");
           }

	}
}