package 
{
	import TileMapReader;
	import citrus.core.starling.StarlingState;
	import starling.display.Image;
	import Takuto;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.view.starlingview.AnimationSequence;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import citrus.objects.platformer.box2d.Sensor;
	import flash.text.TextField;
	import citrus.objects.CitrusSprite;
	import starling.textures.TextureSmoothing;
	import feathers.controls.Label;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	import feathers.core.ITextRenderer;
	import feathers.controls.text.TextFieldTextRenderer
	import flash.text.TextFormat;
	import citrus.core.CitrusObject;
		
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class ALevel extends StarlingState 
	{
		[Embed(source="/../assets/forest.png")]
		public static const forest:Class;
		
		private var _zorgRemaining:int;
		
		public function ALevel() 
		{
			super();
			
			// Useful for not forgetting to import object from the Level Editor
			var objects:Array = [Takuto, Platform, ZorgBaby, EnemyBound, Sensor];
		}
		
		override public function initialize():void {
			
			super.initialize();
			
			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true;
			add(box2D);

			var bgImg:Image = new Image(Assets.Manager.getTexture("Cemetary_FBG"));
			bgImg.smoothing = TextureSmoothing.NONE;
			var background:CitrusSprite = new CitrusSprite("back", {x:-30, y:0, parallaxX:0.1, parallaxY:0.1, view: bgImg });
			add(background);

			var bmp:Bitmap = new forest();
			//// we must add the image name so we know which image is chosen.
			bmp.name = "forest.png";
			bmp.smoothing = false;
			TileMapReader.Read(Assets.Manager.getXml("map"), [bmp]);
			
			var hero:Takuto = getObjectByName("hero") as Takuto;
			hero.setAttackSensor(getObjectByName("attackarea") as Sensor);

			view.camera.setUp(hero, new Rectangle(0, 0, 1600, 400));

			view.camera.allowZoom = true;
			view.camera.setZoom(30);
			
			var lbl:Label = new Label();
			lbl.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.textFormat = new TextFormat( "Arial", 14, 0xffffff);
				textRenderer.isHTML = true;
				return textRenderer;
			}
			lbl.x = 60;
			lbl.y = 10;
			addChildAt(lbl, 1);
			var v:Vector.<CitrusObject> = getObjectsByType(ZorgBaby)
			var remainTxt:String = "Zorg Babies Remaining: ";
			_zorgRemaining = v.length;
			lbl.text = remainTxt + _zorgRemaining;
			for each (var obj:ZorgBaby in v) {
				obj.onDied.add(function():void { 
					_zorgRemaining--; 
					lbl.text = remainTxt + _zorgRemaining;
				});
			}
		}
		
	}

}