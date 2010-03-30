package
{
	import com.makr.jumpnbump.*;
	import org.flixel.*;

//	[SWF(width="1200", height="768", backgroundColor="#000000")] //Set the size and color of the Flash file
	[SWF(width="800", height="512", backgroundColor="#000000")] //Set the size and color of the Flash file
	[Frame(factoryClass = "Preloader")] //Tells flixel to use the default preloader
	
	public class jumpnbump extends FlxGame
	{
					
		public function jumpnbump() 
		{
//			super(400, 256, PlayerSelectState, 2); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			super(400, 256, FireworksState, 2); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			
			var gamePrefs:FlxSave;
			
			if (FlxG.levels.length == 0)	// FlxG.levels stores the games' options
			{
				FlxG.levels = new Array;
				// string for gamemode, default "dm"
				FlxG.levels[0] = String("dm");
				// string for level, default "original"
				FlxG.levels[1] = String("original");
				// bitmask for storing which players are playing a level right now
				FlxG.levels[2] = 0;
				// bitmask for storing which players have been used in this session at all (e.g. to display KeySprites above the others)
				FlxG.levels[3] = 0;

			}

			if (FlxG.scores.length == 0)	// FlxG.scores stores information about the current game (PlayState stuff)
			{
				FlxG.scores = new Array;
				// Score Matrix!
				FlxG.scores[0] = [
					0, 0, 0, 0,
					0, 0, 0, 0,
					0, 0, 0, 0,
					0, 0, 0, 0
				];
				
				// Works like the original scoreboard:
				//	
				// 			DOTT	JIFFY	FIZZ	MIJJI	(TOTAL)
				// DOTT		-		[0+1]	[0+2]	[0+3]	<- sum
				// JIFFY	[4+0]	-		[4+2]	[4+3]	<- sum
				// FIZZ		[8+0]	[8+1]	-		[8+3]	<- sum
				// MIJJI	[12+0]	[12+1]	[12+2]	-		<- sum
				//
				
				// LoTF stores the time in the unused values (DOTT-DOTT, JIFFY-JIFFY, etc.)
			}
			
			// lotf uses this variable to store the lord's rabbitIndex
			FlxG.scores[1] = -1;		
			
			FlxG.music = new FlxSound;
			
			// Load saved game data
			gamePrefs = new FlxSave();
			if(gamePrefs.bind("jnb-flash"))
			{
				if(gamePrefs.data.gamemode != null)
					FlxG.levels[0] = gamePrefs.data.gamemode;
				if(gamePrefs.data.levelname != null)
					FlxG.levels[1] = gamePrefs.data.levelname;
			}

		}
		
	}

}