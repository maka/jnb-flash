package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	
	
	public class ImgButton extends FlxButton
	{
	

		private const _BORDER_WIDTH:Number = 3;
		
		private var _hover:FlxSprite;
		private var _thumbnail:FlxSprite;
		private var _text:FlxText;
		
		public function ImgButton(X:Number,Y:Number, ImgThumbnail:Class, Callback:Function, Text:String):void
		{
			x = X - _BORDER_WIDTH;
			y = Y - _BORDER_WIDTH;
			
			super(x, y, Callback);
			
            // set button size
            width = 80 + _BORDER_WIDTH*2;
            height = 48 + _BORDER_WIDTH*2;
			
			_text = new FlxText(x, y, 80, Text);
			_text.y = y - 11;
			
			_thumbnail = new FlxSprite(X, Y, ImgThumbnail);
			
			_off = new FlxSprite(x,y)
			_off.createGraphic(width, height, 0xff222222);
			_off.scrollFactor = scrollFactor;
			_hover = new FlxSprite(x,y)
			_hover.createGraphic(width, height, 0xff666666);
			_hover.scrollFactor = scrollFactor;
			_on  = new FlxSprite(x,y)
			_on.createGraphic(width, height, 0xff006FD7);
			_on.scrollFactor = scrollFactor;
		}

		public override function update():void
		{
			super.update();
			
			// i don't know why this is so ridiculously complicated in FlxButton,
			// here's the simpe version of what I want to do:
			
			
			
			if (_onToggle) 
			{
				_text.color = 0xff006FD7;
				_hover.visible = false;
				_on.visible = true;
				_off.visible = false;
			}
			if (!_onToggle && !this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				_hover.visible = false;
				_on.visible = false
				_off.visible = true;
			}
			if (!_onToggle && this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) 
			{
				_text.color = 0x666666;
				_hover.visible = true;
				_on.visible = false
				_off.visible = false;
			}
		}

		
		public override function render():void
		{
			if (_hover.visible) 
				_hover.render();
			if (_on.visible) 
				_on.render();
			if (_off.visible)
				_off.render();
				
			_thumbnail.render();

			if (_hover.visible || _on.visible) 
				_text.render();

		}
	}
}