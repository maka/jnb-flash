package com.makr.jumpnbump
{
	import com.makr.jumpnbump.helpers.ObjectPool;
	import com.makr.jumpnbump.objects.Gore;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import com.makr.jumpnbump.objects.Player;
	import com.makr.jumpnbump.objects.ButFly;
	import com.makr.jumpnbump.objects.Fly;
	import com.makr.jumpnbump.objects.Gib;
	import com.makr.jumpnbump.objects.PopupText;
	import com.makr.jumpnbump.objects.Spring;
	import com.makr.jumpnbump.objects.Dust;
	import com.makr.jumpnbump.objects.Splash;
	import com.makr.jumpnbump.objects.Bubble;
	import com.makr.jumpnbump.objects.Scoreboard;
	
	import flash.display.BitmapData;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.flixel.*;
//	import flash.utils.getTimer;
//	import net.hires.debug.Stats;

	public class PlayState extends FlxState
	{
		/// Assets independent from level selection
		[Embed(source = '../../../../data/levels/common/tiles.png')] private var _imgTiles:Class;
		[Embed(source = '../../../../data/levels/common/crown.png')] private var _imgCrown:Class;


		/// Individual level assets
		// green level		
		[Embed(source = '../../../../data/levels/green/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapGreen:Class;
		[Embed(source = '../../../../data/levels/green/level.png')] private var _imgBgGreen:Class;
		[Embed(source = '../../../../data/levels/green/leveloverlay.png')] private var _imgFgGreen:Class;
		
		// topsy level		
		[Embed(source = '../../../../data/levels/topsy/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapTopsy:Class;
		[Embed(source = '../../../../data/levels/topsy/level.png')] private var _imgBgTopsy:Class;
		[Embed(source = '../../../../data/levels/topsy/leveloverlay.png')] private var _imgFgTopsy:Class;
		
		// rabtown level		
		[Embed(source = '../../../../data/levels/rabtown/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapRabtown:Class;
		[Embed(source = '../../../../data/levels/rabtown/level.png')] private var _imgBgRabtown:Class;
		[Embed(source = '../../../../data/levels/rabtown/leveloverlay.png')] private var _imgFgRabtown:Class;
		
		// jump2 level		
		[Embed(source = '../../../../data/levels/jump2/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapJump2:Class;
		[Embed(source = '../../../../data/levels/jump2/level.png')] private var _imgBgJump2:Class;
		[Embed(source = '../../../../data/levels/jump2/leveloverlay.png')] private var _imgFgJump2:Class;

		// crystal2 level		
		[Embed(source = '../../../../data/levels/crystal2/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapCrystal2:Class;
		[Embed(source = '../../../../data/levels/crystal2/level.png')] private var _imgBgCrystal2:Class;
		[Embed(source = '../../../../data/levels/crystal2/leveloverlay.png')] private var _imgFgCrystal2:Class;

		// witch level		
		[Embed(source = '../../../../data/levels/witch/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapWitch:Class;
		[Embed(source = '../../../../data/levels/witch/level.png')] private var _imgBgWitch:Class;
		[Embed(source = '../../../../data/levels/witch/leveloverlay.png')] private var _imgFgWitch:Class;
		private var _rabbitColorsWitch:Array = new Array(0x7CA824, 0xDFBF8B, 0xA7A7A7, 0xB78F77);

		// original level		
		[Embed(source = '../../../../data/levels/original/levelmap.txt', mimeType = "application/octet-stream")] private var _dataMapOriginal:Class;
		[Embed(source = '../../../../data/levels/original/level.png')] private var _imgBgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/leveloverlay.png')] private var _imgFgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/sounds.swf', symbol="Fly")] private var _soundFlyOriginal:Class;
		private var _bgMusicURLOriginal:String = "music/original/m_bump.mp3";
		private var _rabbitColorsOriginal:Array = new Array(0xDBDBDB, 0xDFBF8B, 0xA7A7A7, 0xB78F77);
		
		// asset holders, the assets for the current level will be copied into these variables and then used
		private var _dataMap:Class;
		private var _imgBg:Class;
		private var _imgFg:Class;
		private var _soundFly:Class;
		private var _bgMusicURL:String;
		private var _rabbitColors:Array;
		
		// timers for objects created by players (dust, bubbles)
		private static const _DUST_DELAY:Number = 0.05;			// delay between creating dust particles
		private static const _BUBBLE_DELAY:Number = 0.15;		// delay between creating bubble particles
		
		// other parts of the game
		private var _map:FlxTilemap;
		private var _respawnMap:Array;				// array that holds all positions where a player can spawn (VOID above SOLID or ICE)
		private var _scoreboard:Scoreboard;

		// the various groups
		public static var gBackground:FlxGroup;		// group for background image
		public static var gMap:FlxGroup;			//   "    "  tilemap view for debugging
		public static var gParticles:FlxGroup;		//   "    "  simple particles (dust, splashes)
		public static var opBubbles:ObjectPool;		//   "    "  bubble particles (is Object Pool)
		public static var gore:Gore;
		public static var gSprings:FlxGroup;		//   "    "  springs
		public static var gButflies:FlxGroup;		//   "    "  butterflies
		public static var gFlies:FlxGroup;			//   "    "  flies
		public static var gPlayers:FlxGroup;		//   "    "  players
		public static var gForeground:FlxGroup;		//   "    "  foreground image
		public static var opPopupTexts:ObjectPool;	//   "    "  Popup Texts (is Object Pool)
		public static var gUI:FlxGroup;				//   "    "  unique UI elements (icons (crown), buttons, scoreboard)

		
		// "Lord of the Flies" game mode specific variables
		private var _crown:FlxSprite;				// crown sprite, displayed above current Lord

		
		// bubbles (bubble burst num see above)
		private static const NUM_BUBBLES:uint = 35;
		private static const NUM_BUBBLES_VARIATION:uint = 5;
		private static const BUBBLES_POOLSIZE:uint = (NUM_BUBBLES + NUM_BUBBLES_VARIATION) * 4;
		
		// popuptext 
		private static const POPUPTEXT_POOLSIZE:uint = 4;
		
		// butterflies
		private static const NUM_BUTFLIES:uint = 4;
		
		// flies
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
			// Display Statistics
//			addChild( new Stats() );
			
			// Loading assets into variables
			// defaults
			_dataMap = _dataMapOriginal;
			_imgBg = _imgBgOriginal;
			_imgFg = _imgFgOriginal;
			_soundFly = _soundFlyOriginal;
			_bgMusicURL = _bgMusicURLOriginal;
			_rabbitColors = _rabbitColorsOriginal;

			// overrides by specific levels
			switch (FlxG.levels[1])
			{
				case "green":
					_dataMap = _dataMapGreen;
					_imgBg = _imgBgGreen;
					_imgFg = _imgFgGreen;
					break;
				
				case "topsy":
					_dataMap = _dataMapTopsy;
					_imgBg = _imgBgTopsy;
					_imgFg = _imgFgTopsy;
					break;
				
				case "rabtown":
					_dataMap = _dataMapRabtown;
					_imgBg = _imgBgRabtown;
					_imgFg = _imgFgRabtown;
					break;
				
				case "jump2":
					_dataMap = _dataMapJump2;
					_imgBg = _imgBgJump2;
					_imgFg = _imgFgJump2;
					break;

				case "crystal2":
					_dataMap = _dataMapCrystal2;
					_imgBg = _imgBgCrystal2;
					_imgFg = _imgFgCrystal2;
					break;

				case "witch":
					_dataMap = _dataMapWitch;
					_imgBg = _imgBgWitch;
					_imgFg = _imgFgWitch;
					_rabbitColors = _rabbitColorsWitch;
					break;
			}
			
			FlxG.music.loadStream(_bgMusicURL, true);
			FlxG.music.survive = true;
			FlxG.music.play();
			
			_flyNoise = new FlxSound;
			_flyNoise.loadEmbedded(_soundFly, true);
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
			gSprings = new FlxGroup();
			gButflies = new FlxGroup();
			gFlies = new FlxGroup();
			gPlayers = new FlxGroup();
			gForeground = new FlxGroup();
			gUI = new FlxGroup()				// unique UI elements (icons (crown), buttons, scoreboard)
				
			// creating the background
			var _bg:FlxSprite = new FlxSprite(0, 0, _imgBg);
			gBackground.add(_bg);	
			
			// creating the foreground
			var _fg:FlxSprite = new FlxSprite(0, 0, _imgFg);
			gForeground.add(_fg);

			// creating the map
			_map = new FlxTilemap;
			_map.loadMap(new _dataMap, _imgTiles, 16)
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
			_crown = new FlxSprite(0, 0, _imgCrown);
			_crown.visible = false;
			gUI.add(_crown);
			
			// creating the flies
			var flySpawnPoint:Point;
			flySpawnPoint = _respawnMap[Math.floor(Math.random() * _respawnMap.length)];
			for (var j:int = 0; j < _numFlies; j++) 
			{
				gFlies.add(new Fly(flySpawnPoint.x + Math.random() * 32 - 16, flySpawnPoint.y + Math.random() * 32 - 16));
			}
			
			
			// creating the butflies
			var butflySpawnPoint:Point;
			for (var k:int = 0; k < NUM_BUTFLIES; k++) 
			{
				butflySpawnPoint = _respawnMap[Math.floor(Math.random() * _respawnMap.length)];
				gButflies.add(new ButFly(butflySpawnPoint.x, butflySpawnPoint.y));
			}
			
			/// initializing object pools
			opBubbles = new ObjectPool(Bubble, BUBBLES_POOLSIZE);
			gore = new Gore();
			opPopupTexts = new ObjectPool(PopupText, POPUPTEXT_POOLSIZE);

			// adds all the groups to this state (they are rendered in this order)
			this.add(gBackground);
//			this.add(gMap);
			this.add(gParticles);
			this.add(opBubbles);
			this.add(gore);
			this.add(gSprings);
			this.add(gButflies);
			this.add(gFlies);
			this.add(gPlayers);
			this.add(gForeground);
			this.add(opPopupTexts);
			this.add(gUI);

			// finally, fade in
			FlxG.flash.start(0xff000000, 0.4);
		}
		
		// Returns the TileIndex for the tile at position (x,y), to be used with _map.getTileByIndex() to get tile value at pos(x,y)
		private function getTileIndex(x:Number, y:Number):uint
		{
			return Math.floor(y / 16) * _map.widthInTiles + Math.floor(x / 16);
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
			// ! replaced by onFloor
			
			// SPRING: should propel the bunny upwards if:
			// most of the bunny is on it OR the spring is the only thing underneath the bunny
			// 
			if (tileBelowLeft == 4 || tileBelowRight == 4) // if either corner touches the spring
			{
				if (tileBelow < _map.collideIndex || tileBelow == 4) 	// and the center does too (most of the bunny is on the spring)
																		// OR the tile directly underneath is not solid (the bunny is touching nothing else)
				{				
					var leftCorner:Point = new Point(Math.floor(leftEdge / 16) * 16, Math.floor(below / 16) * 16);
					var rightCorner:Point = new Point(Math.floor(rightEdge / 16) * 16, Math.floor(below / 16) * 16);
					
					for each (var currentSpring:Spring in gSprings.members) 
					{
						if ((currentSpring.x == leftCorner.x && currentSpring.y == leftCorner.y) || 
							(currentSpring.x == rightCorner.x &&currentSpring.y == rightCorner.y))
							currentSpring.activate();

					}
					
					Rabbit.springJump();	// sproing!
				}
			}
			
			// ICE: the bunny should slide on ice if:
			// most of the bunny is on it OR the ice is the only thing colliding with the bunny
			// 
			if ((tileBelowLeft == 3 || tileBelowRight == 3) &&		// if either corner touches the ice
				(tileBelow < _map.collideIndex || tileBelow == 3))	// AND the tile below is either ice too or noncolliding
				Rabbit.isSliding = true;

			if (Rabbit.isSliding && 				// if the bunny is sliding
				tileBelow >= _map.collideIndex && 	// and the tile below is solid but not ice (i.e. the bunny has slid onto a solid tile)
				tileBelow != 3)
				Rabbit.isSliding = false;
			
			// WATER: two behaviors!
			
			// the bunny should SWIM if:
			// most of the bunny is in water
			if (tileBehind == 1 && !Rabbit.isSwimming) 
			{
				Rabbit.isSwimming = true;	// we're swimming now!
				gParticles.add(new Splash(Rabbit.x, Rabbit.y - (Rabbit.y % 16)));	// make a splash!

			}
			
			// the bunny should FLOAT if:
			// the center point of the bunny has just crossed the surface of the water from below
			if (tileBehind != 1 && 			// most of the bunny is not in water, 
				tileBelow == 1 &&			// its feet are wet,
				Rabbit.isSwimming && 		// swimming flag ist still enabled (bunny has just left water)
				Rabbit.velocity.y < 0 &&	// it came from below
				!Rabbit.isFloating)			// floating flag is not yet enabled
			{
				Rabbit.isFloating = true;	// we're floating now!
			}
			
			// exiting the pool in wondrous ways (coming out of the sides, falling through, etc.)
			if (tileBehind != 1 && 			// most of the bunny is not in water, 
				tileBelow != 1)				// there is no water directly below it (so we can't be floating)
			{
				if (Rabbit.isSwimming)		// but we're still swimming! must have fallen through or exited at an edge of the pool
											// otherwise the float check above would have caught it!
					Rabbit.isSwimming = false;
					
				if (Rabbit.isFloating)		// but we're stll floating! must have floated off the side
					Rabbit.isFloating = false;
			}

			if (Rabbit.onFloor || Rabbit.isSwimming || Rabbit.isFloating)
				Rabbit.killCount = 0;	// resets killCounter to zero
		}

		// Flixel does not handle collisions with the edges of the tilemap, only the tiles within.
		// Here we make sure no one can fall off the map.
		private function collideMapBorders(currentObject:FlxObject):void
		{
			var minX:Number = 1;
			var minY:Number = 1;
			var maxX:Number = 352 - currentObject.width -1;
			var maxY:Number = 256 - currentObject.height -1;


		
			if (currentObject.y < minY)	// bunny is above the map ceiling (this IS allowed)
									// in this case we extend the walls in the first row infinitely upward
									// (standing on top of the map was extremely problematic the last time I tried it)
			{
				var leftEdge:Number = currentObject.x; 
				var rightEdge:Number = currentObject.x + currentObject.width - 1;

				var leftTileIndex:uint = getTileIndex(leftEdge, minY);
				var rightTileIndex:uint = getTileIndex(rightEdge, minY);

				var leftTile:uint = _map.getTileByIndex(leftTileIndex);
				var rightTile:uint = _map.getTileByIndex(rightTileIndex);
				
				if (leftTile >= _map.collideIndex)
				{
					currentObject.x = (leftTileIndex + 1) * 16;
					currentObject.hitLeft(null, 0);
					}
				
				if (rightTile >= _map.collideIndex)
				{
					currentObject.x = rightTileIndex * 16 - currentObject.width;
					currentObject.hitRight(null, 0);
				}

			}
			
			
			if (currentObject.x < minX)		// falling off the map on the LEFT side (this is NOT allowed)
			{
				currentObject.x = minX
				currentObject.hitLeft(null, 0);
			}
			if (currentObject.x > maxX)		// falling off the map on the RIGHT side (this is NOT allowed)
			{
				currentObject.x = maxX
				currentObject.hitRight(null, 0);
			}
			if (currentObject.y > maxY)		// falling out of the BOTTOM of the map (this is NOT allowed)
			{
				currentObject.y = maxY
				currentObject.hitBottom(null, 0);
			}
		}
		
		// called when one player kills another
		private function killPlayer(Killer:Player, Killee:Player):void
		{
			Killer.bounceJump();			// killer bounces
			gore.createGibs(Killee.rabbitIndex, Killee.x + Killee.width * 0.5, Killee.y + Killee.height * 0.5 , Killee.velocity.x, Killee.velocity.y); 
			Killee.kill();					// killee and is dead
			
			
			if (FlxG.levels[0] == "lotf")	// if game mode is LOTF
			{
				if (FlxG.score == -1 || FlxG.score == Killee.rabbitIndex)	// and either there is no lord OR the killer killed him
					FlxG.score = Killer.rabbitIndex;						// there is a new lord!
			}
			else	// if game mode is standard DM
			{
				if (Killer.killCount < 5)
					Killer.killCount++;
				FlxG.scores[Killer.rabbitIndex] += Killer.killCount;	// increment killer score

				
				if (Killer.killCount > 1)
				{
					var newPopupText:PopupText = PopupText(opPopupTexts.getFirstAvail());

					if (Killer.killCount < 4)
					{
						newPopupText.activate(Killer.x + 8, Killer.y, 16, "+" + Killer.killCount.toString(), 2, _rabbitColors[Killer.rabbitIndex]);
					}
					else if (Killer.killCount == 4)
					{
						newPopupText.activate(Killer.x + 8, Killer.y, 56, "MULTIKILL!", 2, _rabbitColors[Killer.rabbitIndex]);
					}
					else if (Killer.killCount == 5)
					{
						newPopupText.activate(Killer.x + 8, Killer.y, 100, "M-M-MONSTERKILL!", 3.5, 0xB70000);
					}
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
						if (Math.abs(pA.x - pB.x) < maxWidth && 
							Math.abs(pA.y - pB.y) < maxHeight)	// check that they intersect
						{												
							//trace("PlayState:collidePlayers()");
							//trace("	Players " + pA.rabbitIndex + " and " + pB.rabbitIndex + " intersect;");
							
							if ((pA.y - pB.y > 5 && pA.velocity.y < pB.velocity.y) ||
								(pB.y - pA.y > 5 && pB.velocity.y < pA.velocity.y))
							{
								//trace("	Resolution: Kill");

								if (pA.y < pB.y)	// the one up top is faster than the one below
									killPlayer(pA, pB);								// playerKill(killer, killee);
								else
									killPlayer(pB, pA);
							}
							else
							{
								//trace("	Resolution: Push");

								
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
				spawnPoint = _respawnMap[Math.floor(Math.random() * _respawnMap.length)];
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
				
			for each (var ghost:Player in theDead)
			{
				var respawnPoint:Point = getFreeSpawnPoint();	
//				trace("respawning player R#" + ghost.rabbitIndex + "(" + ghost.x + "," + ghost.y+") at new location (" + respawnPoint.x + "," + respawnPoint.y+")");
				ghost.reset(respawnPoint.x, respawnPoint.y);
				ghost.particleTimer = 0;
			}

			return true;
		}


		
	
		// creates a shower of lovely bubbles
		private function bubbleBurstPlayer(Burstee:Player):void
		{
			var bubbleIndex:uint;
			
			trace("Player " + Burstee.rabbitIndex + " just burst :o");
			
			for (var re:int = 0; re < Math.floor((Math.random() * NUM_BUBBLES_VARIATION * 2) + (NUM_BUBBLES - NUM_BUBBLES_VARIATION)); re++) 
			{
				var currentObject:Bubble = Bubble(opBubbles.getFirstAvail());
				currentObject.activate(
					Burstee.x + 8, Burstee.y + 8,
					(Math.random() - 0.5 ) * 100, (Math.random() - 0.5 ) * 100
				);
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
				currentFly.move(SwarmCenter, 
								closestPlayerToFlyPosition, 
								closestPlayerToFly[1]);
			}
			
			// handle gibs
			for each (var currentGib:Gib in gore.gibs.members) 
			{
				// set underwater flag
				if (_map.getTileByIndex(getTileIndex(currentGib.x, currentGib.y)) == 1)
					currentGib.isUnderwater = true;
				else 
					currentGib.isUnderwater = false;
			}

			
			// handle popuptexts
			for each (var currentText:PopupText in opPopupTexts.members)
				currentText.update();
			
			// create new particles, perform collisions, erase dead ones
			updateParticles();			
			
			super.update();
			
			respawnPlayers();	// respawn dead players
			

			// collide gibs, players, butterflies and flies with the tilemap
			FlxU.collide(_map, gore.gibs);
			FlxU.collide(_map, gPlayers);
			FlxU.collide(_map, gButflies);
			FlxU.collide(_map, gFlies);
			FlxU.collide(_map, opBubbles);
			
			collidePlayers();	// handle player-player collisions
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
				if (currentPlayer.isSwimming && currentPlayer.particleTimer > _BUBBLE_DELAY && !currentPlayer.dead)
				{
					var xBubbleOrigin:Number;
					var yBubbleOrigin:Number;
					var newBubbleIndex:uint;
					
					if (currentPlayer.facing == 0)	// facing LEFT 
						xBubbleOrigin = currentPlayer.x + 3;
					else							// facing RIGHT
						xBubbleOrigin = currentPlayer.x + 10;
						
					yBubbleOrigin = currentPlayer.y + 7;
					
					var currentObject:Bubble = Bubble(opBubbles.getFirstAvail());
					currentObject.activate(xBubbleOrigin, yBubbleOrigin, currentPlayer.velocity.x, 0);

					currentPlayer.particleTimer = 0;
				}
				else if (currentPlayer.isSwimming && currentPlayer.particleTimer != -1 && currentPlayer.dead && currentPlayer.hasDrowned)
				{
					trace("Timer: " + currentPlayer.particleTimer);
					bubbleBurstPlayer(currentPlayer);
				}
				
				// new Dust
				if (currentPlayer.onFloor && !currentPlayer.isSliding 
					&& ((currentPlayer.isRunning && Math.abs(currentPlayer.velocity.x) < 96) 
						|| (!currentPlayer.isRunning && currentPlayer.velocity.x != 0))
					&& currentPlayer.particleTimer > _DUST_DELAY)
				{
					gParticles.add(new Dust(currentPlayer.x + 2 + Math.random() * 9, 
											currentPlayer.y + 13 + Math.random() * 5, 
											0, -10 - Math.random() * 5));
					
					currentPlayer.particleTimer = 0;
				}
			}
			
			// kill particles
			for each (var currentBubble:Bubble in opBubbles.members) 
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