package com.makr.jumpnbump
{
	import com.makr.jumpnbump.objects.ImgButton;
	import com.makr.jumpnbump.objects.RadioButton;
	import flash.geom.Point;
	import org.flixel.*;

	public class LevelSelectState extends FlxState
	{
		
		[Embed(source = '../../../../data/levels/original/thumb.png')] 	private var ImgThumbOriginal:Class;
		[Embed(source = '../../../../data/levels/topsy/thumb.png')]		private var ImgThumbTopsy:Class;
		[Embed(source = '../../../../data/levels/jump2/thumb.png')] 	private var ImgThumbJump2:Class;
		[Embed(source = '../../../../data/levels/green/thumb.png')] 	private var ImgThumbGreen:Class;
		[Embed(source = '../../../../data/levels/rabtown/thumb.png')] 	private var ImgThumbRabtown:Class;
		[Embed(source = '../../../../data/levels/crystal2/thumb.png')] 	private var ImgThumbCrystal2:Class;
		[Embed(source = '../../../../data/levels/witch/thumb.png')] 	private var ImgThumbWitch:Class;
		
		private var _levelButtons:Array = new Array;
		private var _currentLevel:int = -1;
		
		private var _modeButtons:Array = new Array;
		private var _currentMode:int = -1;

		public function LevelSelectState() 
		{
			FlxG.showCursor(null);

			switch (FlxG.levels[0])
			{
				case "lotf":
					_currentMode = 1;
					break;
				
				case "dm":
				default:
					_currentMode = 0;
					break;
			}
			
			switch (FlxG.levels[1])
			{
				case "topsy":
					_currentLevel = 1;
					break;
				
				case "jump2":
					_currentLevel = 2;
					break;

				case "green":
					_currentLevel = 3;
					break;
				
				case "rabtown":
					_currentLevel = 4;
					break;
				
				case "crystal2":
					_currentLevel = 5;
					break;

				case "witch":
					_currentLevel = 6;
					break;

				case "original":
				default:
					_currentLevel = 0;
					break;
			}

			
			// fade in
			FlxG.flash(0xff000000, 0.4);
		
			super();
			
			var titleText:FlxText = new FlxText(12, 14, 112, "Options");
			titleText.color = 0xffffff
			titleText.size = 16;
			this.add(titleText);

			
			var levelBox:Point = new Point(16, 62);
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 0, levelBox.y + 64 * 0, 	ImgThumbOriginal, 	handleButtonOriginal,	"Original"));
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 1, levelBox.y + 64 * 0, 	ImgThumbTopsy, 		handleButtonTopsy,		"Topsy Turvey"));
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 2, levelBox.y + 64 * 0, 	ImgThumbJump2, 		handleButtonJump2,		"Jump 2"));
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 3, levelBox.y + 64 * 0, 	ImgThumbGreen, 		handleButtonGreen,		"Green Land"));
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 0, levelBox.y + 64 * 1, 	ImgThumbRabtown, 	handleButtonRabtown,	"Rabbit Town"));
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 1, levelBox.y + 64 * 1, 	ImgThumbCrystal2, 	handleButtonCrystal2,	"Crystal 2"));
			_levelButtons.push(new ImgButton(levelBox.x + 96 * 2, levelBox.y + 64 * 1, 	ImgThumbWitch, 		handleButtonWitch,		"Witch"));
			
			var exitButtonText:FlxText = new FlxText(5, 1, 50, "done");
			exitButtonText.color = 0x000000
			exitButtonText.size = 16;

			var exitButtonTextAlt:FlxText = new FlxText(5, 1, 50, "done");
			exitButtonTextAlt.color = 0x001020
			exitButtonTextAlt.size = 16;
			
			var exitButton:FlxButton = new FlxButton(324, 203, exitMenu);
			exitButton.width = 60;
			exitButton.height = 24;
			exitButton.loadGraphic(
				new FlxSprite().createGraphic(exitButton.width, exitButton.height, 0xff666666), 
				new FlxSprite().createGraphic(exitButton.width, exitButton.height, 0xff006FD7));
			exitButton.loadText(exitButtonText, exitButtonTextAlt);
			this.add(exitButton);
			
			for each (var button:ImgButton in _levelButtons)
			{
				this.add(button);
			}
			
			_levelButtons[_currentLevel].switchOn();
			
			var modeBox:Point = new Point(12, 185);
			var modeText:FlxText = new FlxText(modeBox.x, modeBox.y, 112, "Gamemode:");
			modeText.color = 0xffffff
			_modeButtons.push(new RadioButton(modeBox.x, modeBox.y + 16, "Deathmatch", 			handleRadioButtonDM, 	112));
			_modeButtons.push(new RadioButton(modeBox.x, modeBox.y + 32, "Lord of the Flies", 	handleRadioButtonLOTF,  112));
			this.add(modeText);

			for each (var radioButton:RadioButton in _modeButtons)
			{
				this.add(radioButton);
			}

			_modeButtons[_currentMode].switchOn();
			
		}

		
		
		override public function update():void
        {
			
			super.update();
		}
		
		private function handleButtonOriginal():void	{ handleButtonPress(0); }
		private function handleButtonTopsy():void		{ handleButtonPress(1); }
		private function handleButtonJump2():void		{ handleButtonPress(2); }
		private function handleButtonGreen():void		{ handleButtonPress(3); }
		private function handleButtonRabtown():void		{ handleButtonPress(4); }
		private function handleButtonCrystal2():void	{ handleButtonPress(5); }
		private function handleButtonWitch():void		{ handleButtonPress(6); }
		private function handleButtonPress(buttonID:uint):void
		{
			for each (var button:ImgButton in _levelButtons)
			{
				button.switchOff();
			}
			_levelButtons[buttonID].switchOn();
			_currentLevel = buttonID;

		}

		private function handleRadioButtonDM():void		{ handleRadioButtonPress(0); }
		private function handleRadioButtonLOTF():void	{ handleRadioButtonPress(1); }
		private function handleRadioButtonPress(radioButtonID:uint):void
		{
			for each (var radiobutton:RadioButton in _modeButtons)
			{
				radiobutton.switchOff();
			}
			_modeButtons[radioButtonID].switchOn();
			_currentMode = radioButtonID;

		}

		
        private function exitMenu():void
        {
			FlxG.fade(0xff000000, 0.4, changeState);
        }
		
		private function changeState():void
		{
			switch (_currentMode)
			{
				case 0:
					FlxG.levels[0] = "dm";
					break;
				
				case 1:
					FlxG.levels[0] = "lotf";
					break;
			}
			
			switch (_currentLevel)
			{
				case 1:
					FlxG.levels[1] = "topsy";
					break;
				
				case 2:
					FlxG.levels[1] = "jump2";
					break;

				case 3:
					FlxG.levels[1] = "green";
					break;
				
				case 4:
					FlxG.levels[1] = "rabtown";
					break;
				
				case 5:
					FlxG.levels[1] = "crystal2";
					break;

				case 6:
					FlxG.levels[1] = "witch";
					break;

				case 0:
					FlxG.levels[1] = "original";
					break;
			}

			FlxG.switchState(PlayerSelectState);
		}
	}
}