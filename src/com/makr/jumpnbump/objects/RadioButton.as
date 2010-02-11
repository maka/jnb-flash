package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	public class RadioButton extends FlxButton
	{
	
		/// Assets independent from level selection
		[Embed(source = '../../../../../data/levels/common/radiobutton.png')] private var ImgRadioButton:Class;
		
		private var _radioButton:FlxSprite;
		private var _text:FlxText;
		
		public function RadioButton(X:Number, Y:Number, Text:String, Callback:Function, Width:Number):void
		{
			x = X; y = Y;
			
			super(x, y, Callback);
			
			_radioButton = new FlxSprite();
			_radioButton.loadGraphic(ImgRadioButton, true, false, 13, 13);
			_radioButton.addAnimation("unchecked", [0]);
			_radioButton.addAnimation("checked", [1]);
			_radioButton.addAnimation("unchecked_hover", [2]);
			_radioButton.addAnimation("checked_hover", [3]);
			_radioButton.x = x + 2;
			_radioButton.y = y;
			
            // set button size
            width = Width;
            height = 13;
			
			_text = new FlxText(x+18, y, Width - 18, Text);
		}

		public override function update():void
		{
			super.update();
			
			// i don't know why this is so ridiculously complicated in FlxButton,
			// here's the simpe version of what I want to do:
			
			if (_onToggle && !this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) 
			{
				_radioButton.play("checked");
			}
			if (_onToggle && this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) 
			{
				_radioButton.play("checked_hover");
			}
			if (!_onToggle && !this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				_radioButton.play("unchecked");
			}
			if (!_onToggle && this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) 
			{
				_radioButton.play("unchecked_hover");
			}
			
			if (this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
				_text.color = 0xffaaaaaa;
			if (!this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
				_text.color = 0xff888888;

		}

		
		public override function render():void
		{
			_radioButton.render();
			
			_text.render();
		}
	}
}