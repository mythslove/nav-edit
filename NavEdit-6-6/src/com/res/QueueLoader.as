package com.res
{	
	
	import com.res.Pool.ObjectPool;
	
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.core.Application;
	
	/**
	 * 队列加载
	 *   1.加载png，jpg，swf
	 *   2.加载二进制文件
	 * 
	 * */
	public class QueueLoader extends EventDispatcher
	{
		//设置加载器个数
		private const maxNum:int = 4;
		//保存所有待加载的物品
		private var loaderArr:Array;
		//保存正在加载的物品
		private var loading_objArr:Array;
		//保存正在加载的加载器
		private var loading_loaderArr:Array;
		//加载重复次数
		private const repeat:int = 1;
		private var currentTime:int = 0;
		private var level:int;
		private var download_Arr:Array;
		private var url:URLRequest;

		public var showProgress:Boolean;
		
		public function QueueLoader()
		{
			loaderArr   	  = [];
			loading_objArr    = [];
            download_Arr	  = [];
            loading_loaderArr = [];
			url = new URLRequest();
			
			for(var i:int=0;i<maxNum;i++)
			{
				var down_load:SingleLoaderBase = new SingleLoaderBase();
				down_load.addEventListener(Event.COMPLETE,complete);
				down_load.addEventListener(IOErrorEvent.IO_ERROR,ioerror);
				down_load.addEventListener(ProgressEvent.PROGRESS,progress);
				download_Arr[download_Arr.length] = down_load;
			}
		}
		public function init():void
		{
			loaderArr.length = 0;
			loading_objArr.length = 0;
			for(var i:int=0;i<loading_loaderArr.length;i++)
			{
				//从正在加载列表中去除已加载的对象
				var down_load:SingleLoaderBase = SingleLoaderBase(loading_loaderArr[i]);
				if(down_load.connected)
					down_load.close();
				download_Arr[download_Arr.length] = down_load;
			}
			loading_loaderArr.length = 0;
		}
		/**
		 *  增加加载对象
		 *    
		 * */
		public function addLoad(obj:Object):void
		{
			
			if(!hasObject(obj.url))
			{
				//////////////采用二叉堆进行排序优化
				add(obj,loaderArr);
			}
		}
		/**
		 * 二叉堆，增加元素 
		 * @param target 增加的对象
		 * @param two    二叉堆数组
		 * 
		 */		
		private function add(target:Object,two:Array):void
		{
			var index:int = two.length;
			var temp:Object;
			var parent:int;
			two[index] = target;
					
			while(true)
			{	
				parent = index*.5;

				if(two[parent].level<two[index].level)
				{
				     temp = two[parent];
					 two[parent] = two[index];
					 two[index] = temp;
					 index = parent;	
				}
				else
				   break;
				if(parent==0)
					break;
			  }
			}
			/**
			 * 二叉堆中取出根对象 
			 * @param two  二叉堆数组
			 * @return    跟对象
			 * 
			 */			
			private function remove(two:Array):Object
			{
				    if(two.length==1) return two.pop();
					var index:int=0;
					var obj:Object = two[index];
					two[index] = two.pop();
					var child1:int = (index+1)*2-1; 
					var child2:int;
					var child:int;
					var temp:Object;
					while(two[child1]!=null)
					{	
							child2 = child1+1;
							if(two[child2]!=null)
							{
								if(two[child1].level<two[child2].level)
								    child = child2;   
								 else
								     child = child1;    
							}
							else
							   child = child1;
							
							
							if(two[child].level>two[index].level)
							{
							    temp = two[child];
								two[child] = two[index];
								two[index] = temp;
								index = child;	
								child1 = (index+1)*2-1; 
							}
							else 
							  break;
					}
					return obj;
			}
			/**
			 *修改二叉堆元素 
			 * @param index 该对象所在数组的索引
			 * @param target 需要修改的对象
			 * @param two   二叉堆数组
			 * 
			 */			
			private function edit(index:int,target:Object,two:Array):void
			{
					var temp:Object;
					var parent:int;
					two[index] = target;
					
					while(true)
					{	
						parent = index*.5;

						if(two[parent].level<two[index].level)
						{
						    temp = two[parent];
							two[parent] = two[index];
							two[index] = temp;
							index = parent;	
						}
						else
						  break;
						 if(parent==0)
						  break;
					}
			}
		/**
		 * 检测是否在加载列表中
		 * */
		private function hasObject(url:String):Boolean
		{
			for each(var obj:Object in loaderArr)
			{
				if(obj.url==url)
				return true;
			}
			for each(var _obj:Object in loading_objArr)
			{
				if(_obj.url==url)
				return true;
			}
			return false;
		}
		/**
		 * 启动加载
		 * */
		public function load():void
		{
			var tempObj:Object;
			var down_load:SingleLoaderBase;
			if(download_Arr.length>0&&loaderArr.length>0)
			{
				//tempObj = loaderArr.shift();
				tempObj = remove(loaderArr);

	            down_load = download_Arr.pop();
	            down_load.info = tempObj;
	            url.url = tempObj.url;
			    down_load.load(url);
			    loading_objArr[loading_objArr.length] 		= tempObj;
			    loading_loaderArr[loading_loaderArr.length] = down_load;

			}
		}
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function ioerror(e:IOErrorEvent):void
		{
			trace("QueueLoader队列加载类出错"+e.toString());
			repeatLoad(SingleLoaderBase(e.target));
		}
		/**
		 * 多次加载
		 * */
		private function repeatLoad(down_load:SingleLoaderBase):void
		{
			//重复加载
			if(currentTime<repeat)
			{
				url.url = down_load.info.url;
				down_load.load(url);
				currentTime++;
			}
			//否则加载下一个
			else
			{
				//从正在加载列表中去除已加载的对象
				loading_objArr.splice(loaderArr.indexOf(down_load.info),1);
				loading_loaderArr.splice(loading_loaderArr.indexOf(down_load),1);
				download_Arr[download_Arr.length] = down_load;
				currentTime = 0;
				load();
			}
		}
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function progress(e:ProgressEvent):void
		{
			//trace("正在加载..");
			if(showProgress)
			{
				//var down_load:SingleLoaderBase = SingleLoaderBase(e.target);
				//var rate:Number = e.bytesLoaded/e.bytesTotal;
			  //  LoadInterface.Instance.setLoading(rate);
			    //LoadInterface.Instance.setResName(down_load.info.url);
			}
		}
		/**
		 * 二进制加载完成开始分类处理
		 * 
		 * */
		private function complete(e:Event):void
		{	
			var bytes:ByteArray = new ByteArray;
			var down_load:SingleLoaderBase = SingleLoaderBase(e.target);
			if(down_load.connected)
			{
				down_load.readBytes(bytes,0,bytes.bytesAvailable);
				down_load.close();
			}
			loading_loaderArr.splice(loading_loaderArr.indexOf(down_load),1);
			download_Arr[download_Arr.length] = down_load;
			//为二进制文件直接返回字节码
			if(down_load.info.type==ResManager.BINTARY_RES)
			{
				//从正在加载列表中去除已加载的对象
				loading_objArr.splice(loading_objArr.indexOf(down_load.info),1);
				//派发加载成功
				var evt:QueueEvent = new QueueEvent(QueueEvent.LOAD_SUCCESS_EVENT);	    
				evt.completeObject = {url:down_load.info.url,type:down_load.info.type,obj:bytes,fun:down_load.info.fun};
				this.dispatchEvent(evt);				
				
				load();
			}
			//其他类型继续加载实体
			else
			{
				//bytes
				//encode(bytes);
				loadPic(bytes,down_load.info);		
			}	
		}
		/**
		 * 加载swf，png，jpg
		 * */
		private function loadPic(bytes:ByteArray,info:Object):void
		{
			var load:SingleLoader = ObjectPool.getObject(SingleLoader);
			load.info = info;
			
			var loaderContext:LoaderContext = new LoaderContext(); 
			loaderContext.allowLoadBytesCodeExecution = true; 
			load.contentLoaderInfo.addEventListener(Event.COMPLETE,picComplete);
			load.loadBytes(bytes,loaderContext);
		}
		private function picComplete(e:Event):void
		{
		     e.target.removeEventListener(Event.COMPLETE,picComplete);
		     
		     var down_load:SingleLoader = e.target.loader;
		     
		    var _obj:Object;
			if(down_load.info.type==ResManager.MOVIE_RES||
			   down_load.info.type==ResManager.EFFECT_RES||
			   down_load.info.type==ResManager.MASTER_RES) //影片剪辑返回一个clas
			{
				var app:ApplicationDomain =  LoaderInfo(e.currentTarget).applicationDomain;
				if(app.hasDefinition("state"))
					_obj = app.getDefinition("state") as Class;
			}
			else if(down_load.info.type==ResManager.SWF_RES) //返回movieclip
			{
				_obj = e.target.content as MovieClip;
			}
			else
			{
				_obj = e.target.content;
			}
			//从正在加载列表中去除已加载的对象
			loading_objArr.splice(loading_objArr.indexOf(down_load.info),1);
			//派发加载成功
			var evt:QueueEvent = new QueueEvent(QueueEvent.LOAD_SUCCESS_EVENT);	    
			evt.completeObject = {url:down_load.info.url,type:down_load.info.type,obj:_obj,fun:down_load.info.fun};
			this.dispatchEvent(evt);
			
			down_load.info = null;
			down_load.unload();
			ObjectPool.disposeObject(down_load,SingleLoader);
			
		    load();
		}
		/**
		 * 获取swf中所有元件 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public function getSymbolName(bytes:ByteArray):Array
		{
			var arr:Array = [];
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position=Math.ceil(((bytes[8]>>>3)*4+5)/8)+12;
			while(bytes.bytesAvailable>2)
			{
				var head:int=bytes.readUnsignedShort();
				var size:int=head&63;
				if (size==63)
					size=bytes.readInt();
				if (head>>6!=76)
					bytes.position+=size;
				else 
				{
					head=bytes.readShort();
					for(var i:int=0;i<head;i++)
					{
						bytes.readShort();
						size=bytes.position;
						while(bytes.readByte()!=0);
						size=bytes.position-(bytes.position=size);
						arr.push(bytes.readUTFBytes(size));
					}
				}
			}
			return arr;
		}
	}
}