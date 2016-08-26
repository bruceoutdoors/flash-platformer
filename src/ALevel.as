package 
{
	import TileMapReader;
	import citrus.core.starling.StarlingState;
	import Takuto;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.view.starlingview.AnimationSequence;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import citrus.objects.platformer.box2d.Sensor;
	
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class ALevel extends StarlingState 
	{
		[Embed(source="/../assets/map.tmx", mimeType="application/octet-stream")]
		private const _Map:Class;
		
		[Embed(source="/../assets/forest.png")]
		private const _ImgTiles:Class;
		
		public function ALevel() 
		{
			super();
			
			// Useful for not forgetting to import object from the Level Editor
			var objects:Array = [Takuto, Platform, ZorgBaby, EnemyBound];
		}
		
		override public function initialize():void {
			
			super.initialize();
			
			var box2D:Box2D = new Box2D("box2D");
			box2D.visible = true;
			add(box2D);
			
			var bmp:Bitmap = new _ImgTiles();
			// we must add the image name so we know which image is chosen.
			bmp.name = "forest.png";
			bmp.smoothing = false;

			TileMapReader.Read(XML(new _Map()), [bmp]);
			
			var hero:Takuto = getObjectByName("hero") as Takuto;

			view.camera.setUp(hero, new Rectangle(0, 0, 1600, 400));

			view.camera.allowZoom = true;
			view.camera.setZoom(30);
			
		}
		
	}

}