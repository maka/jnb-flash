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
		private var killTimer:Number;
		
		public function Bubble():void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgBubble = ImgBubbleOriginal;
					break;
			}

			super(0, 0);
			loadGraphic(ImgBubble, true, false, 4, 4); // load player sprite (is animated, is not reversible, is 4x4)
			
			alpha = Math.random() * 0.5;
			
		//	color = 0x80C1F3;
			
			maxVelocity.x = 40;
			maxVelocity.y = 40;
			
            // set bounding box
            width = 4;
            height = 4;
			
			drag.x = 10;
			drag.y = 10;
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis

			exists = false;
			active = false;
			visible = false;
		}

		public function activate(X:Number = 0, Y:Number = 0, Xvel:Number = 0, Yvel:Number = 0):void
		{
			x = X;
			y = Y;
			exists = true;
			active = true;
			visible = true;

			acceleration.y = -30;

			velocity.x = Xvel;
			velocity.y = Yvel;
			
			killTimer = 0;

			switch (FlxU.floor(Math.random()*4)) 
			{
				case 0:
					frame = 0;
					maxVelocity.y = 31;
					break;
					
				case 1:
					frame = 1;
					maxVelocity.y = 34;
					break;
					
				case 2:
					frame = 2;
					maxVelocity.y = 37;
					break;
					
				case 3:
					frame = 3;
					maxVelocity.y = 40;
					break;
			}
		}

		public override function kill():void
		{
			exists = false;
			active = false;
			visible = false;
		}
		
		public override function update():void
		{
			if (acceleration.y != -30)
				trace("y-acceleration: " + acceleration.y);
			
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