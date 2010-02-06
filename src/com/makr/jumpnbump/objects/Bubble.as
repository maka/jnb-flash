package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	public class Bubble	extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/bubble.png')] private var ImgBubbleOriginal:Class;
		
		
		private var ImgBubble:Class;
		
		
		public function Bubble(X:Number = 0, Y:Number = 0, Xvel:Number = 0, Yvel:Number = 0):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgBubble = ImgBubbleOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(ImgBubble, true, false, 4, 4); // load player sprite (is animated, is reversible, is 19x19)
			
			alpha = Math.random() * 0.5 + 0.5;
			
			color = 0x80C1F3;
			
			velocity.x = Xvel;
			velocity.y = Yvel;
			
			maxVelocity.x = 40;
			maxVelocity.y = 40;
			
			acceleration.y = -30;
			
            // set bounding box
            width = 4;
            height = 4;
			
			drag.x = 10;
			drag.y = 10;
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("bubble", [0]);
			
			play("bubble");
			trace("com.makr.jumpnbump.objects.Bubble");
			trace("	Initialized");
		}
		
		public override function update():void
		{
			// random factor
			velocity.x += (int(Math.random() * 3) - 1) * 3;
			super.update();

		}
		
	}
}