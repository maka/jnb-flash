package  
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Splash	extends FlxSprite
	{
		
		[Embed(source='../data/levels/test/splash.png')] private var ImgSplash:Class;
		[Embed(source = '../data/levels/test/splash.mp3')] private var SoundSplash:Class;
		
		
		public function Splash(X:Number,Y:Number):void
		{
			super(X, Y);
			loadGraphic(ImgSplash, true, true, 31, 13); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 31;
            height = 13;
			
            offset.x = 6;  //Where in the sprite the bounding box starts on the X axis
            offset.y = -4;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("splish", [0, 1, 2, 3, 4, 5, 6, 7, 8, 8], 25, false);
			addAnimationCallback(CallbackTest);
			FlxG.play(SoundSplash);		// make some noise
			play("splish");
			
			trace("Splash: Initialized")
			
		}
		
		private function CallbackTest(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (frameNumber == 9)
			{
				trace("Splash: Animation finished, entity destroyed")
				kill();
			}

		}
	}
}