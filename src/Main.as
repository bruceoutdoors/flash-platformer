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

	[SWF(frameRate="60", width="600", height="400", wmode="direct")]
	public class Main extends StarlingCitrusEngine {

		public function Main() {
		}
		
		override public function initialize():void
		{
			setUpStarling(true);

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
				setupSounds();
				state = new ALevel();
			});
		}
		
		private function setupSounds():void 
		{
			sound.addSound("Kaboom", {sound:Assets.Manager.getSound("enemy_explosion"), volume:0.5, group:CitrusSoundGroup.SFX});
			sound.addSound("HeroDie", {sound:Assets.Manager.getSound("man_die"), volume:0.6, group:CitrusSoundGroup.SFX});
			sound.addSound("EnemyHurt", {sound:Assets.Manager.getSound("enemy_hurt"), group:CitrusSoundGroup.SFX});
			sound.addSound("SwordSwoosh", {sound:Assets.Manager.getSound("sword_swoosh"), group:CitrusSoundGroup.SFX});
			sound.addSound("SwordClash", {sound:Assets.Manager.getSound("sword_clash"), group:CitrusSoundGroup.SFX});
			sound.addSound("Walk", { sound:Assets.Manager.getSound("walk"), loops: -1, volume:1, group:CitrusSoundGroup.SFX } );
			sound.addSound("Jump", { sound:Assets.Manager.getSound("jump"), volume:1, group:CitrusSoundGroup.SFX } );
		}
	}
	
}