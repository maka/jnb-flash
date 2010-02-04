package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Scoreboard
	{
		public var Tiles:Array = new Array;
		
		private function numberToArray(x:Number):Array
		{  
			var i:Array = [];  
			var j:uint = 0;  
			var text:String = "0" + int(x).toString();
			while (j < text.length) {  
				i.push(text.charAt(j++));  
			}  
			return i;  
		}  
		
		public function Scoreboard():void
		{
			for (var y:int = 0; y < 4; y++) 
			{
				for (var x:int = 0; x < 2; x++) 
				{
					Tiles[y * 2 + x] = new ScoreboardTile(360 + x * 16, 34 + y * 64);
				}
			}
			
			trace("Scoreboard:	Initialized");
		}
		
		public function update():void
		{
			for (var i:int = 0; i < FlxG.scores.length; i++) 
			{
				var scoreArray:Array = numberToArray(FlxG.scores[i]);
				Tiles[2 * i + 1].play(scoreArray.pop());
				Tiles[2 * i + 0].play(scoreArray.pop());
			}
		}
	}
}