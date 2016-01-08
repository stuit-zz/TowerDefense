package testtd.managers
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import testtd.model.bullet.Bullet;
	import testtd.model.bullet.BulletData;
	import testtd.model.bullet.BulletType;
	import testtd.model.enemy.Creep;
	import testtd.model.enemy.CreepData;
	import testtd.model.enemy.DirectionType;
	import testtd.model.enemy.Spawn;
	import testtd.model.enemy.SpawnType;
	import testtd.model.enemy.Wave;
	import testtd.model.tower.Tower;
	import testtd.model.tower.TowerBlueprint;
	import testtd.model.tower.TowerData;
	import testtd.utils.Config;

	public class GameManager extends EventDispatcher
	{
		public static const GAME_WON:String = "GAME_WON";
		public static const GAME_LOST:String = "GAME_LOST";
		
		// game managers
		private var _assets:AssetManager = AssetManager.instance;
		private var _mapMan:MapManager = new MapManager();
		private var _uiMan:UIManager;
		
		// used elements in game
		private var _target:Sprite;
		private var _mapImage:Image;
		private var _towerBp:TowerBlueprint;
		private var _currTower:Tower;
		
		// arrays of elements and datas
		private var _towers:Vector.<Tower> = new Vector.<Tower>();
		private var _towersData:Vector.<TowerData> = new Vector.<TowerData>();
		private var _creeps:Vector.<Creep> = new Vector.<Creep>();
		private var _creepsData:Vector.<CreepData> = new Vector.<CreepData>();
		private var _bullets:Vector.<Bullet> = new Vector.<Bullet>();
		private var _bulletsData:Vector.<BulletData> = new Vector.<BulletData>();
		private var _waves:Vector.<Wave> = new Vector.<Wave>();
		
		// layers for elements
		private var _creepsLayer:Sprite;
		private var _bulletsLayer:Sprite;
		private var _towersLayer:Sprite;
		private var _uiLayer:Sprite;
		
		// current amount of money
		private var _money:Number = 0;
		private var _moneyOld:Number = 0;
		// current amount of lives
		private var _lives:int = 0;
		private var _livesOld:int = 0;
		// delay time for creep spawning
		private var _spawnDelay:Number = 0;
		// countdown for spawning
		private var _spawnTime:Number = 0;
		// countdown checkpoint
		private var _startTime:Number = 0;
		// current creep attack wave and wave index
		private var _currWave:Wave;
		private var _currWaveIdx:int = 0;
		// attack wave timer and flag
		private var _waveTimer:Timer;
		private var _waveIsActive:Boolean = false;
		// helper offsets and properties
		private var _cellsOffsetX:Number = 0;
		private var _mapOffsetX:Number = 0;
		private var _mapOffsetY:Number = 0;
		private var _tileWidth:Number = 0;
		private var _tileHeight:Number = 0;
		private var _mouseCoords:Point = new Point();
		
		/**
		 * 	Game's main manager
		 * 	<br><b>param: parent container
		 */
		public function GameManager(target:Sprite)
		{
			_target = target;
			
			// adding layers for game objects
			_creepsLayer = new Sprite();
			_target.addChild(_creepsLayer);
			
			_bulletsLayer = new Sprite();
			_target.addChild(_bulletsLayer);
			
			_towersLayer = new Sprite();
			_target.addChild(_towersLayer);
			
			_uiLayer = new Sprite(); 
			_target.addChild(_uiLayer);
			
			_uiMan = new UIManager(_uiLayer);
			
			// adding stage click listener for deactivating tower's perimeter
			Starling.current.nativeStage.addEventListener(MouseEvent.CLICK, stage_onClickHandler);
		}
		
		/**
		 * 	Setting level data
		 * 	<br><b>param: game data json object
		 */
		public function setLevelWithData(json:Object):void
		{
			// setting starting properties
			_currWaveIdx = 0;
			_money = json.money;
			_lives = json.lives;
			_tileWidth = json.map.tileWidth;
			_tileHeight = json.map.tileHeight;
			Config.params.TILE_WIDTH = _tileWidth;
			Config.params.TILE_HEIGHT = _tileHeight;
			Config.params.DIAG_DIST = Math.sqrt(_tileWidth * _tileWidth + _tileHeight * _tileHeight) * .5;
			Config.params.MAP_COLUMNS = json.map.columns;
			Config.params.MAP_ROWS = json.map.rows;
			_cellsOffsetX = _tileWidth * .5 * (Config.params.MAP_ROWS - 1);
			_mapOffsetX = json.map.xOffset;
			_mapOffsetY = json.map.yOffset;
			
			// placing layers to match map's offset
			_creepsLayer.x = _bulletsLayer.x = _towersLayer.x = _mapOffsetX;
			_creepsLayer.y = _bulletsLayer.y = _towersLayer.y = _mapOffsetY;
			
			// giving map data for parsing and processing
			_mapMan.processMapData(json.map.mapData);
			
			// setting up UI
			_uiMan.setupUI();
			_uiMan.updateMoney(_money);
			_uiMan.updateLives(_lives);
			_uiMan.addEventListener(UIManager.TOWER_SELECT, towerBtn_onSelectHandler);

			// populating data arrays
			var i:int, j:int;
			var arr:Array = json.enemies.creeps;
			var creepData:CreepData;
			_creepsData.length = 0;
			for (i = 0; i < arr.length; i++)
			{
				creepData = new CreepData(arr[i]);
				creepData.setTextueData(_assets.getTextureData(creepData.name + "_" + DirectionType.TOP));
				_creepsData[i] = creepData;
			}
			
			arr = json.enemies.waves;
			_waves.length = 0;
			for (i = 0; i < arr.length; i++)
				_waves[i] = new Wave(arr[i]);
			
			arr = json.allies.towers;
			_towersData.length = 0;
			_bulletsData.length = 0;
			var towerData:TowerData;
			var bulletData:BulletData;
			var included:Boolean;
			for (i = 0; i < arr.length; i++)
			{
				towerData = new TowerData(arr[i]);
				towerData.setTextueData(_assets.getTextureData(towerData.name));
				_towersData[i] = towerData;
				_uiMan.addTowerButton(towerData.name, _assets.getTexture(towerData.icon));
				
				// in case bullets will be same for different towers
				included = false;
				for (j = 0; j < _bulletsData.length; j++)
				{
					if (_bulletsData[j].type == towerData.bulletType)
					{
						included = true;
						break;
					}
				}
				
				if (!included)
				{
					bulletData = new BulletData(arr[i]);
					_bulletsData.push(bulletData);
				}
			}
			
			// adding map to stage
			if (!_mapImage)
			{
				_mapImage = new Image(_assets.getTexture(Config.assets.MAP_IMAGE));
				_target.addChildAt(_mapImage, 0);
			}
			
			// setting wave timer
			if (!_waveTimer)
			{
				_waveTimer = new Timer(1, 1);
				_waveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, waveTimer_onCompleteHandler);
			}
		}
		
		/**
		 * 	The main update loop
		 * 	<br><b>param: passed time
		 */
		public function update(elapsedTime:Number):void
		{
			if (_waveIsActive == false && !_waveTimer.running)
			{
				// if all creeps are destroyed call winning event
				if (_currWaveIdx >= _waves.length)
					dispatchEventWith(GAME_WON);
				
				// getting next wave
				_waveTimer.reset();
				_waveTimer.start();
				_currWave = _waves[_currWaveIdx].clone();
				_spawnDelay = _currWave.creepGap / _currWave.creepSpd;
				_startTime = elapsedTime;
				_currWaveIdx++;
				Spawn.clear();
			}
			else if (_waveIsActive)
			{
				if (_currWave.creepNum > 0)
				{
					if (_spawnTime >= _spawnDelay)
					{
						// create new creep after some time
						_currWave.creepNum--;
						_startTime = elapsedTime;
						_spawnTime = 0;
						
						var newCreep:Creep = creepForSpawnType(_currWave.spawningType);
						newCreep.addEventListener(Creep.KILLED, creep_onKilledHandler);
						newCreep.addEventListener(Creep.REACHED_TARGET, creep_onReachedTargetHandler);
						_creeps.push(newCreep);
						_creepsLayer.addChild(newCreep);
					}
					else
					{
						// elapsing spawn time
						_spawnTime += .01;
					}
				}
				// deactivate wave if creeps and queue are empty
				if (_creeps.length == 0 && _currWave.creepNum <= 0)
					_waveIsActive = false;
			}
			
			// updating every creep
			if (_creeps.length)
			{
				for (var i:int = _creeps.length - 1; i >= 0; i--)
					_creeps[i].update(elapsedTime);
			}
			
			// updating every tower
			if (_towers.length)
			{
				var tower:Tower, creep:Creep, fired:Boolean, dist:int = 9999, nearest:Creep;
				for (var t:int = 0; t < _towers.length; t++)
				{
					tower = _towers[t];
					tower.update(elapsedTime);
					fired = false;
					for (var c:int = 0; c < _creeps.length; c++)
					{
						creep = _creeps[c];
						// checking intersection of tower's range with creeps
						if (tower.canFire() && tower.inRange(creep))
						{
							// Mass hit bullets should behave differently than Single hit bullets
							if (tower.data.bulletType == BulletType.MASS_HIT)
							{
								// shooting multiple targets
								towerFireAt(tower, creep);
								fired = true;
							}
							else
							{
								// finding nearest creep to end point
								if (creep.totalDistance < dist)
								{
									nearest = creep;
									dist = creep.totalDistance;
								}
							}
						}
					}
					if (tower.data.bulletType == BulletType.MASS_HIT && fired)
						tower.fired();
					else if (tower.data.bulletType != BulletType.MASS_HIT)
					{
						if (nearest)
						{
							// shooting nearest creep
							towerFireAt(tower, nearest);
							tower.fired();
							nearest = null;
						}
					}
				}
			}
			
			// updating every bullet
			if (_bullets.length)
			{
				for(var b:int = _bullets.length - 1; b >= 0; b--)
				{
					_bullets[b].update(elapsedTime);
				}
			}
			
			// updating lives display
			if (_lives != _livesOld)
			{
				_livesOld = _lives;
				_uiMan.updateLives(_lives);
				if (_lives == 0)
					// called when lives are equal to zero
					dispatchEventWith(GAME_LOST);
			}
			
			// updating money display
			if (_money != _moneyOld)
			{
				_moneyOld = _money;
				_uiMan.updateMoney(_money);
				var td:TowerData;
				for (var j:int = 0; j < _towersData.length; j++)
				{
					td = _towersData[j];
					// disabling or enabling tower buttons according to money
					if (_money < td.cost)
						_uiMan.disableTowerButton(td.name);
					else
						_uiMan.disableTowerButton(td.name, false);
				}
			}
			
			// updating tower's blueprint
			if (_towerBp)
			{
				// getting mouse coordinates
				const stageX:Number = Starling.current.nativeStage.mouseX - _mapOffsetX;
				const stageY:Number = Starling.current.nativeStage.mouseY - _mapOffsetY;
				
				// getting coordinates according to maps offset
				const ty:Number = ((_tileWidth / _tileHeight) * stageY - (stageX - _cellsOffsetX)) * .5;
				const tx:Number = (stageX - _cellsOffsetX) + ty;
				
				// getting row and column indexes of point under mouse
				const row:int = Math.round(ty / (_tileWidth * .5));
				const col:int = Math.round(tx / (_tileWidth * .5));
				
				var pnt:Point = _towerBp.size;
				_mouseCoords.setTo(col, row);
				for (var _y:int = 0; _y < pnt.y; _y++)
				{
					for (var _x:int = 0; _x < pnt.x; _x++)
						_towerBp.updateTile(_y, _x, _mapMan.isTileFree(_y + row, _x + col));
				}
				
				// moving tower's blueprint coordinates
				_towerBp.x = (_tileWidth * .5) * (col - row) + _cellsOffsetX;
				_towerBp.y = (_tileHeight * .5) * (col + row);
			}
		}
		
		/**
		 * 	Build tower in chosen location
		 */
		private function placeTower():void
		{
			// getting tower data
			var td:TowerData;
			for (var i:int = 0; i < _towersData.length; i++)
			{
				if (_towersData[i].name == _towerBp.name)
				{
					td = _towersData[i];
					break;
				}
			}
			// creating tower
			var tower:Tower = new Tower();
			tower.useHandCursor = true;
			tower.touchGroup = true;
			tower.addEventListener(TouchEvent.TOUCH, tower_onClickHandler);
			tower.x = (_tileWidth * .5) * (_mouseCoords.x - _mouseCoords.y - 1) + _cellsOffsetX;
			tower.y = (_tileHeight * .5) * (_mouseCoords.x + _mouseCoords.y);
			tower.setData(td);
			_towers.push(tower);
			_towersLayer.addChild(tower);
			_mapMan.occupy(new Rectangle(_mouseCoords.x - 1, _mouseCoords.y - 1, _towerBp.size.x + 2, _towerBp.size.y + 2));
			_money -= tower.data.cost;
		}
		
		/**
		 * 	Tower shooting at target
		 * 	<br><b>param tower: tower which is shooting
		 * 	<br>param creep: targeted creep
		 */
		private function towerFireAt(tower:Tower, creep:Creep):void
		{
			// getting bullet data
			var bd:BulletData;
			for (var i:int = 0; i < _bulletsData.length; i++)
			{
				if (tower.data.bulletType == _bulletsData[i].type)
				{
					bd = _bulletsData[i];
					break;
				}
			}
			// creating bullet
			var bullet:Bullet = new Bullet();
			bullet.addEventListener(Bullet.DESTROYED, bullet_onDestroyedHandler);
			bullet.setData(bd);
			bullet.setOrigin(tower);
			bullet.setTarget(creep);
			_bullets.push(bullet);
			_bulletsLayer.addChild(bullet);
		}
		
		/**
		 * 	Creating creep according to spawning type
		 * 	<br><b>param:  spawn type
		 * 	<br>return: creep
		 */
		private function creepForSpawnType(type:int = 0):Creep
		{
			switch (type) {
				case SpawnType.STRAIGHT:
					return Spawn.creepForTypeStraight(_currWave, _creepsData, _mapMan.startingPoints, _mapMan.getPathWithStartingPointName);
					break;
				case SpawnType.MIX:
					return Spawn.creepForTypeMix(_currWave, _creepsData, _mapMan.startingPoints, _mapMan.getPathWithStartingPointName);
					break;
			}
			return null;
		}
		
		/**
		 * 	Removing creep from game
		 * 	<br><b>param: creep which will be removed
		 */
		private function removeCreep(creep:Creep):void
		{
			if (creep)
			{
				creep.removeEventListener(Creep.KILLED, creep_onKilledHandler);
				creep.removeEventListener(Creep.REACHED_TARGET, creep_onReachedTargetHandler);
				_creeps.splice(_creeps.indexOf(creep), 1);
				creep.removeFromParent(true);
			}
		}
		
		/**
		 * 	Stopping game and removing all objects from the screen
		 */
		public function stopGame():void
		{
			if (_towerBp)
			{
				_towerBp.removeFromParent(true);
				_towerBp = null;
			}
			
			var element:Sprite;
			if (_towers.length)
			{
				for each(element in _towers)
				{
					element.removeFromParent(true);
					element = null;
				}
				_towers.length = 0;
			}
			if (_creeps.length)
			{
				for each(element in _creeps)
				{
					element.removeFromParent(true);
					element = null;
				}
				_creeps.length = 0;
			}
			if (_bullets.length)
			{
				for each(element in _bullets)
				{
					element.removeFromParent(true);
					element = null;
				}
				_bullets.length = 0;
			}
			if (_currTower)
			{
				_currTower = null;
			}
			if (_creepsLayer)
			{
				_creepsLayer.removeFromParent(true);
				_creepsLayer = null;
			}
			if (_bulletsLayer)
			{
				_bulletsLayer.removeFromParent(true);
				_bulletsLayer = null;
			}
			if (_towersLayer)
			{
				_towersLayer.removeFromParent(true);
				_towersLayer = null;
			}
			if (_uiLayer)
			{
				_uiLayer.removeFromParent(true);
				_uiLayer = null;
			}
		}
		
		////////////////////////////
		/// EVENT HANDLERS
		////////////////////////////
		
		/**
		 * 	Handler for showing tower's perimeter
		 */
		protected function tower_onClickHandler(event:TouchEvent):void
		{
			if (event.touches[0].phase == TouchPhase.ENDED)
			{
				if (_currTower)
					_currTower.hidePerimeter();
				
				const tower:Tower = event.target as Tower;
				tower.showPerimeter();
				_currTower = tower;
			}
		}
		
		/**
		 * 	Handler for hiding tower's perimeter
		 */
		protected function stage_onClickHandler(event:MouseEvent):void
		{
			if (_currTower)
				_currTower.hidePerimeter();
		}
		
		/**
		 * 	Handler for creating blueprint
		 */
		protected function towerBtn_onSelectHandler(event:Event):void
		{
			if (_towerBp)
				return;
			
			_towerBp = new TowerBlueprint();
			_towerBp.init(event.data as String);
			_towersLayer.addChild(_towerBp);
			
			Mouse.hide();
			Starling.current.nativeStage.addEventListener(MouseEvent.CLICK, tower_onPlacementHandler);
		}
		
		/**
		 * 	Handler for placing tower
		 */
		protected function tower_onPlacementHandler(event:MouseEvent):void
		{
			if (_towerBp.canPlace())
			{
				Starling.current.nativeStage.removeEventListener(MouseEvent.CLICK, tower_onPlacementHandler);
				Mouse.show();
				placeTower();
				
				if (_towerBp)
				{
					_towerBp.removeFromParent(true);
					_towerBp = null;
				}
			}
		}
		
		/**
		 * 	Handler for removing creep
		 */
		protected function creep_onKilledHandler(event:Event):void
		{
			_money += event.data;
			removeCreep(event.target as Creep);
		}
		
		/**
		 * 	Handler for subtracting lives
		 */
		protected function creep_onReachedTargetHandler(event:Event):void
		{
			_lives--;
			removeCreep(event.target as Creep);
		}
		
		/**
		 * 	Handler for destroying bullets
		 */
		protected function bullet_onDestroyedHandler(event:Event):void
		{
			var bullet:Bullet = event.target as Bullet;
			if (bullet)
			{
				bullet.removeEventListener(Bullet.DESTROYED, bullet_onDestroyedHandler);
				_bullets.splice(_bullets.indexOf(bullet), 1);
				bullet.removeFromParent(true);
			}
		}
		
		/**
		 * 	Handler for stopping wave timer
		 */
		protected function waveTimer_onCompleteHandler(event:TimerEvent):void
		{
			_waveTimer.stop();
			_waveIsActive = true;
		}
	}
}