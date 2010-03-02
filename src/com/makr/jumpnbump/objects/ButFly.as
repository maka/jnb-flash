package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import flash.geom.Point;
	import org.flixel.*;	
	
	public class ButFly extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/butfly.png')] private var _imgButflyOriginal:Class;
		
		private var _imgButfly:Class;

		public function ButFly(X:Number, Y:Number):void
		{
			// Loading assets into variables
			// defaults
			_imgButfly = _imgButflyOriginal;

			
			x = X;
			y = Y;
			
			loadGraphic(_imgButfly, true, true, 9, 8); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 4;
            height = 4;
			
            maxVelocity.x = 40;
            maxVelocity.y = 40;
			
            offset.x = 1;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 3;  //Where in the sprite the bounding box starts on the Y axis

			
			/// set sprites
			var frames:Array = new Array();
			
			// this is a hack to make the animation start on a random frame
			switch (Math.floor(Math.random()*10)) 
			{
				case 0:
					frames = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1];
					break;
				case 1:
					frames = [1, 2, 3, 4, 5, 4, 3, 2, 1, 0];
					break;
				case 2:
					frames = [2, 3, 4, 5, 4, 3, 2, 1, 0, 1];
					break;
				case 3:
					frames = [3, 4, 5, 4, 3, 2, 1, 0, 1, 2];
					break;
				case 4:
					frames = [4, 5, 4, 3, 2, 1, 0, 1, 2, 3];
					break;
				case 5:
					frames = [5, 4, 3, 2, 1, 0, 1, 2, 3, 4];
					break;
				case 6:
					frames = [4, 3, 2, 1, 0, 1, 2, 3, 4, 5];
					break;
				case 7:
					frames = [3, 2, 1, 0, 1, 2, 3, 4, 5, 4];
					break;
				case 8:
					frames = [2, 1, 0, 1, 2, 3, 4, 5, 4, 3];
					break;
				case 9:
					frames = [1, 0, 1, 2, 3, 4, 5, 4, 3, 2];
					break;
			}
			
			if (Math.random() < 0.5)
				for (var i:int = 0; i < frames.length; i++) 
					frames[i] += 6;	// pink butterfly
			
			addAnimation("Fly", frames, 30);
			
			play("Fly");
		}
		
		public override function update():void
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
			if (y + velocity.y > 239)
				velocity.y = 0;
			
			super.update();
		
		}
	}
}