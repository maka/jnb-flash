package
{
	import com.makr.jumpnbump.*;
	import org.flixel.*;

	[SWF(width="800", height="512", backgroundColor="#000000")] //Set the size and color of the Flash file
	[Frame(factoryClass = "Preloader")] //Tells flixel to use the default preloader
	
	public class jumpnbump extends FlxGame
	{

		public function jumpnbump() 
		{
			FlxG.levels = new Array;
			FlxG.levels[0] = "dm";			// string for gamemode
			FlxG.levels[1] = "original";	// string for level
			FlxG.levels[2] = 0; 			// bitmask for storing which players are playing
			
			FlxG.scores = new Array;
			FlxG.scores[0] = 0;
			FlxG.scores[1] = 0;
			FlxG.scores[2] = 0;
			FlxG.scores[3] = 0;

			super(400, 256, PlayerSelectState, 2); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			showLogo = false;
			//setLogoFX(0xff930000)
		}
		
	}

}