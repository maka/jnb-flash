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
		
		private var _gravity:Number = 200;
		private var _numBloodSprites:uint = 6;
		private var _blood:FlxEmitter;
		private var _force:Number = 200;
		private var _static:Boolean = false;
		
		public function Gib(PlayerID:uint, Kind:String, X:Number, Y:Number, Static:Boolean=false, Xvel:Number = 0, Yvel:Number = 0 ):void
		{
			_static = Static;
			
			super(X, Y);
			loadGraphic(ImgGib, true, true, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 3;
            height = 3;
			
			drag.x = 25;
			
			acceleration.y = _gravity;
			
			if (Xvel == 0 && Yvel == 0)
			{
				velocity.x = Math.random() * _force - _force * 0.5;
				velocity.y = Math.random() * _force - _force * 0.5;
			}
			else
			{
				velocity.x = Xvel;
				velocity.y = Yvel;
			}
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis

			// set up the blood emitter
			
			_blood = FlxG.state.add(new FlxEmitter (X, Y)) as FlxEmitter;
			_blood.createSprites(ImgBlood, _numBloodSprites, true, PlayState.lyrBGSprites);
			_blood.gravity = _gravity * 0.2;
			_blood.setRotation();

			
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
					animationName = "Fur" + Math.floor(Math.random()*8).toString();
					break;
					
				case "Flesh":
					animationName = "Flesh";
					break;
			}
			
			play(animationName);
			
			trace("com.makr.jumpnbump.objects.Gib");
			trace("	Initialized");
		}
		
		public function makeStatic():void
		{
			_static = true;
			velocity.x = 0;
			velocity.y = 0;
			acceleration.x = 0;
			acceleration.y = 0;
			_blood.kill();
		}
		
		override public function update():void
		{
			if (_static)
				return;
				
			_blood.x = x + 2;
			_blood.y = y + 2;
			
			_blood.setXVelocity(velocity.x * 0.2, velocity.x*0.6);
			_blood.setYVelocity(velocity.y * 0.2, velocity.y*0.6);
			


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
				if (Math.random() * 100 < 7)	// 7 percent chance of becoming static
				{
					makeStatic();
				}
				else
					kill();
			}

			
			
			
			
			super.update();
		}
		
		override public function kill():void
		{
			_blood.kill();
			super.kill();
		}
	}
}