package
{
    import org.flixel.*;
    public class MenuState extends FlxState
    {
        override public function MenuState():void
	{
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
            FlxG.switchState(PlayState);
        }
    }
}