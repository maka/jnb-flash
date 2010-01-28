package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class ScoreboardTile extends FlxSprite
	{
		
		// original level
		[Embed(source = '../../../../../data/levels/original/numbers.png')] private var ImgNumber:Class;
		
		public var Tiles:Array = new Array;
		
		
		public function ScoreboardTile(X:Number, Y:Number):void
		{
			x = X;
			y = Y;
			
			loadGraphic(ImgNumber, true, false, 16, 22);

			// set animations for everything the bunny can do
			addAnimation("0", [0]);
			addAnimation("1", [1]);
			addAnimation("2", [2]);
			addAnimation("3", [3]);
			addAnimation("4", [4]);
			addAnimation("5", [5]);
			addAnimation("6", [6]);
			addAnimation("7", [7]);
			addAnimation("8", [8]);
			addAnimation("9", [9]);
			play("0");
		}
	}
}