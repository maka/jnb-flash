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

			var red:uint = uint(Math.random() * 0x40);
			var green:uint = uint(Math.random() * 0x40);
			var blue:uint = uint(Math.random() * 0x40);
			var color:uint = 0xff000000 + red * 0x00010000 + green * 0x00000100 + blue;

			createGraphic(1, 1, color);
			
            // set bounding box
            width = 1;
            height = 1;
			
  			if (FlxG.levels[0] == "lotf")
			{
				maxVelocity.x = 100;
				maxVelocity.y = 100;
			}
			else
			{
				maxVelocity.x = 50;
				maxVelocity.y = 50;
			}
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis
		}
		
		public function move(SwarmCenter:Point, ClosestPlayerPosition:Point, ClosestPlayerDistance:Number):void
		{
			var thisPosition:Point = new Point(x, y);
			
			var direction:Point = new Point (0, 0);
			
			// cohesion
			var cohesion:Point = new Point(0, 0);
			if ((FlxG.levels[0] != "lotf" && getDistance(SwarmCenter, thisPosition) > 30) || 
				(FlxG.levels[0] == "lotf" && getDistance(SwarmCenter, thisPosition) > 18))
			{
				cohesion = SwarmCenter.subtract(thisPosition);
			}
			direction = direction.add(cohesion);
			
			// avoidance
			var avoidance:Point = new Point(0, 0);
			if ((FlxG.levels[0] != "lotf" && ClosestPlayerDistance < 30) || 
				(FlxG.levels[0] == "lotf" && ClosestPlayerDistance < 12))
			{
				var avoidanceDirection:Point = thisPosition.subtract(ClosestPlayerPosition);
				avoidanceDirection.normalize(1);
				
				var avoidanceVelocity:Number = (30 - ClosestPlayerDistance) * 4;

				avoidance.x = avoidanceDirection.x * avoidanceVelocity;
				avoidance.y = avoidanceDirection.y * avoidanceVelocity;
			}
		
			direction = direction.add(avoidance);
			
			// random factor
			var randomness:Point = new Point(0, 0);
			randomness.x += (int(Math.random() * 3) - 1) * 30
			randomness.y += (int(Math.random() * 3) - 1) * 30
			direction = direction.add(randomness);
			
			// boundary check
			if (thisPosition.x + direction.x < 0)
				direction.x = 0;
			if (thisPosition.x + direction.x > 352)
				direction.x = 0;
			if (thisPosition.y + direction.y < 0)
				direction.y = 0;
			if (thisPosition.y + direction.y > 256)
				direction.y = 0;

			// go go go
			velocity = velocity.add(direction);
		}

		override public function update():void
		{
			super.update();
		}
	}
}