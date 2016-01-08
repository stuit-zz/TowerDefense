package testtd
{
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	import testtd.managers.AssetManager;
	import testtd.managers.GameManager;
	import testtd.utils.Config;
	
	public class Game extends Sprite
	{
		// game's main managing object
		private var _gameMan:GameManager;
		
		// setting state to pause
		private var _currentState:int = Config.state.PAUSE_STATE;
		
		/**
		 * 	Starts game.
		 */
		public function startGame():void
		{
			if (stage)
				stageReady();
			else
				addEventListener(Event.ADDED_TO_STAGE, game_onAddedToStageHandler);
		}
		
		/**
		 * 	Called when stage is available.
		 */
		private function stageReady():void
		{
			_gameMan = new GameManager(this);
			
			// setting data for next level if leveling would be available
			_gameMan.setLevelWithData(AssetManager.instance.json);
			
			// linking listeners for state changes
			_gameMan.addEventListener(GameManager.GAME_WON, game_onWinHandler);
			_gameMan.addEventListener(GameManager.GAME_LOST, game_onLostHandler);
			
			// adding listeners for main game loop
			addEventListener(Event.ENTER_FRAME, update);
			
			// setting state to play the game
			_currentState = Config.state.GAME_RUNNING_STATE;
		}
		
		/**
		 * 	Game's main loop.
		 */
		private function update(event:Event):void
		{
			if (_currentState == Config.state.GAME_RUNNING_STATE)
			{
				_gameMan.update(Starling.juggler.elapsedTime);
			}
			else if (_currentState == Config.state.GAME_WON_STATE)
			{
				_gameMan.stopGame();
				var won:TextField = new TextField(stage.stageWidth, 100, "YOU WON", "Verdana", 60, 0x00ff00, true);
				won.x = (stage.stageWidth - won.width) * .5;
				won.y = (stage.stageHeight - won.height) * .5;
				addChild(won);
				_currentState = Config.state.PAUSE_STATE;
			}
			else if (_currentState == Config.state.GAME_OVER_STATE)
			{
				_gameMan.stopGame();
				var lost:TextField = new TextField(stage.stageWidth, 100, "GAME OVER", "Verdana", 60, 0xff0000, true);
				lost.x = (stage.stageWidth - lost.width) * .5;
				lost.y = (stage.stageHeight - lost.height) * .5;
				addChild(lost);
				_currentState = Config.state.PAUSE_STATE;
			}
		}
		
		/////////////////////////
		///  EVENT HANDLERS
		/////////////////////////
		protected function game_onAddedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, game_onAddedToStageHandler);
			stageReady();
		}
		
		/**
		 * 	Called when all creeps have been beaten.
		 */
		protected function game_onWinHandler(event:Event):void
		{
			_currentState = Config.state.GAME_WON_STATE;
		}
		
		/**
		 * 	Called when no more lives left.
		 */
		protected function game_onLostHandler(event:Event):void
		{
			_currentState = Config.state.GAME_OVER_STATE;
		}
	}
}