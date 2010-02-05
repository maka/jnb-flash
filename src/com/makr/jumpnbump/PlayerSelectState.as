package com.makr.jumpnbump
{
	import com.makr.jumpnbump.objects.Gib;
	import com.makr.jumpnbump.objects.Spring;
	import flash.geom.Point;
	import org.flixel.*;

	public class PlayerSelectState extends FlxState
	{
		// green level		
		[Embed(source = '../../../../data/levels/green/menu.png')] private var ImgBgGreen:Class;

		// topsy level		
		[Embed(source = '../../../../data/levels/topsy/menu.png')] private var ImgBgTopsy:Class;
		
		// rabtown level		
		[Embed(source = '../../../../data/levels/rabtown/menu.png')] private var ImgBgRabtown:Class;

		
		// original level		
		[Embed(source = '../../../../data/levels/original/menu.png')] private var ImgBgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/menuoverlay.png')] private var ImgFgOriginal:Class;
		private var _bgMusicURLOriginal:String = "../data/levels/original/m_jump.mp3";
		
	
		private var ImgBg:Class;
		private var ImgFg:Class;
		private var _bgMusicURL:String;

		
		private var _player:Array = new Array();
		private var _bg:FlxSprite;
		private var _fg:FlxSprite;
		private var _trunk:Array = new Array();
		
		public static var lyrBG:FlxLayer;
		public static var lyrStage:FlxLayer;
		public static var lyrBGSprites:FlxLayer;
		public static var lyrPlayers:FlxLayer;
		public static var lyrFG:FlxLayer;
		
		private function getAbsValue(x:Number):Number
		{
			if (x < 0)
				return -x;
			else
				return x;
			// return (x ^ (x >> 31)) - (x >> 31);
		}
		
		private function getDistance(a:Point, b:Point):Number
		{
			var deltaX:Number = b.x-a.x;  
			var deltaY:Number = b.y-a.y;  
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY); 
		}

		
		public function PlayerSelectState() 
		{
			FlxG.hideCursor();

			switch (FlxG.levels[1])
			{
				case "green":
					ImgBg = ImgBgGreen;
					ImgFg = ImgFgOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;

				case "topsy":
					ImgBg = ImgBgTopsy;
					ImgFg = ImgFgOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;
			
				case "rabtown":
					ImgBg = ImgBgRabtown;
					ImgFg = ImgFgOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;
				
				
				case "original":
				default:
					ImgBg = ImgBgOriginal;
					ImgFg = ImgFgOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;
			}

			FlxG.music = new FlxSound;
			FlxG.music.loadStream(_bgMusicURL, true);
			FlxG.music.play();

			
			// fade in
			FlxG.flash(0xff000000, 0.4);

			FlxG.levels[2] = FlxG.scores[0] = FlxG.scores[1] = FlxG.scores[2] = FlxG.scores[3] = 0;
			FlxG.score = -1;

			
			super();
			
			

			
			// creating new layers
            lyrBG = new FlxLayer;
            lyrBGSprites = new FlxLayer;
            lyrPlayers = new FlxLayer;
            lyrFG = new FlxLayer;
			
			// creating the background
			_bg = new FlxSprite;
			_bg.loadGraphic(ImgBg, false, false, 400, 256);
			_bg.x = _bg.y = 0;
			lyrBG.add(_bg);	
			
			// creating the foreground
			_fg = new FlxSprite;
			_fg.loadGraphic(ImgFg, false, false, 400, 256);
			_fg.x = _fg.y = 0;
			lyrFG.add(_fg);
			

			
			for (var i:int = 0; i < 4; i++) 
			{
				_trunk[i] = new FlxBlock(179 + i * 2, 153 + i * 2, 30, 22);
			}

			// creating a bunny
			_player[0] = new Player(0, Math.random()*160, 170);			
			_player[1] = new Player(1, Math.random()*160, 170);	
			_player[2] = new Player(2, Math.random()*160, 170);			
			_player[3] = new Player(3, Math.random()*160, 170);	
			
			for (var j:int = 0; j < _player.length; j++) 
			{
				lyrPlayers.add(_player[j]);
			}
			
			this.add(lyrBG);
			this.add(lyrBGSprites);
			this.add(lyrPlayers);
			this.add(lyrFG);

			var statusText:FlxText = new FlxText(10, 236, 380, "Press ESC for options.		 (level: " + FlxG.levels[0] + "_" + FlxG.levels[1] + ")");
			statusText.color = 0xff333333;
			this.add(statusText);
			
		
		}

		
		
		private function performMenuCollisions(playerid:uint):void
		{
			var pHeight:Number = _player[playerid].height;
			var pWidth:Number = _player[playerid].width;
			
			var pX:Number = _player[playerid].x;
			var pY:Number = _player[playerid].y;
			
			var leftEdge:Number = 1;
			var rightEdge:Number = 400;
			var floor:Number = 175 + playerid * 2;	
			
			// preventing exit left
			if (pX < leftEdge)
			{
				_player[playerid].velocity.x = 0;
				_player[playerid].x = leftEdge
			}
			
			// triggering transition on right edge
			if (pX > rightEdge - pWidth)
			{
				transition();
			}
			
			if (pY > floor - pHeight)
			{
				_player[playerid].velocity.y = 0;
				_player[playerid].y = floor - pHeight;
				_player[playerid].setGrounded(true);
			}
			else
			{
				_player[playerid].setGrounded(false);
			}
			
			_trunk[playerid].collide(_player[playerid]);
			
			if (pX > _trunk[playerid].x - pWidth && pX < _trunk[playerid].x + _trunk[playerid].width && pY > _trunk[playerid].y - pHeight - 1)
				_player[playerid].setGrounded(true);
		}	
		
		private function transition():void
		{
				if (_player[0].x > _trunk[0].x - _player[0].width)
					FlxG.levels[2] |= 1;
				if (_player[1].x > _trunk[1].x - _player[1].width)
					FlxG.levels[2] |= 2;
				if (_player[2].x > _trunk[2].x - _player[2].width)
					FlxG.levels[2] |= 4;
				if (_player[3].x > _trunk[3].x - _player[3].width)
					FlxG.levels[2] |= 8;
					
				for (var i:int = 0; i < _player.length; i++) 
				{
					if (_player[i].x > _trunk[i].x - _player[i].width)
					{
						_player[i].setControls(false);
						_player[i].setControlOverride("RIGHT");
					}
				}
					
				FlxG.fade(0xff000000, 1, startGame);
		}
		
		override public function update():void
        {
			if (FlxG.keys.justPressed("ESC"))
				FlxG.fade(0xff000000, 0.4, gotoMenu);

			for (var i:int = 0; i < _player.length; i++) 
			{
				performMenuCollisions(i);
			}
			
			super.update();
		}

        private function gotoMenu():void
        {
			FlxG.switchState(LevelSelectState);
        }
		
		private function startGame():void
        {
			FlxG.hideCursor();
			FlxG.music.stop();
			FlxG.switchState(PlayState);
        }
	}
}