package com.makr.jumpnbump.objects
{
	import org.flixel.*;	
	
	public class KeySprite extends FlxSprite
	{
		[Embed(source = '../../../../../data/levels/common/keys.png')] private var ImgKeyLayout:Class;

		private var _fadeTime:Number = 0;
		private var _fadeTimer:Number = 0;
		
		public var rabbitIndex:uint;
		
		public function KeySprite(RabbitIndex:uint, X:Number = 0, Y:Number = 0):void
		{
			super(X, Y);
			loadGraphic(ImgKeyLayout, true, false, 19, 14); // load player sprite (is animated, is reversible, is 19x19)
			
			offset.x = 1;
			offset.y = 16;

			rabbitIndex = RabbitIndex;
			frame = rabbitIndex;
			
			alpha = 0;
			
			_fadeTime = -0.5;
		}
		
		
		public override function update():void
		{
			if (_fadeTime != 0)		// fading
				_fadeTimer += FlxG.elapsed;
				
			if (_fadeTime > 0 && _fadeTimer > 0)	// fading out
			{
				alpha = 1 - (_fadeTimer / _fadeTime);
				alpha *= alpha;
			}
			
			if (_fadeTime < 0 && _fadeTimer > 0)	// fading in
			{
				alpha = _fadeTimer / -_fadeTime;
				alpha *= alpha;
			}
			
			// limiting alpha to [0-1]
			if (alpha < 0)
				alpha = 0;
			if (alpha < 0)
				alpha = 0;
			
			if (_fadeTime > 0 && _fadeTimer > _fadeTime)	// fade out complete
				kill();

			if (_fadeTime < 0 && _fadeTimer > -_fadeTime)	// fade in complete
			{
				alpha = 1;
				_fadeTime = 0;
				_fadeTimer = 0;
			}

			super.update();
		}
		
		public function fadeOut(Time:Number = 0.5):void
		{
			_fadeTime = Time;
		}
	}
}