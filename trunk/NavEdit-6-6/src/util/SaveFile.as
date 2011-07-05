package com.util
{
	import com.map.NPC.Npc;
	import com.view.ResElement;
	
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/***
	 * 保存配置文件类
	 * 
	 * 
	 * */
	public class SaveFile
	{
		public function SaveFile()
		{
		}
		/**
		 * 保存地图数据
		 * @param sceneId:场景名称
		 * @param mapdata:场景阻挡的数据
		 * @param mapw:地图x轴上菱形个数
		 * @param maph:地图y轴上菱形个数
		 * @param picw:背景切割后小图片的宽度
		 * @param pich:背景切割后小图片的高度
		 * @param mapWidth:地图宽度
		 * @param mapHeight:地图高度
		 * 
		 * */
		public static function saveTo(sceneId:String,mapdata:Array,mapw:int,maph:int,
		                              picw:int,pich:int,mapWidth:int,mapHeight:int,npc:Array,pass:Array,effect:Array):void
		{
			var str:String="";
			sceneId = sceneId;
			for(var i:int=0;i<mapdata[0].length;i++)
			{
				for(var j:int=0;j<mapdata.length;j++)
				  str += mapdata[j][i].toString();
			}
			var passstr:String = "";
			for(var i:int=0;i<pass.length;i++)
			{
			   passstr += pass[i].x+','+pass[i].y+','+pass[i].scene+',';	
			}
			var effectstr:String="";
			for(var i:int=0;i<effect.length;i++)
			{
				var mc:DisplayObject = effect[i].swf;
			   effectstr += mc.x+','+mc.y+','+"state,"+effect[i].name+',';	
			}
	 		var mapXml:XML = <map name={sceneId} mapwidth={mapWidth} mapheight={mapHeight} mapw={mapw} 
	 		           maph={maph} picw={picw} pich={pich} mapdata={str}>
	 		           <pass data={passstr}/>
	 		           <effect data={effectstr} />
	 		           </map>;
	 		saveXml(sceneId,sceneId,mapXml);
	 		
	 		var npcXml:XML = <npc name={sceneId}></npc>;
	 		for each(var obj:Npc in npc)
	 		{
	 		  npcXml.appendChild(<item name={obj.npcInfo.name} x={obj.x} y={obj.y} scene={obj.npcInfo.scene}/>);
	 		}
	 		saveXml(sceneId,"npc",npcXml);
		}

		/**
		 * 保存
		 *   @param sceneId:场景名称
		 * */
		private static function saveXml(sceneId:String,name:String,mapXml:XML):void
		{
			var file:File = File.documentsDirectory.resolvePath("map/"+sceneId);
			file.createDirectory();
			var _file:File = file.resolvePath(name+".map");
			   //保存场景文件xml
		     var tmpfs:FileStream = new FileStream();
			 tmpfs.open(_file, FileMode.WRITE);
			 tmpfs.writeUTFBytes(mapXml.toXMLString());
			 tmpfs.close();
		}

	}
}