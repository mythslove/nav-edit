package models
{
	
	public class ModelLocator
	{
		
		public var addState:int = 0;
		public var step:int = -1;
		public var tailStep:int = -1;
		public var fileBaseUrl:String;
		public var mapname:String;
		public var mapWidth:int;
		public var mapHeight:int;
		public var picw:int = 300;
		public var picH:int = 300;
		
		public var fileUrl:String;
		public var fileName:String;
		
		
		private static var instance:ModelLocator;  
  
        public static function getInstance():ModelLocator  
        {  
            if(instance==null)  instance = new ModelLocator();  
            return instance;  
        }  
  																											
        public function ModelLocator()  
        {  
           if(instance!=null) throw new Error("Error: Singletons can only be instantiated via getInstance() method!");  
            ModelLocator.instance = this;  
        }  

	}
}