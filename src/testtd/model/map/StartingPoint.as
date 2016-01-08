package testtd.model.map
{
	import flash.geom.Point;

	public class StartingPoint
	{
		// name of the starting point
		public var name:String;
		
		// direction for movement
		public var direction:String;
		
		// starting point
		public var coords:Point;
		
		/**
		 * 	Object of starting location for creeps to start moving
		 * 	<br><b>param name: name of the starting point
		 * 	<br>param dir: movement starting direction
		 */
		public function StartingPoint(name:String, dir:String)
		{
			this.name = name;
			this.direction = dir;
		}
	}
}