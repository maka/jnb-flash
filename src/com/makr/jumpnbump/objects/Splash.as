package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	
	
	public class Splash	extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/splash.png')] private var _imgSplashOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Splash")] private var _soundSplashOriginal:Class;
		
		
		private var _imgSplash:Class;
		private var _soundSplash:Class;
		
		
		public function Splash(X:Number,Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					_imgSplash = _imgSplashOriginal;
					_soundSplash = _soundSplashOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(_imgSplash, true, false, 31, 13); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 31;
            height = 13;
			
            offset.x = 6;  //Where in the sprite the bounding box starts on the X axis
            offset.y = -4;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("splish", [0, 1, 2, 3, 4, 5, 6, 7, 8], 25, false);

			FlxG.play(_soundSplash);		// make some noise
			play("splish");
		}
		
		public override function update():void
		{
			if (finished == true)
				kill();
			
			super.update();
		}
	}
}