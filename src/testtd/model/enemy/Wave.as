package testtd.model.enemy
{
	
	public class Wave
	{
		// wave name
		public var name:String;
		
		// creeps number in wave
		public var creepNum:int;
		
		// creep's hit points
		public var creepHP:int;
		
		// creep's speed
		public var creepSpd:Number;
		
		// distance between creeps
		public var creepGap:Number;
		
		// bounty for killed creep
		public var creepBnty:Number;
		
		// creep names in wave
		public var creepNames:Array;
		
		// starting points for wave
		public var startingPnt:Array;
		
		// creep spawn method
		public var spawningType:int;
		
		// wave data
		private var _data:Object;
		
		/**
		 * 	Creep wave object
		 * 	<br><b>param: wave data
		 */
		public function Wave(waveData:Object)
		{
			_data = waveData;
			name = waveData.name;
			creepNum = waveData.creep_num;
			creepHP = waveData.creep_hp;
			creepSpd = waveData.creep_speed;
			creepGap = waveData.creep_gap;
			creepBnty = waveData.creep_bounty;
			creepNames = waveData.creep_name;
			startingPnt = waveData.starting_point;
			spawningType = waveData.spawning_type;
		}
		
		/**
		 * 	Get copy of the wave
		 * 	<br><b>return: wave object
		 */
		public function clone():Wave
		{
			return new Wave(_data);
		}
	}
}