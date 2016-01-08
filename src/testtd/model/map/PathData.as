package testtd.model.map
{
	import flash.geom.Point;

	public class PathData
	{
		// direction of movement in path segment
		public var direction:String;
		
		// distance of the path segment
		public var distance:Number;
		
		// coordinates of the path segment
		public var point:Point;
		
		/**
		 * 	Object for storing path data.
		 * 	<br><b>param dir: direction of path
		 * 	<br>param dist: distance
		 * 	<br>param pnt: cell coordinates
		 */
		public function PathData(dir:String, dist:Number, pnt:Point)
		{
			direction = dir;
			distance = dist;
			point = pnt;
		}
	}
}