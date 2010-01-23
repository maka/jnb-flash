package  
{
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		[Embed(source='../data/levels/test/tiles.png')] private var ImgTiles:Class;
		[Embed(source = '../data/levels/test/map.txt', mimeType = "application/octet-stream")] private var DataMap:Class;
		
		private var _player:Player;
		private var _map:FlxTilemap;
		
		public static var lyrStage:FlxLayer;
		public static var lyrSprites:FlxLayer;
		public static var lyrHUD:FlxLayer;

		public function PlayState() 
		{
			super();
			
			// creating new layers
            lyrStage = new FlxLayer;
            lyrSprites = new FlxLayer;
            lyrHUD = new FlxLayer;
			
			// creating a bunny
			_player = new Player(200, 128);
			lyrSprites.add(_player);
			
			// creating the map
			_map = new FlxTilemap;
			_map.loadMap(new DataMap, ImgTiles, 16)
            _map.drawIndex = 0;
            _map.collideIndex = 2;
			_map.follow();
            lyrStage.add(_map);

			this.add(lyrStage);
			this.add(lyrSprites);
			this.add(lyrHUD);
			
		}
		
		override public function update():void
        {
			// TILE LOGIC
			
			// looking up the tiles directly below the center and left and right edges of the bunny sprite			
			var tileBelow:uint = _map.getTile(Math.floor((_player.x + _player.width / 2) / 16), Math.floor((_player.y + _player.height) / 16));
			var tileBelowLeft:uint =  _map.getTile(Math.floor(_player.x / 16), Math.floor((_player.y + _player.height) / 16));
			var tileBelowRight:uint =  _map.getTile(Math.floor((_player.x + _player.width) / 16), Math.floor((_player.y + _player.height) / 16));
			
		//	trace(tileBelowLeft.toString() + tileBelow.toString() + tileBelowRight.toString());

			trace(_player.drag.x.toString());
			
			// 0 = Air
			// 1 = Water
			// 2 = Ground
			// 3 = Ice
			// 4 = Spring

			if (Math.max(tileBelowLeft, tileBelow, tileBelowRight) < _map.collideIndex)	// the bunny's feet are touching a non-solid tile (air, water)
				_player.setGrounded(false);
			else
				_player.setGrounded(true);

			
			// SPRING: should propel the bunny upwards if:
			// most of the bunny is on it OR the spring is the only thing colliding with the bunny
			// 
			if (tileBelowLeft == 4 || tileBelowRight == 4) // if an edge touches the spring
			{
				if (tileBelow < _map.collideIndex || tileBelow == 4) 	// and either the center does too (most of the bunny is in the spring)
																		// OR the tile directly underneath is not solid (the bunny is touching nothing else)
				{
					_player.jump(true);	// bounce!
				}
			}
			
			// ICE: the bunny should slip on ice if:
			// most of the bunny is on it OR the ice is the only thing colliding with the bunny
			// 
			if (tileBelowLeft == 3 || tileBelowRight == 3) // if an edge touches the ice
			{
				if (tileBelow < _map.collideIndex || tileBelow == 3) 	// and either the center does too (most of the bunny is in the ice)
																		// OR the tile directly underneath is not solid (the bunny is touching nothing else)
				{
					_player.setSliding(true);	// slide!
				}
			}
			if (_player.isSliding() && tileBelow >= _map.collideIndex && tileBelow != 3)	// if the bunny is sliding and the tile below is solid but not ice
																							// (i.e. the bunny has slid onto a solid tile)
			{
				_player.setSliding(false);	// unslide!
			}
			
            super.update();
            _map.collide(_player);	// perform player-tilemap collisions
		}	
	}
}