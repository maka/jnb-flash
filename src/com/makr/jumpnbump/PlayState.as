package com.makr.jumpnbump
{
	import com.makr.jumpnbump.objects.Gib;
	import com.makr.jumpnbump.objects.Spring;
	import flash.geom.Point;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		FlxG.showCursor();

		[Embed(source = '../../../../data/levels/common/tiles.png')] private var ImgTiles:Class;

		// original level		
		[Embed(source = '../../../../data/levels/original/map.txt', mimeType = "application/octet-stream")] private var DataMap:Class;
		[Embed(source = '../../../../data/levels/original/level.png')] private var ImgBg:Class;
		[Embed(source = '../../../../data/levels/original/leveloverlay.png')] private var ImgFgMask:Class;
		private var _bgMusicURL:String = "../data/levels/original/m_bump.mp3";
		private var _bgMusic:FlxSound = new FlxSound();
		
		private var _player:Array = new Array();
		private var _map:FlxTilemap;
		private var _bg:FlxSprite;
		private var _fg:FlxSprite;
		
		private var _springs:Array;
		private var _gibs:Array;
		
		private var _respawnMap:Array;
		
		public static var lyrBG:FlxLayer;
		public static var lyrStage:FlxLayer;
		public static var lyrBGSprites:FlxLayer;
		public static var lyrSprites:FlxLayer;
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

		
		public function PlayState() 
		{
			_bgMusic.loadStream(_bgMusicURL, true);
			_bgMusic.play();
			

			
			super();
			
			// creating new layers
            lyrBG = new FlxLayer;
			lyrStage = new FlxLayer;
            lyrBGSprites = new FlxLayer;
            lyrSprites = new FlxLayer;
            lyrFG = new FlxLayer;
			
			// creating the background
			_bg = new FlxSprite;
			_bg.loadGraphic(ImgBg, false, false, 400, 256);
			_bg.x = _bg.y = 0;
			lyrBG.add(_bg);	
			
			// creating the foreground
			_fg = new FlxSprite;
			_fg.loadGraphic(ImgFgMask, false, false, 400, 256);
			_fg.x = _fg.y = 0;
			lyrFG.add(_fg);

			// creating the map
			_map = new FlxTilemap;
			_map.loadMap(new DataMap, ImgTiles, 16)
            _map.drawIndex = 0;
            _map.collideIndex = 2;
            _map.follow();
           lyrStage.add(_map);

			
			this.add(lyrBG);
		//	this.add(lyrStage);
			this.add(lyrBGSprites);
			this.add(lyrSprites);
			this.add(lyrFG);
			
			// creating the springs
			createSprings();
			
			_gibs = new Array;
			
			buildRespawnMap();

			// creating the bunnies
			if (FlxG.levels[2] & 1)
				_player.push(new Player(0, 196, 128));			
			if (FlxG.levels[2] & 2)
				_player.push(new Player(1, 208, 128));	
			if (FlxG.levels[2] & 4)
				_player.push(new Player(2, 224, 128));			
			if (FlxG.levels[2] & 8)
				_player.push(new Player(3, 240, 128));	
			
				
			for (var i:int = 0; i < _player.length; i++) 
			{
				lyrSprites.add(_player[i]);
			}
			
			// fade in
			FlxG.flash(0xff000000, 0.4);
		}
		
		private function createSprings():void
		{
			_springs = new Array;
			// TileIndex for Spring is 4
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
		
		private function getTileIndex(x:Number, y:Number):uint
		{
			return int(y / 16) * _map.widthInTiles + int(x / 16);
		}
		
		private function performTileLogic(playerid:uint):void
		{
			// Preparations:
			var floatThreshold:uint = 1;	// the size of the area where the bunny is floating between water and air
						
			// defining various x/y values around the bunny's position
			var leftEdge:Number = _player[playerid].x; 
			var rightEdge:Number = _player[playerid].x + _player[playerid].width - 1;
			var center:Point = new Point(_player[playerid].x + (_player[playerid].width - 1) / 2, _player[playerid].y + (_player[playerid].height - 1) / 2);
			var below:Number = _player[playerid].y + _player[playerid].height;
						
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
				_player[playerid].setGrounded(false);
			else
				_player[playerid].setGrounded(true);

			
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
					trace("player " + playerid + " is sprung");
					
					_player[playerid].jump(true);	// bounce!
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
					_player[playerid].setSliding(true);		// slide!
				}
			}
			if (_player[playerid].isSliding() && 			// if the bunny is sliding
				tileBelow >= _map.collideIndex && 			// and the tile below is solid
				tileBelow != 3)								// but not ice
															// (i.e. the bunny has slid onto a solid tile)
			{
				_player[playerid].setSliding(false);		// unslide!
			}
			
			// WATER: two behaviors!
			
			// the bunny should SWIM if:
			// most of the bunny is in water
			
			// the bunny should FLOAT if:
			// the center point of the bunny has just crossed the surface of the water from below
			
			// swim check
			if (tileBehind == 1 &&						// most of the bunny is underwater.
				!_player[playerid].isSwimming())		// swimming flag ist not yet enabled
			{
				_player[playerid].setSwimming(true);	// we're swimming!
				_player[playerid].setFloating(false);	// but not floating
			}
			
			// float check
			if (tileBehind != 1 && 						// most of the bunny is not in water, 
				tileBelow == 1 &&						// its feet are wet,
				_player[playerid].isSwimming() && 		// swimming flag ist still enabled (bunny has just left water)
				_player[playerid].velocity.y < 0 &&		// it came from below
				!_player[playerid].isFloating())		// floating flag is not yet enabled
			{
				_player[playerid].setSwimming(false);	// not swimming anymore
				_player[playerid].setFloating(true);	// we're floating now!
			}
			
			// exiting the pool in wondrous ways (coming out of the sides, falling through, etc.)
			if (tileBehind != 1 && 						// most of the bunny is not in water, 
				tileBelow != 1)							// there is no water directly below it (so we can't be floating)
			{
				if (_player[playerid].isSwimming())		// but we're still swimming! must have fallen through or exited at an edge of the pool
					_player[playerid].setSwimming(false);
					
				if (_player[playerid].isFloating())		// but we're stll floating! must have floated off the side
					_player[playerid].setFloating(false);
			}
		}
		
		private function collideMapBorders(playerid:uint):void
		{
			var minX:Number = 1;
			var minY:Number = 1;
			var maxX:Number = 352 - _player[playerid].width -1;
			var maxY:Number = 256 - _player[playerid].height -1;


		
			if (_player[playerid].y < minY)
			{
				var leftEdge:Number = _player[playerid].x; 
				var rightEdge:Number = _player[playerid].x + _player[playerid].width - 1;

				var leftTileIndex:uint = getTileIndex(leftEdge, minY);
				var rightTileIndex:uint = getTileIndex(rightEdge, minY);

				var leftTile:uint = _map.getTileByIndex(leftTileIndex);
				var rightTile:uint = _map.getTileByIndex(rightTileIndex);
				
				if (leftTile >= _map.collideIndex)
				{
					_player[playerid].velocity.x = 0;
					_player[playerid].x = (leftTileIndex + 1) * 16;
					trace("PlayState.collideMapBorders: Can't go further left!");
				}
				
				if (rightTile >= _map.collideIndex)
				{
					_player[playerid].velocity.x = 0;
					_player[playerid].x = rightTileIndex * 16 - _player[playerid].width;
					trace("PlayState.collideMapBorders: Can't go further right!");
				}

			}
			
			
			if (_player[playerid].x < minX)
			{
				_player[playerid].velocity.x = 0;
				_player[playerid].x = minX
					trace("PlayState.collideMapBorders: Collision with left side of map");
			}
			if (_player[playerid].x > maxX)
			{
				_player[playerid].velocity.x = 0;
				_player[playerid].x = maxX
					trace("PlayState.collideMapBorders: Collision with right side of map");
			}
			if (_player[playerid].y > maxY)
			{
				_player[playerid].velocity.y = 0;
				_player[playerid].y = maxY
					trace("PlayState.collideMapBorders: Collision with map floor");
				_player[playerid].setGrounded(true);
			}
		}
		
		private function playerKill(killer:uint, killee:uint):void
		{
			_player[killer].velocity.y = -150;		
			_player[killee].die();
			gibPlayer(killee);
			FlxG.scores[killer]++;
			
		}
		
		
		private function collidePlayers():void
		{
			var numPlayers:uint = _player.length;
			
			var a:int = 0;
			var b:int = 0;
			
			var maxWidth:Number, maxHeight:Number;
			
			for (a = 0; a < _player.length - 1; a++) 
			{
				for (b = a + 1; b < _player.length; b++) 
				{
					//maxWidth = Math.max(_player[a].width, _player[b].width);
					maxWidth = 12;
					//maxHeight = Math.max(_player[a].height, _player[b].height);
					maxHeight = 12;

					if (!_player[a].dead && !_player[b].dead)						// check that both are alive
					{
						if (getAbsValue(_player[a].x - _player[b].x) < maxWidth && 
							getAbsValue(_player[a].y - _player[b].y) < maxHeight)	// check that they intersect
						{												
							trace("players " + a.toString() + " and " + b.toString() + " intersect!");
							
							if ( (_player[a].y - _player[b].y > 5 && _player[a].velocity.y < _player[b].velocity.y) ||
								(_player[b].y - _player[a].y > 5 && _player[b].velocity.y < _player[a].velocity.y) )
							{
								trace("	someones going to die.");

								
								if (_player[a].y < _player[b].y)	// the one up top is faster than the one below
								{
									playerKill(a, b);								// playerKill(killer, killee);
								}
								else
								{
									playerKill(b, a);
								}
							}
							else
							{
								trace("	someones going to get pushed.");

								
								if (_player[a].x < _player[b].x)
								{
									if (_player[a].velocity.x > 0)
										_player[a].x = _player[b].x - maxWidth;
									else if (_player[b].velocity.x < 0)
										_player[b].x = _player[a].x + maxWidth;
									else
									{
										_player[a].x -= _player[a].velocity.x * FlxG.elapsed;
										_player[b].x -= _player[b].velocity.x * FlxG.elapsed;
									}
									
									// swap the bunnies' velocity values
									_player[a].velocity.x ^= _player[b].velocity.x;
									_player[b].velocity.x ^= _player[a].velocity.x;
									_player[a].velocity.x ^= _player[b].velocity.x;
									if (_player[a].velocity.x > 0)
										_player[a].velocity.x = -_player[a].velocity.x;
									if (_player[b].velocity.x < 0)
										_player[b].velocity.x = -_player[b].velocity.x;
								}
								else
								{
									if (_player[a].velocity.x > 0)
										_player[b].x = _player[a].x - maxWidth;
									else if (_player[b].velocity.x < 0)
										_player[a].x = _player[b].x + maxWidth;
									else
									{
										_player[a].x -= _player[a].velocity.x * FlxG.elapsed;
										_player[b].x -= _player[b].velocity.x * FlxG.elapsed;
									}
									
									// swap the bunnies' velocity values
									_player[a].velocity.x ^= _player[b].velocity.x;
									_player[b].velocity.x ^= _player[a].velocity.x;
									_player[a].velocity.x ^= _player[b].velocity.x;
									if (_player[a].velocity.x < 0)
										_player[a].velocity.x = -_player[a].velocity.x;
									if (_player[b].velocity.x > 0)
										_player[b].velocity.x = -_player[b].velocity.x;
								}
							}
						}
					}
				}
			}
		}
		
		private function getClosestPlayerToPoint(A:Point):Array
		{
			var playerPosition:Point = new Point;
			
			var closestPlayer:uint;
			var closestDistance:Number = 10000;
			var currentDistance:Number;
			
			for (var i:int = 0; i < _player.length; i++) 
			{
				playerPosition.x = _player[i].x;
				playerPosition.y = _player[i].y;
				
				currentDistance = getDistance(playerPosition, A);
				
				if (currentDistance < closestDistance)
				{
					closestDistance = currentDistance;
					closestPlayer = i;
				}
				
			}
			
			return new Array(closestPlayer, closestDistance);
		}

		private function buildRespawnMap():void
		{
			_respawnMap = new Array;
			
			for (var x:int = 0; x < 22; x++) 
			{
				for (var y:int = 1; y < 15; y++) 
				{
					if (_map.getTileByIndex(y * 22 + x) == 0 &&		// if current tile  is VOID
						_map.getTileByIndex((y + 1) * 22 + x) == 2)	// and tile below is SOLID
					{
						_respawnMap.push(new Point(x * 16 + 8, y * 16 + 8));

					}
				}
			}
			
		}
		
		private function respawnPlayers():Boolean
		{
			var theDead:Array = new Array;
			
			for (var i:int = 0; i < _player.length; i++) 
			{
				if (!_player[i].exists)
					theDead.push(i);
			}

			if (theDead.length == 0)
				return false;
				
			for each (var ghost:uint in theDead)
			{
				var respawnPoint:Point;
				var closestPlayerDistance:Number;
				do {
					respawnPoint = _respawnMap[int(Math.random() * _respawnMap.length)];
					closestPlayerDistance = getClosestPlayerToPoint(respawnPoint)[1];
					trace("respawnPlayers: Searching for respawn point for player "+ghost+"...")
				} while (closestPlayerDistance < 32);
				
				_player[ghost].reset(respawnPoint.x - 7, respawnPoint.y - 9);
				trace("respawnPlayers: Found! (" + respawnPoint.x + ", " + respawnPoint.y + ")");
			}
				
				
			return true;
		}
		
		
		private function gibPlayer(PlayerID:uint):void
		{
			var _gibKind:String;
			var _gibIndex:uint;
			
			for (var re:int = 0; re < int(Math.random() * 6 + 5 ); re++) 
			{
				if (Math.random() * 10 < 4)
				{
					_gibKind = "Fur";
				}
				else
				{
					_gibKind = "Flesh";
				}
					
				_gibIndex = _gibs.push(new Gib(	_player[PlayerID].rabbitIndex, 
												_gibKind, _player[PlayerID].x + _player[PlayerID].width / 2, 
												_player[PlayerID].y + _player[PlayerID].height / 2));
				lyrBGSprites.add(_gibs[_gibIndex - 1]);
			}
			
			// cleanup gib array
			trace ("BEFORE: " + _gibs.length.toString());
			
			var indicesToDelete:Array = new Array;
			
			for (var i:int = 0; i < _gibs.length; i++) 
			{
				if (_gibs[i].dead)
					indicesToDelete.push(i)
			}

			for (var j:int = 0; j < indicesToDelete.length; j++) 
			{
				_gibs.splice(indicesToDelete.pop, 1);
			}
			trace ("AFTER: " + _gibs.length.toString());
			
		}
		

		
		override public function update():void
        {
			for (var i:int = 0; i < _player.length; i++) 
			{
				performTileLogic(i)
				collideMapBorders(i);
			}
			
			super.update();
			
			respawnPlayers();
			
			collidePlayers();

			for (var j:int = 0; j < _gibs.length; j++) 
			{
				_map.collide(_gibs[j]);	// perform player-tilemap collisions
			}

			for (var k:int = 0; k < _player.length; k++) 
			{
				_map.collide(_player[k]);	// perform player-tilemap collisions
			}
			

		}	
	}
}