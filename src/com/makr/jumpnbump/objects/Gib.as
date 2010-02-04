package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Gib extends FlxSprite
	{
		
		// original level
		[Embed(source = '../../../../../data/levels/original/gore.png')] private var ImgGib:Class;
		[Embed(source = '../../../../../data/levels/original/blood.png')] private var ImgBlood:Class;
		
		private var _gravity:Number = 150;
		private var _numBloodSprites:uint = 6;
		private var _blood:FlxEmitter;
		private var _force:Number = 200;
		private var _static:Boolean = false;
		private var _bleeding:Boolean = true;
		private var _killTimer:Number = 0;
		
		public function Gib(PlayerID:uint, Kind:String, X:Number, Y:Number, Static:Boolean=false, Bleeding:Boolean=true, Xvel:Number = 0, Yvel:Number = 0 ):void
		{
			_static = Static;
			_bleeding = Bleeding;
			super(X, Y);
			loadGraphic(ImgGib, true, true, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 3;
            height = 3;
			
			drag.x = 25;
			
            maxVelocity.x = 100;
            maxVelocity.y = 200;

			acceleration.y = _gravity;
			
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
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis

			// set up the blood emitter
			
			if (_bleeding)
			{
				_blood = FlxG.state.add(new FlxEmitter (X, Y, 0.05)) as FlxEmitter;
				_blood.createSprites(ImgBlood, _numBloodSprites, true, PlayState.lyrBGSprites);
				_blood.gravity = 0;
				_blood.setRotation( -30, 30);
			}

			
			// set sprites
			var sO:uint = PlayerID * 8;
			addAnimation("Fur0", [0+sO]);
			addAnimation("Fur1", [1+sO]);
			addAnimation("Fur2", [2+sO]);
			addAnimation("Fur3", [3+sO]);
			addAnimation("Fur4", [4+sO]);
			addAnimation("Fur5", [5+sO]);
			addAnimation("Fur6", [6+sO]);
			addAnimation("Fur7", [7+sO]);
			addAnimation("Flesh", [32]);
			
						
			
			var animationName:String;
			switch (Kind) 
			{
				case "Fur":
					animationName = "Fur" + int(Math.random()*8).toString();
					break;
					
				case "Flesh":
					animationName = "Flesh";
					break;
			}
			
			play(animationName);
			
			trace("Gib:	Initialized");
		}
		
		public function makeStatic():void
		{
			_static = true;
			velocity.x = 0;
			velocity.y = 0;
			acceleration.x = 0;
			acceleration.y = 0;
			if (_bleeding)
				_blood.kill();
		}
		
		override public function update():void
		{
			if (_static)
				return;
				
			angularVelocity = velocity.x * 22.9183118;	// value is degrees per pixel of circumference of an object with 5 pixels diameter
			
			// Velocity.x in pixels/sec * 360 degrees / (5 pixels diameter * PI) == Velocity.x in pixels/sec * 22.9183118 degrees/pixel

			if (_bleeding)
			{
				_blood.x = x + 2;
				_blood.y = y + 2;
				
				_blood.setXVelocity(velocity.x * 0.2, velocity.x*0.6);
				_blood.setYVelocity(velocity.y * 0.2, velocity.y*0.6);
			}
			
			if (x < 0 || x > 352)
			{
				velocity.x *= -.3;
			}
			
			if (y > 250)
			{
				velocity.y = 0;
				acceleration.y = 0;
			}

			if (velocity.x == 0 && velocity.y  == 0)
			{
				_killTimer += FlxG.elapsed;
			}
			
			if (_killTimer > 1 )
			{
				
				if (Math.random() * 100 < 7)	// 7 percent chance of becoming static
				{
					makeStatic();
					trace("Gib:	Made Static");
				}
				else
				{
					kill();
					trace("Gib:	Killed");
				}
			}

			
			
			
			
			super.update();
		
		}
		
		override public function hitWall(Contact:FlxCore = null):Boolean
		{
			velocity.x *= -Math.random();
			
			return true;
		}

		override public function hitFloor(Contact:FlxCore = null):Boolean
		{
			if (velocity.y > 10)
				velocity.y *= -0.25;
			else
				velocity.y = 0;
			
			return true;
		}

		override public function kill():void
		{
			if (_bleeding)
				_blood.kill();
			super.kill();
		}
	}
}