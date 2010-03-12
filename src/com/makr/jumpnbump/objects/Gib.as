package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.helpers.SpritePool;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;

	public class Gib extends FlxSprite
	{
		private var _gibGraphic:BitmapData;

		private var _collideWithBorders:Boolean = true;
	
//		private const _STATIC_PERCENTAGE:uint = 8;
		private const _STATIC_PERCENTAGE:uint = 100;
		private const _GRAVITY:Number = 150;
		private var _RANDOM_VELOCITY:Number = 75;
		
		private var _killTimer:Number = 0;
		private const _KILL_TIMEOUT:Number = 1.5;
		
		private var _isUnderwater:Boolean = false;

		// information for blood trails
		public var previousBloodPosition:Point = new Point();
		public var previousBloodTime:Number = 0;
		public var bloodTimer:Number = 0;

		private var _rotationFrame:uint = 0;
		private var _rotationAngle:Number = 0;
		private var _frameRect:Rectangle = new Rectangle(0, 0, 8, 8);
		private var _renderDest:Point = new Point(0, 0);
		
		public function Gib():void
		{
			_gibGraphic = null;
			super(0, 0);
			
			createGraphic(8, 8);
			
            // set bounding box
            width = 3;
            height = 3;
			
			drag.x = 15;
			
            maxVelocity.x = 150;
            maxVelocity.y = 200;
			
			
			offset.x = offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis

//			offset.x = 2+3-Math.floor(Math.random()*2);  //Where in the sprite the bounding box starts on the X axis
//            offset.y = 2+3-Math.floor(Math.random()*2);  //Where in the sprite the bounding box starts on the Y axis

			// set up the blood emitter
			
			exists = false;
			active = false;
			visible = false;
		}
		
	   public function activate(Graphic:BitmapData, Frame:uint, X:Number, Y:Number, Bleeding:Boolean = true, Xvel:Number = 0, Yvel:Number = 0, CollideWithBorders:Boolean = true):void
		{
			_killTimer = 0;

			exists = true
			active = true;
			visible = true;
			
//			color = Math.floor(Math.random() * 0xffffff);	// fasching mode
			color = 0xffffff - Math.floor(Math.random() * 0x66) * 0x010101;
			
			velocity.x = (Math.random() * 2 - 1 ) * _RANDOM_VELOCITY + Xvel;
			velocity.y = (Math.random() * 2 - 1 ) * _RANDOM_VELOCITY + Yvel;
			
			var maximumLength:Number = _RANDOM_VELOCITY * (99 / 70);	// 99/70 is an approximation of sqrt(2)
			if (Xvel != 0 || Yvel != 0)
				maximumLength += Math.sqrt(Xvel * Xvel + Yvel * Yvel)
				
			x = X + Xvel * FlxG.elapsed;
			y = Y + Yvel * FlxG.elapsed;// + velocity.y / maximumLength * 2;
			
			acceleration.y = _GRAVITY;

			

			_gibGraphic = Graphic;
			frame = Frame;

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
			
			// ^- Velocity.x in pixels/sec * 360 degrees / (5 pixels diameter * PI) == Velocity.x in pixels/sec * 22.9183118 degrees/pixel

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
			
			if (_killTimer > _KILL_TIMEOUT )
			{
				
				if (Math.random() * 100 < _STATIC_PERCENTAGE)
					makeStatic();
				else
					kill();
			}
			
			if (x < -width && velocity.x < 0)	// kill gib if it is off the left side of the screen and not coming back
				kill();
			else if (x > FlxG.width && velocity.x > 0)	// same thing right
				kill();
			else if (y > FlxG.height && velocity.y > 0)	// same thing below
				kill();

			super.update();
		}
		
		public function drawGib(Surface:BitmapData, MergeAlpha:Boolean = true):void
		{
			// calculate baked rotation frame from angle
			_rotationAngle = angle % 360;
			if (_rotationAngle < 0)
				_rotationAngle += 360;
			_rotationFrame = Math.floor((_rotationAngle * _gibGraphic.height) / (360 * 8));
			
			// location of frame on the spritesheet
			_frameRect.x = frame * 8;
			_frameRect.y = _rotationFrame * 8;
			
			// location of object to be rendered
			_renderDest.x = x - offset.x - 1.5;
			_renderDest.y = y - offset.y - 1.5;

			// render!
			Surface.copyPixels(_gibGraphic, _frameRect, _renderDest, null, null, MergeAlpha);
		}
		
		public override function render():void
		{
			if (_gibGraphic == null)
				return;

			drawGib(FlxG.buffer);
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