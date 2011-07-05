package com.res
{	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/***
	 * 资源管理类
	 *    示例:
	 *       ResManager.getInstance().loadRes({url:url,fun:xmlComplete,type:ResManager.BINTARY_RES,level:1,
	 *                                         symbol:xx,params:object});
	 * 
	 *       function xmlComplete(resVo:ResVo)
	 *       {
	 *             //处理。。。
	 *       }
	 *     当加载的资源为movieclip时请加上他的symbol标识名，其他情况下不加
	 *     每个回调函数里面只能带一个参数，比如你需要加载的类型，如bitmapdata，
	 *     class（当加载的是symoble标识的movielcip时），movieclip，bytearry
	 *    params为你可以带的参数
	 *     接受的参数必须为ResVo
	 * 
	 * */
	public class ResManager
	{	
		//资源库
        private  var res_list:Hash;
        //地图资源库
        private  var map_list:Hash;
        //效果资源库
        private var effect_list:Hash;       
        //将要加载的所有物品
        private var res_Arr:Array;
	    	    
	    //资源类型
	    public static const MAP_RES:String   = "MAP_RES";
	    public static const ROLE_RES:String  = "ROLE_RES";
	    public static const OTHER_RES:String = "OTHER_RES";
	    //swf
	    public static const SWF_RES:String   = "SWF_RES";
	    //影片剪辑
	    public static const MOVIE_RES:String = "MOVIE_RES";
	    //加载二进制资源
	    public static const BINTARY_RES:String = "BINTARY_RES";
	    //效果
	    public static const EFFECT_RES:String = "EFFECT_RES";
	    //野怪
	    public static const MASTER_RES:String = "MASTER_RES";
	    
	    private static var Instance:ResManager = new ResManager;
	    private  var queue_loader:QueueLoader;
	    private var resVo:ResVO;
	    
	    public function showProgress(b:Boolean):void
	    {
	    	queue_loader.showProgress = b;
	    }
	    
	    public static function getInstance():ResManager
	    {
	    	return Instance;
	    }
		public  function init():void
		{
			queue_loader = new QueueLoader();
			res_list = new Hash();
       		map_list = new Hash();
       		effect_list = new Hash();
       		res_Arr    = [];
       		resVo = new ResVO();
       		
       		queue_loader.addEventListener(QueueEvent.LOAD_SUCCESS_EVENT,resComplete);
		}
		public function ResManager()
		{
            init();
		}
		/** 
		 * 加载资源 obj{url:url,fun:function,type:type,level:int}
		 *         level为优先级程度，值越大越能保证加载成功，10为最高等级
		 * res_list:obj["url"]=bitmapdata
		 * */
		public  function loadRes(obj:Object):void
		{
		   if(!checkRes(obj))
		   {
				_load(queue_loader,obj);
		   } 
		}
		/***
		 * 开始启用队列加载
		 * */
		private function _load(load:QueueLoader,obj:Object):void
		{
			load.addLoad(obj);
			load.load();
		}
		/***
		 * 监听队列加载完成
		 * 
		 * */
		private  function resComplete(e:QueueEvent):void
		{
			
			var res_obj:Object = null;
			switch(e.completeObject.type)
			{
				case MAP_RES:
				        res_obj = Bitmap(e.completeObject.obj).bitmapData;
						map_list.put(e.completeObject.obj,e.completeObject.url);
						//地图刷新，特殊
						var l:int = res_Arr.length;
						for(var i:int = 0;i<l;i++)
						{
							 var _obj:Object = res_Arr[i];
							 if(_obj.url == e.completeObject.url)
							 {
							 	resVo.graphicObj = res_obj;
								resVo.params = _obj.params;
								e.completeObject.fun(resVo);
								e.completeObject.fun = null;
								res_Arr.splice(i,1);
								break ;
							 }
						}
						return ;
				break;
				case ROLE_RES:
						res_list.put(e.completeObject.obj,e.completeObject.url);
						res_obj = e.completeObject.obj.bitmapData;
				break;
				case SWF_RES:
					 res_obj = e.completeObject.obj;
				break;
				case BINTARY_RES:
				      res_obj = e.completeObject.obj;
					/////二进制文件未保存，可以修改为保存
					
					////////////////////////////
				break;
				case MOVIE_RES:
				     res_list.put(e.completeObject.obj,e.completeObject.url);
				     res_obj = e.completeObject.obj;
				break;
				case EFFECT_RES:
						effect_list.put(e.completeObject.obj,e.completeObject.url);
						res_obj = e.completeObject.obj;
				break;
				case MASTER_RES:
						//effect_list.put(e.completeObject.obj,e.completeObject.url);
						map_list.put(e.completeObject.obj,e.completeObject.url);
						res_obj = e.completeObject.obj;
				break;
				default:
				       res_obj = e.completeObject.obj; 
			}
			
			/**
			* 加载完成一个图片后刷新所有需要
			* 相同资源的对象
		    * */
			var str:String = e.completeObject.url;
			if(res_obj)
			{
				 var index:int = res_Arr.length-1;
				 while(index>-1)
				{
					 var _obj:Object = res_Arr[index];
					 if(_obj.url == str)
					 {
						resVo.graphicObj = res_obj;
						resVo.params = _obj.params;
						_obj.fun(resVo);
						_obj.fun = null;
						res_Arr.splice(index,1);
					 }
					index--; 
				}
			}
		}
		/**
		 *  验证资源是否存在 obj{url:url,fun:function,type:type}
		 * 不存在则加入加载列表
		 * */
		public  function checkRes(obj:Object):Boolean
		{
			if(obj.type==MAP_RES)
			{
				 if(map_list.has(obj.url))
				{
					resVo.graphicObj = Bitmap(map_list.take(obj.url)).bitmapData;
					resVo.params = obj.params;
					obj.fun(resVo);
					obj.fun = null;
					return true;
				}
			}
			else if(obj.type==MASTER_RES)
			{
				if(map_list.has(obj.url))
				{
					resVo.graphicObj = map_list.take(obj.url);
					resVo.params = obj.params;
					obj.fun(resVo);
					obj.fun = null;
					return true;
				}
			}
			else if(obj.type==ROLE_RES)
			{
				 if(res_list.has(obj.url))
				{
					resVo.graphicObj = Bitmap(res_list.take(obj.url)).bitmapData;
					resVo.params = obj.params;
					obj.fun(resVo);
					obj.fun = null;
					return true;
				}
			}
			else if(obj.type==SWF_RES)
			{
				 if(map_list.has(obj.url))
				 {
					resVo.graphicObj = Sprite(res_list.take(obj.url));
					resVo.params = obj.params;
					obj.fun(resVo);
					obj.fun = null;
					return true;
				 }
			}
			else if(obj.type==EFFECT_RES)
			{
				if(effect_list.has(obj.url))
				{
					resVo.graphicObj = effect_list.take(obj.url);
					resVo.params = obj.params;
					obj.fun(resVo);
					obj.fun = null;
					return true;
				}
			}
			res_Arr[res_Arr.length] = obj;
			return false;
		}
		/**
		 * 移除
		 * */
		public  function removeAllmap():void
		{
			for(var str:String in map_list.hash)
			{
				map_list.remove(str);
			}
			res_Arr.length = 0;
			queue_loader.init();
		}
	}
}