package com.makr.jumpnbump
{
	import com.makr.jumpnbump.helpers.FxGroup;
	import com.makr.jumpnbump.helpers.ObjectPool;
	import com.makr.jumpnbump.objects.BloodLayer;
	
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

		public static var opRabbits:ObjectPool;
		private static const _RABBITS_POOLSIZE:uint = 20;

		// gibs (number of gibs is NUM_GIBS ± random() * NUM_GIBS_VARIATION
		public static var opGibs:ObjectPool;
		private static const _NUM_GIBS:uint = 13;
		private static const _NUM_GIBS_VARIATION:uint = 3;
		private static const _GIBS_POOLSIZE:uint = (_NUM_GIBS + _NUM_GIBS_VARIATION) * 4;
		public static var blood:BloodLayer;
		
		private var _spawnTimer:Number = 0;
		
		public override function create():void
		{
//			FlxG.timeScale = 0.1;

			// Display Statistics
//			addChild( new Stats() );
			
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

			blood = new BloodLayer();

			/// initializing object pools
			opRabbits = new ObjectPool(RabbitDummy, _RABBITS_POOLSIZE);
			opGibs = new ObjectPool(Gib, _GIBS_POOLSIZE);

			// adds all the groups to this state (they are rendered in this order)
			this.add(blood);
			this.add(opGibs);
			this.add(opRabbits);

			// finally, fade in
			FlxG.flash.start(0xff000000, 0.4);
		}
		
		// creates a shower of blood and gore
		private function gibRabbit(Gibbee:RabbitDummy):void
		{
//			var totalTime:Number = getTimer();
			var gibKind:String;
			var gibIndex:uint;
			
			var currentObject:Gib;
			for (var re:int = 0; re < Math.floor((Math.random() * _NUM_GIBS_VARIATION * 2) + (_NUM_GIBS - _NUM_GIBS_VARIATION)); re++) 
			{
				if (Math.random() < 0.33)
					gibKind = "Fur";
				else
					gibKind = "Flesh";
				
				currentObject = opGibs.getFirstAvail() as Gib;
				currentObject.activate(
					Gibbee.rabbitIndex, 
					gibKind, Gibbee.x + Gibbee.width * 0.5, Gibbee.y + Gibbee.height * 0.5,
					true, Gibbee.velocity.x, Gibbee.velocity.y, false
				);
			}
//			trace("Total Time: " + (getTimer() - totalTime) + "ms");
		}
		
		private function spawnRabbit():void
		{
			var currentObject:RabbitDummy;
			currentObject = opRabbits.getFirstAvail() as RabbitDummy;
			currentObject.activate(
				Math.floor(Math.random() * 4), 
				150 + Math.random() * 100, 265, 
//				Math.pow(Math.random(), 2) * Math.floor(Math.random() * 3 - 1) * 96, -265 + (Math.random() * 80)
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
					gibRabbit(currentRabbit);
					currentRabbit.kill();
				}
			}

			super.update();
		}	

		public override function render():void
		{
			trace("BEGIN render")
			var totalTime:Number = getTimer();
				var bloodTime:Number = getTimer();
					blood.render();
				bloodTime = getTimer() - bloodTime;
				var gibTime:Number = getTimer();
					opGibs.render();
				gibTime = getTimer() - gibTime;
				var rabbitTime:Number = getTimer();
					opRabbits.render();
				rabbitTime = getTimer() - rabbitTime;
			totalTime = getTimer() - totalTime;
			trace("TIMES: blood="+bloodTime+"ms; gibs="+gibTime+"ms; rabbit="+rabbitTime+"ms;; total: "+totalTime+"ms.");
			trace("END render");
		}

		// exits PlayState
        private function quit():void
        {
			FlxG.state = new PlayerSelectState();
        }
	
	}
}