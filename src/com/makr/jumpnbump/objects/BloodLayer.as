package com.makr.jumpnbump.objects
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import org.flixel.*;

	public class BloodLayer extends FlxObject
	{
		[Embed(source = '../../../../../data/levels/original/blood.png')] private var _imgBloodOriginal:Class;
		
		private var splashEffect:Boolean = true;
		
		private var _imgBlood:Class;
		private var _bloodParticleBitmap:BitmapData;
		
		private var _blood:BitmapData;
		
		private var _members:Array;

		private var _frames:uint;
		private var _frameHeight:uint;
		private var _frameWidth:uint;
		
		private const _FRAMERATE:uint = 6;
		
		private const _CLEANUP_DELAY:uint = 5;
		private var _lastCleanup:int;
		
		public var timer:Number = 0;
		
		public var colorTimer:Number = 0;
		
		public function BloodLayer():void
		{
			// default graphics
			_imgBlood = _imgBloodOriginal;

			_bloodParticleBitmap = FlxG.addBitmap(_imgBlood);

			if (splashEffect)
				_bloodParticleBitmap = desaturate(_bloodParticleBitmap);
				
			_frameHeight = _bloodParticleBitmap.height;
			_frameWidth = _frameHeight; 	// assuming square sprites
			_frames = _bloodParticleBitmap.width / _frameWidth;
			
			_members = new Array();
			
			_lastCleanup = timer;

			super(0, 0);
			
			_blood = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			_blood.fillRect(new Rectangle(10, 10, 5, 5), 0xffffffff);
		}
		
		private function ColorTransformHSV(H:Number, S:Number = 1.0, V:Number = 1.0):ColorTransform
		{
			var RGB:Array;
			var C:Number = V * S;
			var H:Number = H * 6;
			var X:Number = C * (1 - Math.abs(H % 2 - 1));
			
			if (H < 1)
				RGB = new Array(C, X, 0);
			if (1 <= H && H < 2)
				RGB = new Array(X, C, 0);
			if (2 <= H && H < 3)
				RGB = new Array(0, C, X);
			if (3 <= H && H < 4)
				RGB = new Array(0, X, C);
			if (4 <= H && H < 5)
				RGB = new Array(X, 0, C);
			if (5 <= H)
				RGB = new Array(C, 0, X);
			
			var m:Number = V - C;
			
			RGB[0] += m;
			RGB[1] += m;
			RGB[2] += m;
			
			return new ColorTransform(RGB[0], RGB[1], RGB[2]);
		}
		
		private function desaturate(Bitmap:BitmapData):BitmapData
		{
			const rc:Number = 1, gc:Number = 1, bc:Number = 1;
			
			Bitmap.applyFilter(
				Bitmap,
				Bitmap.rect, 
				new Point(), 
				new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0])
			);
			
			return Bitmap;
		}
		
		public function addMultiple(Num:uint, PreviousPosition:Point, CurrentPosition:Point, MinVelocity:Point, MaxVelocity:Point, PreviousTimestamp:int = -1):Number
		{
			var distanceDeltaX:Number = (PreviousPosition.x - CurrentPosition.x) / Num;
			var distanceDeltaY:Number = (PreviousPosition.y - CurrentPosition.y) / Num;
			
			var timeNow:int = timer;
			var timeDelta:Number = 0;
			
			if (PreviousTimestamp > 0)
			 timeDelta = (PreviousTimestamp - timeNow) / Num;
			
			for (var sectionNumber:uint = 0; sectionNumber < Num; sectionNumber++) 
			{
				add(
					new Point(
						CurrentPosition.x + distanceDeltaX * sectionNumber, 
						CurrentPosition.y + distanceDeltaY * sectionNumber
					),
					MinVelocity, MaxVelocity, timeNow + timeDelta * sectionNumber
				);
			}

			return timer;
		}

		public function add(Position:Point, MinVelocity:Point, MaxVelocity:Point, Timestamp:int = -1):Number
		{
			var Velocity:Point = new Point(
				Math.random() * (MaxVelocity.x - MinVelocity.x) + MinVelocity.x,
				Math.random() * (MaxVelocity.y - MinVelocity.y) + MinVelocity.y
			);
			
			if (Timestamp > 0)
				_members.push(new Array(Position, Velocity, Timestamp, true));
			else
				_members.push(new Array(Position, Velocity, timer, true));
			
			_members[_members.length -1][3] = check(_members[_members.length -1]);
			
			/* member[0] = Point(x,y)
			 * member[1] = Point(velocity.x,velocity.y)
			 * member[2] = creation timestamp
			 * member[3] = is particle active? (boolean)
			 */
			
			 // _numBloodSprites = 12 - int(Math.random() * 5)
			 
			 return timer;
		}

		private function check(member:Array):Boolean
		{
			
			if (timer - member[2] > _frames / _FRAMERATE)	// too old
				return false;
			else if ((member[0].x < -5 && member[1].x < 0) || (member[0].x > 405 && member[1].x > 0))
				return false;								// off the side of the screen and not coming back
			else if (member[0].y > 256)						// below floor
				return false;
			else
				return true;
		}
		
		override public function update():void
		{		
			timer += FlxG.elapsed;
			
			colorTimer += FlxG.elapsed * 0.05;	
			if (colorTimer > 1)
				colorTimer -= 1;

				
			var cleanup:Boolean = false;
			var cleanMembers:Array;
			if (timer - _lastCleanup > _CLEANUP_DELAY)
			{
				cleanup = true;
				cleanMembers = new Array()
				_lastCleanup = timer;
			}
			
			for each (var member:Array in _members) 
			{
				if (member[3])	// check again
					member[3] = check(member);
					
				if (member[3])
				{
					member[0].x += member[1].x * FlxG.elapsed;
					member[0].y += member[1].y * FlxG.elapsed;
					
					if (cleanup)
						cleanMembers.push(member);
				}
			}
			
			if (cleanup)
				_members = cleanMembers;
		}
		
		override public function render():void
		{
			var fullScreen:Rectangle = new Rectangle(0, 0, FlxG.width, FlxG.height);
			var sprite:Rectangle;
			// erase the previous image
			
			if (splashEffect)
				_blood.colorTransform(fullScreen, new ColorTransform(0.995, 0.995, 0.995, 0.999));
			else
				_blood.colorTransform(fullScreen, new ColorTransform(1.0, 1.0, 1.0, 0));

			for each (var member:Array in _members)
			{
				if (member[3])
				{
					sprite = new Rectangle(_frameWidth * int((timer - member[2]) * _FRAMERATE), 0, _frameHeight, _frameWidth);
					_blood.copyPixels(_bloodParticleBitmap, sprite, member[0], null, null, true);
				}
			}		
			if (splashEffect)
				FlxG.buffer.draw(_blood, null, ColorTransformHSV(colorTimer));
			else
				FlxG.buffer.copyPixels(_blood, fullScreen, new Point(0, 0), null, null, true);
		}
	}
}