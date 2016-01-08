package testtd.model.enemy
{
	import flash.utils.Dictionary;
	
	import testtd.managers.AssetManager;
	import testtd.utils.TextureDataFrame;

	public class CreepData
	{
		// creep's asset name
		public var name:String;
		
		// dictionary for chaching animation
		public var anims:Dictionary = new Dictionary(true);
		
		// texture data helper
		public var textureData:TextureDataFrame;
		
		// offsets from creep's coordinates for targeting
		public var targetX:Number;
		public var targetY:Number;
		
		/**
		 * 	Object for storing creep data.
		 * 	<br><b>param: json object
		 */
		public function CreepData(creepData:Object)
		{
			var assets:AssetManager = AssetManager.instance;
			
			name = creepData.name;
			
			// caching 8-direction movement textures
			anims[DirectionType.TOP_LEFT] = assets.getTextures(name + "_" + creepData.dir_ul);
			anims[DirectionType.TOP] = assets.getTextures(name + "_" + creepData.dir_u);
			anims[DirectionType.TOP_RIGHT] = assets.getTextures(name + "_" + creepData.dir_ur);
			anims[DirectionType.RIGHT] = assets.getTextures(name + "_" + creepData.dir_r);
			anims[DirectionType.DOWN_RIGHT] = assets.getTextures(name + "_" + creepData.dir_dr);
			anims[DirectionType.DOWN] = assets.getTextures(name + "_" + creepData.dir_d);
			anims[DirectionType.DOWN_LEFT] = assets.getTextures(name + "_" + creepData.dir_dl);
			anims[DirectionType.LEFT] = assets.getTextures(name + "_" + creepData.dir_l);
			
			// setting target's coordinate offsets for bullets
			targetX = creepData.target_x;
			targetY = creepData.target_y;
		}
		
		/**
		 * 	Adding texture data.
		 * 	<br><b>param: texture data
		 */
		public function setTextueData(txrData:TextureDataFrame):void
		{
			textureData = txrData;
		}
	}
}