package testtd.utils
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;

	public class Utils
	{
		// unique id storing object
		private static var _uid:int = -1;
		
		// dictionary for caching parameters
		private static var _cache:Dictionary = new Dictionary(true);
		
		/**
		 * 	Get unique ID
		 * 	<br><b>return: unique id
		 */
		public static function getUID():String
		{
			_uid++;
			return "id" + _uid;
		}
		
		/**
		 * 	Get game tile texture
		 * 	<br><b>param: color for tile
		 * 	<br>return: tile texture
		 */
		public static function getTile(color:uint = 0x00ff00):Texture
		{
			if (_cache[color])
				return _cache[color];
			
			var shp:Shape = new Shape();
			shp.graphics.beginFill(color);
			shp.graphics.moveTo(Config.params.TILE_WIDTH / 2, 0);
			shp.graphics.lineTo(Config.params.TILE_WIDTH, Config.params.TILE_HEIGHT / 2);
			shp.graphics.lineTo(Config.params.TILE_WIDTH / 2, Config.params.TILE_HEIGHT);
			shp.graphics.lineTo(0, Config.params.TILE_HEIGHT / 2);
			shp.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(Config.params.TILE_WIDTH, Config.params.TILE_HEIGHT, true, 0xffffff);
			bmd.draw(shp);
			shp.graphics.clear();
			shp = null;
			
			var txr:Texture = Texture.fromBitmapData(bmd, false);
			_cache[color] = txr;
			return txr;
		}
		
		/**
		 * 	Get perimeter view for tower
		 * 	<br><b>param a: major radius
		 * 	<br>param b: minor radius
		 * 	<br>return: perimeter texture
		 */
		public static function getPerimeter(a:Number, b:Number):Texture
		{
			var pname:String = a + "_" + b;
			if (!a || !b)
				return null;
			else if (_cache[pname])
				return _cache[pname];
			
			var _w:Number = (a + 1) * Config.params.TILE_WIDTH * 2;
			var _h:Number = (b + 1) * Config.params.TILE_HEIGHT * 2;
			
			var shp:Shape = new Shape();
			shp.graphics.lineStyle(.5, 0x00ff00, .5);
			shp.graphics.beginFill(0,0);
			shp.graphics.drawEllipse(0,0,_w,_h);
			shp.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(_w, _h, true, 0xffffff);
			bmd.draw(shp);
			shp.graphics.clear();
			shp = null;
			
			var txr:Texture = Texture.fromBitmapData(bmd, false);
			_cache[pname] = txr;
			return txr;
		}
	}
}