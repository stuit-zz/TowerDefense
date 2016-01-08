package testtd.model.tower
{
	import testtd.utils.TextureDataFrame;

	public class TowerData
	{
		// tower's asset name
		public var name:String;
		
		// icon for UI
		public var icon:String;
		
		// how much money will this tower costs
		public var cost:int;
		
		// targeting range of the tower
		public var radius:Number;
		
		// time for cooling down
		public var fireRate:Number;
		
		// type of the bullet
		public var bulletType:int;
		
		// texture data helper
		public var textureData:TextureDataFrame;
		
		// offsets from tower's coordinates for shooting
		public var firePointX:Number;
		public var firePointY:Number;
		
		/**
		 * 	Object for storing tower data.
		 * 	<br><b>param: json object
		 */
		public function TowerData(towerData:Object)
		{
			name = towerData.name;
			icon = towerData.icon;
			cost = towerData.cost;
			radius = towerData.radius;
			fireRate = towerData.fire_rate;
			bulletType = towerData.bullet_type;
			firePointX = towerData.fire_pointx;
			firePointY = towerData.fire_pointy;
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