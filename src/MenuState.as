package
{
    import org.flixel.*;
    public class MenuState extends FlxState
    {
        override public function MenuState():void
	{
		var txt:FlxText
		txt = new FlxText(0, (FlxG.width / 2) - 80, FlxG.width, "Flixel Tutorial Game")
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
                FlxG.flash(0xffffffff, 0.75);
                FlxG.fade(0xff000000, 1, onFade);
            }
            super.update();
        }
        private function onFade():void
        {
            FlxG.switchState(PlayState);
        }
    }
}