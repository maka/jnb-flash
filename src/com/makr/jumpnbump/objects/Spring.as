package com.makr.jumpnbump.objects
{
	import org.flixel.*;	
	
	public class Spring	extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/spring.png')] private var _imgSpringOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Spring")] private var _soundSpringOriginal:Class;
		
		private var _imgSpring:Class;
		private var _soundSpring:Class;
		
		public function Spring(X:Number,Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					_imgSpring = _imgSpringOriginal;
					_soundSpring = _soundSpringOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(_imgSpring, true, true, 16, 12); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 16;
            height = 12;
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 8;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("idle", [5]);
			addAnimation("sproing", [0, 1, 2, 3, 4, 5], 20, false);
			addAnimationCallback(callbackTest);

			play("idle");
		}
		
		public function activate():void
		{
			play("idle");
			play("sproing");
			FlxG.play(_soundSpring);
		}
		
		private function callbackTest(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (name == "sproing" && frameNumber == 5)
				play("idle");
		}
	}
}