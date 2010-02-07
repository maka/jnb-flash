package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import flash.geom.Point;
	import org.flixel.*;	
	
	public class ButFly extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/butfly.png')] private var ImgButflyOriginal:Class;
		
		private var ImgButfly:Class;

		public function ButFly(X:Number, Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgButfly = ImgButflyOriginal;
					break;
			}

			
			x = X;
			y = Y;
			
			loadGraphic(ImgButfly, true, true, 9, 8); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 4;
            height = 4;
			
            maxVelocity.x = 40;
            maxVelocity.y = 40;
			
            offset.x = 1;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 3;  //Where in the sprite the bounding box starts on the Y axis

			
			// set sprites
			if (Math.random() > 0.5)
				addAnimation("Fly", 	[0, 1, 2, 3, 4, 5, 4, 3, 2, 1], 20); // Yellow Butfly
			else
				addAnimation("Fly", 	[6, 7, 8, 9, 10, 11, 10, 9, 8, 7], 20);	// Pink Butfly
			
			
			play("Fly");
		}
		
		override public function update():void
		{
			velocity.x += Math.random() * 8 - 4;
			velocity.y += Math.random() * 8 - 4;
			
			if (velocity.x > 0)
				facing = RIGHT;
			else
				facing = LEFT;
			
			if (x + velocity.x < 0)
				velocity.x = 0;
			if (x + velocity.x> 351)
				velocity.x = 0;
			if (y + velocity.y < 0)
				velocity.y = 0;
			if (y +velocity.y > 239)
				velocity.y = 0;
			
			super.update();
		
		}
		
		override public function hitWall(Contact:FlxCore = null):Boolean
		{
			velocity.x *= -0.5;
			velocity.x = 0;
			return true;
		}

		override public function hitFloor(Contact:FlxCore = null):Boolean
		{
			velocity.y *= -0.5;
			velocity.y = 0;
			
			return true;
		}

		override public function hitCeiling(Contact:FlxCore = null):Boolean
		{
			velocity.y *= -0.5;
			velocity.y = 0;
			
			return true;
		}
	}
}