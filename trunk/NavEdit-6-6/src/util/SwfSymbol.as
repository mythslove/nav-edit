package com.util
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/***
	 * 解析整个swf，将swf中的元件取出
	 * 
	 * */
	public class SwfSymbol
	{
		public var resArr:Array;
		public function SwfSymbol()
		{
		}
		///获取一个SWF中的所有元件
		public function getswf(url:String):void
		{
            var loader:Loader=new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
            loader.load(new URLRequest(url));
        }
        
        private function completeHandler(event:Event):void 
        {
            var bytes:ByteArray=LoaderInfo(event.target).bytes;
            resArr = getSymbolName(bytes);
        }
        ////
        public function getSymbolName(bytes:ByteArray):Array
        {
        	var arr:Array = new Array;
            bytes.endian=Endian.LITTLE_ENDIAN;
            bytes.position=Math.ceil(((bytes[8]>>>3)*4+5)/8)+12;
            while(bytes.bytesAvailable>2)
            {
                var head:int=bytes.readUnsignedShort();
                var size:int=head&63;
                if (size==63)
                     size=bytes.readInt();
                if (head>>6!=76)bytes.position+=size;
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