package com.makr.jumpnbump
{
	import com.makr.jumpnbump.helpers.FxGroup;
	import com.makr.jumpnbump.helpers.ObjectPool;
	import com.makr.jumpnbump.helpers.SpritePool;
	import com.makr.jumpnbump.objects.Gore;
	
	import com.makr.jumpnbump.objects.RabbitDummy;
	import com.makr.jumpnbump.objects.Gib;
	
	import flash.display.BitmapData;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.flixel.*;
	import net.hires.debug.Stats;
	import flash.utils.getTimer;

	public class FireworksState extends FlxState
	{
		/// Individual level assets
		// witch level		
		private var _rabbitColorsWitch:Array = new Array(0x7CA824, 0xDFBF8B, 0xA7A7A7, 0xB78F77);

		// original level		
		private var _rabbitColorsOriginal:Array = new Array(0xDBDBDB, 0xDFBF8B, 0xA7A7A7, 0xB78F77);
		
		// asset holders, the assets for the current level will be copied into these variables and then used
		private var _rabbitColors:Array;

		private var gore:Gore;
		private var opRabbits:ObjectPool;
		private const _RABBITS_POOLSIZE:uint = 20;

		private var _spawnTimer:Number = 0;
		
		public override function create():void
		{
//			FlxG.timeScale = 0.1;

			// Display Statistics
			addChild( new Stats() );
			
			// Loading assets into variables
			// defaults
			_rabbitColors = _rabbitColorsOriginal;

			// overrides by specific levels
			switch (FlxG.levels[1])
			{
				case "witch":
					_rabbitColors = _rabbitColorsWitch;
					break;
			}


			/// initializing objects
			opRabbits = new ObjectPool(RabbitDummy, _RABBITS_POOLSIZE);
			gore = new Gore();

			this.add(gore);
			this.add(opRabbits);

			// finally, fade in
			FlxG.flash.start(0xff000000, 0.4);
		}
				
		private function spawnRabbit():void
		{
			var currentObject:RabbitDummy;
			currentObject = opRabbits.getFirstAvail() as RabbitDummy;
			currentObject.activate(
				Math.floor(Math.random() * 4), 
				150 + Math.random() * 100, 265, 
				Math.random() * 128 - 64, -265 + (Math.random() * 80)
			);
		}
		
	
		public override function update():void
        {
			// check if ESCAPE has been pressed and if so, exit PlayState
			if (FlxG.keys.justPressed("ESCAPE"))
				FlxG.fade.start(0xff000000, 1, quit);
			
			
			_spawnTimer -= FlxG.elapsed;
			if (_spawnTimer < 0 || FlxG.keys.pressed("SPACE"))
			{
				_spawnTimer = Math.random() * 3;
				spawnRabbit();
			}
			
			for each (var currentRabbit:RabbitDummy in opRabbits.members) 
			{
				if (currentRabbit.exists && currentRabbit.timer < 0)
				{
					gore.createGibs(currentRabbit.rabbitIndex, currentRabbit.x + currentRabbit.width * 0.5, currentRabbit.y + currentRabbit.height * 0.5, currentRabbit.velocity.x, currentRabbit.velocity.y, true, false); 
					currentRabbit.kill();
				}
			}
			
			super.update();
		}	

		// exits PlayState
        private function quit():void
        {
			FlxG.state = new PlayerSelectState();
        }
	
	}
}