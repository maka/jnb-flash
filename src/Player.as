package  
{
	import flash.geom.Point;
	import org.flixel.*;	
	
	
	public class Player	extends FlxSprite
	{
		
		[Embed(source='../data/levels/test/rabbit.png')] private var ImgPlayer:Class;
		
		private static const _DEFAULT_moveSpeed:int = 600;
		private static const _DEFAULT_DRAG_X:int = 400;

		private var _moveSpeed:int = _DEFAULT_moveSpeed;
		
		private var _jumpPower:int = 210;   // power of a normal jump (slightly more than 3 tiles)
		private var _springPower:int = 300;  // power of a spring jump (slightly more than 6 tiles)
		
		private var _max_health:int = 1;
		
		private var _isGrounded:Boolean = true;
		private var _isSliding:Boolean = false;
		private var _isRunning:Boolean = false;
		
		private var _apexThreshold:int = 35;	// the vertical velocity where the apex animation is played
		
		
		public function jump(spring:Boolean = false):void
		{
			if (!_isGrounded)	// return if already in the air
				return;
				
			if (!spring)		// normal jump
			    velocity.y = -_jumpPower;
			else				// spring jump
				velocity.y = -_springPower;
		}
		
		public function setGrounded(isGrounded:Boolean):void
		{
			if (_isGrounded == isGrounded)	// return if value is already set
				return;
				
			_isGrounded = isGrounded;		// set value
			
			if (!_isGrounded)				// no drag in the air!
				drag.x = 0;
			else if (!_isSliding)			// set default drag if we're on solid, non-icy ground
				drag.x = _DEFAULT_DRAG_X
		}
		
		public function setSliding(isSliding:Boolean):void
		{
			if (_isSliding == isSliding)	// return if value is already set
				return;
				
			_isSliding = isSliding;			// set value
			
			if (isSliding)					// if we're sliding, remove drag, set movement speed to 1/10th of normal
			{
				drag.x = 0
				_moveSpeed = _DEFAULT_moveSpeed / 10;
			}
			else if (_isGrounded)			// else, reset to normal if we're on solid ground
			{
				drag.x = _DEFAULT_DRAG_X;
				_moveSpeed = _DEFAULT_moveSpeed;
			}
		}
		
		public function isSliding():Boolean		
		{
			return _isSliding;				// returns sliding state
		}
		
		public function Player(X:Number,Y:Number):void
		{
			super(X, Y);
			loadGraphic(ImgPlayer, true, true, 19, 19); // load player sprite (is animated, is reversible, is 19x19)
			
		    //Max speeds
            maxVelocity.x = 120;
            maxVelocity.y = 300;
            //Set the player health
            health = 1;
            //Gravity
            acceleration.y = 420;            
            //Friction
            drag.x = _DEFAULT_DRAG_X;
            // set bounding box
            width = 13;
            height = 15;
            offset.x = 3;
            offset.y = 4;
			
			// set animations for everything the bunny can do
			addAnimation("idle", [0]);
			addAnimation("normal", [0, 1, 2, 3], 10);
			addAnimation("jump", [4]);
			addAnimation("apex", [5]);
			addAnimation("fall", [6, 7], 10);
			addAnimation("dead", [8, 8, 8], 5);
			
			// the sprites face right by default
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
			
			// handle input
			if (FlxG.keys.LEFT || FlxG.keys.RIGHT)
			{
				_isRunning = true;
				
				if(FlxG.keys.LEFT)
				{
					facing = LEFT;
					velocity.x -= _moveSpeed * FlxG.elapsed;
				}
				else if (FlxG.keys.RIGHT)
				{
					facing = RIGHT;
					velocity.x += _moveSpeed * FlxG.elapsed;                
				}
			}
			else
			{
				_isRunning = false
			}
            if (FlxG.keys.justPressed("UP") && velocity.y == 0)
            {
                jump();
            }
			

			// animate!
			if (_isGrounded == false) // in the air
			{
				if (velocity.y < _apexThreshold)
				{
					play("jump");
				}
				if ((velocity.y < 0 ? -velocity.y : velocity.y) < _apexThreshold)
				{
					play("apex");
				}
				if (velocity.y > _apexThreshold)
				{
					play("fall");
				}
			}
			else if (_isRunning == true) // on the ground, running
			{
				play("normal");
			}
			else						// on the ground, doing nothing
			{
				play("idle");
			}			
		
			super.update();
		}
	}

}