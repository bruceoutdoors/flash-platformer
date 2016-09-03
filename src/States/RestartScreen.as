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
	public class RestartScreen extends StarlingState
	{
		private var _loader:Loader;
		private var _restartBtn:SimpleButton
		private var _returnLvl:*;
		
		public function RestartScreen(returnLvl:*):void
		{
			_returnLvl = returnLvl;
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			_loader = new Loader();
			_loader.load(new URLRequest("restart-screen.swf"));
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSWFLoadComplete);
		}
		
		override public function destroy():void
		{
			_restartBtn.removeEventListener(MouseEvent.CLICK, restartLevel);
			// when using nativeOverlay we have to do the garbage collection manually
			Starling.current.nativeOverlay.removeChild(_loader);
			_loader.unloadAndStop();
		}
		
		private function handleSWFLoadComplete(evt:Event):void
		{
			Starling.current.nativeOverlay.addChild(_loader);
			_restartBtn = MovieClip(_loader.content).restartBtn as SimpleButton;
			evt.target.removeEventListener(Event.COMPLETE, handleSWFLoadComplete);
			//setTimeout(function():void { _ce.state = new ALevel(); }, 2000);
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