package com.makr.jumpnbump.objects 
{
	import com.makr.jumpnbump.helpers.ObjectPool;
	import com.makr.jumpnbump.helpers.SpritePool;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import flash.utils.getTimer;
	
	public class Gore extends FlxObject
	{
		// witch level		
		[Embed(source = '../../../../../data/levels/witch/gore.png')] private var _imgGibWitch:Class;

		// original level		
		[Embed(source = '../../../../../data/levels/original/gore.png')] private var _imgGibOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/blood.png')] private var _imgBloodOriginal:Class;
		
		private var _imgBlood:Class;
		private var _blood:SpritePool;
		private const _BLOOD_DELAY:Number = 0.04;
		private const _BLOOD_FRAMERATE:uint = 5;
		private const _BLOOD_MIN_V:Number = 0.2;
		private const _BLOOD_MAX_V:Number = 0.6;

		private var _imgGib:Class;
		private var _gibGraphics:BitmapData;
		public var gibs:ObjectPool;
		private var _staticGibLayer:BitmapData;	// the image onto which static gibs are rendered before they are reused.
		private const _NUM_GIBS:uint = 13;
		private const _NUM_GIBS_VARIATION:uint = 3;
		private const _GIBS_POOLSIZE:uint = (_NUM_GIBS + _NUM_GIBS_VARIATION) * 4;
				
		public function Gore() 
		{
			// defaults
			_imgGib = _imgGibOriginal;
			_imgBlood = _imgBloodOriginal;

			switch (FlxG.levels[1])
			{
				case "witch":
					_imgGib = _imgGibWitch;
					break;
			}
			
			_blood = new SpritePool(_imgBlood, _BLOOD_FRAMERATE);
			gibs = new ObjectPool(Gib, _GIBS_POOLSIZE);
			
			// creating the layer for static gibs
			_gibGraphics = generateRotatedGibs();
			_staticGibLayer = new BitmapData(FlxG.width, FlxG.height, true, 0);
		}

		public override function update():void
		{
			_blood.update();

			var currentGib:Gib, vMulti:Number, numNewParticles:uint;
			var currentPosition:Point = new Point(), velocity:Point = new Point();
			var staticGibsDrawn:Boolean = false;
			
			for (var gibIndex:int = 0; gibIndex < gibs.firstAvailIndex; gibIndex++) 
			{
				currentGib = Gib(gibs.members[gibIndex]);

				// render static gibs onto the background
				if (currentGib.exists == true && currentGib.active == false && currentGib.visible == true)
				{
					// if this is the first time this cycle that static gibs are drawn, fade the layer slightly
					if (staticGibsDrawn == false)
						_staticGibLayer.colorTransform(FlxG.buffer.rect, new ColorTransform(1, 1, 1, 0.99));
						
					currentGib.drawGib(_staticGibLayer);
					currentGib.kill();
					staticGibsDrawn = true;
				}

				// blood
				if (currentGib.exists == true && currentGib.active == true)
				{
					currentGib.update();

					currentPosition.x = currentGib.x - currentGib.offset.x;
					currentPosition.y = currentGib.y - currentGib.offset.y;
					
					currentGib.bloodTimer += FlxG.elapsed;
					
					numNewParticles = 0;
					
					while (currentGib.bloodTimer > _BLOOD_DELAY)
					{
						currentGib.bloodTimer -= _BLOOD_DELAY;
						numNewParticles++;
					}
					
					vMulti = _BLOOD_MIN_V + Math.random() * (_BLOOD_MAX_V - _BLOOD_MIN_V);
					velocity.x = currentGib.velocity.x * vMulti;
					velocity.y = currentGib.velocity.y * vMulti;
				
					if (numNewParticles > 0)
					{
						currentGib.previousBloodTime = _blood.addMultiple(numNewParticles, currentGib.previousBloodPosition, currentPosition, velocity, currentGib.previousBloodTime);
						currentGib.previousBloodPosition = currentPosition;
					}
				}
			}
		}

		public override function render():void
		{
			_blood.render();

			FlxG.buffer.copyPixels(_staticGibLayer, _staticGibLayer.rect, new Point(), null, null, true);
			gibs.render();
		}
		
		// creates a shower of blood and gore
		public function createGibs(RabbitIndex:uint, PosX:Number, PosY:Number, VelX:Number, VelY:Number, Bleeding:Boolean = true, CollideWithBorders:Boolean = true):void
		{
			var gibFrame:uint;
			
			var currentObject:Gib;
			for (var re:int = 0; re < Math.floor((Math.random() * _NUM_GIBS_VARIATION * 2) + (_NUM_GIBS - _NUM_GIBS_VARIATION)); re++) 
			{
				// 	rI 0 => frames 0-7
				// 	rI 1 => frames 8-15
				// 	rI 2 => frames 16-23
				// 	rI 3 => frames 24-31
				// flesh => frame 32

				if (Math.random() < 0.33)
					gibFrame = RabbitIndex * 8 + Math.floor(Math.random() * 8);
				else
					gibFrame = 32;
				
				currentObject = Gib(gibs.getFirstAvail());
				currentObject.activate(_gibGraphics, gibFrame, PosX, PosY, Bleeding, VelX, VelY, CollideWithBorders);
				
				currentObject.bloodTimer = _BLOOD_DELAY;
				currentObject.previousBloodPosition = new Point(PosX, PosY);
				currentObject.previousBloodTime = _blood.timer;
				
			}
		}
		
		// Creates 36 rotated variations of every frame of the gib graphic (taken from FlxSprite and modified to suit my needs)
		private function generateRotatedGibs(Rotations:uint = 36):BitmapData
		{
			
			//Create the brush and canvas
			var brush:FlxSprite = new FlxSprite().loadGraphic(_imgGib, true);
			brush.antialiasing = true;
			
			var frames:uint = brush.pixels.width / brush.pixels.height;

			var size:uint = 8;
			
			var rotationIncrement:Number = 360/Rotations;

			var canvas:FlxSprite = new FlxSprite().createGraphic(frames * size, Rotations * size, 0, true);
			
			//Generate a new sheet if necessary, then fix up the width & height

			var center:uint = size/2;
			for(var row:int = 0; row < frames; row++)
			{
				brush.frame = row;
				for(var column:int = 0; column < Rotations; column++)
				{
					canvas.draw(brush, center + size*row - brush.frameWidth/2, center + size*column - brush.frameHeight/2);
					brush.angle += rotationIncrement;
				}
			}

			return canvas.pixels;
		}
	}
}
