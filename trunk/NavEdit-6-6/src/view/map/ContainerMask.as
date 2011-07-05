package view.map
{
	import flash.display.Shape;
	
	import mx.core.UIComponent;
	
	public class ContainerMask extends UIComponent
	{
		private var contentUI:UIComponent;
		private var maskShape:Shape;
		public function ContainerMask()
		{
			contentUI = new UIComponent;
			maskShape = new Shape;
			
			
		}
	}
}