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
		
		[Embed(source="/../assets/sounds/enemy_explosion.mp3")]
		public static const enemy_explosion:Class;
		
		[Embed(source="/../assets/sounds/enemy_hurt.mp3")]
		public static const enemy_hurt:Class;
		
		[Embed(source="/../assets/sounds/jump.mp3")]
		public static const jump:Class;
		
		[Embed(source="/../assets/sounds/man_die.mp3")]
		public static const man_die:Class;
		
		[Embed(source="/../assets/sounds/sword_clash.mp3")]
		public static const sword_clash:Class;
		
		[Embed(source="/../assets/sounds/sword_swoosh.mp3")]
		public static const sword_swoosh:Class;
		
		[Embed(source="/../assets/sounds/walk.mp3")]
		public static const walk:Class;
		
		public static var Manager:AssetManager;
		public static var onLoadComplete:Signal = new Signal();;
		public static var onLoadProgress:Signal = new Signal(Number);
		private static var _isLoadCalled:Boolean = false;
		
		public static function load():void
		{
			if (_isLoadCalled) return;
			
			_isLoadCalled = true;
			
			Manager = new AssetManager();
			
			Manager.enqueue(Assets);
			
			Manager.loadQueue(function(ratio:Number):void
			{
				onLoadProgress.dispatch(ratio);
				
				// -> When the ratio equals '1', we are finished.
				if (ratio == 1.0) onLoadComplete.dispatch();
			});
		}
	}

}