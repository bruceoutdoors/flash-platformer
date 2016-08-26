package 
{
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.math.MathVector;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.view.starlingview.AnimationSequence;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import citrus.objects.platformer.box2d.Platform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	/**
	 * ...
	 * @author Lee Zhen Yong
	 */
	public class ZorgBaby extends Enemy 
	{
		[Embed(source="/../assets/zorg-baby.xml", mimeType="application/octet-stream")]
		private var _babyZorgConfig:Class;
		
		[Embed(source="/../assets/zorg-baby.png")]
		private var _babyZorgPng:Class;
		
		private var _gravConst:Number = -15.6;
		private var _defyGravity:Number = _gravConst;
		private var _gravityTimer:Timer = new Timer(500);;
		
		public function ZorgBaby(name:String, params:Object=null) 
		{
			super(name, params);
			
			var bitmap:Bitmap = new _babyZorgPng();
			var texture:Texture = Texture.fromBitmap(bitmap);

			var xml:XML = XML(new _babyZorgConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var animseq:AnimationSequence = new AnimationSequence(sTextureAtlas, ["walk", "die"], "walk", 15, false, "none");
			
			animseq.scale = 0.4;
			animseq.pivotY  = 8;
			speed = 0.8;
			
			view = animseq;
			
			_gravityTimer.start();
			_gravityTimer.addEventListener(TimerEvent.TIMER, function():void {
				if (_defyGravity == _gravConst) {
					_defyGravity = -14.2;
				} else {
					_defyGravity = _gravConst;
				}
			});
		}
		
		override protected function defineFixture():void {
			super.defineFixture();
		}
		
		override protected function defineBody():void {
			super.defineBody();

			//_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);

			var ant_gravity:b2Vec2 = new b2Vec2(0.0, _defyGravity*_body.GetMass());
			_body.ApplyForce(ant_gravity, _body.GetWorldCenter());
			
			var position:b2Vec2 = _body.GetPosition();
			
			//Turn around when they pass their left/right bounds
			if ((_inverted && position.x * _box2D.scale < leftBound) || (!_inverted && position.x * _box2D.scale > rightBound))
				turnAround();
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if (!_hurt) {
				velocity.x = _inverted ? -speed : speed;
			} else
				velocity.x = 0;
			
			updateAnimation();
		}
		
		
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (collider is _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)
				hurt();
				
			if (_body.GetLinearVelocity().x < 0 && (contact.GetFixtureA() == _rightSensorFixture || contact.GetFixtureB() == _rightSensorFixture))
				return;
			
			if (_body.GetLinearVelocity().x > 0 && (contact.GetFixtureA() == _leftSensorFixture || contact.GetFixtureB() == _leftSensorFixture))
				return;
			
			if (contact.GetManifold().m_localPoint) {
				
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				
				if ((collider is Platform && collisionAngle != 90) || collider is Enemy || collider is EnemyBound)
					turnAround();
			}
				
		}
	}

}