package com.makr.jumpnbump.objects 
{
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import org.flixel.*;
	
	public class PopupText extends FlxText
	{
		
		private var _lifeTime:Number;
	
		private var _fadeTimer:Number;
		
		public function PopupText():void
		{
			super(0, 0, 1);
			exists = false;
			active = false;
			visible = false;
		}
		
		public function activate(X:Number, Y:Number, Width:uint, Text:String, LifeTime:Number = 2, Color:uint = 0xffffff):void
		{
			var xPos:Number = X - Width * 0.5;
			if (xPos < 0)
				xPos = 0;
			else if (xPos > 352 - Width)
				xPos = 352 - Width;
			var yPos:Number = Math.max(0, Y);
			
			// FlxText super() function
			if(Text == null)
				Text = "";
			_tf = new TextField();
			_tf.width = Width;
			_tf.height = 1;
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.sharpness = 100;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.defaultTextFormat = new TextFormat("system",8,0xffffff);
			_tf.text = Text;
			x = xPos;
			y = yPos;
			exists = true
			active = true;
			visible = true;
			createGraphic(Width,1);
			_regen = true;
			_shadow = 0x434343;
			alpha = 1;
			color = Color;
			solid = false;
			calcFrame();
			// end FlxText super() function
			
			_fadeTimer = 0
			_lifeTime = LifeTime;
			
		}
		
		public override function kill():void
		{
			exists = false;
			active = false;
			visible = false;
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