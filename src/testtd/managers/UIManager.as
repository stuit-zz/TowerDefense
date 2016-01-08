package testtd.managers
{
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.HAlign;

	public class UIManager extends EventDispatcher
	{
		public static const TOWER_SELECT:String = "TOWER_SELECT";
		
		// parent sprite
		private var _target:Sprite;
		
		// money amount showing text fields
		private var _moneyLbl:TextField;
		private var _moneyInfo:TextField;
		
		// left lives showing text fields
		private var _livesLbl:TextField;
		private var _livesInfo:TextField;
		
		// tower buttons
		private var _towerBtns:Vector.<Button> = new Vector.<Button>();
		
		public function UIManager(target:Sprite)
		{
			_target = target;
		}
		
		/**
		 * 	Initiating user interface
		 */
		public function setupUI():void
		{
			_moneyLbl = new TextField(100, 30, "Credits:", "Verdana", 16, 0xffffff, true);
			_moneyLbl.autoSize = TextFieldAutoSize.HORIZONTAL;
			_moneyLbl.x = 10;
			_moneyLbl.y = 10;
			_target.addChild(_moneyLbl);
			
			_moneyInfo = new TextField(200, 30, "0", "Verdana", 16, 0x00ff00, true);
			_moneyInfo.hAlign = HAlign.LEFT;
			_moneyInfo.x = _moneyLbl.bounds.right + 10;
			_moneyInfo.y = 10;
			_target.addChild(_moneyInfo);
			
			_livesLbl = new TextField(100, 30, "Lives:", "Verdana", 16, 0xffffff, true);
			_livesLbl.autoSize = TextFieldAutoSize.HORIZONTAL;
			_livesLbl.x = 10;
			_livesLbl.y = _moneyLbl.bounds.bottom + 10;
			_target.addChild(_livesLbl);
			
			_livesInfo = new TextField(200, 30, "0", "Verdana", 16, 0xff0000, true);
			_livesInfo.hAlign = HAlign.LEFT;
			_livesInfo.x = _livesLbl.bounds.right + 10;
			_livesInfo.y = _livesLbl.y;
			_target.addChild(_livesInfo);
		}
		
		/**
		 * 	Updating money amount
		 * 	<br><b>param: money amount
		 */
		public function updateMoney(amount:Number):void
		{
			_moneyInfo.text = amount.toString();
		}
		
		/**
		 * 	Updating lives left
		 * 	<br><b>param: lives left
		 */
		public function updateLives(amount:int):void
		{
			_livesInfo.text = amount.toString();
		}
		
		/**
		 * 	Adding tower button
		 * 	<br><b>param id: tower ID
		 * 	<br>param image: tower icon
		 */
		public function addTowerButton(id:String, image:Texture):void
		{
			var btn:Button = new Button(image);
			btn.addEventListener(Event.TRIGGERED, towerBtn_onTriggerHandler);
			btn.name = id;
			_target.addChild(btn);
			
			btn.x = 10;
			btn.y = _towerBtns.length * (btn.height + 10) + _livesInfo.bounds.bottom + 10;
			_towerBtns.push(btn);
		}
		
		/**
		 * 	Disabling/enabling tower button
		 * 	<br><b>param id: tower button ID
		 * 	<br>param disable: enabling or disabling
		 */
		public function disableTowerButton(id:String, disable:Boolean = true):void
		{
			for (var i:int = 0; i < _towerBtns.length; i++)
			{
				var btn:Button = _towerBtns[i];
				if (id == btn.name)
				{
					if (disable)
					{
						btn.enabled = false;
						btn.alpha = .5;
					}
					else
					{
						btn.enabled = true;
						btn.alpha = 1;
					}
				}
			}
		}
		
		protected function towerBtn_onTriggerHandler(event:Event):void
		{
			// called when tower button is clicked
			dispatchEventWith(TOWER_SELECT, false, Button(event.target).name);
		}
	}
}