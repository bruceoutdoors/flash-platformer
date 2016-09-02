package 
{
	import org.osflash.signals.Signal;
	import starling.utils.AssetManager;
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class Assets 
	{
		[Embed(source="/../assets/zorg_baby.xml", mimeType="application/octet-stream")]
		public static const zorg_baby_xml:Class;
		
		[Embed(source="/../assets/zorg_baby.png")]
		public static const zorg_baby:Class;
		
		[Embed(source="/../assets/explode.xml", mimeType="application/octet-stream")]
		public static const explode_xml:Class;
		
		[Embed(source="/../assets/explode.png")]
		public static const explode:Class;
	
		[Embed(source="/../assets/takuto_spritesheet.xml", mimeType="application/octet-stream")]
		public static const takuto_spritesheet_xml:Class;
		
		[Embed(source="/../assets/takuto_spritesheet.png")]
		public static const takuto_spritesheet:Class;
		
		[Embed(source="/../assets/map.tmx", mimeType="application/octet-stream")]
		public static const map:Class;
		
		[Embed(source="/../assets/Cemetary_FBG.png")]
		public static const Cemetary_FBG:Class;
		
		public static var Manager:AssetManager;
		public static var onLoadComplete:Signal;
		private static var _isLoadCalled:Boolean = false;
		
		public static function load():void
		{
			if (_isLoadCalled) return;
			
			_isLoadCalled = true;
			
			onLoadComplete = new Signal();
			Manager = new AssetManager();
			
			Manager.enqueue(Assets);
			
			
			Manager.loadQueue(function(ratio:Number):void
			{
				// -> When the ratio equals '1', we are finished.
				if (ratio == 1.0) onLoadComplete.dispatch();
			});
		}
	}

}