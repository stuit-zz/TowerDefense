package testtd.model.tower
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.display.Sprite;
	
	import testtd.model.map.Tiles;
	
	/**
	 * 	Object for indicating tower's placement tiles the on ground.
	 */
	public class TowerBlueprint extends Sprite
	{
		private var _towerImg:Image;
		
		// placement tiles
		private var _tiles:Tiles;
		
		// width and height size cells
		private var _size:Point;
		
		// dictionary for storing info if cell is placeable
		private var _cellsData:Dictionary = new Dictionary(true);
		
		public function get size():Point
		{
			return _size;
		}
		
		/**
		 * 	Initiating blueprint
		 * 	<br><b>param: name of the tower
		 */
		public function init(name:String):void
		{
			this.name = name;
			_tiles = new Tiles();
			_tiles.init(2,2);
			_size = new Point(2,2);
			addChild(_tiles);
		}
		
		/**
		 * 	Update color of the tile in blueprint
		 * 	<br><b>param row: cell row
		 * 	<br>param col: cell column
		 * 	<br>param isPlaceable: if cell can be placed
		 */
		public function updateTile(row:int, col:int, isPlaceable:Boolean):void
		{
			var color:uint = 0x00ff00;
			if (!isPlaceable)
				color = 0xff0000;
			_tiles.tintTile(row, col, color);
			_cellsData[row + "_" + col] = isPlaceable;
		}
		
		/**
		 * 	If blueprint can be placed
		 */
		public function canPlace():Boolean
		{
			for each(var isPlaceable:Boolean in _cellsData)
			{
				if (!isPlaceable)
					return false;
			}
			return true;
		}
		
		override public function dispose():void
		{
			if (_tiles)
			{
				_tiles.removeFromParent(true);
				_tiles = null;
			}
			if (_towerImg)
			{
				_towerImg.removeFromParent(true);
				_towerImg = null;
			}
			super.dispose();
		}
	}
}