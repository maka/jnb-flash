package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	
	
	public class Dust extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/dust.png')] private var _imgDustOriginal:Class;
		
		
		private var _imgDust:Class;
		
		
		public function Dust(X:Number = 0, Y:Number = 0, Xvel:Number = 0, Yvel:Number = 0):void
		{
			// Loading assets into variables
			// defaults
			_imgDust = _imgDustOriginal;

			super(X, Y);
			loadGraphic(_imgDust, true, false, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
			velocity.x = Xvel;
			velocity.y = Yvel;
			
           // set bounding box
            width = 5;
            height = 5;
			
            offset.x = 1;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 6;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("dust", [0, 1, 2, 3, 4], 25, false);
			
			play("dust");
		}
		public override function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			play("dust");
		}
		
		public override function update():void
		{
			if (finished == true)
				kill();
			
			super.update();
		}
	}
}