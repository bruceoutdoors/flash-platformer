package States
{
	import citrus.core.starling.StarlingState;
	import flash.display.Loader;
	import citrus.core.State;
	import flash.net.URLRequest;
	import starling.core.Starling;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class WinScreen extends SwfBaseScreen
	{
		private var _restartBtn:SimpleButton;
		private var _returnLvl:*;
		
		public function WinScreen(returnLvl:*):void
		{
			super("win-screen.swf");
			_returnLvl = returnLvl;
		}
		
		override public function destroy():void
		{
			super.destroy();
			_restartBtn.removeEventListener(MouseEvent.CLICK, restartLevel);
		}
		
		protected override function handleSWFLoadComplete(evt:Event):void
		{
			super.handleSWFLoadComplete(evt);
			_restartBtn = MovieClip(_loader.content).restartBtn as SimpleButton;
			_restartBtn.addEventListener(MouseEvent.CLICK, restartLevel);
		}
		
		private function restartLevel(evt:MouseEvent):void
		{
			_ce.state = new _returnLvl();
			// when you click the focus is set to the swf file.
			// We need to set input focus back in citrus:
			Starling.current.nativeStage.focus = Starling.current.nativeStage;
		}
	}

}