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
	public class SwfBaseScreen extends StarlingState
	{
		protected var _loader:Loader;
		protected var _urlReq:URLRequest;
		
		public function SwfBaseScreen(swfFile:String):void
		{
			super();
			_urlReq = new URLRequest(swfFile);
		}
		
		override public function initialize():void
		{
			super.initialize();
			_loader = new Loader();
			_loader.load(_urlReq);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSWFLoadComplete);
		}
		
		override public function destroy():void
		{
			super.destroy();
			// when using nativeOverlay we have to do the garbage collection manually
			Starling.current.nativeOverlay.removeChild(_loader);
			_loader.unloadAndStop();
		}
		
		protected function handleSWFLoadComplete(evt:Event):void
		{
			Starling.current.nativeOverlay.addChild(_loader);
			evt.target.removeEventListener(Event.COMPLETE, handleSWFLoadComplete);
		}	
	}

}