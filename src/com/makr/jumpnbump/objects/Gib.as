package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import flash.geom.Point;
	import org.flixel.*;	

	public class Gib extends FlxSprite
	{
		// witch level		
		[Embed(source = '../../../../../data/levels/witch/gore.png')] private var ImgGibWitch:Class;

		// original level		
		[Embed(source = '../../../../../data/levels/original/gore.png')] private var ImgGibOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/blood.png')] private var ImgBloodOriginal:Class;

		private var ImgGib:Class;
		private var ImgBlood:Class;

//		private static const _STATIC_PERCENTAGE:uint = 8;
		private static const _STATIC_PERCENTAGE:uint = 100;
		private var _gravity:Number = 150;
		private var _numBloodSprites:uint = 6;
		private var _blood:FlxEmitter;
		private var _force:Number = 200;
		private var _bleeding:Boolean = true;
		private var _killTimer:Number = 0;
		private const killTimeout:Number = 1.5;
		private var _isSwimming:Boolean = false;
		
		public function Gib():void
		{
			// defaults
			ImgGib = ImgGibOriginal;
			ImgBlood = ImgBloodOriginal;

			
			switch (FlxG.levels[1])
			{
				case "witch":
					ImgGib = ImgGibWitch;
					break;
			}
			
			super(0, 0);
			loadGraphic(ImgGib, true, false, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 3;
            height = 3;
			
			drag.x = 25;
			
            maxVelocity.x = 100;
            maxVelocity.y = 200;
			
			
			offset.x = 1-Math.floor(Math.random()*3);  //Where in the sprite the bounding box starts on the X axis
            offset.y = 1-Math.floor(Math.random()*3);  //Where in the sprite the bounding box starts on the Y axis

			// set up the blood emitter
			
			if (_bleeding)
			{
				_blood = PlayState.gParticles.add(new FlxEmitter (0, 0)) as FlxEmitter;
				_blood.createSprites(ImgBlood, _numBloodSprites, 16, true);
				_blood.gravity = 0;
//				_blood.setRotation( -30, 30);
				_blood.setRotation(0, 0);
				
			}
			
			exists = false;
			active = false;
			visible = false;
		}
		
		public function activate(rabbitIndex:uint, Kind:String, X:Number, Y:Number, Bleeding:Boolean=true, Xvel:Number = 0, Yvel:Number = 0):void
		{
			_killTimer = 0;
			x = X;
			y = Y;
			exists = true
			active = true;
			visible = true;
			
			color = 0xffffff - FlxU.floor(Math.random() * 0x66) * 0x010101;
//			color = FlxU.floor(Math.random() * 0xffffff);	// fasching mode
			
			_bleeding = Bleeding;
			if (_bleeding)
			{
				_blood.x = X+1;
				_blood.y = Y+1;
				_blood.start(false, 0.03, 0)
				for each (var bloodParticle:FlxSprite in _blood.members) 
				{
					bloodParticle.color = color;
					bloodParticle.alpha = 1;
				}

			}
			
			if (Xvel == 0 && Yvel == 0)
			{
				velocity.x = (Math.random() - 0.5 ) * _force;
				velocity.y = (Math.random() - 0.5 ) * _force;
			}
			else
			{
				velocity.x = Xvel;
				velocity.y = Yvel;
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
					frame = rabbitIndex * 8 + FlxU.floor(Math.random() * 8);
					break;
					
				case "Flesh":
					frame = 32;
					break;
			}
		}
		
		public function isSwimming():Boolean { return _isSwimming; }
		public function setSwimming(isSwimming:Boolean):void
		{
			if (_isSwimming == isSwimming)	// return if value is already set
				return;
				
			_isSwimming = isSwimming;		// set value
			
			if (isSwimming)	
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
			if (_bleeding)
				_blood.kill();
		}
		
		public override function update():void
		{
			angularVelocity = velocity.x * 22.9183118;	// degrees/sec
			
			//Velocity.x in pixels/sec * 360 degrees / (5 pixels diameter * PI) == Velocity.x in pixels/sec * 22.9183118 degrees/pixel

			if (_bleeding)
			{
				_blood.x = x + 1;
				_blood.y = y + 1;

				_blood.setXSpeed(velocity.x * 0.2, velocity.x*0.6);
				_blood.setYSpeed(velocity.y * 0.2, velocity.y*0.6);

			}
		
			
			if (x < 0 || x > 352)
				velocity.x *= -.3;
			
			if (y > 250)
			{
				velocity.y = 0;
				acceleration.y = 0;
			}

			if (velocity.x == 0 && velocity.y  == 0)
			{
				_killTimer += FlxG.elapsed;
			}
			
			if (_killTimer > 0)
			{
				for each (var bloodParticle:FlxSprite in _blood.members) 
				{
					bloodParticle.alpha = 1 - _killTimer / killTimeout;
					if (bloodParticle.alpha < 0)
						bloodParticle.alpha = 0;
				}
			}
			
			if (_killTimer > killTimeout )
			{
				
				if (Math.random() * 100 < _STATIC_PERCENTAGE)	// [_STATIC_PERCENTAGE]% chance of becoming static
				{
					makeStatic();
				}
				else
					kill();
			}
						
			super.update();
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
			if (_bleeding)
				_blood.kill();
			
			exists = false;
			active = false;
			visible = false;
		}
	}
}