package testtd.model.enemy
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import testtd.utils.Config;
	import testtd.utils.Utils;
	import testtd.model.bullet.Bullet;
	import testtd.model.bullet.BulletEffectType;
	import testtd.model.bullet.BulletType;
	import testtd.model.map.Path;
	import testtd.model.map.PathData;
	import testtd.model.map.StartingPoint;
	
	public class Creep extends Sprite
	{
		public static const REACHED_TARGET:String = "REACHED_TARGET";
		public static const KILLED:String = "KILLED";
		
		// creep asset name
		private var _name:String;
		
		// velocity of the creep
		private var _velocity:Number = 0;
		
		// speed multiplier
		private var _multp:Number = 1;
		
		// vector of movement
		private var _speedVec:Point = new Point();
		
		// distance to the next point
		private var _toNextPoint:Number = 0;
		
		// total distance left to the end
		private var _totalDistance:Number = 0;
		
		// targeting offset point of the creep
		private var _targetOffset:Point = new Point();
		
		// current direction of the creep's movement
		private var _direction:String;
		
		// hit points of the creep
		private var _hp:Number;
		
		// game's FPS
		private var _fps:int;
		
		// dictionary containing creep direction animation
		private var _anims:Dictionary = new Dictionary(true);
		
		// effects applied to creep
		private var _effects:Dictionary = new Dictionary(true);
		
		// current direction animation of the creep
		private var _currAnim:MovieClip;
		
		// if creep is still alive
		private var _isAlive:Boolean = false;
		
		// creep data
		private var _data:CreepData;
		
		// starting point of the creep
		private var _sp:StartingPoint;
		
		// wave which this creep belongs
		private var _wave:Wave;
		
		// creep's pathway
		private var _path:Path;
		
		// current path segment
		private var _currPath:PathData;
		
		public function get data():CreepData
		{
			return _data;
		}
		
		public function get targetOffset():Point
		{
			_targetOffset.setTo(x + _data.targetX, y + _data.targetY);
			return _targetOffset;
		}
		
		public function get totalDistance():Number
		{
			return _totalDistance;
		}
		
		private function get speed():Number
		{
			return _velocity * _multp;
		}
		
		/**
		 * 	Setting data for creep.
		 * 	<br><b>param: creep data
		 */
		public function setData(data:CreepData):void
		{
			_data = data;
			_name = data.name + Utils.getUID();
			_fps = Starling.current.nativeStage.frameRate;
			addEventListener(Event.ADDED_TO_STAGE, creep_onAddedToStageHandler);
		}
		
		/**
		 * 	Setting starting point for creep creation.
		 * 	<br><b>param: starting point
		 */
		public function setStartingPoint(sp:StartingPoint):void
		{
			_sp = sp;
			x = (Config.params.TILE_WIDTH * .5) * ((_sp.coords.x - _sp.coords.y) + (Config.params.MAP_ROWS - 1));
			y = (Config.params.TILE_HEIGHT * .5) * (_sp.coords.x + _sp.coords.y);
		}
		
		/**
		 * 	Setting wave data.
		 * 	<br><b>param: wave object
		 */
		public function setWaveData(wave:Wave):void
		{
			_wave = wave;
			_velocity = _wave.creepSpd;
			_hp = _wave.creepHP;
		}
		
		/**
		 * 	Setting pathway for creep to follow.
		 * 	<br><b>param: pathway
		 */
		public function setPath(path:Path):void
		{
			_path = path;
			_totalDistance = _path.totalDistance;
		}
		
		/**
		 * 	Update loop for creep.
		 * 	<br><b>param: passed time
		 */
		public function update(elapsedTime:Number):void
		{
			if (!_totalDistance || !_isAlive)
				return;
			
			if (_toNextPoint <= 0)
			{
				// getting next path data to follow
				_currPath = _path.getNextPath();
				if (_currPath)
				{
					_direction = _currPath.direction;
					_toNextPoint = _currPath.distance;
					
					// calculating speed for x and y coordinates
					calcStep();
					// update movement direction
					updateAnim();
					// placing creep to path origin points
					x = (Config.params.TILE_WIDTH * .5) * ((_currPath.point.x - _currPath.point.y) + (Config.params.MAP_ROWS - 1));
					y = (Config.params.TILE_HEIGHT * .5) * (_currPath.point.x + _currPath.point.y);
				}
				else
				{
					_isAlive = false;
					// event informing about creep reaching end of the pathway
					dispatchEventWith(REACHED_TARGET);
				}
			}
			else
			{
				x += _speedVec.x;
				y += _speedVec.y;
				_toNextPoint -= _speedVec.length;
				_totalDistance -= _speedVec.length;
			}
			
			// applying effects to creep
			for (var prop:String in _effects)
			{
				if (prop == BulletEffectType.SLOWING)
				{
					_multp = .25;
					if (_effects[prop] <= 0)
					{
						_effects[prop] = null;
						_multp = 1;
						continue;
					}
				}
				// effect countdown
				_effects[prop]--; 
			}
		}
		
		/**
		 * 	Called when bullet hit the creep.
		 * 	<br><b>param: bullet
		 */
		public function hit(bullet:Bullet):void
		{
			if (!bullet)
				return;
			
			var damage:Number = 0;
			var effect:String = BulletEffectType.NONE;
			switch (bullet.type)
			{
				case BulletType.REGULAR:
					damage = bullet.damage;
					break;
				case BulletType.SLOWER:
					effect = BulletEffectType.SLOWING;
					break;
				case BulletType.MASS_HIT:
					damage = bullet.damage;
					break;
			}
			// inflicting damage to creep
			_hp -= bullet.damage;
			// applying effect to creep
			setEffect(effect);
			if (_hp <= 0)
			{
				_isAlive = false;
				// event informing about destroying creep
				dispatchEventWith(KILLED, false, _wave.creepBnty);
			}
		}
		
		/**
		 * 	Applying effect to creep.
		 * 	<br><b>param: effect name
		 */
		private function setEffect(effect:String):void
		{
			if (!_effects[effect])
				_effects[effect] = 2 * _fps;
		}
		
		/**
		 * 	Updating creep's direction animation.
		 */
		private function updateAnim():void
		{
			if (_currAnim)
			{
				Starling.juggler.remove(_currAnim);
				removeChild(_currAnim);
			}
			
			if (!_anims[_direction])
				_anims[_direction] = new MovieClip(data.anims[_direction]);
			
			_currAnim = _anims[_direction];
			if (_data.textureData)
			{
				_currAnim.x = _data.textureData.origin.x;
				_currAnim.y = _data.textureData.origin.y;
			}
			Starling.juggler.add(_currAnim);
			addChild(_currAnim);
		}
		
		/**
		 * 	Calculating creep's step toward path direction.
		 */
		private function calcStep():void
		{
			var xspd:Number = 0;
			var yspd:Number = 0;
			var tileHalfWidth:Number = Config.params.TILE_WIDTH * .5;
			var tileHalfHeight:Number = Config.params.TILE_HEIGHT * .5;
			switch (_direction) 
			{
				case DirectionType.TOP_LEFT:
					yspd = -getStep(Config.params.TILE_HEIGHT);
					break;
				case DirectionType.TOP:
					xspd = getStep(tileHalfWidth);
					yspd = -getStep(tileHalfHeight);
					break;
				case DirectionType.TOP_RIGHT:
					xspd = getStep(Config.params.TILE_WIDTH);
					break;
				case DirectionType.RIGHT:
					xspd = getStep(tileHalfWidth);
					yspd = getStep(tileHalfHeight);
					break;
				case DirectionType.DOWN_RIGHT:
					yspd = getStep(Config.params.TILE_HEIGHT);
					break;
				case DirectionType.DOWN:
					xspd = -getStep(tileHalfWidth);
					yspd = getStep(tileHalfHeight);
					break;
				case DirectionType.DOWN_LEFT:
					xspd = -getStep(Config.params.TILE_WIDTH);
					break;
				case DirectionType.LEFT:
					xspd = -getStep(tileHalfWidth);
					yspd = -getStep(tileHalfHeight);
					break;
			}
			_speedVec.setTo(xspd, yspd);
		}
		
		/**
		 * 	Get step length for distance.
		 * 	<br><b>param: distance
		 */
		private function getStep(dist:Number):Number
		{
			return dist / _fps * speed;
		}
		
		protected function creep_onAddedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, creep_onAddedToStageHandler);
			_isAlive = true;
		}
		
		override public function dispose():void
		{
			if (_currAnim)
			{
				Starling.juggler.remove(_currAnim);
				removeChild(_currAnim);
			}
			
			for each(var mc:MovieClip in _anims)
				mc.dispose();
			super.dispose();
		}
	}
}