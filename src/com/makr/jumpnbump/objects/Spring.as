package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Spring	extends FlxSprite
	{
		
		// original level
		[Embed(source = '../../../../../data/levels/original/spring.png')] private var ImgSpring:Class;
		[Embed(source = '../../../../../data/levels/original/spring.mp3')] private var SoundSpring:Class;
		
		
		public function Spring(X:Number,Y:Number):void
		{
			super(X, Y);
			loadGraphic(ImgSpring, true, true, 16, 12); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 16;
            height = 12;
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 8;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("idle", [5]);
			addAnimation("sproing", [0, 1, 2, 3, 4, 5], 20, false);
			addAnimationCallback(CallbackTest);

			play("idle");
			
			trace("com.makr.jumpnbump.objects.Spring");
			trace("	Initialized");
		}
		
		public function Activate():void
		{
			play("idle");
			play("sproing");
			FlxG.play(SoundSpring);
		
			trace("com.makr.jumpnbump.objects.Spring");
			trace("	Activated");

		}
		
		private function CallbackTest(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (name == "sproing" && frameNumber == 5)
			{
				play("idle");
				trace("Spring: Animation finished, now idle")
			}
		}
	}
}