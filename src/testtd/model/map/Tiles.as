package testtd.model.map
{
	import starling.display.Image;
	import starling.display.Sprite;
	
	import testtd.utils.Config;
	import testtd.utils.Utils;
	
	public class Tiles extends Sprite
	{
		// grouped tile views
		private var _tiles:Vector.<Vector.<Image>> = new Vector.<Vector.<Image>>();
		
		/**
		 * 	Initiating tiles for view
		 * 	<br><b>param row: number of cells in row
		 * 	<br>param col: number of cells in col
		 */
		public function init(row:int, col:int):void
		{
			var tile:Image;
			for (var i:int = 0; i < row; i++)
			{
				_tiles[i] = new Vector.<Image>();
				for (var j:int = 0; j < col; j++)
				{
					tile = new Image(Utils.getTile());
					tile.x = (Config.params.TILE_WIDTH / 2) * (j - i);
					tile.y = (Config.params.TILE_HEIGHT / 2) * (j + i);
					addChild(tile);
					_tiles[i][j] = tile;
				}
			}
		}
		
		/**
		 * 	Colorizing tile
		 * 	<br><b>param row: cell in row
		 * 	<br>param col: cell in col
		 * 	<br>param newColor: color for tinting
		 */
		public function tintTile(row:int, col:int, newColor:uint):void
		{
			_tiles[row][col].texture = Utils.getTile(newColor);
		}
		
		override public function dispose():void
		{
			var tile:Image;
			for (var i:int = 0; i < _tiles.length; i++)
			{
				_tiles[i] = new Vector.<Image>();
				for (var j:int = 0; j < _tiles[i].length; j++)
				{
					tile = _tiles[i][j];
					tile.removeFromParent(true);
					tile = null;
				}
			}
			super.dispose();
		}
	}
}