package com.makr.jumpnbump
{
	import com.makr.jumpnbump.objects.Dust;
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
		private var _bgMusicURLOriginal:String = "music/original/m_jump.mp3";
		
	
		private var ImgBg:Class;
		private var ImgFg:Class;
		private var _bgMusicURL:String;

		
		private static const DUST_DELAY:Number = 0.1;			// delay between creating a dust particles

		private var _bg:FlxSprite;
		private var _fg:FlxSprite;
		private var _trunk:Array = new Array();
		
		public static var gBackground:FlxGroup;
		public static var gParticles:FlxGroup;
		public static var gPlayers:FlxGroup;
		public static var gForeground:FlxGroup;
		
		private function getDistance(a:Point, b:Point):Number
		{
			var deltaX:Number = b.x-a.x;  
			var deltaY:Number = b.y-a.y;  
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY); 
		}


		
		public override function create():void
		{
			FlxG.mouse.show();

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

			if (!FlxG.music.active)
			{
				FlxG.music.loadStream(_bgMusicURL, true);
				FlxG.music.survive = true;
				FlxG.music.play();
			}
			
			FlxG.levels[2] = FlxG.scores[0] = FlxG.scores[1] = FlxG.scores[2] = FlxG.scores[3] = 0;
			FlxG.score = -1;

			// creating new layers
			gBackground = new FlxGroup();
			gParticles = new FlxGroup();
			gPlayers = new FlxGroup();
			gForeground = new FlxGroup();
			
			// creating the background
			_bg = new FlxSprite;
			_bg.loadGraphic(ImgBg, false, false, 400, 256);
			_bg.x = _bg.y = 0;
			gBackground.add(_bg);	
			
			// creating the foreground
			_fg = new FlxSprite;
			_fg.loadGraphic(ImgFg, false, false, 400, 256);
			_fg.x = _fg.y = 0;
			gForeground.add(_fg);
			

			
			for (var i:int = 0; i < 4; i++) 
			{
				_trunk[i] = new FlxTileblock(179 + i * 2, 153 + i * 2, 30, 22);
			}

			// creating a bunny
			gPlayers.add(new Player(0, Math.random()*160, 170));
			gPlayers.add(new Player(1, Math.random()*160, 170));
			gPlayers.add(new Player(2, Math.random()*160, 170));
			gPlayers.add(new Player(3, Math.random()*160, 170));

			this.add(gBackground);
			this.add(gParticles);
			this.add(gPlayers);
			this.add(gForeground);

			var statusText:FlxText = new FlxText(10, 236, 380, "Press ESC for options.		 (level: " + FlxG.levels[0] + "_" + FlxG.levels[1] + ")");
			statusText.color = 0xff333333;
			this.add(statusText);
			
			// fade in
			FlxG.flash.start(0xff000000, 0.4);
		
		}

		
		
		private function performMenuCollisions(Collidee:Player):void
		{
			var pHeight:Number = Collidee.height;
			var pWidth:Number = Collidee.width;
			
			var pX:Number = Collidee.x;
			var pY:Number = Collidee.y;
			
			var leftEdge:Number = 1;
			var rightEdge:Number = 400;
			var floor:Number = 175 + Collidee.rabbitIndex * 2;	
			
			// preventing exit left
			if (pX < leftEdge)
			{
				Collidee.velocity.x = 0;
				Collidee.x = leftEdge
			}
			
			// triggering transition on right edge
			if (pX > rightEdge - pWidth)
			{
				transition();
			}
			
			if (pY > floor - pHeight)
			{
				Collidee.velocity.y = 0;
				Collidee.y = floor - pHeight;
				Collidee.setGrounded(true);
			}
			else
			{
				Collidee.setGrounded(false);
			}
			
			_trunk[Collidee.rabbitIndex].collide(Collidee);
			
			if (pX > _trunk[Collidee.rabbitIndex].x - pWidth + 1 && pX < _trunk[Collidee.rabbitIndex].x + _trunk[Collidee.rabbitIndex].width - 1 && 
				pY > _trunk[Collidee.rabbitIndex].y - pHeight - 1)
				Collidee.setGrounded(true);
		}	
		
		private function transition():void
		{
			for each (var currentPlayer:Player in gPlayers.members) 
			{
				if (currentPlayer.x > _trunk[currentPlayer.rabbitIndex].x - currentPlayer.width)
				{
					currentPlayer.setControls(false);
					currentPlayer.setControlOverride("RIGHT");
					
					
					switch (currentPlayer.rabbitIndex) 
					{
						case 0:
							FlxG.levels[2] |= 1;
							break;
						case 1:
							FlxG.levels[2] |= 2;
							break;
						case 2:
							FlxG.levels[2] |= 4;
							break;
						case 3:
							FlxG.levels[2] |= 8;
							break;
					}
				}
			}
					
			FlxG.fade.start(0xff000000, 1, startGame);
		}
		
		public override function update():void
        {
			if (FlxG.keys.justPressed("ESCAPE"))
				FlxG.fade.start(0xff000000, 0.4, gotoMenu);

			updateParticles();
				
			for each (var Collidee:Player in gPlayers.members) 
			{
				performMenuCollisions(Collidee);
			}
			
			super.update();
		}

		// creates new particles, perform collisions, erase dead ones
		private function updateParticles():void
		{
			// create new Particles
			for each (var currentPlayer:Player in gPlayers.members)
			{
				currentPlayer.particleTimer += FlxG.elapsed;
				
				// new Dust
				if (currentPlayer.isGrounded() && !currentPlayer.isSliding() 
					&& ((currentPlayer.isRunning() && FlxU.abs(currentPlayer.velocity.x) < 96) || (!currentPlayer.isRunning() && currentPlayer.velocity.x != 0))
					&& currentPlayer.particleTimer > DUST_DELAY)
				{
					var xDustOrigin:Number;
					var yDustOrigin:Number;
					var xDustDirection:int;
					
					if (currentPlayer.facing == 0)	// facing LEFT
						xDustDirection = 1;
					else							// facing RIGHT
						xDustDirection = -1;

					xDustOrigin = currentPlayer.x + 2 + Math.random() * 9;
					yDustOrigin = currentPlayer.y + 13 + Math.random() * 5;
					
					gParticles.add(new Dust(xDustOrigin, yDustOrigin, xDustDirection));
					
					currentPlayer.particleTimer = 0;
				}
			}
		}

		
        private function gotoMenu():void
        {
			FlxG.state = new LevelSelectState();
        }
		
		private function startGame():void
        {
			FlxG.mouse.cursor.visible = false;
			FlxG.music.stop();
			FlxG.state = new PlayState();
        }
	}
}