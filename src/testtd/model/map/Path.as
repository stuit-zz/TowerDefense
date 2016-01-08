package testtd.model.map
{

	public class Path
	{
		// name of the path
		private var _name:String;
		
		// total distance of pathway
		private var _totalDistance:Number = 0;
		
		// active path data
		private var _currPath:int = -1;
		
		// all path segments in pathway
		private var _pathDatas:Vector.<PathData> = new Vector.<PathData>();
		
		public function get name():String
		{
			return _name;
		}
		
		public function get totalDistance():Number
		{
			return _totalDistance;
		}
		
		/**
		 * 	Pathway for creeps to follow
		 * 	<br><b>param: name of the pathway
		 */
		public function Path(name:String)
		{
			_name = name;
		}
		
		/**
		 * 	Adding path segment to pathway
		 * 	<br><b>param: path segment
		 */
		public function addPath(pathData:PathData):void
		{
			_totalDistance += pathData.distance;
			_pathDatas.push(pathData);
		}
		
		/**
		 * 	Get next path segment
		 * 	<br><b>return: path data
		 */
		public function getNextPath():PathData
		{
			_currPath++;
			if (_currPath < _pathDatas.length)
				return _pathDatas[_currPath];
			return null;
		}
		
		/**
		 * 	Get copy of pathway
		 * 	<br><b>return: pathway
		 */
		public function clone():Path
		{
			var path:Path = new Path(_name);
			for (var i:int = 0; i < _pathDatas.length; i++)
				path.addPath(_pathDatas[i]);
			return path;
		}
	}
}