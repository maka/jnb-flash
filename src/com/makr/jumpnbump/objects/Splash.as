package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Splash	extends FlxSprite
	{
		
		// original level
		[Embed(source = '../../../../../data/levels/original/splash.png')] private var ImgSplashOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Splash")] private var SoundSplashOriginal:Class;
		
		
		private var ImgSplash:Class;
		private var SoundSplash:Class;
		
		
		public function Splash(X:Number,Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgSplash = ImgSplashOriginal;
					SoundSplash = SoundSplashOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(ImgSplash, true, false, 31, 13); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 31;
            height = 13;
			
            offset.x = 6;  //Where in the sprite the bounding box starts on the X axis
            offset.y = -4;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("splish", [0, 1, 2, 3, 4, 5, 6, 7, 8, 8], 25, false);
			addAnimationCallback(animationCallback);
			FlxG.play(SoundSplash);		// make some noise
			play("splish");
			
			trace("com.makr.jumpnbump.objects.Splash");
			trace("	Initialized");
		}
		
		private function animationCallback(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (frameNumber == 9)
			{
				trace("com.makr.jumpnbump.objects.Splash");
				trace("	Animation finished");
				trace("	Entity destroyed");
				kill();
			}

		}
	}
}