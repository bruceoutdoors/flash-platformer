package 
{
	import Takuto;
	import Box2D.Common.Math.b2Vec2;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.view.starlingview.AnimationSequence;
	import flash.display.Bitmap;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.objects.platformer.box2d.Enemy;
	
	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class Takuto extends Hero 
	{
		private var _attack:Boolean = false;
		private var _attackTimeoutID:uint;
		private var _dying:Boolean = false;
		private var _attackSensor:Sensor;
		private var _restarting:Boolean = false;
		
		public var attackDuration:Number = 300;
		public var damage:Number = 10;
		
		[Embed(source="/../assets/takuto-spritesheet.xml", mimeType="application/octet-stream")]
		private var _heroConfig:Class;
		
		[Embed(source="/../assets/takuto-spritesheet.png")]
		private var _heroPng:Class;
		
		public function Takuto(name:String, params:Object=null) 
		{
			super(name, params);
			
			jumpHeight = 4.8;
			maxVelocity = 1.5;
			acceleration = 0.7;
			hurtVelocityX = 5;
			hurtVelocityY = 5;
			canDuck = false;
			
			var bitmap:Bitmap = new _heroPng();
			var texture:Texture = Texture.fromBitmap(bitmap);

			var xml:XML = XML(new _heroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var animseq:AnimationSequence = new AnimationSequence(sTextureAtlas, 
				["walk", "duck", "idle", "jump", "hurt", "attack", "die"], 
				"idle", 15, false, "none");
			
			animseq.scale = 0.6;
			animseq.pivotY  = 8;
			
			view = animseq;
			
			onTakeDamage.add(takuto_onTakeDamage);
		}
		
		public function setAttackSensor(s:Sensor):void 
		{
			_attackSensor = s;
			_attackSensor.onBeginContact.add(Takuto_onAttackSensorBeginContact);
			_attackSensor.beginContactCallEnabled = false;
		}
		
		private function Takuto_onAttackSensorBeginContact(contact:b2Contact):void
		{
			var enemy:ZorgBaby = Box2DUtils.CollisionGetOther(_attackSensor, contact) as ZorgBaby;
			if (enemy is ZorgBaby) {
				trace("taste some blade mothafucka!");
				enemy.takeDamage(damage, _inverted);
			}
		}
		
		private function takuto_onTakeDamage():void
		{
			if (_dying) return; // so you don't die twice

			controlsEnabled = false;
			setTimeout(function():void {
				_dying = true;
			}, 350);
			
			setTimeout(function():void {
				restartLevel();
			}, 1800);
		}
		
		// player dies in one hit, so we don't need this.
		override protected function endHurtState():void {}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			// we get a reference to the actual velocity vector
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			// reduce gravitanional force on player
			//var ant_gravity:b2Vec2 = new b2Vec2(0.0, -8.0*_body.GetMass());
			//_body.ApplyForce(ant_gravity, _body.GetWorldCenter());
			if (this.y > 1500) {
				restartLevel();
			}
			
			_attackSensor.x = _inverted ? x - 20 : x + 20;
			_attackSensor.y = y - 5;
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDoing("down", inputChannel) && _onGround && canDuck);
				
				if (!_attack && _ce.input.justDid("attack", inputChannel)) {
					_attack = true;
					setTimeout(triggerAttack, 50);
					_attackTimeoutID = setTimeout(endAttackState, attackDuration);
				}
				
				if (!_attack && _ce.input.isDoing("right", inputChannel) && !_ducking)
				{
					velocity.Add(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (!_attack && _ce.input.isDoing("left", inputChannel) && !_ducking)
				{
					velocity.Subtract(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
				//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ducking)
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
					_onGround = false; // also removed in the handleEndContact. Useful here if permanent contact e.g. box on hero.
				}
				
				if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0)
				{
					velocity.y -= jumpAcceleration;
				}
				
				if (_springOffEnemy != -1)
				{
					if (_ce.input.isDoing("jump", inputChannel))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
			}
			
			updateAnimation();
		}
		
		private function triggerAttack():void 
		{
			if (_attackSensor.beginContactCallEnabled) return;
			
			_attackSensor.beginContactCallEnabled = true;
			setTimeout(function():void { 
				_attackSensor.beginContactCallEnabled = false; 
			}, 250);
		}
		
		override protected function updateAnimation():void {
			
			var prevAnimation:String = _animation;
			
			var walkingSpeed:Number = getWalkingSpeed();
			
			if (_dying) {
				_animation = "die";
			} else if (_hurt) {
				_animation = "hurt";	
				view.pivotY  = -6; // death animaton is not offset properly.
			} else if (!_onGround) {
				
				_animation = "jump";
				
				if (walkingSpeed < -acceleration)
					_inverted = true;
				else if (walkingSpeed > acceleration)
					_inverted = false;
				
			} else if (_ducking)
				_animation = "duck";
				
			else {
				
				if (walkingSpeed < -acceleration) {
					_inverted = true;
					_animation = "walk";
					
				} else if (walkingSpeed > acceleration) {
					
					_inverted = false;
					_animation = "walk";
					
				} else
					_animation = "idle";
			}
			
			if (_attack == true) {
				_animation = "attack";
			}
			
			if (prevAnimation != _animation)
				onAnimationChange.dispatch();
		}
		
		private function endAttackState():void 
		{
			_attack = false;
		}
		
		private function restartLevel():void 
		{
			if (_restarting) return;
			_restarting = true;
			_ce.state = new RestartScreen(ALevel);
		}
		
		public override function destroy():void 
		{
			super.destroy();
			clearTimeout(_attackTimeoutID);
		}
	}

}