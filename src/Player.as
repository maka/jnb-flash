package  
{
	import org.flixel.*;	
	
	
	public class Player	extends FlxSprite
	{
		
		[Embed(source='../data/levels/test/rabbit.png')] private var ImgPlayer:Class;
		
		private var _move_speed:int = 600;
		
		private var _jump_power:int = 210;   
		private var _max_health:int=1;
		private var _jumping:Boolean=false;
		
		public function Player(X:Number,Y:Number):void
		{
			super(X, Y);
			loadGraphic(ImgPlayer, true, true, 19, 19); 
			
		    //Max speeds
            maxVelocity.x = 120;
            maxVelocity.y = 300;
            //Set the player health
            health = 1;
            //Gravity
            acceleration.y = 420;            
            //Friction
            drag.x = 300;
            //bounding box tweaks
            width = 13;
            height = 15;
            offset.x = 4;
            offset.y = 2;
			
			addAnimation("idle", [0]);
			addAnimation("normal", [0, 1, 2, 3], 10);
			addAnimation("jump", [4]);
			addAnimation("apex", [5]);
			addAnimation("fall", [6, 7], 10);
			addAnimation("dead", [8, 8, 8], 5);
			
			facing = RIGHT;
		}
		
		override public function update():void
		{
			if(dead)
            {
                if(finished) exists = false;
                else
                    super.update();
                return;
            }
			
			if(FlxG.keys.LEFT)
            {
                facing = LEFT;
                velocity.x -= _move_speed * FlxG.elapsed;
            }
            else if (FlxG.keys.RIGHT)
            {
                facing = RIGHT;
                velocity.x += _move_speed * FlxG.elapsed;                
            }
						
            if (FlxG.keys.justPressed("UP") && velocity.y == 0)
            {
                velocity.y = -_jump_power;
				_jumping = true;
            }
			if (FlxG.keys.justReleased("UP") && _jumping == true)
			{
				velocity.y = 0;
				_jumping = false;
			}
			
			
			if (velocity.y > 40)
			{
				play("fall");
			}
			if (_jumping == true)
			{
				if (velocity.y < 40)
				{
					play("jump");
				}
				if ((velocity.y < 0 ? -velocity.y : velocity.y) < 40)
				{
					play("apex");
				}
				if (velocity.y > 40)
				{
					_jumping = false;
				}

			}
			if (velocity.y == 0 && velocity.x == 0)
			{
				play("idle");
			}
			if (velocity.y == 0	&& velocity.x != 0)
			{
				play("normal");
			}
			
			
			
			super.update();
		}
	}

}