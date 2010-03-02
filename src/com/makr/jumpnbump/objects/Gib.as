package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import com.makr.jumpnbump.FireworksState;
	import flash.geom.Point;
	import org.flixel.*;

	public class Gib extends FlxSprite
	{
		// witch level		
		[Embed(source = '../../../../../data/levels/witch/gore.png')] private var _imgGibWitch:Class;

		// original level		
		[Embed(source = '../../../../../data/levels/original/gore.png')] private var _imgGibOriginal:Class;

		private var _imgGib:Class;

		private var _collideWithBorders:Boolean = true;
	
//		private static const _STATIC_PERCENTAGE:uint = 8;
		private static const _STATIC_PERCENTAGE:uint = 100;
		private var _gravity:Number = 150;
		private var _force:Number = 75;
		
		private var _bleeding:Boolean = true;
		private var _previousBloodPosition:Point = new Point(-1, -1);
		private var _previousBloodTime:int = -1;
		private const _BLOOD_DELAY:Number = 0.05;
		private var _bloodTimer:Number = _BLOOD_DELAY;
		
		private var _killTimer:Number = 0;
		private const _KILL_TIMEOUT:Number = 1.5;
		
		private var _isUnderwater:Boolean = false;
		
		public function Gib():void
		{
			// defaults
			_imgGib = _imgGibOriginal;

			
			switch (FlxG.levels[1])
			{
				case "witch":
					_imgGib = _imgGibWitch;
					break;
			}
			
			super(0, 0);
//			loadGraphic(_imgGib, true, false, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 3;
            height = 3;
			
			drag.x = 15;
			
            maxVelocity.x = 150;
            maxVelocity.y = 200;
			
			
			offset.x = 1-Math.floor(Math.random()*3);  //Where in the sprite the bounding box starts on the X axis
            offset.y = 1-Math.floor(Math.random()*3);  //Where in the sprite the bounding box starts on the Y axis

			// set up the blood emitter
			
			exists = false;
			active = false;
			visible = false;
		}
		
	   public function activate(RabbitIndex:uint, Kind:String, X:Number, Y:Number, Bleeding:Boolean = true, Xvel:Number = 0, Yvel:Number = 0, CollideWithBorders:Boolean = true):void
		{
			_killTimer = 0;

			exists = true
			active = true;
			visible = true;
			
//			color = Math.floor(Math.random() * 0xffffff);	// fasching mode
			color = 0xffffff - Math.floor(Math.random() * 0x66) * 0x010101;

			_force = 75;
			
			velocity.x = (Math.random() * 2 - 1 ) * _force + Xvel;
			velocity.y = (Math.random() * 2 - 1 ) * _force + Yvel;
			
			var maximumLength:Number = _force * (99 / 70);	// 99/70 is an approximation of sqrt(2)
			if (Xvel != 0 || Yvel != 0)
				maximumLength += Math.sqrt(Xvel * Xvel + Yvel * Yvel)
				
			x = X + Xvel * FlxG.elapsed;
			y = Y + Yvel * FlxG.elapsed;// + velocity.y / maximumLength * 2;
			
			_bleeding = Bleeding;
			if (_bleeding)
			{
				_previousBloodPosition.x = x - offset.x + width;
				_previousBloodPosition.y = y - offset.x + height;
				_bloodTimer = _BLOOD_DELAY;
			}

			acceleration.y = _gravity;

			// 	rI 0 => frames 0-7
			// 	rI 1 => frames 8-15
			// 	rI 2 => frames 16-23
			// 	rI 3 => frames 24-31
			// flesh => frame 32
			
			var animationName:String;
			switch (Kind) 
			{
				case "Fur":
					frame = RabbitIndex * 8 + Math.floor(Math.random() * 8);
					break;
					
				case "Flesh":
					frame = 32;
					break;
			}

			loadRotatedGraphic(_imgGib, 12, frame);

			_collideWithBorders = CollideWithBorders;
		}
		
		public function get isUnderwater():Boolean { return _isUnderwater; }
		public function set isUnderwater(State:Boolean):void
		{
			if (_isUnderwater == State)	// return if value is already set
				return;
				
			_isUnderwater = State;		// set value
			
			if (State == true)	
			{
				maxVelocity.x = 30;
				maxVelocity.y = 40;
			}
			else
			{
				maxVelocity.x = 100;
				maxVelocity.y = 200;
			}
		}

		public function makeStatic():void
		{
			exists = true
			active = false;
			visible = true;
			velocity.x = 0;
			velocity.y = 0;
			acceleration.y = 0;
		}
		
		public override function update():void
		{
			angularVelocity = velocity.x * 22.9183118;	// degrees/sec
			
			//Velocity.x in pixels/sec * 360 degrees / (5 pixels diameter * PI) == Velocity.x in pixels/sec * 22.9183118 degrees/pixel

			if (_collideWithBorders)
			{
				if (x < 0 || x > 352)
					velocity.x *= -.3;
				
				if (y > 250)
				{
					velocity.y = 0;
					acceleration.y = 0;
				}
			}
				
			if (velocity.x == 0 && velocity.y  == 0)
				_killTimer += FlxG.elapsed;
			
/*		if (_killTimer > 0)
			{
				for each (var bloodParticle:FlxSprite in _blood.members) 
				{
					bloodParticle.alpha = 1 - _killTimer / _KILL_TIMEOUT;
					if (bloodParticle.alpha < 0)
						bloodParticle.alpha = 0;
				}
			}
*/
			if (_killTimer > _KILL_TIMEOUT )
			{
				
				if (Math.random() * 100 < _STATIC_PERCENTAGE)	// [_STATIC_PERCENTAGE]% chance of becoming static
					makeStatic();
				else
					kill();
			}
	
			if (y > 300)		// kill gib if it is well outside of the screen
				kill();

			super.update();
			
			if (_bleeding)
			{
				var currentPosition:Point = new Point(x - offset.x + 2.5, y - offset.x + 2.5);
				
				_bloodTimer += FlxG.elapsed;
				
				var numNewParticles:uint = 0;
				while (_bloodTimer > _BLOOD_DELAY)
				{
					_bloodTimer -= _BLOOD_DELAY;
					numNewParticles++;
				}

				var minVelocity:Point = new Point(velocity.x * .3, velocity.y * .3);
				var maxVelocity:Point = new Point(velocity.x * .7, velocity.y * .7);
				
				if (numNewParticles > 1)
				{
					if (FlxG.state.toString() == "[object FireworksState]")
						_previousBloodTime = FireworksState.blood.addMultiple(numNewParticles, _previousBloodPosition, currentPosition, minVelocity, maxVelocity, _previousBloodTime);

					if (FlxG.state.toString() == "[object PlayState]")
						_previousBloodTime = PlayState.blood.addMultiple(numNewParticles, _previousBloodPosition, currentPosition, minVelocity, maxVelocity, _previousBloodTime);

					_previousBloodPosition = currentPosition;

				}
				else if (numNewParticles > 0)
				{
					if (FlxG.state.toString() == "[object FireworksState]")
						_previousBloodTime = FireworksState.blood.add(currentPosition, minVelocity, maxVelocity);

					if (FlxG.state.toString() == "[object PlayState]")
						_previousBloodTime = PlayState.blood.add(currentPosition, minVelocity, maxVelocity);
	
					_previousBloodPosition = currentPosition;
				}
			}
			
		}
		
		public override function hitLeft(Contact:FlxObject,Velocity:Number):void
		{
			velocity.x *= -Math.random();
		}

		public override function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			if (velocity.y > 10)
				velocity.y *= -0.25;
			else
				velocity.y = 0;
		}

		public override function kill():void
		{
			exists = false;
			active = false;
			visible = false;
		}
	}
}