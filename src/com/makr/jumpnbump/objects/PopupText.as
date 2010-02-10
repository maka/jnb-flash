package com.makr.jumpnbump.objects 
{
	import flash.geom.Point;
	import org.flixel.*;
	/**
	 * ...
	 * @author Max Käfler
	 */
	
	public class PopupText extends FlxText
	{
		
		private static const _VELOCITY:Point = new Point(0, -20);
		private var _lifeTime:Number;
	
		private var _fadeTimer:Number = 0;
		
		public function PopupText(X:Number, Y:Number, Width:uint, Text:String, LifeTime:Number = 2):void
		{
			_lifeTime = LifeTime;
			
			trace("popupText init(" + X + ", " + Y + ", " + Width + ", " + Text + ")");
			
			super(X - Width * 0.5, Y, Width, Text);
			
			velocity.y = _VELOCITY.y / _lifeTime;
			velocity.x = _VELOCITY.x / _lifeTime;
		}
		public override function kill():void
		{
			trace("popupText kill");
			active = false;
			super.kill();
		}
		
		public override function update():void
		{
			if (!active)
				return;
				
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