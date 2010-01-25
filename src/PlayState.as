package  
{
	import flash.geom.Point;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		[Embed(source='../data/levels/test/tiles.png')] private var ImgTiles:Class;
		[Embed(source = '../data/levels/test/map.txt', mimeType = "application/octet-stream")] private var DataMap:Class;
		
		[Embed(source = '../data/levels/test/level.png')] private var ImgBg:Class;
		[Embed(source = '../data/levels/test/leveloverlay.png')] private var ImgFgMask:Class;
		
		private var bgMusic:FlxSound = new FlxSound();
		
		private var _player:Array = new Array();
		private var _map:FlxTilemap;
		private var _bg:FlxSprite;
		private var _fg:FlxSprite;
		
		private var _springs:Array;
		
		public static var lyrBG:FlxLayer;
		public static var lyrStage:FlxLayer;
		public static var lyrBGSprites:FlxLayer;
		public static var lyrSprites:FlxLayer;
		public static var lyrFG:FlxLayer;
		
		public function PlayState() 
		{
//			bgMusic.loadStream("http://sloeff.com/sachen/New.mp3", true);
			bgMusic.loadStream("../data/levels/test/m_bump.mp3", true);

			bgMusic.play();
			
			// fade in
			FlxG.flash(0xff000000, 0.4);

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

			// creating a bunny
			_player[0] = new Player(0, 200, 128);			
			_player[1] = new Player(1, 216, 128);	
			_player[2] = new Player(2, 232, 128);			
			_player[3] = new Player(3, 248, 128);	
			
			for (var i:int = 0; i < _player.length; i++) 
			{
				lyrSprites.add(_player[i]);
			}
			
			// lyrSprites.add(_player[playerid]);
			
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
			return Math.floor(y / 16) * _map.widthInTiles + Math.floor(x / 16);
		}
		
		private function performTileLogic(playerid:int):void
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
					var leftCorner:Point = new Point(Math.floor(leftEdge / 16) * 16, Math.floor(below / 16) * 16);
					var rightCorner:Point = new Point(Math.floor(rightEdge / 16) * 16, Math.floor(below / 16) * 16);
					
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
		
		private function collideMapBorders(playerid:int):void
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
		
		override public function update():void
        {
			for (var i:int = 0; i < _player.length; i++) 
			{
				performTileLogic(i)
				collideMapBorders(i);
			}

			super.update();
			
			for (var j:int = 0; j < _player.length; j++) 
			{
				_map.collide(_player[j]);	// perform player-tilemap collisions
			}
		}	
	}
}