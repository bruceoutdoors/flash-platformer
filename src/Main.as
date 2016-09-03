package
{
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	import States.ALevel;
	import States.LoadingScreen;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.CitrusEngine;
	import citrus.input.controllers.Keyboard;
	import citrus.sounds.CitrusSoundGroup;

	[SWF(frameRate="60", width="600", height="400")]
	public class Main extends StarlingCitrusEngine {

		public function Main() {
		}
		
		override public function initialize():void
		{
			setUpStarling(true);
			
			sound.addSound("Kaboom", {sound:"sounds/enemy-explosion.mp3", volume:0.5, group:CitrusSoundGroup.SFX});
			sound.addSound("HeroDie", {sound:"sounds/man-die.mp3", volume:0.6, group:CitrusSoundGroup.SFX});
			sound.addSound("EnemyHurt", {sound:"sounds/enemy-hurt.mp3", group:CitrusSoundGroup.SFX});
			sound.addSound("SwordSwoosh", {sound:"sounds/sword-swoosh.mp3", group:CitrusSoundGroup.SFX});
			sound.addSound("SwordClash", {sound:"sounds/sword-clash.mp3", group:CitrusSoundGroup.SFX});
			sound.addSound("Walk", { sound:"sounds/walk.mp3", loops: -1, volume:1, group:CitrusSoundGroup.SFX } );
			sound.addSound("Jump", { sound:"sounds/jump.mp3", volume:1, group:CitrusSoundGroup.SFX } );
			
			var kb:Keyboard = CitrusEngine.getInstance().input.keyboard;
			kb.removeActionFromKey("jump", Keyboard.SPACE);
			kb.addKeyAction("jump", Keyboard.UP);
			kb.addKeyAction("attack", Keyboard.X);
		}
		
		override public function handleStarlingReady():void
		{
			// setup loading screen
			var loading:LoadingScreen = new LoadingScreen();
			state = loading;
			Assets.onLoadProgress.add(function(ratio:Number):void{
				loading.updateProgress(ratio);
			});
			
			// load assets, and once we're done the game starts!
			Assets.load();
			Assets.Manager.verbose = true;
			Assets.onLoadComplete.add(function():void {
				state = new ALevel();
			});
		}
	}
	
}