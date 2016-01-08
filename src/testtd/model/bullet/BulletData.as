package testtd.model.bullet
{
	public class BulletData
	{
		// color of the bullet
		public var color:uint;
		
		// type of the bullet
		public var type:int;
		
		// how much damage would this bullet inflict on target
		public var damage:Number;
		
		/**
		 * 	Object for storing bullet data.
		 * 	<br><b>param: json object
		 */
		public function BulletData(data:Object)
		{
			color = data.bullet_color;
			type = data.bullet_type;
			damage = data.damage;
		}
	}
}