package testtd.model.bullet
{
	import flash.geom.Rectangle;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import testtd.model.enemy.Creep;
	import testtd.model.tower.Tower;
	
	public class Bullet extends Sprite
	{
		public static const DESTROYED:String = "DESTROYED";
		
		// bullet data
		private var _data:BulletData;
		
		// bullet view
		private var _view:Quad;
		
		// bullet's target
		private var _target:Creep;
		
		// target's hit area
		private var _tBounds:Rectangle = new Rectangle();
		
		// bullet's speed
		private var _speed:Number = 20;
		
		// hit area range
		private var _hitArea:int = 10;
		
		// distance to target
		private var _distToTargetX:Number;
		private var _distToTargetY:Number;
		
		// movement vector
		private var _vecx:Number;
		private var _vecy:Number;
		
		// attack angle
		private var _angleRad:Number;
		
		// if bullet is updating
		private var _isActive:Boolean = false;
		
		public function get type():int
		{
			return _data.type;
		}
		
		public function get damage():Number
		{
			return _data.damage;
		}
		
		/**
		 * 	Setting bullet data
		 * 	<br><b>param: bullet data
		 */
		public function setData(data:BulletData):void
		{
			_data = data;
			
			// creating bullet's view
			_view = new Quad(8, 8, _data.color);
			_view.pivotX = _view.pivotY = 4;
			addChild(_view);
			addEventListener(Event.ADDED_TO_STAGE, bullet_onAddedToStageHandler);
		}
		
		/**
		 * 	Setting starting point of the bullet
		 * 	<br><b>param: tower which shot the bullet
		 */
		public function setOrigin(tower:Tower):void
		{
			x = tower.x + tower.data.firePointX;
			y = tower.y + tower.data.firePointY;
		}
		
		/**
		 * 	Setting target creep
		 * 	<br><b>param: targeted creep
		 */
		public function setTarget(creep:Creep):void
		{
			_target = creep;
		}
		
		/**
		 * 	Creep's update loop
		 * 	<br><b>param: passed time
		 */
		public function update(elapsedTime:Number):void
		{
			if (!_target && !_isActive)
				return;
			
			// calculating distance to target
			_distToTargetX = x - _target.targetOffset.x;
			_distToTargetY = y - _target.targetOffset.y;
			
			// target's angle from tower
			_angleRad = Math.atan2(_distToTargetY , _distToTargetX);
			
			// find amount to move x and y
			_vecx = _speed * Math.cos(_angleRad);
			_vecy = _speed * Math.sin(_angleRad);
			
			// actually move x and y
			x -= _vecx;
			y -= _vecy;
			
			// setting target's hit area
			_tBounds.setTo(_target.targetOffset.x - _hitArea, _target.targetOffset.y - _hitArea, _target.targetOffset.x + _hitArea, _target.targetOffset.y + _hitArea);
			if (x > _tBounds.x && x < _tBounds.width && y > _tBounds.y && y < _tBounds.height)
			{
				_target.hit(this);
				_isActive = false;
				// event informing about bullet destroyed
				dispatchEventWith(DESTROYED);
			}
		}
		
		protected function bullet_onAddedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, bullet_onAddedToStageHandler);
			_isActive = true;
		}
		
		override public function dispose():void
		{
			if (_view)
			{
				_view.removeFromParent(true);
				_view = null;
			}
			super.dispose();
		}
	}
}