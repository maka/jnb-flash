package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Fly extends FlxSprite
	{
		
		private function getDistance(a:Point, b:Point):Number
		{
			var deltaX:Number = b.x-a.x;  
			var deltaY:Number = b.y-a.y;  
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY); 
		}

		public function Fly(X:Number, Y:Number):void
		{
			super(X, Y);

			var brightness:uint = uint(Math.random() * 0x40);
			var color:uint = 0xff000000 + brightness * 0x00010000 + brightness * 0x00000100 + brightness;
			createGraphic(1, 1, color);
			
            // set bounding box
            width = 1;
            height = 1;
			
            maxVelocity.x = 50;
            maxVelocity.y = 50;
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis
		}
		
		public function move(SwarmCenter:Point, ClosestPlayer:Point, ClosestPlayerDistance:Number):void
		{
			var thisPosition:Point = new Point(x, y);
			
			// X AXIS
			var direction:Point = new Point (0, 0);
			
			var cohesion:Point = new Point(0, 0);
			if (getDistance(SwarmCenter, thisPosition) > 30 && ClosestPlayerDistance > 30)
			{
				cohesion = SwarmCenter.subtract(thisPosition);
			}
			direction = direction.add(cohesion);
			
			var avoidance:Point = new Point(0, 0);
			if (ClosestPlayerDistance < 30)
			{
				var avoidanceDirection:Point = thisPosition.subtract(ClosestPlayer);
				avoidanceDirection.normalize(1);
				
				var avoidanceVelocity:Number = (30 - ClosestPlayerDistance) * 4;

				avoidance.x = avoidanceDirection.x * avoidanceVelocity;
				avoidance.y = avoidanceDirection.y * avoidanceVelocity;
			}
		
			direction = direction.add(avoidance);
			
			var randomness:Point = new Point(0, 0);
			randomness.x += (int(Math.random() * 3) - 1) * 30
			randomness.y += (int(Math.random() * 3) - 1) * 30
			direction = direction.add(randomness);
			
//			direction.x *= 50;
//			direction.y *= 50;
			
			if (thisPosition.x + direction.x < 16)
				direction.x = 0;
			if (thisPosition.x + direction.x> 351)
				direction.x = 0;
			if (thisPosition.y + direction.y < 0)
				direction.y = 0;
			if (thisPosition.y +direction.y > 239)
				direction.y = 0;

			velocity = velocity.add(direction);
		}

		override public function update():void
		{
			super.update();
		}
	}
}