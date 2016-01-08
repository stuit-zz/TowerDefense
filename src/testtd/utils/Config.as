package testtd.utils
{
	public class Config
	{
		private static var _assets:Assets;
		private static var _state:GameStates;
		private static var _params:Parameters;
		
		public static function get assets():Assets
		{
			return _assets || (_assets = new Assets());
		}
		
		public static function get params():Parameters
		{
			return _params || (_params = new Parameters());
		}
		
		public static function get state():GameStates
		{
			return _state || (_state = new GameStates());
		}
	}
}

class Assets
{
	public const MAP_IMAGE					:String = 'map';
}

class Parameters
{
	public var TILE_WIDTH					:Number = 0;
	public var TILE_HEIGHT					:Number = 0;
	public var DIAG_DIST					:Number = 0;
	public var MAP_COLUMNS					:int = 0;
	public var MAP_ROWS						:int = 0;
}

class GameStates
{
	public const PAUSE_STATE				:int = 0;
	public const GAME_RUNNING_STATE			:int = 1;
	public const GAME_OVER_STATE			:int = 2;
	public const GAME_WON_STATE				:int = 3;
}