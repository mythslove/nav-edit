package com.util
{
	import com.res.ResManager;
	import com.res.ResVO;
	
	import flash.display.DisplayObject;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	/***
	 * 文件处理类
	 * 
	 * */
	public class SystemFile
	{
		private var file:File;
		private var resArr:ArrayCollection;
		private var imagesFilter:FileFilter = new FileFilter("swf", "*.swf");
		private var _x:int = 0;
		private var _y:int = 0;
		private var keyArr:Array;
		public function SystemFile(arr:ArrayCollection)
		{
			//file = new File;
			resArr = arr;
			file = File.documentsDirectory;
		}
		public function leadInFile(arr:Array=null):void
		{
			keyArr = arr;
	 		file.browseForOpenMultiple("选择资源",[imagesFilter]);
	 		file.addEventListener(FileListEvent.SELECT_MULTIPLE,selectPic);
		}
		private function selectPic(e:FileListEvent):void
		{
			var fa:Array = e.files;
			for each (var _file:File in fa)
			{	
				var picName:String = getName(_file.nativePath);		 
				
				ResManager.getInstance().loadRes({url:_file.nativePath,fun:resSuccess,type:ResManager.SWF_RES,level:1});
				    
				_file.copyTo(file.resolvePath("map/res/"+picName),true); //将文件复制
			}     
		}
		public function initFile(arr:Array):void
		{
			for each(var obj:Object in arr)
			{
				if(obj.nativePath.indexOf(".swf")!=-1)
				{	
					ResManager.getInstance().loadRes({url:obj.nativePath,fun:resSuccess,type:ResManager.EFFECT_RES,level:1,
						symbol:"state",params:{picName:getName(obj.nativePath)}});
				}
			}
		}
		private function getName(url:String):String
		{
			var arr:Array = url.split("\\");
			return arr[arr.length-1];
		}
		private function resSuccess(resVo:ResVO):void
		{
			 /*resload.removeEventListener(LoadEvent.load_success,resSuccess);
			 resArr.source = resArr.source.concat(e.movieArr);
			 resArr.refresh();*/
			Application.application.resContain.addRes(resVo.graphicObj,resVo.params.picName);
		}
		public function delFile(str:String):void
		{
			var l:int = resArr.length;
			for(var i:int=0;i<l;i++)
			{
				if(resArr[i].name == str)
				{
				   resArr.removeItemAt(i);
				   break;
				}
			}
			resArr.refresh();
		}
	}
}