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
		private var killTimer:Number = 0;
		
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
			loadGraphic(ImgBubble, true, false, 4, 4); // load player sprite (is animated, is not reversible, is 4x4)
			
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
			addAnimation("bubble0", [0]);
			addAnimation("bubble1", [1]);
			addAnimation("bubble2", [2]);
			addAnimation("bubble3", [3]);
			
			switch (int(Math.random()*4)) 
			{
				case 0:
					play("bubble0")
					maxVelocity.y -= 9;
					break;
					
				case 1:
					play("bubble1")
					maxVelocity.y -= 6;
					break;
					
				case 2:
					play("bubble2")
					maxVelocity.y -= 3;
					break;
					
				case 3:
					play("bubble3")
					break;
			}
			trace("com.makr.jumpnbump.objects.Bubble");
			trace("	Initialized");
		}
		
		public override function update():void
		{
			if (velocity.y == 0)
				killTimer += FlxG.elapsed;
			
			if (killTimer > 1)
				kill();
			
			// random factor
			velocity.x += (int(Math.random() * 3) - 1) * 3;
			super.update();

		}
		
	}
}