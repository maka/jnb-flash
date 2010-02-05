﻿package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Dust	extends FlxSprite
	{
		
		// original level
		[Embed(source = '../../../../../data/levels/original/dust.png')] private var ImgDustOriginal:Class;
		
		
		private var ImgDust:Class;
		
		
		public function Dust(X:Number = 0, Y:Number = 0, XDirection:Number = 0):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgDust = ImgDustOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(ImgDust, true, false, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
 			velocity.x = 15 * XDirection;
			
           // set bounding box
            width = 5;
            height = 5;
			
            offset.x = 5;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 3;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("dust", [0, 1, 2, 3, 4, 4], 20, false);
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