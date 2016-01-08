package testtd.managers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import testtd.utils.Config;
	import testtd.model.enemy.DirectionType;
	import testtd.model.map.Path;
	import testtd.model.map.PathData;
	import testtd.model.map.StartingPoint;

	public class MapManager
	{
		// map's array
		private var _map:Array = [];
		
		// starting points in map
		private var _startingPnts:Vector.<StartingPoint> = new Vector.<StartingPoint>();
		
		// pathways in map
		private var _paths:Vector.<Path> = new Vector.<Path>();
		
		public function get startingPoints():Vector.<StartingPoint>
		{
			return _startingPnts;
		}
		
		/**
		 * 	Parsing map data
		 * 	<br><b>param: map's json object
		 */
		public function processMapData(mapData:Array):void
		{
			_map = mapData;
			findStartingPoints();
			findPaths();
		}
		
		/**
		 * 	Getting path for path name
		 * 	<br><b>param: name of the path
		 * 	<br>return: pathway
		 */
		public function getPathWithStartingPointName(spName:String):Path
		{
			for each(var p:Path in _paths)
			{
				if (p.name == spName)
					return p.clone();
			}
			return null;
		}
		
		/**
		 * 	Checking if cell is available
		 * 	<br><b>param row: cell row
		 * 	<br>param col: cell column
		 */
		public function isTileFree(row:int, col:int):Boolean
		{
			if (row > 0 && row < _map.length && col > 0 && col < _map[row].length && _map[row][col] == 1)
				return true;
			return false;
		}
		
		/**
		 * 	Set given rect in map as occupied
		 * 	<br><b>param rect: rectangle with coordinates
		 */
		public function occupy(rect:Rectangle):void
		{
			for (var row:int = rect.y, rowlen:int = rect.y + rect.height; row < rowlen; row++)
			{
				for (var col:int = rect.x, collen:int = rect.x + rect.width; col < collen; col++)
				{
					if (row > 0 && row < _map.length && col > 0 && col < _map[row].length)
						_map[row][col] = 0;
				}
			}
		}
		
		/**
		 * 	Running through map cells and find starting points
		 */
		private function findStartingPoints():void
		{
			var sp:StartingPoint;
			var obj:Object;
			_startingPnts.length = 0;
			for (var i:int = 0; i < _map.length; i++)
			{
				for (var j:int = 0; j < _map[i].length; j++)
				{
					obj = _map[i][j];
					if (obj is String && String(obj).indexOf("S") != -1)
					{
						sp = new StartingPoint(obj as String, "");
						sp.coords = new Point(j, i);
						sp.direction = getDirectionFromPoint(i, j);
						_startingPnts.push(sp);
					}
				}
			}
		}
		
		/**
		 * 	Running through map cells and find pathways
		 */
		private function findPaths():void
		{
			var dir:String, x:int, y:int, obj:Object, sp:StartingPoint, pd:PathData, path:Path;
			var idx:int = 0;
			_paths.length = 0;
			for (var i:int = 0; i < _startingPnts.length; i++)
			{
				sp = _startingPnts[i];
				path = new Path(sp.name);
				dir = null;
				do {
					if (!dir)
					{
						dir = sp.direction;
						x = sp.coords.x;
						y = sp.coords.y;
					}
					else
					{
						obj = getNextCoords(dir);
						x = x + obj.x;
						y = y + obj.y;
						dir = _map[y][x];
						obj = getNextCoords(dir);
						if (dir != "E")
						{
							pd = new PathData(dir, obj.dist, new Point(x, y));
							path.addPath(pd);
						}
					}
				} while(dir != "E");
				_paths.push(path);
			}
		}
		
		/**
		 * 	Get coordinates and distance of the next direction
		 * 	<br><b>param: direction
		 */
		private function getNextCoords(dir:String):Object
		{
			if (dir == DirectionType.TOP_LEFT)
				return {x:-1, y:-1, dist:Config.params.TILE_HEIGHT};
			else if (dir == DirectionType.TOP)
				return {x:0, y:-1, dist:Config.params.DIAG_DIST};
			else if (dir == DirectionType.TOP_RIGHT)
				return {x:1, y:-1, dist:Config.params.TILE_WIDTH};
			else if (dir == DirectionType.RIGHT)
				return {x:1, y:0, dist:Config.params.DIAG_DIST};
			else if (dir == DirectionType.DOWN_RIGHT)
				return {x:1, y:1, dist:Config.params.TILE_HEIGHT};
			else if (dir == DirectionType.DOWN)
				return {x:0, y:1, dist:Config.params.DIAG_DIST};
			else if (dir == DirectionType.DOWN_LEFT)
				return {x:-1, y:1, dist:Config.params.TILE_WIDTH};
			else if (dir == DirectionType.LEFT)
				return {x:-1, y:0, dist:Config.params.DIAG_DIST};
			return null;
		}
		
		/**
		 * 	Get direction in x and y coordinate in map
		 */
		private function getDirectionFromPoint(y:int, x:int):String
		{
			for (var i:int = y - 1; i < y + 1; i++)
			{
				for (var j:int = x - 1; j < x + 1; j++)
				{
					if (!(i == y && j == x) && i > 0 && i < _map.length && j > 0 && j < _map[i].length && _map[i][j] is String)
					{
						return _map[i][j];
					}
				}
			}
			return null;
		}
	}
}