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
			var text:String = "0" + Math.floor(x).toString();
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
		}
		
		public function logScoreboard():void
		{
			var a:Array = FlxG.scores[0].concat();
			
			for (var i:int = 0; i < a.length; i++) 
			{
				a[i] = int((a[i])*10)/10;
			}
			
			FlxG.log("		DOTT	JIFFY	FIZZ	MIJJI");
			FlxG.log("DOTT:	" + a[0] + "		" + a[1] + "		" + a[2] + "		" + a[3] + "		" + (a[0]+a[1]+a[2]+a[3]));
			FlxG.log("JIFFY:	" + a[4] + "		" + a[5] + "		" + a[6] + "		" + a[7] + "		" + (a[4]+a[5]+a[6]+a[7]));
			FlxG.log("FIZZ:	" + a[8] + "		" + a[9] + "		" + a[10] + "		" + a[11] + "		" + (a[8]+a[9]+a[10]+a[11]));
			FlxG.log("MIJJI:	" + a[12] + "		" + a[13] + "		" + a[14] + "		" + a[15] + "		" + (a[12]+a[13]+a[14]+a[15]));
		}
		
		public function update():void
		{
			var score:int;
			var scoreArray:Array;
			for (var i:int = 0; i < 4; i++) 
			{
				score = FlxG.scores[0][i * 4];
				score += FlxG.scores[0][i * 4 + 1];
				score += FlxG.scores[0][i * 4 + 2];
				score += FlxG.scores[0][i * 4 + 3];
				scoreArray = numberToArray(score);
				Tiles[2 * i + 1].play(scoreArray.pop());
				Tiles[2 * i + 0].play(scoreArray.pop());
			}
			
			logScoreboard();
		}
	}
}