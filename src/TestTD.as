package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import starling.core.Starling;
	
	import testtd.Game;
	import testtd.managers.AssetManager;
	
	[SWF(frameRate="60",width="1275",height="929",wmode="direct")]
	public class TestTD extends Sprite
	{
		// game data, can be delivered with flashvars
		private var link:String = "data/game.json";
		
		// Starling instance
		private var star:Starling;
		
		public function TestTD()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// setting up game
			star = new Starling(Game, stage);
			star.showStats = true;
			star.showStatsAt("right", "top");
			star.stage.stageWidth = 1275;
			star.stage.stageHeight = 929;
			
			// loading json file
			loadData();
		}
		
		private function loadData():void
		{
			const request:URLRequest = new URLRequest(link);
			const loader:URLLoader = new URLLoader(request);
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, assets_onLoadCompleteHandler);
		}
		
		private function assets_onLoadCompleteHandler(event:Event):void
		{
			// parsing json file to load assets.swf and prepare game assets
			AssetManager.instance.parseData(event.target.data as String);
			AssetManager.instance.addEventListener(AssetManager.ASSETS_PARSED, assets_onParseCompleteHandler);
		}
		
		private function assets_onParseCompleteHandler(event:Event):void
		{
			// starting Starling
			star.start();
			
			// starting game
			Game(star.root).startGame();
		}
	}
}