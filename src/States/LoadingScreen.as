package States 
{
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import starling.display.Quad;
	import feathers.controls.Label;
	import feathers.core.ITextRenderer;
	import feathers.controls.text.TextFieldTextRenderer
	import flash.text.TextFormat;
	import flash.globalization.NumberFormatter;
	import flash.globalization.LocaleID;
	
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class LoadingScreen extends StarlingState 
	{
		private var _progressLbl:Label;
		private var _nf:NumberFormatter;
		
		public function LoadingScreen() 
		{
			super();
			_progressLbl = new Label();
			_progressLbl.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.textFormat = new TextFormat( "Arial", 50, 0xffffff);
				textRenderer.isHTML = true;
				return textRenderer;
			}
			
			_nf = new NumberFormatter(LocaleID.DEFAULT); 
			_nf.fractionalDigits = 0;
		}
		
		override public function initialize():void {
			super.initialize();
			
			add(new CitrusSprite("quad", {view:new Quad(stage.stageWidth, stage.stageHeight, 0x000000)}));
			
			
			_progressLbl.x = stage.stageWidth/2 - 180;
			_progressLbl.y = stage.stageHeight/2 - 40;
			addChildAt(_progressLbl, 1);
			updateProgress(0.51587);
		}
		
		public function updateProgress(ratio:Number):void
		{
			var percent:Number = ratio * 100;
			
			_progressLbl.text = "<b>LOADING: " + _nf.formatNumber(percent) + "%</b>";
		}
	}

}