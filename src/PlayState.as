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
			
            lyrStage = new FlxLayer;
            lyrSprites = new FlxLayer;
            lyrHUD = new FlxLayer;
			
			_player = new Player(200, 128);
			
			lyrSprites.add(_player);
			
			_map = new FlxTilemap;
			_map.loadMap(new DataMap, ImgTiles, 16)
            _map.drawIndex = 1;
            _map.collideIndex = 1;
			_map.follow();
            lyrStage.add(_map);

			this.add(lyrStage);
            this.add(lyrSprites);
            this.add(lyrHUD);
		}
		
		override public function update():void
        {
            super.update();
            _map.collide(_player);
        }	
	}
}