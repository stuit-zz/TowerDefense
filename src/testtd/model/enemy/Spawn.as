package testtd.model.enemy
{
	import testtd.model.map.StartingPoint;

	public class Spawn
	{
		// current starting point index
		private static var _currSPIndex:int;
		
		// current creep name index
		private static var _currCNIndex:int;
		
		/**
		 * 	Method for creating creeps straightly in one starting point
		 * 	<br><b>param wave: current wave object
		 * 	<br>param creepDatas: creep data array
		 * 	<br>param statringPoints: starting point data array
		 * 	<br>param pathFactory: function for getting path according to name
		 * 	<br>return: creep
		 */
		public static function creepForTypeStraight(wave:Wave, creepDatas:Vector.<CreepData>, statringPoints:Vector.<StartingPoint>, pathFactory:Function):Creep
		{
			var sp:StartingPoint;
			for (var i:int = 0; i < statringPoints.length; i++)
			{
				if (statringPoints[i].name == wave.startingPnt[0])
				{
					sp = statringPoints[i];
					break;
				}
			}
			var cd:CreepData;
			for (i = 0; i < creepDatas.length; i++)
			{
				if (creepDatas[i].name == wave.creepNames[0])
				{
					cd = creepDatas[i];
					break;
				}
			}
			var creep:Creep = new Creep();
			creep.setData(cd);
			creep.setStartingPoint(sp);
			creep.setWaveData(wave);
			creep.setPath(pathFactory(sp.name));
			return creep;
		}
		
		/**
		 * 	Method for creating creeps in multiple starting points
		 * 	<br><b>param wave: current wave object
		 * 	<br>param creepDatas: creep data array
		 * 	<br>param statringPoints: starting point data array
		 * 	<br>param pathFactory: function for getting path according to name
		 * 	<br>return: creep
		 */
		public static function creepForTypeMix(wave:Wave, creepDatas:Vector.<CreepData>, statringPoints:Vector.<StartingPoint>, pathFactory:Function):Creep
		{
			var sp:StartingPoint;
			for (var i:int = 0; i < statringPoints.length; i++)
			{
				if (statringPoints[i].name == wave.startingPnt[_currSPIndex])
				{
					_currSPIndex++;
					if (_currSPIndex >= wave.startingPnt.length)
						_currSPIndex = 0;
					sp = statringPoints[i];
					break;
				}
			}
			var cd:CreepData;
			for (i = 0; i < creepDatas.length; i++)
			{
				if (creepDatas[i].name == wave.creepNames[_currCNIndex])
				{
					_currCNIndex++;
					if (_currCNIndex >= wave.creepNames.length)
						_currCNIndex = 0;
					cd = creepDatas[i];
					break;
				}
			}
			var creep:Creep = new Creep();
			creep.setData(cd);
			creep.setStartingPoint(sp);
			creep.setWaveData(wave);
			creep.setPath(pathFactory(sp.name));
			return creep;
		}
		
		/**
		 * 	Reseting indexes
		 */
		public static function clear():void
		{
			_currSPIndex = 0;
			_currCNIndex = 0;
		}
	}
}