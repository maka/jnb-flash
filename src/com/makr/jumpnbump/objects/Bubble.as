package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Bubble	extends FlxSprite
	{
		
		// original level
		[Embed(source = '../../../../../data/levels/original/dust.png')] private var ImgBubbleOriginal:Class;
		
		
		private var ImgBubble:Class;
		
		
		public function Bubble(X:Number = 0,Y:Number = 0):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgBubble = ImgBubbleOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(ImgBubble, true, false, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 5;
            height = 5;
			
            offset.x = 5;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 3;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("dust", [0, 1, 2, 3, 4, 4], 5, false);
			addAnimationCallback(animationCallback);
			
			play("dust");
			trace("com.makr.jumpnbump.objects.Dust");
			trace("	Initialized");
		}
		public override function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			play("dust");
		}
		
		private function animationCallback(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (frameNumber == 5)
			{
				trace("com.makr.jumpnbump.objects.Dust");
				trace("	Animation finished");
				trace("	Entity destroyed");
				kill();
			}

		}
	}
}