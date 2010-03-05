package com.makr.jumpnbump.helpers
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

	public class SpritePool extends FlxObject
	{
		private var splashEffect:Boolean;
		
		private var _spriteBitmap:BitmapData;
		private var _spriteLayer:BitmapData;
		
		public var members:Vector.<Member>;
		public var memberCount:uint;
		public var membersCleaned:Vector.<Member>;

		private var _frames:uint;
		private var _frameHeight:uint;
		private var _frameWidth:uint;
		private var _framerate:uint;
		
		private var _lifetime:Number;
		
		public var timer:Number;
		
		public var colorTimer:Number;
		
		public function SpritePool(ImgSprite:Class, Framerate:uint, FrameWidth:uint = 0, Lifetime:Number = 0):void
		{
			splashEffect = false;
			
			_spriteBitmap = FlxG.addBitmap(ImgSprite);

			_lifetime = Lifetime;
			_framerate = Framerate;
			
			if (splashEffect)
				_spriteBitmap = desaturate(_spriteBitmap);
				
			_frameHeight = _spriteBitmap.height;
			if (FrameWidth != 0)
				_frameWidth = FrameWidth;
			else
				_frameWidth = _frameHeight; 	// assuming square sprites if no width is given

			_frames = _spriteBitmap.width / _frameWidth;
			
			members = new Vector.<Member>();
			memberCount = 0;			
			membersCleaned = new Vector.<Member>();
			
			timer = colorTimer = 0;
			
			super(0, 0);
			
			_spriteLayer = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			_spriteLayer.fillRect(new Rectangle(10, 10, 5, 5), 0xffffffff);
		}
		
		private function ColorTransformHSV(H:Number, S:Number = 1.0, V:Number = 1.0):ColorTransform
		{
			H *= 6;
			var C:Number = V * S;
			var X:Number = C * (1 - Math.abs(H % 2 - 1));
			
			var m:Number = V - C;

			if (0 <= H && H < 1)
				return new ColorTransform(C + m, X + m, m);
			else if (1 <= H && H < 2)
				return new ColorTransform(X + m, C + m, m);
			else if (2 <= H && H < 3)
				return new ColorTransform(m, C + m, X + m);
			else if (3 <= H && H < 4)
				return new ColorTransform(m, X + m, C + m);
			else if (4 <= H && H < 5)
				return new ColorTransform(X + m, m, C + m);
			else if (5 <= H && H < 6)
				return new ColorTransform(C + m, m, X + m);	
			else 
				return new ColorTransform(0, 0, 0);
		}
		
		private function desaturate(Bitmap:BitmapData):BitmapData
		{
			Bitmap.applyFilter(
				Bitmap,
				Bitmap.rect, 
				new Point(),
				new ColorMatrixFilter([1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0])
			);
			
			return Bitmap;
		}
		
		public function addMultiple(Num:uint, PreviousPosition:Point, CurrentPosition:Point, Velocity:Point, PreviousTimestamp:Number = -1):Number
		{
			if (Num == 1)
				return add(CurrentPosition, Velocity);
			
			var timeDelta:Number = 0;
			
			if (PreviousTimestamp > 0)
			 timeDelta = (PreviousTimestamp - timer) / Num;
			
			var interpolatedPosition:Point = new Point();
			for (var sectionNumber:uint = 0; sectionNumber < Num; sectionNumber++) 
			{
				interpolatedPosition.x = CurrentPosition.x + (PreviousPosition.x - CurrentPosition.x) * sectionNumber / Num;
				interpolatedPosition.y = CurrentPosition.y + (PreviousPosition.y - CurrentPosition.y) * sectionNumber / Num;
				add(interpolatedPosition, Velocity, timer + timeDelta * sectionNumber);
			}

			return timer;
		}

		public function add(Position:Point, Velocity:Point, Timestamp:Number = -1):Number
		{
			
			if (Timestamp < 0)
				Timestamp = timer;
			
			members[memberCount] = new Member(Position, Velocity, Timestamp);
			
			check(members[memberCount++]);
			
			/* member[0] = Point(x,y)
			 * member[1] = Point(xVel,yVel)
			 * member[2] = creation timestamp
			 * member[3] = is particle active? (boolean)
			 */
			
			 return timer;
		}

		private function check(member:Member, killAtScreenEdges:Boolean = true):Boolean
		{
			// don't check inactive members
			if (!member.active)
				return false;
			
			if (_lifetime == 0 && timer - member.created > _frames / _framerate)	// animation is finished
				member.active = false;
			else if (_lifetime != 0 && timer - member.created > _lifetime)	// lifetime has expired
				member.active = false;
			else if (killAtScreenEdges && member.x < -_frameWidth && member.xVel <= 0)	// off the left side of the screen and not coming back
				member.active = false;								
			else if (killAtScreenEdges && member.x > FlxG.width && member.xVel >= 0)	// same on the right side
				member.active = false;								
			else if (killAtScreenEdges && member.y < -_frameHeight && member.yVel <= 0) // same on the top
				member.active = false;							
			else if (killAtScreenEdges && member.y > FlxG.height && member.yVel >= 0) // same on the bottom
				member.active = false;							
			else
				member.active = true;
			
			return member.active;
		}

		override public function update():void
		{		
			timer += FlxG.elapsed;
			
			colorTimer += FlxG.elapsed * 0.05;	
			if (colorTimer > 1)
				colorTimer -= 1;

//			membersCleaned.slice(0, 1);
			memberCount = 0;
			
			for each (var member:Member in members) 
			{
				if (check(member))
				{
					member.x += member.xVel * FlxG.elapsed;
					member.y += member.yVel * FlxG.elapsed;
					
					members[memberCount++] = member;
				}
			}
			members.length = memberCount;
		}
		
		override public function render():void
		{
			var clip:Rectangle = new Rectangle(0, 0, _frameWidth, _frameHeight);

			// erase the previous image
			if (splashEffect)
				_spriteLayer.colorTransform(FlxG.buffer.rect, new ColorTransform(0.995, 0.995, 0.995, 0.998));
			else
				_spriteLayer.colorTransform(FlxG.buffer.rect, new ColorTransform(1.0, 1.0, 1.0, 0));


			var renderDest:Point = new Point();
			
			var member:Member;
			
			
			//for each (var member:Member in members)
			for (var i:int = 0; i < memberCount; i++) 
			{
				member = members[i];
				
				if (member.active)
				{
					clip.x = _frameWidth * int((timer - member.created) * _framerate);
					renderDest.x = member.x;
					renderDest.y = member.y;
					_spriteLayer.copyPixels(_spriteBitmap, clip, renderDest, null, null, true);
				}
			}
			
			// draw the sprite layer to the buffer
			if (splashEffect)
				FlxG.buffer.draw(_spriteLayer, null, ColorTransformHSV(colorTimer));
			else
				FlxG.buffer.copyPixels(_spriteLayer, FlxG.buffer.rect, new Point(), null, null, true);

		}
	}
}

import flash.geom.Point;
import org.flixel.FlxG;
class Member
{
	public var x:Number;
	public var y:Number;
	
	public var xVel:Number;
	public var yVel:Number;
	
	public var active:Boolean = true;
	public var created:Number;

	public function Member(Position:Point, Velocity:Point, Created:Number):void
	{
		x = Position.x;
		y = Position.y;
		xVel = Velocity.x;
		yVel = Velocity.y;
		created = Created;
	}
}