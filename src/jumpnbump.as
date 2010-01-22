package  
{
	import org.flixel.*;

	[SWF(width="800", height="512", backgroundColor="#000000")] //Set the size and color of the Flash file
	[Frame(factoryClass = "Preloader")] //Tells flixel to use the default preloader
	
	public class jumpnbump extends FlxGame
	{
		
		public function jumpnbump() 
		{
			super(400, 256, PlayState, 2); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			showLogo = false;
			//setLogoFX(0xff930000)
		}
		
	}

}