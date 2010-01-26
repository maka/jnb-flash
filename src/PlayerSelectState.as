package
{
    import org.flixel.*;
    public class PlayerSelectState extends FlxState
    {
		
		// original level		
		[Embed(source = '../data/levels/original/map.txt', mimeType = "application/octet-stream")] private var DataMap:Class;
		[Embed(source = '../data/levels/original/level.png')] private var ImgBg:Class;
		[Embed(source = '../data/levels/original/leveloverlay.png')] private var ImgFgMask:Class;
		private var _bgMusicURL:String = "../data/levels/original/m_jump.mp3";
		private var _bgMusic:FlxSound = new FlxSound();
		
        override public function PlayerSelectState():void
		{
			FlxG.showCursor(null);
			
			_bgMusic.loadStream(_bgMusicURL, true);
			_bgMusic.play();

			FlxG.flash(0xff000000, .4);
			
			var txt:FlxText
			txt = new FlxText(0, (FlxG.width / 2) - 80, FlxG.width, "Jump 'n Bump")
			txt.setFormat(null,16,0xFFFFFFFF,"center")
			this.add(txt);
				
			txt = new FlxText(0, FlxG.height  -24, FlxG.width, "PRESS X TO START")
			txt.setFormat(null, 8, 0xFFFFFFFF, "center");
			this.add(txt);
        }
        override public function update():void
        {
            if (FlxG.keys.X)
            {
                FlxG.fade(0xff000000, .4, onFade);
            }
            super.update();
        }
        private function onFade():void
        {
			_bgMusic.stop();
			FlxG.switchState(PlayState);
        }
    }
}