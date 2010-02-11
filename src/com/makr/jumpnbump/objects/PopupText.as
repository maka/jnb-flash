package com.makr.jumpnbump.objects 
{
	import flash.geom.Point;
	import flash.text.TextFormat;
	import org.flixel.*;
	/**
	 * ...
	 * @author Max Käfler
	 */
	
	public class PopupText extends FlxText
	{
		
		private var _lifeTime:Number;
	
		private var _fadeTimer:Number = 0;
		
		public function PopupText(X:Number, Y:Number, Width:uint, Text:String, LifeTime:Number = 2):void
		{
			var xPos:Number = X - Width * 0.5;
			if (xPos < 0)
				xPos = 0;
			else if (xPos > 352 - Width)
				xPos = 352 - Width;
			var yPos:Number = Math.max(0, Y);
			
			super(xPos, yPos, Width, Text);

			_lifeTime = LifeTime;
			
			_shadow = 0x434343;
			

		}
		public override function kill():void
		{
			active = false;
			super.kill();
		}
		
		public override function update():void
		{
			if (!active)
				return;
				
			y -= 20 * FlxG.elapsed / _lifeTime;

			_fadeTimer += FlxG.elapsed;
			
			alpha = 1 - (_fadeTimer / _lifeTime) * (_fadeTimer / _lifeTime);
			
			if (_fadeTimer > _lifeTime)
			{
				alpha = 0;
				kill();
			}
				
			super.update();
		}
		
	}

}