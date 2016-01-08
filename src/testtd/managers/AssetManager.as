package testtd.managers
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	
	import testtd.utils.TextureDataFrame;

	public class AssetManager extends EventDispatcher
	{
		public static const ASSETS_PARSED:String = "ASSETS_PARSED";
		
		// AssetsManager instance
		private static var _instance:AssetManager;
		
		// dictionary for storing asset data
		private const _assets:Dictionary = new Dictionary(true);
		
		// dictionary for storing textures
		private const _cached:Dictionary = new Dictionary(true);
		
		// json object
		private var _json:Object;
		
		public function AssetManager(enforcer:SingletonEnforcer)
		{
		}
		
		public static function get instance():AssetManager
		{
			if (!_instance)
				_instance = new AssetManager(new SingletonEnforcer());
			return _instance;
		}
		
		// reference for json object
		public function get json():Object
		{
			return _json;
		}
		
		/**
		 * 	Get single texture for the asset name
		 * 	<br><b>param: name of the asset
		 * 	<br>return: texture
		 */
		public function getTexture(name:String):Texture
		{
			if (_cached[name])
				return _cached[name] as Texture;
			else if (_assets[name] is TextureDataFrame)
			{
				var texture:Texture = TextureDataFrame(_assets[name]).data;
				_cached[name] = texture;
				return texture;
			}
			return null;
		}
		
		/**
		 * 	Get texture vector for the asset name
		 * 	<br><b>param: name of the asset
		 * 	<br>return: textures
		 */
		public function getTextures(name:String):Vector.<Texture>
		{
			if (_cached[name])
				return _cached[name] as Vector.<Texture>;
			else if (_assets[name] is Vector.<TextureDataFrame>)
			{
				var datas:Vector.<TextureDataFrame> = _assets[name] as Vector.<TextureDataFrame>;
				var txtrs:Vector.<Texture> = new Vector.<Texture>();
				for (var i:int = 0; i < datas.length; i++)
					txtrs.push(datas[i].data);
				_cached[name] = txtrs;
				return txtrs;
			}
			return null;
		}
		
		/**
		 * 	Get texture data for static asset by its name. This data contains origin point of asset's graphics in swf symbol object before it was parsed.
		 * 	<br><b>param: name of the asset
		 * 	<br>return: texture data with origin coordinates
		 */
		public function getTextureData(name:String):TextureDataFrame
		{
			if (_assets[name] is TextureDataFrame)
				return _assets[name];
			else if (_assets[name] is Vector.<TextureDataFrame>)
				return _assets[name][0];
			return null;
		}
		
		/**
		 * 	Parsing raw json object
		 * 	<br><b>param: downloaded raw json object
		 */
		public function parseData(data:String):void
		{
			// deserializing raw json file to readable json object
			_json = JSON.parse(data);
			
			// loading swf file with assets
			loadSWF(_json.assets);
		}
		
		/**
		 * 	Parses swf file to retrieve assets and dispatches ASSETS_PARSED event after finishing.
		 * 	<br><b>param: loader object which was downloading swf file
		 */
		private function parseSWF(loader:LoaderInfo):void
		{
			// getting all available object reference link names
			var defs:Vector.<String> = loader.applicationDomain.getQualifiedDefinitionNames();
			
			var classObj:Class, classInst:Object, assetObj:Object;
			for (var i:int = 0; i < defs.length; i++)
			{
				// getting class object from linkage
				classObj = loader.applicationDomain.getDefinition(defs[i]) as Class;
				
				// initiating object instance
				classInst = new classObj();
				
				// separating movieclips from static objects
				if (classInst is MovieClip && MovieClip(classInst).totalFrames > 1)
					// extracting movieclip into array of texture datas
					assetObj = extractMovieClip(classInst as MovieClip);
				else if (classInst is Sprite)
					// rasterizing sprite into texture data
					assetObj = rasterizeSprite(classInst as Sprite);
				else
					// can be used for texturizing bitmaps if necessary
					assetObj = classObj;
				
				// storing texture datas in dictionary by their linkage name
				_assets[defs[i]] = assetObj;
			}
			
			// informing about process completion
			dispatchEvent(new Event(ASSETS_PARSED));
		}
		
		private function loadSWF(swfLink:String):void
		{
			var loader:Loader = new Loader();
			loader.load(new URLRequest(swfLink));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoader_onLoadCompleteHandler);
		}
		
		private function swfLoader_onLoadCompleteHandler(event:Event):void
		{
			parseSWF(event.target as LoaderInfo);
		}
		
		/**
		 * 	Parses movieclip object into array of texture datas. This data contains origin point of asset's graphics in swf symbol object before it was parsed.
		 * 	<br><b>param: movieclip
		 * 	<br>return: vector of texture datas
		 */
		private function extractMovieClip(mc:MovieClip):Vector.<TextureDataFrame>
		{
			var txtrs:Vector.<TextureDataFrame> = new Vector.<TextureDataFrame>(mc.totalFrames, true);
			var bmd:BitmapData, rect:Rectangle, textureFrame:TextureDataFrame, texture:Texture;
			for (var i:int = 0; i < mc.totalFrames; i++, mc.nextFrame())
			{
				if (mc.width && mc.height)
				{
					rect = mc.getBounds(mc);
					bmd = new BitmapData(mc.width, mc.height, true, 0);
					bmd.draw(mc, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
					texture = Texture.fromBitmapData(bmd, false);
					textureFrame = new TextureDataFrame(texture, new Point(rect.x, rect.y));
					txtrs[i] = textureFrame;
				}
			}
			return txtrs;
		}
		
		/**
		 * 	Parses sprite object into texture data. This data contains origin point of asset's graphics in swf symbol object before it was parsed.
		 * 	<br><b>param: sprite
		 * 	<br>return: texture data
		 */
		private function rasterizeSprite(sprt:Sprite):TextureDataFrame
		{
			var rect:Rectangle = sprt.getBounds(sprt);
			var bmd:BitmapData = new BitmapData(sprt.width, sprt.height, true, 0);
			bmd.draw(sprt, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
			var texture:Texture = Texture.fromBitmapData(bmd, false);
			var textureFrame:TextureDataFrame = new TextureDataFrame(texture, new Point(rect.x, rect.y));
			return textureFrame;
		}
	}
}
internal class SingletonEnforcer{}

