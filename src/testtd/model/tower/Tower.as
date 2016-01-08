package testtd.model.tower
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import testtd.utils.Config;
	import testtd.utils.Utils;
	import testtd.managers.AssetManager;
	import testtd.model.enemy.Creep;
	
	public class Tower extends Sprite
	{
		// tower data
		private var _data:TowerData;
		
		// tower's name
		private var _name:String;
		
		// tower's image
		private var _view:Image;
		
		// tower's range ellipse
		private var _perimeter:Image;
		
		// cooldown timer
		private var _cooldown:int;
		
		// elapsed time checkpoint
		private var _startTime:Number;
		
		// if tower is updating
		private var _isActive:Boolean = false;
		
		public function get id():String
		{
			return _name;
		}
		
		public function get data():TowerData
		{
			return _data;
		}
		
		/**
		 * 	Initiating blueprint
		 * 	<br><b>param: name of the tower
		 */
		public function setData(data:TowerData):void
		{
			_data = data;
			_name = _data.name + Utils.getUID();
			_view = new Image(AssetManager.instance.getTexture(_data.name));
			_startTime = _data.fireRate;
			if (_data.textureData)
			{
				_view.x = _data.textureData.origin.x;
				_view.y = _data.textureData.origin.y;
			}
			addChild(_view);
			
			_perimeter = new Image(Utils.getPerimeter(_data.radius, _data.radius));
			_perimeter.touchable = false;
			_perimeter.pivotX = _perimeter.width * .5;
			_perimeter.pivotY = _perimeter.height * .5;
			_perimeter.x = Config.params.TILE_WIDTH;
			_perimeter.y = Config.params.TILE_HEIGHT;
			_perimeter.visible = false;
			addChild(_perimeter);
			
			addEventListener(Event.ADDED_TO_STAGE, tower_onAddedToStageHandler);
		}
		
		/**
		 * 	Update loop
		 * 	<br><b>param: time passed from the start of game
		 */
		public function update(elapsedTime:Number):void
		{
			if (!_isActive)
				return;
			
			if (!_startTime)
				_startTime = elapsedTime;
			_cooldown = elapsedTime - _startTime;
		}
		
		/**
		 * 	Checking if creep is in range of an ellipse
		 * 	<br><b>param: creep for check
		 */
		public function inRange(creep:Creep):Boolean
		{
			// coordinates of the creep
			const _x:int = creep.targetOffset.x;
			const _y:int = creep.targetOffset.y;
			
			// major radius of range ellipse
			const _a:int = Config.params.TILE_WIDTH * (data.radius + 1);
			
			// minor radius of range ellipse
			const _b:int = Config.params.TILE_HEIGHT * (data.radius + 1);
			
			// coordinates of the tower
			const _h:int = x + Config.params.TILE_WIDTH;
			const _k:int = y + Config.params.TILE_HEIGHT;
			
			// calculations
			const sqrX:int = (_x - _h) * (_x - _h);
			const sqrY:int = (_y - _k) * (_y - _k);
			const dist:int = (sqrX / (_a * _a)) + (sqrY / (_b * _b));
			return dist < 1;
		}
		
		/**
		 * 	Checking if tower is cold to shoot
		 */
		public function canFire():Boolean
		{
			return _cooldown > _data.fireRate;
		}
		
		/**
		 * 	Reset cooldown
		 */
		public function fired():void
		{
			_startTime = 0;
			_cooldown = 0;
		}
		
		/**
		 * 	Show perimeter view
		 */
		public function showPerimeter():void
		{
			_perimeter.visible = true;
		}
		
		/**
		 * 	Hide perimeter view
		 */
		public function hidePerimeter():void
		{
			_perimeter.visible = false;
		}
		
		protected function tower_onAddedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, tower_onAddedToStageHandler);
			_isActive = true;
		}
	}
}