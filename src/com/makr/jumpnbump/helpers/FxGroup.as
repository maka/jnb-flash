package com.makr.jumpnbump.helpers 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxPoint;
		
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
		
	/**
	 * @author PaulGene
	 */
	public class FxGroup extends FlxGroup
	{
		private var _helper:FlxSprite;
		private var _mtx:Matrix = new Matrix();
		public function FxGroup():void
		{
			super();
			
			// create a sprite that will act as an uncleared buffer for the bullets
			_helper = new FlxSprite();
			_helper.createGraphic(FlxG.width, FlxG.height, 0x00000000, true);
		}
		
		override public function render():void
		{
			// fade the alpha of the helper buffer
			_helper.pixels.colorTransform(new Rectangle(0, 0, FlxG.width, FlxG.height), new ColorTransform(1,1,1, 0.9999));
			
				
			// save FlxG.buffer
			var tmp:BitmapData = FlxG.buffer;

			// point FlxG.buffer at our helper sprite so the bullets get drawn onto this instead of FlxG.buffer
			FlxG.buffer = _helper.pixels;

			super.render();
				
			// put the buffer back
			FlxG.buffer = tmp;
				
			// copy our helper buffer to the main flixel buffer
			FlxG.buffer.copyPixels(_helper.pixels, new Rectangle(0, 0, FlxG.width, FlxG.height), new Point(0, 0), null, null, true);			
		}
	}
}