package com.makr.jumpnbump
{
	import com.makr.jumpnbump.objects.ButFly;
	import com.makr.jumpnbump.objects.Fly;
	import com.makr.jumpnbump.objects.Gib;
	import com.makr.jumpnbump.objects.Spring;
	import com.makr.jumpnbump.objects.Dust;
	import com.makr.jumpnbump.objects.Bubble;
	import com.makr.jumpnbump.objects.Scoreboard;
	import flash.geom.Point;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		FlxG.showCursor();

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

		// original level		
		[Embed(source = '../../../../data/levels/original/levelmap.txt', mimeType = "application/octet-stream")] private var DataMapOriginal:Class;
		[Embed(source = '../../../../data/levels/original/level.png')] private var ImgBgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/leveloverlay.png')] private var ImgFgOriginal:Class;
		[Embed(source = '../../../../data/levels/original/sounds.swf', symbol="Fly")] private var SoundFlyOriginal:Class;
		private var _bgMusicURLOriginal:String = "../data/levels/original/m_bump.mp3";
		
		// asset holders, the assets for the current level will be copied into these variables and then used
		private var DataMap:Class;
		private var ImgBg:Class;
		private var ImgFg:Class;
		private var SoundFly:Class;
		private var _bgMusicURL:String;
		
		// arrays and timers for players and things created by players (dust, bubbles)
		private var _player:Array = new Array();				
		private var _playerParticleTimer:Array = new Array();	// a particle timer for each player
		private static const DUST_DELAY:Number = 0.1;			// delay between creating a dust particles
		private static const BUBBLE_DELAY:Number = 0.2;		// delay between creating a bubble particles
		private var _bubbles:Array = new Array();
		private var _springs:Array;
		private var _gibs:Array;
		
		// other of the game
		private var _map:FlxTilemap;
		private var _respawnMap:Array;				// array that holds all positions where a player can spawn (VOID above SOLID)
		private var _scoreboard:Scoreboard;

		// the various layers
		public static var lyrBG:FlxLayer;			// background layer
		public static var lyrStage:FlxLayer;		// tilemap layer, always disabled
		public static var lyrBGSprites:FlxLayer;	// sprites that should appear behind players (e.g. gibs)
		public static var lyrSprites:FlxLayer;		// other sprites (e.g. players)
		public static var lyrFG:FlxLayer;			// foreground layer
		
		// "Lord of the Flies" game mode specific variables
		private var _crown:FlxSprite;				// crown sprite, displayed above current Lord

		// butterfly variables
		private var _butflies:Array = new Array();
		private static const NUM_BUTFLIES:uint = 4;
		
		// fly variables
		private var _flyNoise:FlxSound;
		private var _flies:Array = new Array();
		private static const NUM_FLIES:uint = 20;
		private static const NUM_FLIES_LOTF:uint = 50;	// "Lord of the Flies" game mode specific variable
		private var _numFlies:uint;						// is set to either NUM_FLIES or NUM_FLIES_LOTF, depending on game mode

		
		
		
		
		// returns absolute value, faster than Math.abs()	
		private function getAbsValue(x:Number):Number
		{
			if (x < 0)
				return -x;
			else
				return x;
		}
		
		// returns distance between two Points a and b
		private function getDistance(A:Point, B:Point):Number
		{
			var deltaX:Number = B.x-A.x;  
			var deltaY:Number = B.y-A.y;  
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY); 
		}
		
		public function PlayState() 
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
					break;
				
				case "topsy":
					DataMap = DataMapTopsy;
					ImgBg = ImgBgTopsy;
					ImgFg = ImgFgTopsy;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;
				
				case "rabtown":
					DataMap = DataMapRabtown;
					ImgBg = ImgBgRabtown;
					ImgFg = ImgFgRabtown;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;
				
				case "jump2":
					DataMap = DataMapJump2;
					ImgBg = ImgBgJump2;
					ImgFg = ImgFgJump2;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;

				case "crystal2":
					DataMap = DataMapCrystal2;
					ImgBg = ImgBgCrystal2;
					ImgFg = ImgFgCrystal2;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;

				case "witch":
					DataMap = DataMapWitch;
					ImgBg = ImgBgWitch;
					ImgFg = ImgFgWitch;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;

				case "original":
				default:
					DataMap = DataMapOriginal;
					ImgBg = ImgBgOriginal;
					ImgFg = ImgFgOriginal;
					SoundFly = SoundFlyOriginal;
					_bgMusicURL = _bgMusicURLOriginal;
					break;
			}

			
			
			
			FlxG.music = new FlxSound;
			FlxG.music.loadStream(_bgMusicURL, true);
			FlxG.music.play();
			
			_flyNoise = new FlxSound;
			_flyNoise.loadEmbedded(SoundFly, true);
			_flyNoise.volume = 0;
			_flyNoise.play();
			
			super();
			
			if (FlxG.levels[0] == "lotf")
				_numFlies = NUM_FLIES_LOTF;
			else
				_numFlies = NUM_FLIES;
			
			// creating new layers
            lyrBG = new FlxLayer;
			lyrStage = new FlxLayer;
            lyrBGSprites = new FlxLayer;
            lyrSprites = new FlxLayer;
            lyrFG = new FlxLayer;
			
			// creating the background
			var _bg:FlxSprite = new FlxSprite;
			_bg.loadGraphic(ImgBg, false, false, 400, 256);
			_bg.x = _bg.y = 0;
			lyrBG.add(_bg);	
			
			// creating the foreground
			var _fg:FlxSprite = new FlxSprite;
			_fg.loadGraphic(ImgFg, false, false, 400, 256);
			_fg.x = _fg.y = 0;
			lyrFG.add(_fg);

			// creating the map
			_map = new FlxTilemap;
			_map.loadMap(new DataMap, ImgTiles, 16)
            _map.drawIndex = 0;
            _map.collideIndex = 2;
            _map.follow();
           lyrStage.add(_map);
			
			// creating the scoreboard
			_scoreboard = new Scoreboard();
			for each (var tile:FlxSprite in _scoreboard.Tiles) 
			{
				lyrBG.add(tile);
			}

			this.add(lyrBG);
		//	this.add(lyrStage);	// uncomment this to view the tilemap directly
			this.add(lyrBGSprites);
			this.add(lyrSprites);
			this.add(lyrFG);
			
			// creating the springs
			createSprings();
			
			// setting up gib array
			_gibs = new Array;
			
			// building respawn map
			_respawnMap = buildRespawnMap();

			// creating the bunnies
			var bunnySpawnPoint:Point = new Point(0, 0);
			if (FlxG.levels[2] & 1)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				_player.push(new Player(0, bunnySpawnPoint.x, bunnySpawnPoint.y));			
			}
			if (FlxG.levels[2] & 2)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				_player.push(new Player(1, bunnySpawnPoint.x, bunnySpawnPoint.y));	
			}
			if (FlxG.levels[2] & 4)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				_player.push(new Player(2, bunnySpawnPoint.x, bunnySpawnPoint.y));			
			}
			if (FlxG.levels[2] & 8)
			{
				bunnySpawnPoint = getFreeSpawnPoint();
				_player.push(new Player(3, bunnySpawnPoint.x, bunnySpawnPoint.y));	
			}
			
			// adding bunnies to Sprite Layer
			for (var i:int = 0; i < _player.length; i++) 
			{
				_playerParticleTimer[i] = 0;
				lyrSprites.add(_player[i]);
			}
			
			// creating the lotf crown
			_crown = new FlxSprite(0, 0, ImgCrown);
			_crown.visible = false;
			lyrFG.add(_crown);
			
			// creating the flies
			var flySpawnPoint:Point;
			flySpawnPoint = _respawnMap[int(Math.random() * _respawnMap.length)];
			for (var j:int = 0; j < _numFlies; j++) 
			{
				_flies.push(new Fly(flySpawnPoint.x + Math.random() * 32 - 16, flySpawnPoint.y + Math.random() * 32 - 16));
				lyrBGSprites.add(_flies[j]);
			}
			
			
			// creating the butflies
			var butflySpawnPoint:Point;
			for (var k:int = 0; k < NUM_BUTFLIES; k++) 
			{
				butflySpawnPoint = _respawnMap[int(Math.random() * _respawnMap.length)];
				_butflies.push(new ButFly(butflySpawnPoint.x, butflySpawnPoint.y));
				lyrBGSprites.add(_butflies[k]);
			}
			
			// fade in
			FlxG.flash(0xff000000, 0.4);
		}
		
		// looks for tiles with value 4 (SPRING) and creates a Spring object at that position
		private function createSprings():void
		{
			_springs = new Array;
			// Tile for Spring is 4
			for (var x:int = 0; x < 22; x++) 
			{
				for (var y:int = 0; y < 16; y++) 
				{
					if (_map.getTileByIndex(y * 22 + x) == 4)
					{
						trace("x:" + x + "; y:" + y);
						_springs.push(lyrBGSprites.add(new Spring(x * 16, y * 16)));
					}
					
				}
			}		}
		
		// returns the TileIndex for the tile at position (x,y), to be used with _map.getTileByIndex() to get tile value at pos(x,y)
		private function getTileIndex(x:Number, y:Number):uint
		{
			return int(y / 16) * _map.widthInTiles + int(x / 16);
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
			if (Math.max(tileBelowLeft, tileBelow, tileBelowRight) < _map.collideIndex)	// the bunny's feet are touching a non-solid tile (air, water)
				Rabbit.setGrounded(false);
			else
				Rabbit.setGrounded(true);

			
			// SPRING: should propel the bunny upwards if:
			// most of the bunny is on it OR the spring is the only thing underneath the bunny
			// 
			if (tileBelowLeft == 4 || tileBelowRight == 4) // if either corner touches the spring
			{
				if (tileBelow < _map.collideIndex || tileBelow == 4) 	// and the center does too (most of the bunny is on the spring)
																		// OR the tile directly underneath is not solid (the bunny is touching nothing else)
				{				
					var leftCorner:Point = new Point(int(leftEdge / 16) * 16, int(below / 16) * 16);
					var rightCorner:Point = new Point(int(rightEdge / 16) * 16, int(below / 16) * 16);
					
					for (var i:int = 0; i < _springs.length; i++) 
					{
						if ((_springs[i].x == leftCorner.x && _springs[i].y == leftCorner.y) || 
							(_springs[i].x == rightCorner.x && _springs[i].y == rightCorner.y))
							_springs[i].Activate();

					}
					trace("rabbit " + Rabbit.rabbitIndex + " is sprung");
					
					Rabbit.jump(true);	// bounce!
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
					trace("PlayState.collideMapBorders: Can't go further left!");
				}
				
				if (rightTile >= _map.collideIndex)
				{
					Sprite.velocity.x = 0;
					Sprite.x = rightTileIndex * 16 - Sprite.width;
					trace("PlayState.collideMapBorders: Can't go further right!");
				}

			}
			
			
			if (Sprite.x < minX)		// falling off the map on the LEFT side (this is NOT allowed)
			{
				Sprite.velocity.x = 0;
				Sprite.x = minX
					trace("PlayState.collideMapBorders: Collision with left side of map");
			}
			if (Sprite.x > maxX)		// falling off the map on the RIGHT side (this is NOT allowed)
			{
				Sprite.velocity.x = 0;
				Sprite.x = maxX
					trace("PlayState.collideMapBorders: Collision with right side of map");
			}
			if (Sprite.y > maxY)		// falling out of the BOTTOM of the map (this is NOT allowed)
			{
				Sprite.velocity.y = 0;
				Sprite.y = maxY
					trace("PlayState.collideMapBorders: Collision with map floor");
				Sprite.setGrounded(true);
			}
		}
		
		// called when one player kills another
		private function killPlayer(Killer:Player, Killee:Player):void
		{
			Killer.jump(false, true);		// killer bounces
			Killee.kill();					// killee dies
			gibPlayer(Killee);						// and gets gibbed
			
			
			if (FlxG.levels[0] == "lotf")	// if game mode is LOTF
			{
				if (FlxG.score == -1 || FlxG.score == Killee.rabbitIndex)	// and either there is no lord OR the killer killed him
					FlxG.score = Killer.rabbitIndex;						// there is a new lord!
			}
			else	// if game mode is standard DM
			{
				FlxG.scores[Killer.rabbitIndex]++;	// increment killer score
				_scoreboard.update();		// update the scoreboard
			}

		}
		
		// resolves all interactions between all players (Flixel collision is completely useless for this purpose)
		private function collidePlayers():void
		{
			var numPlayers:uint = _player.length;
			
			var a:int = 0;
			var b:int = 0;
			
			var pA:Player;
			var pB:Player;

			var maxWidth:Number, maxHeight:Number;
			
			for (a = 0; a < _player.length - 1; a++) 
			{
				for (b = a + 1; b < _player.length; b++) 
				{
					pA = _player[a];
					pB = _player[b];
					
					//maxWidth = Math.max(_player[a].width, _player[b].width);
					maxWidth = 12;
					//maxHeight = Math.max(_player[a].height, _player[b].height);
					maxHeight = 12;

					if (!pA.dead && !pB.dead)						// check that both are alive
					{
						if (getAbsValue(pA.x - pB.x) < maxWidth && 
							getAbsValue(pA.y - pB.y) < maxHeight)	// check that they intersect
						{												
							trace("players " + a.toString() + " and " + b.toString() + " intersect!");
							
							if ((pA.y - pB.y > 5 && pA.velocity.y < pB.velocity.y) ||
								(pB.y - pA.y > 5 && pB.velocity.y < pA.velocity.y))
							{
								trace("	someones going to die.");

								if (pA.y < pB.y)	// the one up top is faster than the one below
									killPlayer(pA, pB);								// playerKill(killer, killee);
								else
									killPlayer(pB, pA);
							}
							else
							{
								trace("	someones going to get pushed.");

								
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
			
			for each (var currentPlayer:Player in _player) 
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
					if (_map.getTileByIndex(y * 22 + x) == 0 &&					// if current tile  is VOID
						_map.getTileByIndex((y + 1) * 22 + x) == 2)				// and tile below is SOLID
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
				spawnPoint = _respawnMap[int(Math.random() * _respawnMap.length)];
				closestPlayerDistance = getClosestPlayerToPoint(spawnPoint)[1];
				trace("getFreeSpawnPoint: Searching for spawn point...")
			} while (closestPlayerDistance < 32);
			
			return spawnPoint;
		}
		
		// respawns dead players
		private function respawnPlayers():Boolean
		{
			var theDead:Array = new Array;
			
			
			for each (var currentPlayer:Player in _player)
			{
				if (!currentPlayer.active)
				{
					trace("!!!!!! respawn: player " + currentPlayer.rabbitIndex + " is dead!");
					currentPlayer.visible = false;
					theDead.push(currentPlayer);
				}
			}

			if (theDead.length == 0)
				return false;
				
			for each (var ghost:Player in theDead)
			{
				var respawnPoint:Point = getFreeSpawnPoint();	
				ghost.reset(respawnPoint.x, respawnPoint.y);
				trace("!!!!!! respawned player " + ghost.rabbitIndex);
			}

			return true;
		}
		
		// creates a shower of blood and gore
		private function gibPlayer(Gibbee:Player):void
		{
			var gibKind:String;
			var gibIndex:uint;
			
			for (var re:int = 0; re < int(Math.random() * 6 + 9 ); re++) 
			{
				if (Math.random() * 10 < 4)
				{
					gibKind = "Fur";
				}
				else
				{
					gibKind = "Flesh";
				}
					
				gibIndex = _gibs.push(new Gib(	Gibbee.rabbitIndex, 
												gibKind, Gibbee.x + Gibbee.width / 2, 
												Gibbee.y + Gibbee.height / 2));
				lyrBGSprites.add(_gibs[gibIndex - 1]);
			}
			
			// cleanup gib array
			trace ("BEFORE: " + _gibs.length.toString());
			
			var indicesToDelete:Array = new Array;
			
			for (var i:int = 0; i < _gibs.length; i++) 
			{
				if (_gibs[i].dead)
					indicesToDelete.push(i)
			}

			var currentIndex:int = 0;
			for (var j:int = 0; j < indicesToDelete.length; j++) 
			{
				currentIndex = indicesToDelete.pop();
				_gibs[currentIndex].kill();
				_gibs.splice(currentIndex, 1);
			}
			trace ("AFTER: " + _gibs.length.toString());
			
		}
		

		
		override public function update():void
        {
			// check if ESCAPE has been pressed and if so, exit PlayState
			if (FlxG.keys.justPressed("ESC"))
				FlxG.fade(0xff000000, 1, quit);

			// perform tile logic and collision with map borders for players
			for each (var currentPlayer:Player in _player) 
			{
				performTileLogic(currentPlayer)
				collideMapBorders(currentPlayer);
			}
	
			// create new particles, perform collisions, erase dead ones
			updateParticles();			
			
			
			/// LOTF GAME MODE
			// determine who is currently the Lord
			var LoTF:Player;
			if (FlxG.levels[0] == "lotf" && FlxG.score != -1)
				LoTF = getPlayerfromRabbitIndex(FlxG.score);
		
			// put a crown on the Lord
			if (FlxG.levels[0] == "lotf" && FlxG.score != -1)
			{
				_crown.visible = true;
				if (LoTF.facing == 0)		// facing LEFT
					_crown.x = LoTF.x + 2;
				else						// facing RIGHT
					_crown.x = LoTF.x + 5;
				_crown.y = LoTF.y - 10;
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
				for each (var thisFly:Fly in _flies) 
				{
					SwarmCenter.x += thisFly.x;
					SwarmCenter.y += thisFly.y;
				}
				SwarmCenter.x /= _numFlies;
				SwarmCenter.y /= _numFlies;
			}

			
			// fly noise volume control
			var PlayerToSwarmDistance:Number = getClosestPlayerToPoint(SwarmCenter)[1];
			var FlyVolume:Number = 0.6 - PlayerToSwarmDistance / 200;
			if (FlyVolume < 0)
				FlyVolume = 0;
				
			_flyNoise.volume = FlyVolume;
			
			if (FlxG.levels[0] == "lotf")				// in LoTF, flies are always near the Lord, so the _flyNoise is always heard
				_flyNoise.volume *= 0.5;				// make the experience less annoying by lowering the volume
			
			
			// make flies avoid player and stay in the swarm
			var closestPlayerToFly:Array = new Array;
			var closestPlayerToFlyPosition:Point;
			for (var j:int = 0; j < _numFlies; j++) 
			{
				closestPlayerToFly = getClosestPlayerToPoint(new Point(_flies[j].x, _flies[j].y));
				closestPlayerToFlyPosition = new Point(closestPlayerToFly[0].x + 8, closestPlayerToFly[0].y + 8);
				_flies[j].move(	SwarmCenter, 
								closestPlayerToFlyPosition, 
								closestPlayerToFly[1]);
			}
			
			// handle gibs underwater
			for each (var gib:Gib in _gibs) 
			{
				if (_map.getTileByIndex(getTileIndex(gib.x, gib.y)) == 1)
					gib.setSwimming(true);
				else 
					gib.setSwimming(false);
			}
			
			super.update();
			
			
			respawnPlayers();	// respawn dead players
			
			collidePlayers();	// handle player-player collisions

			// collide gibs, players, butterflies and flies with the tilemap
			_map.collideArray(_gibs);
			_map.collideArray(_player);
			_map.collideArray(_butflies);
			_map.collideArray(_flies);
		}	

		// returns a Player that matches the given RabbitIndex
		private function getPlayerfromRabbitIndex(RabbitIndex:uint):Player
		{
			var match:Player;
			
			for each (var currentPlayer:Player in _player) 
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
			var currentPlayerIndex:int = -1;
			for each (var currentPlayer:Player in _player)
			{
				_playerParticleTimer[++currentPlayerIndex] += FlxG.elapsed;
				
				// new Bubble
				if (currentPlayer.isSwimming() && 					// if the player is swimming AND
					_playerParticleTimer[currentPlayerIndex] > BUBBLE_DELAY)		// a new bubble can be created
				{
					var xBubbleOrigin:Number;
					var yBubbleOrigin:Number;
					var newBubbleIndex:uint;
					
					if (currentPlayer.facing == 0)	// facing LEFT 
						xBubbleOrigin = currentPlayer.x + 3;
					else							// facing RIGHT
						xBubbleOrigin = currentPlayer.x + 10;
						
					yBubbleOrigin = currentPlayer.y + 7;
					
					newBubbleIndex = _bubbles.push(new Bubble(xBubbleOrigin, yBubbleOrigin, currentPlayer.velocity.x, 0)) - 1;
					lyrBGSprites.add(_bubbles[newBubbleIndex]);
					
					_playerParticleTimer[currentPlayerIndex] = 0;
				}
				
				// new Dust
				if (currentPlayer.isGrounded() && 					// if the player is on the ground AND
					(currentPlayer.movementX * currentPlayer.velocity.x < 0 || getAbsValue(currentPlayer.velocity.x) < 15) &&
																// (is either moving in the opposite direction than the desired direction OR is moving quite slowly) AND
					currentPlayer.movementX != 0 &&				// a movement key is pressed AND
					_playerParticleTimer[currentPlayerIndex] > DUST_DELAY)		// a new dust particle can be created
				{
					var xDustOrigin:Number;
					var yDustOrigin:Number;
					var xDustDirection:int;
					
					if (currentPlayer.facing == 0)	// facing LEFT
					{
						xDustOrigin = currentPlayer.x + 14;
						xDustDirection = 1;
					}
					else							// facing RIGHT
					{
						xDustOrigin = currentPlayer.x + 8;
						xDustDirection = -1;
					}
					yDustOrigin = currentPlayer.y + currentPlayer.width
					
					lyrBGSprites.add(new Dust(xDustOrigin, yDustOrigin, xDustDirection));
					
					_playerParticleTimer[currentPlayerIndex] = 0;
				}
			}
			
			// perform bubble-tilemap collisions
			_map.collideArray(_bubbles);

			// erase dead bubbles from array
			var bubblesToDelete:Array = new Array;
			for (var i:int = 0; i < _bubbles.length; i++) 
			{
				// TileIndex 1 == WATER
				if (_map.getTileByIndex(getTileIndex(_bubbles[i].x, _bubbles[i].y)) != 1)
					bubblesToDelete.push(i);
			}
			var currentIndex:int;
			for (var j:int = 0; j < bubblesToDelete.length; j++) 
			{
				currentIndex = bubblesToDelete.pop();
				_bubbles[currentIndex].kill();
				_bubbles.splice(currentIndex, 1);
			}
			
		}

		// exits PlayState
        private function quit():void
        {
			_flyNoise.stop();
			FlxG.music.stop();
			FlxG.switchState(PlayerSelectState);
        }
	
	}
}