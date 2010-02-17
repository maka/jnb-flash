package com.makr.jumpnbump
{
	import com.makr.jumpnbump.objects.ButFly;
	import com.makr.jumpnbump.objects.Fly;
	import com.makr.jumpnbump.objects.Gib;
	import com.makr.jumpnbump.objects.PopupText;
	import com.makr.jumpnbump.objects.Spring;
	import com.makr.jumpnbump.objects.Dust;
	import com.makr.jumpnbump.objects.Bubble;
	import com.makr.jumpnbump.objects.Scoreboard;
	import flash.geom.Point;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		/// Assets independent from level selection
		[Embed(source = '../../../../data/levels/common/tiles.png')] private var ImgTiles:Class;
		[Embed(source = '../../../../data/levels/common/crown.png')] private var ImgCrown:Class;


		/// Individual level assets
		// green level		
		[Embed(source = '../../../../data/levels/green/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapGreen:Class;
		[Embed(source = '../../../../data/levels/green/level.png')] private var ImgBgGreen:Class;
		[Embed(source = '../../../../data/levels/green/leveloverlay.png')] private var ImgFgGreen:Class;
		
		// topsy level		
		[Embed(source = '../../../../data/levels/topsy/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapTopsy:Class;
		[Embed(source = '../../../../data/levels/topsy/level.png')] private var ImgBgTopsy:Class;
		[Embed(source = '../../../../data/levels/topsy/leveloverlay.png')] private var ImgFgTopsy:Class;
		
		// rabtown level		
		[Embed(source = '../../../../data/levels/rabtown/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapRabtown:Class;
		[Embed(source = '../../../../data/levels/rabtown/level.png')] private var ImgBgRabtown:Class;
		[Embed(source = '../../../../data/levels/rabtown/leveloverlay.png')] private var ImgFgRabtown:Class;
		
		// jump2 level		
		[Embed(source = '../../../../data/levels/jump2/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapJump2:Class;
		[Embed(source = '../../../../data/levels/jump2/level.png')] private var ImgBgJump2:Class;
		[Embed(source = '../../../../data/levels/jump2/leveloverlay.png')] private var ImgFgJump2:Class;

		// crystal2 level		
		[Embed(source = '../../../../data/levels/crystal2/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapCrystal2:Class;
		[Embed(source = '../../../../data/levels/crystal2/level.png')] private var ImgBgCrystal2:Class;
		[Embed(source = '../../../../data/levels/crystal2/leveloverlay.png')] private var ImgFgCrystal2:Class;

		// witch level		
		[Embed(source = '../../../../data/levels/witch/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapWitch:Class;
		[Embed(source = '../../../../data/levels/witch/level.png')] private var ImgBgWitch:Class;
		[Embed(source = '../../../../data/levels/witch/leveloverlay.png')] private var ImgFgWitch:Class;
		private var _rabbitColorsWitch:Array = new Array(0x7CA824, 0xDFBF8B, 0xA7A7A7, 0xB78F77);

		// original level		
		[Embed(source = '../../../../data/levels/original/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapOriginal:Class;
		[Embed(source = '../../../../data/levels/original/level.png')] private var ImgBgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/leveloverlay.png')] private var ImgFgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/sounds.swf', symbol="Fly")] private var SoundFlyOriginal:Class;
		private var _bgMusicURLOriginal:String = "music/original/m_bump.mp3";
		private var _rabbitColorsOriginal:Array = new Array(0xDBDBDB, 0xDFBF8B, 0xA7A7A7, 0xB78F77);
		
		// asset holders, the assets for the current level will be copied into these variables and then used
		private var DataMap:Class;
		private var ImgBg:Class;
		private var ImgFg:Class;
		private var SoundFly:Class;
		private var _bgMusicURL:String;
		private var _rabbitColors:Array;
		
		// timers for objects created by players (dust, bubbles)
		private static const DUST_DELAY:Number = 0.1;			// delay between creating a dust particles
		private static const BUBBLE_DELAY:Number = 0.2;		// delay between creating a bubble particles
		
		// other parts of the game
		private var _map:FlxTilemap;
		private var _respawnMap:Array;				// array that holds all positions where a player can spawn (VOID above SOLID)
		private var _scoreboard:Scoreboard;

		//the various groups
		public static var gBackground:FlxGroup;		// holds the background image
		public static var gMap:FlxGroup;			//   "    "  tilemap view for debugging
		public static var gParticles:FlxGroup;		//   "    "  simple particles (dust, splashes)
		public static var gBubbles:FlxGroup;		//   "    "  bubble particles
		public static var gGibs:FlxGroup;			//   "    "  gibs
		public static var gSprings:FlxGroup;		//   "    "  springs
		public static var gButflies:FlxGroup;		//   "    "  butterflies
		public static var gFlies:FlxGroup;			//   "    "  flies
		public static var gPlayers:FlxGroup;		//   "    "  players
		public static var gForeground:FlxGroup;		//   "    "  foreground image
		public static var gPopupTexts:FlxGroup;		//   "    "  Popup Texts
		public static var gUI:FlxGroup;				//   "    "  unique UI elements (icons (crown), buttons, scoreboard)
		
		// "Lord of the Flies" game mode specific variables
		private var _crown:FlxSprite;				// crown sprite, displayed above current Lord

		// butterfly variables
		private static const NUM_BUTFLIES:uint = 4;
		
		// fly variables
		private var _flyNoise:FlxSound;
		private static const NUM_FLIES:uint = 20;
		private static const NUM_FLIES_LOTF:uint = 50;	// "Lord of the Flies" game mode specific variable
		private var _numFlies:uint;						// is set to either NUM_FLIES or NUM_FLIES_LOTF, depending on game mode

		// returns distance between two Points a and b
		private function getDistance(A:Point, B:Point):Number
		{
			var deltaX:Number = B.x-A.x;  
			var deltaY:Number = B.y-A.y;  
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY); 
		}
		
		public override function create():void
		{
			
			// Loading assets into variables
			switch (FlxG.levels[1])
			{
				case "green":
					DataMap = DataMapGreen;
					ImgBg = ImgBgGreen;
					ImgFg = ImgFgGreen;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsOriginal;
					break;
				
				case "topsy":
					DataMap = DataMapTopsy;
					ImgBg = ImgBgTopsy;
					ImgFg = ImgFgTopsy;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsOriginal;
					break;
				
				case "rabtown":
					DataMap = DataMapRabtown;
					ImgBg = ImgBgRabtown;
					ImgFg = ImgFgRabtown;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsOriginal;
					break;
				
				case "jump2":
					DataMap = DataMapJump2;
					ImgBg = ImgBgJump2;
					ImgFg = ImgFgJump2;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsOriginal;
					break;

				case "crystal2":
					DataMap = DataMapCrystal2;
					ImgBg = ImgBgCrystal2;
					ImgFg = ImgFgCrystal2;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsOriginal;
					break;

				case "witch":
					DataMap = DataMapWitch;
					ImgBg = ImgBgWitch;
					ImgFg = ImgFgWitch;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsWitch;
					break;

				case "original":
				default:
					DataMap = DataMapOriginal;
					ImgBg = ImgBgOriginal;
					ImgFg = ImgFgOriginal;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					_rabbitColors = _rabbitColorsOriginal;
					break;
			}

			
			
			
			FlxG.music.loadStream(_bgMusicURL, true);
			FlxG.music.survive = true;
			FlxG.music.play();
			
			_flyNoise = new FlxSound;
			_flyNoise.loadEmbedded(SoundFly, true);
			_flyNoise.survive = false;
			FlxG.sounds.push(_flyNoise);
			_flyNoise.volume = 0;
			_flyNoise.play();
			
			if (FlxG.levels[0] == "lotf")
				_numFlies = NUM_FLIES_LOTF;
			else
				_numFlies = NUM_FLIES;
			
			// creating new groups
			gBackground = new FlxGroup();
			gMap = new FlxGroup();
			gParticles = new FlxGroup();
			gBubbles = new FlxGroup();
			gGibs = new FlxGroup();
			gSprings = new FlxGroup();
			gButflies = new FlxGroup();
			gFlies = new FlxGroup();
			gPlayers = new FlxGroup();
			gForeground = new FlxGroup();
			gPopupTexts = new FlxGroup();
			gUI = new FlxGroup()				// unique UI elements (icons (crown), buttons, scoreboard)
				
			// creating the background
			var _bg:FlxSprite = new FlxSprite(0, 0, ImgBg);
			gBackground.add(_bg);	
			
			// creating the foreground
			var _fg:FlxSprite = new FlxSprite(0, 0, ImgFg);
			gForeground.add(_fg);

			// creating the map
			_map = new FlxTilemap;
			_map.loadMap(new DataMap, ImgTiles, 16)
            _map.drawIndex = 0;
            _map.collideIndex = 2;
            _map.follow();
			gMap.add(_map);
			
			// creating the scoreboard
			_scoreboard = new Scoreboard();
			for each (var tile:FlxSprite in _scoreboard.Tiles) 
				gUI.add(tile);
			
			// creating the springs
			// looks for tiles with value 4 (SPRING) and creates a Spring object at that position
			for (var x:int = 0; x < 22; x++) 
			{
				for (var y:int = 0; y < 16; y++) 
				{
					if (_map.getTileByIndex(y * 22 + x) == 4)
						gSprings.add(new Spring(x * 16, y * 16));
				}
			}
			
			// building respawn map
			_respawnMap = buildRespawnMap();

			// creating the bunnies
			var bunnySpawnPoint:Point = new Point(0, 0);
			if (FlxG.levels[2] & 1)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				gPlayers.add(new Player(0, bunnySpawnPoint.x, bunnySpawnPoint.y));			
			}
			if (FlxG.levels[2] & 2)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				gPlayers.add(new Player(1, bunnySpawnPoint.x, bunnySpawnPoint.y));	
			}
			if (FlxG.levels[2] & 4)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				gPlayers.add(new Player(2, bunnySpawnPoint.x, bunnySpawnPoint.y));			
			}
			if (FlxG.levels[2] & 8)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				gPlayers.add(new Player(3, bunnySpawnPoint.x, bunnySpawnPoint.y));	
			}
			
			// creating the lotf crown
			_crown = new FlxSprite(0, 0, ImgCrown);
			_crown.visible = false;
			gUI.add(_crown);
			
			// creating the flies
			var flySpawnPoint:Point;
			flySpawnPoint = _respawnMap[FlxU.floor(Math.random() * _respawnMap.length)];
			for (var j:int = 0; j < _numFlies; j++) 
			{
				gFlies.add(new Fly(flySpawnPoint.x + Math.random() * 32 - 16, flySpawnPoint.y + Math.random() * 32 - 16));
			}
			
			
			// creating the butflies
			var butflySpawnPoint:Point;
			for (var k:int = 0; k < NUM_BUTFLIES; k++) 
			{
				butflySpawnPoint = _respawnMap[FlxU.floor(Math.random() * _respawnMap.length)];
				gButflies.add(new ButFly(butflySpawnPoint.x, butflySpawnPoint.y));
			}
			
			
			// adds all the groups to this state (they are rendered in this order)
			this.add(gBackground);
//			this.add(gMap);
			this.add(gParticles);
			this.add(gBubbles);
			this.add(gGibs);
			this.add(gSprings);
			this.add(gButflies);
			this.add(gFlies);
			this.add(gPlayers);
			this.add(gForeground);
			this.add(gPopupTexts);
			this.add(gUI);

			
			// fade in
			FlxG.flash.start(0xff000000, 0.4);
		}
		
		// returns the TileIndex for the tile at position (x,y), to be used with _map.getTileByIndex() to get tile value at pos(x,y)
		private function getTileIndex(x:Number, y:Number):uint
		{
			return FlxU.floor(y / 16) * _map.widthInTiles + FlxU.floor(x / 16);
		}
		
		// resolves all interactions between player and tilemap apart from basic collision
		private function performTileLogic(Rabbit:Player):void
		{
			// Preparations:
			var floatThreshold:uint = 1;	// the size of the area where the bunny is floating between water and air
						
			// defining various x/y values around the bunny's position
			var leftEdge:Number = Rabbit.x; 
			var rightEdge:Number = Rabbit.x + Rabbit.width - 1;
			var center:Point = new Point(Rabbit.x + (Rabbit.width - 1) / 2, Rabbit.y + (Rabbit.height - 1) / 2);
			var below:Number = Rabbit.y + Rabbit.height;
						
			// looking up the tiles directly behind the bunny, as well as below the center and edges
			var tileBehind:uint = _map.getTileByIndex(getTileIndex(center.x, center.y));
			var tileBelow:uint = _map.getTileByIndex(getTileIndex(center.x, below));
			var tileBelowLeft:uint = _map.getTileByIndex(getTileIndex(leftEdge, below));
			var tileBelowRight:uint = _map.getTileByIndex(getTileIndex(rightEdge, below));
			
			// Tile Indices:
			// 0 = Void
			// 1 = Water
			// 2 = Solid
			// 3 = Ice
			// 4 = Spring

			// SOLID: determining if the bunny is on solid ground
			//if (Math.max(tileBelowLeft, tileBelow, tileBelowRight) < _map.collideIndex)	// the bunny's feet are touching a non-solid tile (air, water)
			if (Rabbit.onFloor)
			{
				Rabbit.killCount = 0;	// resets killCounter to zero
				Rabbit.setGrounded(true);
			}
			else
				Rabbit.setGrounded(false);

			
			// SPRING: should propel the bunny upwards if:
			// most of the bunny is on it OR the spring is the only thing underneath the bunny
			// 
			if (tileBelowLeft == 4 || tileBelowRight == 4) // if either corner touches the spring
			{
				if (tileBelow < _map.collideIndex || tileBelow == 4) 	// and the center does too (most of the bunny is on the spring)
																		// OR the tile directly underneath is not solid (the bunny is touching nothing else)
				{				
					var leftCorner:Point = new Point(FlxU.floor(leftEdge / 16) * 16, FlxU.floor(below / 16) * 16);
					var rightCorner:Point = new Point(FlxU.floor(rightEdge / 16) * 16, FlxU.floor(below / 16) * 16);
					
					for each (var currentSpring:Spring in gSprings.members) 
					{
						if ((currentSpring.x == leftCorner.x && currentSpring.y == leftCorner.y) || 
							(currentSpring.x == rightCorner.x &&currentSpring.y == rightCorner.y))
							currentSpring.Activate();

					}
					
					Rabbit.springJump();	// sproing!
				}
			}
			
			// ICE: the bunny should slide on ice if:
			// most of the bunny is on it OR the ice is the only thing colliding with the bunny
			// 
			if (tileBelowLeft == 3 || tileBelowRight == 3) 	// if either corner touches the ice
			{
				if (tileBelow < _map.collideIndex			// and either the center does too (most of the bunny is in the ice)
					|| tileBelow == 3) 						// OR the tile directly underneath is not solid (the bunny is touching nothing else)
				{
					Rabbit.setSliding(true);		// slide!
				}
			}
			if (Rabbit.isSliding() && 			// if the bunny is sliding
				tileBelow >= _map.collideIndex && 			// and the tile below is solid
				tileBelow != 3)								// but not ice
															// (i.e. the bunny has slid onto a solid tile)
			{
				Rabbit.setSliding(false);		// unslide!
			}
			
			// WATER: two behaviors!
			
			// the bunny should SWIM if:
			// most of the bunny is in water
			
			// the bunny should FLOAT if:
			// the center point of the bunny has just crossed the surface of the water from below
			
			// swim check
			if (tileBehind == 1 &&						// most of the bunny is underwater.
				!Rabbit.isSwimming())		// swimming flag ist not yet enabled
			{
				Rabbit.setSwimming(true);	// we're swimming!
				Rabbit.setFloating(false);	// but not floating
			}
			
			// float check
			if (tileBehind != 1 && 						// most of the bunny is not in water, 
				tileBelow == 1 &&						// its feet are wet,
				Rabbit.isSwimming() && 		// swimming flag ist still enabled (bunny has just left water)
				Rabbit.velocity.y < 0 &&		// it came from below
				!Rabbit.isFloating())		// floating flag is not yet enabled
			{
				Rabbit.setSwimming(false);	// not swimming anymore
				Rabbit.setFloating(true);	// we're floating now!
			}
			
			// exiting the pool in wondrous ways (coming out of the sides, falling through, etc.)
			if (tileBehind != 1 && 						// most of the bunny is not in water, 
				tileBelow != 1)							// there is no water directly below it (so we can't be floating)
			{
				if (Rabbit.isSwimming())		// but we're still swimming! must have fallen through or exited at an edge of the pool
														// otherwise the float check above would have caught it!
					Rabbit.setSwimming(false);
					
				if (Rabbit.isFloating())		// but we're stll floating! must have floated off the side
					Rabbit.setFloating(false);
			}
		}
		
		// Flixel does not handle collisions with the edges of the tilemap, only the tiles within.
		// Here we make sure no one can fall off the map.
		private function collideMapBorders(Sprite:Player):void
		{
			var minX:Number = 1;
			var minY:Number = 1;
			var maxX:Number = 352 - Sprite.width -1;
			var maxY:Number = 256 - Sprite.height -1;


		
			if (Sprite.y < minY)	// bunny is above the map ceiling (this IS allowed)
									// in this case we extend the walls in the first row infinitely upward
									// (standing on top of the map was extremely problematic the last time I tried it)
			{
				var leftEdge:Number = Sprite.x; 
				var rightEdge:Number = Sprite.x + Sprite.width - 1;

				var leftTileIndex:uint = getTileIndex(leftEdge, minY);
				var rightTileIndex:uint = getTileIndex(rightEdge, minY);

				var leftTile:uint = _map.getTileByIndex(leftTileIndex);
				var rightTile:uint = _map.getTileByIndex(rightTileIndex);
				
				if (leftTile >= _map.collideIndex)
				{
					Sprite.velocity.x = 0;
					Sprite.x = (leftTileIndex + 1) * 16;
				}
				
				if (rightTile >= _map.collideIndex)
				{
					Sprite.velocity.x = 0;
					Sprite.x = rightTileIndex * 16 - Sprite.width;
				}

			}
			
			
			if (Sprite.x < minX)		// falling off the map on the LEFT side (this is NOT allowed)
			{
				Sprite.velocity.x = 0;
				Sprite.x = minX
			}
			if (Sprite.x > maxX)		// falling off the map on the RIGHT side (this is NOT allowed)
			{
				Sprite.velocity.x = 0;
				Sprite.x = maxX
			}
			if (Sprite.y > maxY)		// falling out of the BOTTOM of the map (this is NOT allowed)
			{
				Sprite.velocity.y = 0;
				Sprite.y = maxY
				Sprite.setGrounded(true);
			}
		}
		
		// called when one player kills another
		private function killPlayer(Killer:Player, Killee:Player):void
		{
			Killer.bounceJump();		// killer bounces
			Killee.kill();					// killee dies
			gibPlayer(Killee);						// and gets gibbed
			
			
			if (FlxG.levels[0] == "lotf")	// if game mode is LOTF
			{
				if (FlxG.score == -1 || FlxG.score == Killee.rabbitIndex)	// and either there is no lord OR the killer killed him
					FlxG.score = Killer.rabbitIndex;						// there is a new lord!
			}
			else	// if game mode is standard DM
			{
				if (Killer.killCount < 9)
					Killer.killCount++;
				FlxG.scores[Killer.rabbitIndex] += Killer.killCount;	// increment killer score

				
				
				if (Killer.killCount > 1 && Killer.killCount != 4)
				{
					var newPopupText:PopupText = new PopupText(Killer.x + 8, Killer.y, 16, "+" + Killer.killCount.toString());
					newPopupText.color = _rabbitColors[Killer.rabbitIndex];
				
					gPopupTexts.add(newPopupText);
					
		// FIXME:			cleanupArray(_popupTexts);
				}
				else if (Killer.killCount == 4)
				{
					newPopupText = new PopupText(Killer.x + 8, Killer.y, 126, "M-M-M-M-MONSTERKILL!", 3);
					newPopupText.color = 0xB70000;
				
					gPopupTexts.add(newPopupText);
					
		// FIXME:			cleanupArray(_popupTexts);
				}
				
				_scoreboard.update();		// update the scoreboard
			}

		}
		
		// resolves all interactions between all players (Flixel collision is completely useless for this purpose)
		private function collidePlayers():void
		{
			var numPlayers:uint = gPlayers.members.length;
			
			var a:int = 0;
			var b:int = 0;
			
			var pA:Player;
			var pB:Player;

			var maxWidth:Number, maxHeight:Number;
			
			for (a = 0; a < numPlayers - 1; a++) 
			{
				for (b = a + 1; b < numPlayers; b++) 
				{
					pA = gPlayers.members[a];
					pB = gPlayers.members[b];
					
					maxWidth = maxHeight = 12;

					if (!pA.dead && !pB.dead)						// check that both are alive
					{
						if (FlxU.abs(pA.x - pB.x) < maxWidth && 
							FlxU.abs(pA.y - pB.y) < maxHeight)	// check that they intersect
						{												
							trace("PlayState:collidePlayers()");
							trace("	Players " + pA.rabbitIndex + " and " + pB.rabbitIndex + " intersect;");
							
							if ((pA.y - pB.y > 5 && pA.velocity.y < pB.velocity.y) ||
								(pB.y - pA.y > 5 && pB.velocity.y < pA.velocity.y))
							{
								trace("	Resolution: Kill");

								if (pA.y < pB.y)	// the one up top is faster than the one below
									killPlayer(pA, pB);								// playerKill(killer, killee);
								else
									killPlayer(pB, pA);
							}
							else
							{
								trace("	Resolution: Push");

								
								if (pA.x < pB.x)
								{
									if (pA.velocity.x > 0)
										pA.x = pB.x - maxWidth;
									else if (pB.velocity.x < 0)
										pB.x = pA.x + maxWidth;
									else
									{
										pA.x -= pA.velocity.x * FlxG.elapsed;
										pB.x -= pB.velocity.x * FlxG.elapsed;
									}
									
									// swap the bunnies' velocity values
									pA.velocity.x ^= pB.velocity.x;
									pB.velocity.x ^= pA.velocity.x;
									pA.velocity.x ^= pB.velocity.x;
									if (pA.velocity.x > 0)
										pA.velocity.x = -pA.velocity.x;
									if (pB.velocity.x < 0)
										pB.velocity.x = -pB.velocity.x;
								}
								else
								{
									if (pA.velocity.x > 0)
										pB.x = pA.x - maxWidth;
									else if (pB.velocity.x < 0)
										pA.x = pB.x + maxWidth;
									else
									{
										pA.x -= pA.velocity.x * FlxG.elapsed;
										pB.x -= pB.velocity.x * FlxG.elapsed;
									}
									
									// swap the bunnies' velocity values
									pA.velocity.x ^= pB.velocity.x;
									pB.velocity.x ^= pA.velocity.x;
									pA.velocity.x ^= pB.velocity.x;
									if (pA.velocity.x < 0)
										pA.velocity.x = -pA.velocity.x;
									if (pB.velocity.x > 0)
										pB.velocity.x = -pB.velocity.x;
								}
							}
						}
					}
				}
			}
		}
		
		// determines the closest player to Point A, returns an array with PlayerID and distance to point
		private function getClosestPlayerToPoint(A:Point):Array
		{
			var playerPosition:Point = new Point;
			
			var closestPlayer:Player;
			var closestDistance:Number = 10000;
			var currentDistance:Number;
			
			for each (var currentPlayer:Player in gPlayers.members) 
			{
				playerPosition.x = currentPlayer.x + 8;
				playerPosition.y = currentPlayer.y + 8;
				
				currentDistance = getDistance(playerPosition, A);
				
				if (currentDistance < closestDistance)
				{
					closestDistance = currentDistance;
					closestPlayer = currentPlayer;
				}
				
			}
			
			return new Array(closestPlayer, closestDistance);
		}

		// goes through tilemap, saving positions where VOID is above SOLID
		private function buildRespawnMap():Array
		{
			var respawnMap:Array = new Array;
			
			for (var x:int = 0; x < 22; x++) 
			{
				for (var y:int = 1; y < 15; y++) 
				{
					if (_map.getTileByIndex(y * 22 + x) == 0 &&					// if current tile  is VOID and tile below is SOLID or ICE
						(_map.getTileByIndex((y + 1) * 22 + x) == 2 || _map.getTileByIndex((y + 1) * 22 + x) == 3))
					{
						respawnMap.push(new Point(x * 16, y * 16 + 1));		// add current tile to respawnMap

					}
				}
			}
			
			return respawnMap;
			
		}
		
		// chooses a random spawnpoint from the respawnMap and checks that no other player is near that point (prevents spawning inside another player)
		private function getFreeSpawnPoint():Point
		{
			var spawnPoint:Point;
			var closestPlayerDistance:Number;
			
			do {
				spawnPoint = _respawnMap[FlxU.floor(Math.random() * _respawnMap.length)];
				closestPlayerDistance = getClosestPlayerToPoint(spawnPoint)[1];
			} while (closestPlayerDistance < 32);
			
			return spawnPoint;
		}
		
		// respawns dead players
		private function respawnPlayers():Boolean
		{
			var theDead:Array = new Array;
			
			
			for each (var currentPlayer:Player in gPlayers.members)
			{
				if (!currentPlayer.active)
				{
					currentPlayer.visible = false;
					theDead.push(currentPlayer);
				}
			}

			if (theDead.length == 0)
				return false;
			else
				trace(theDead.length + " rabbits are dead!");
				
			for each (var ghost:Player in theDead)
			{
				var respawnPoint:Point = getFreeSpawnPoint();	
				trace("respawning player R#" + ghost.rabbitIndex + "(" + ghost.x + "," + ghost.y+") at new location (" + respawnPoint.x + "," + respawnPoint.y+")");
				ghost.reset(respawnPoint.x, respawnPoint.y);
				ghost.particleTimer = 0;
			}

			return true;
		}
		
		// creates a shower of blood and gore
		private function gibPlayer(Gibbee:Player):void
		{
			var gibKind:String;
			var gibIndex:uint;
			
			for (var re:int = 0; re < FlxU.floor(Math.random() * 6 + 9 ); re++) 
			{
				if (Math.random() * 10 < 4)
				{
					gibKind = "Fur";
				}
				else
				{
					gibKind = "Flesh";
				}
					
				gGibs.add(new Gib(	Gibbee.rabbitIndex, 
									gibKind, Gibbee.x + Gibbee.width / 2, 
									Gibbee.y + Gibbee.height / 2));
			}
			
			// cleanup gib array
	// FIXME:		cleanupArray(_gibs);
			
		}
		
		private function cleanupArray(thisArray:Array):void
		{
			var indicesToDelete:Array = new Array;

			for (var i:int = 0; i < thisArray.length; i++) 
			{
				if (thisArray[i].dead)
					indicesToDelete.push(i)
			}

			var currentIndex:int = 0;
			for (var j:int = 0; j < indicesToDelete.length; j++) 
			{
				currentIndex = indicesToDelete.pop();
				thisArray[currentIndex].kill();
				thisArray.splice(currentIndex, 1);
			}
			
			trace ("INFO: PlayState: " + (j) + " dead items removed.");

		}
		
		// creates a shower of blood and gore
		private function bubbleBurstPlayer(Burstee:Player):void
		{
			var bubbleIndex:uint;
			
			trace("Player " + Burstee.rabbitIndex + " just burst :o");
			
			for (var re:int = 0; re < FlxU.floor(Math.random() * 10 + 30 ); re++) 
			{
				gBubbles.add(new Bubble(Burstee.x + 8, Burstee.y + 8,
							(Math.random() - 0.5 ) * 100, (Math.random() - 0.5 ) * 100));
			}
			
			Burstee.particleTimer = -1;
		}
		
		public override function update():void
        {
			// check if ESCAPE has been pressed and if so, exit PlayState
			if (FlxG.keys.justPressed("ESCAPE"))
				FlxG.fade.start(0xff000000, 1, quit);

			// perform tile logic and collision with map borders for players
			for each (var currentPlayer:Player in gPlayers.members) 
			{
				performTileLogic(currentPlayer)
				collideMapBorders(currentPlayer);
			}
	
			/// LOTF GAME MODE
			// determine who is currently the Lord
			var LoTF:Player;
			if (FlxG.levels[0] == "lotf" && FlxG.score != -1)
				LoTF = getPlayerFromRabbitIndex(FlxG.score);
		
			// put a crown on the Lord
			if (FlxG.levels[0] == "lotf" && FlxG.score != -1)
			{
				_crown.visible = true;
				if (LoTF.facing == 0)		// facing LEFT
					_crown.x = LoTF.x + 2 + LoTF.velocity.x * FlxG.elapsed;
				else						// facing RIGHT
					_crown.x = LoTF.x + 4 + LoTF.velocity.x * FlxG.elapsed;
				_crown.y = LoTF.y - 11 + LoTF.velocity.y * FlxG.elapsed;
				FlxG.scores[FlxG.score] += FlxG.elapsed;
				_scoreboard.update();
			}
			else
				_crown.visible = false;

				
			// handle flies
			var SwarmCenter:Point = new Point(0, 0);
			if (FlxG.levels[0] == "lotf" && FlxG.score != -1)	// make flies swarm around the Lord if there is one
			{
				SwarmCenter.x = LoTF.x + 8;
				SwarmCenter.y = LoTF.y + 8;
			}
			else												// otherwise use the average position of all flies as the swarm's center
			{
				for each (var thisFly:Fly in gFlies.members) 
				{
					SwarmCenter.x += thisFly.x;
					SwarmCenter.y += thisFly.y;
				}
				SwarmCenter.x /= _numFlies;
				SwarmCenter.y /= _numFlies;
			}

			
			// fly noise volume control
			var closestPlayerToSwarm:Player = getClosestPlayerToPoint(SwarmCenter)[0];

			if (FlxG.levels[0] == "lotf")				// in LoTF, flies are always near the Lord, so the _flyNoise is always heard
				_flyNoise.volume = 0.4;				// make the experience less annoying by lowering the volume
			else
				_flyNoise.volume = 0.7;

			_flyNoise.proximity(SwarmCenter.x, SwarmCenter.y, closestPlayerToSwarm, 80, true);
			_flyNoise.update();
			
			
			// make flies avoid player and stay in the swarm
			var closestPlayerToFly:Array = new Array;
			var closestPlayerToFlyPosition:Point;
			for each (var currentFly:Fly in gFlies.members) 
			{
				closestPlayerToFly = getClosestPlayerToPoint(new Point(currentFly.x, currentFly.y));
				closestPlayerToFlyPosition = new Point(closestPlayerToFly[0].x + 8, closestPlayerToFly[0].y + 8);
				currentFly.move(	SwarmCenter, 
								closestPlayerToFlyPosition, 
								closestPlayerToFly[1]);
			}
			
			// handle gibs underwater
			for each (var currentGib:Gib in gGibs.members) 
			{
				if (_map.getTileByIndex(getTileIndex(currentGib.x, currentGib.y)) == 1)
					currentGib.setSwimming(true);
				else 
					currentGib.setSwimming(false);
			}
			
			for each (var currentText:PopupText in gPopupTexts.members)
				currentText.update();
			
			// create new particles, perform collisions, erase dead ones
			updateParticles();			
			
			super.update();
			
			respawnPlayers();	// respawn dead players
			
			collidePlayers();	// handle player-player collisions

			// collide gibs, players, butterflies and flies with the tilemap
			FlxU.collide(_map, gGibs);
			FlxU.collide(_map, gPlayers);
			FlxU.collide(_map, gButflies);
			FlxU.collide(_map, gFlies);
			FlxU.collide(_map, gBubbles);
		}	

		// returns a Player that matches the given RabbitIndexPlayerArray
		private function getPlayerFromRabbitIndex(RabbitIndex:uint):Player
		{
			var matchID:uint;
			var match:Player;
			
			for each (var currentPlayer:Player in gPlayers.members)
			{
				if (currentPlayer.rabbitIndex == RabbitIndex)
					match = currentPlayer;
			}
			
			return match;
		}
		
		// creates new particles, perform collisions, erase dead ones
		private function updateParticles():void
		{
			// create new Particles
			for each (var currentPlayer:Player in gPlayers.members)
			{
				if (!currentPlayer.dead)
					currentPlayer.particleTimer += FlxG.elapsed;
				
				// new Bubble
				if (currentPlayer.isSwimming() && currentPlayer.particleTimer > BUBBLE_DELAY && !currentPlayer.dead)
				{
					var xBubbleOrigin:Number;
					var yBubbleOrigin:Number;
					var newBubbleIndex:uint;
					
					if (currentPlayer.facing == 0)	// facing LEFT 
						xBubbleOrigin = currentPlayer.x + 3;
					else							// facing RIGHT
						xBubbleOrigin = currentPlayer.x + 10;
						
					yBubbleOrigin = currentPlayer.y + 7;
					
					gBubbles.add(new Bubble(xBubbleOrigin, yBubbleOrigin, currentPlayer.velocity.x, 0));
					
					currentPlayer.particleTimer = 0;
				}
				else if (currentPlayer.isSwimming() && currentPlayer.particleTimer != -1 && currentPlayer.dead)
				{
					trace("Timer: " + currentPlayer.particleTimer);
					bubbleBurstPlayer(currentPlayer);
				}
				
				// new Dust
				if (currentPlayer.isGrounded() && currentPlayer.isRunning() && !currentPlayer.isSliding() 
					&& FlxU.abs(currentPlayer.velocity.x) < 96	// player is running slower than max speed
					&& currentPlayer.particleTimer > DUST_DELAY)
				{
					var xDustOrigin:Number;
					var yDustOrigin:Number;
					var xDustDirection:int;
					
					if (currentPlayer.facing == 0)	// facing LEFT
						xDustDirection = 1;
					else							// facing RIGHT
						xDustDirection = -1;
					if (!currentPlayer.isRunning())
						xDustDirection = 0;

					xDustOrigin = currentPlayer.x + 2 + Math.random() * 9;
					yDustOrigin = currentPlayer.y + 13 + Math.random() * 5;
					
					gParticles.add(new Dust(xDustOrigin, yDustOrigin, xDustDirection));
					
					currentPlayer.particleTimer = 0;
				}
			}
			
			// kill particles
			for each (var currentBubble:Bubble in gBubbles.members) 
			{
				if (_map.getTileByIndex(getTileIndex(currentBubble.x, currentBubble.y)) != 1)
					currentBubble.kill()
			}
		}

		// exits PlayState
        private function quit():void
        {
			_flyNoise.stop();
			FlxG.music.stop();
			FlxG.state = new PlayerSelectState();
        }
	
	}
}