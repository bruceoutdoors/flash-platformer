package
{
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.CitrusEngine;
	import citrus.input.controllers.Keyboard;

	[SWF(frameRate="60", width="600", height="400")]
	public class Main extends StarlingCitrusEngine {

		public function Main() {
		}
		
		override public function initialize():void
		{
			setUpStarling(true);
			
			var kb:Keyboard = CitrusEngine.getInstance().input.keyboard;
			kb.removeActionFromKey("jump", Keyboard.SPACE);
			kb.addKeyAction("jump", Keyboard.UP);
		}
		
		override public function handleStarlingReady():void
		{
			state = new ALevel();
		}
	}
	
}