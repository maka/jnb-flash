package com.makr.jumpnbump

{
	import com.makr.jumpnbump.objects.Splash;
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Player	extends FlxSprite
	{
		// original level
		[Embed(source = '../../../../data/levels/original/death.mp3')] private var SoundDeath:Class;
		[Embed(source = '../../../../data/levels/original/jump.mp3')] private var SoundJump:Class;
		[Embed(source = '../../../../data/levels/original/rabbit.png')] private var ImgPlayer:Class;
	
		// controls for all players
		private static const _KEY_LEFT:Array = ["LEFT", "A", "J", "NUMPAD_FOUR"];
		private static const _KEY_RIGHT:Array = ["RIGHT", "D", "L", "NUMPAD_SIX"];
		private static const _KEY_JUMP:Array = ["UP", "W", "I", "NUMPAD_EIGHT"];
		
		// current rabbit id [0-3]
		public var rabbitIndex:uint;

		
		private static const _DEFAULT_GRAVITY:int = 560;
		
		// different speeds for different tiles
		private static const _GROUND_SPEED:int = 750;
		private static const _WATER_SPEED:int = _GROUND_SPEED;
		private static const _AIR_SPEED:int = _GROUND_SPEED;
		private static const _ICE_SPEED:int = 50;
		
		// different friction as well
		private static const _GROUND_FRICTION:int = 500;
		private static const _WATER_FRICTION:int = 0;
		private static const _AIR_FRICTION:int = 0;
		private static const _ICE_FRICTION:int = 0;

		private var _moveSpeed:int = _GROUND_SPEED;
		
		private var _floatJumpPower:int = 170;   // power of a normal jump (slightly more than 3 tiles)
		private var _jumpPower:int = 240;   // power of a normal jump (slightly more than 3 tiles)
		private var _springPower:int = 340;  // power of a spring jump (slightly more than 6 tiles)
		private var _bouncePower:int = 150;   // power of the bounce off a killed bunny
		
		private var _max_health:int = 1;
		
		private var _isGrounded:Boolean = false;
		private var _isSliding:Boolean = false;
		private var _isRunning:Boolean = false;
		private var _isSwimming:Boolean = false;
		private var _isFloating:Boolean = false;		
		
		private var _disableControls:Boolean = false;
		private var _controlOverride:String = "";
		
		public function die():void
		{
			dead = true;
			velocity.x = 0;
			velocity.y = 0;
            acceleration.y = 0;
			FlxG.play(SoundDeath);				
		}
		
		public function jump(spring:Boolean = false, bounce:Boolean = false):void
		{
			trace("jump init");
			
			if (!_isGrounded && !_isFloating/* && !_isSwimming */)	// return if already in the air
				return;
				
			if (spring)				// spring jump (6 tiles)
			    velocity.y += -_springPower;
			else if (bounce)				// bounce
			    velocity.y += -_bouncePower;
			else if (_isFloating)	// jump out of water (1 tile)
			{
				velocity.y += -_floatJumpPower;
				setFloating(false);	// stop floating (restore gravity);
			}
	/*		else if (_isSwimming)	// jump out of water (1 tile)
			{
				velocity.y = -_floatJumpPower;
			} */
			else					// normal jump (3 tiles)
			{
				velocity.y += -_jumpPower;
			}
			
			if (!spring)				// spring jump (6 tiles)
				FlxG.play(SoundJump);				
		}
		
		public function setGrounded(isGrounded:Boolean):void
		{
			if (_isGrounded == isGrounded)	// return if value is already set
				return;
/*			if (_isSwimming && isGrounded)	// can't walk in water
			{
				trace ("touchdown");
				return;
			}					
*/			_isGrounded = isGrounded;		// set value
			
			if (!isGrounded)				// can only slide on the ground
				setSliding(false);				
		}
		
		public function isSwimming():Boolean { return _isSwimming; }
		public function setSwimming(isSwimming:Boolean):void
		{
			if (_isSwimming == isSwimming)	// return if value is already set
				return;
				
			_isSwimming = isSwimming;		// set value
			
			if (isSwimming)	
			{
				setGrounded(false);			// not on the ground anymore
			
				velocity.y *= 0.35;

				var topTileEdge:Number = y - (y % 16);
				PlayState.lyrBGSprites.add(new Splash(x, topTileEdge));
				
			

			}	
		}

		public function isFloating():Boolean { return _isFloating; }
		public function setFloating(isFloating:Boolean):void
		{
			if (_isFloating == isFloating)	// return if value is already set
				return;
				
			_isFloating = isFloating;		// set value
			
			if (_isFloating)				// set vertical velocity to 0
			{
				velocity.y = 0;
				setGrounded(false);
			}
		}

		public function isSliding():Boolean { return _isSliding; }
		public function setSliding(isSliding:Boolean):void
		{
			if (_isSliding == isSliding)	// return if value is already set
				return;
				
			_isSliding = isSliding;			// set value
		}

		public function setControls(enabled:Boolean):void
		{
			if (_disableControls == !enabled)	// return if value is already set
				return;
				
			_disableControls = !enabled;			// set value
		}

		public function setControlOverride(Override:String):void
		{
			if (Override == _controlOverride)	// return if value is already set
				return;
				
			_controlOverride = Override;			// set value
		}

		public function resetControlOverride():void
		{
			_controlOverride = "";	// reset value
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			if (Math.random() > 0.5)
				facing = LEFT;
			else
				facing = RIGHT;
				
			dead = false;
			exists = true;
			x = X;
			y = Y;
			acceleration.y = _DEFAULT_GRAVITY;
		}
		
		public function Player(newRabbitIndex:uint, X:Number, Y:Number):void
		{
			rabbitIndex = newRabbitIndex;
			
			super(X, Y);
			
			loadGraphic(ImgPlayer, true, true, 19, 19); // load player sprite (is animated, is reversible, is 19x19)
			
		    //Max speeds
            maxVelocity.x = 75;
            maxVelocity.y = 400;
            //Set the player health
            health = 1;
            //Gravity
            acceleration.y = _DEFAULT_GRAVITY;            
            //Friction
            drag.x = _GROUND_FRICTION;
            // set bounding box
            width = 15;
            height = 15;
            offset.x = 2;
            offset.y = 4;
			
			// set animationOffset to use the right graphics
			var aO:uint = rabbitIndex * 9;
			
			// set animations for everything the bunny can do
		
			addAnimation("idle", [0+aO]);
			addAnimation("normal", [0+aO, 1+aO, 2+aO, 3+aO], 15);
			addAnimation("up", [4+aO]);
			addAnimation("apex", [5+aO]);
			addAnimation("down", [6+aO]);
			addAnimation("downfast", [6+aO, 7+aO], 10);
			addAnimation("dead", [8+aO, 8+aO], 7);
			
			addAnimationCallback(animateCallback);
			
			// the sprites face right by default
			facing = RIGHT;
		}
		
		private function setMovementVariables():void
		{
			// Sets the movement variables (speed of movement, drag, vertical acceleration) according to the Player's state (_isGrounded, _isSwimming, etc.)
			
			// on solid ground (non ice)
			if (_isGrounded && !_isSliding)
			{
				_moveSpeed = _GROUND_SPEED;
				drag.x = _GROUND_FRICTION;
			}
				
			// on ice
			if (_isGrounded && _isSliding)
			{
				_moveSpeed = _ICE_SPEED;
				drag.x = _ICE_FRICTION;
			}
			
			// in the air
			if (!_isGrounded && !_isFloating && !_isSwimming)
			{
				_moveSpeed = _AIR_SPEED;
				drag.x = _AIR_FRICTION;
			}

			// swimming
			if (_isSwimming && !_isFloating)
			{
				_moveSpeed = _WATER_SPEED;
				drag.x = _WATER_FRICTION;
				acceleration.y = -60;
			}

			// floating
			if (!_isSwimming && _isFloating)
			{
				_moveSpeed = _WATER_SPEED;
				drag.x = _WATER_FRICTION;
				acceleration.y = 0;
			}

			// out of water
			if (!_isSwimming && !_isFloating)
			{
				acceleration.y = _DEFAULT_GRAVITY;
			}

		}
		
		private function animateCallback(name:String, framenumber:uint, frameindex:uint):void
		{
//			trace("name:" + name + ", framenumber:" + framenumber.toString() + ", frameindex:" + frameindex.toString());
			if (name == "dead" && framenumber == 1)
				kill();
		}
		
		private function animate():void
		{
			if (dead)
			{
				play("dead");
				return;
			}	
			
			// animate!
			var _apexThreshold:int = 30;	// the vertical downward velocity where the apex animation is played (-[value] - [value])
			var _downfastThreshold:int = 100;	// the vertical downward velocity where the downfast animation is played ([value] - ∞)

			 // not on the ground (in air or water)
			if (_isGrounded == false)
			{
				// going up
				if (velocity.y < _apexThreshold)
				{
					play("up");
				}
				// at the apex of a jump or dive
				if ((velocity.y < 0 ? -velocity.y : velocity.y) < _apexThreshold)
				{
					play("apex");
				}
				// going down
				if (velocity.y > _apexThreshold && velocity.y < _downfastThreshold)
				{
					play("down");
				}
				// going down quickly
				if (velocity.y >= _downfastThreshold)
				{
					play("downfast");
				}
			}
			
			// on the ground, running
			else if (_isRunning == true)
			{
				play("normal");
			}
			
			// on the ground, doing nothing
			else			{
				play("idle");
			}			

		}
		
		override public function update():void
		{
			if (dead)
			{
				animate();
				super.update();
                return;
			}
			
			// handle input
			if (!dead)
			{
				if ((( FlxG.keys.pressed(_KEY_LEFT[rabbitIndex]) || FlxG.keys.pressed(_KEY_RIGHT[rabbitIndex]) ) && !_disableControls ) || 
					_controlOverride == "LEFT" || _controlOverride == "RIGHT" )
				{
					_isRunning = true;
					
					if (((FlxG.keys.pressed(_KEY_LEFT[rabbitIndex]) ) && !_disableControls ) || 
						_controlOverride == "LEFT")
					{
						facing = LEFT;
						velocity.x -= _moveSpeed * FlxG.elapsed;
					}
					else if (((FlxG.keys.pressed(_KEY_RIGHT[rabbitIndex]) ) && !_disableControls ) || 
						_controlOverride == "RIGHT")
					{
						facing = RIGHT;
						velocity.x += _moveSpeed * FlxG.elapsed;                
					}
				}
				else
				{
					_isRunning = false
				}
				if (((FlxG.keys.justPressed(_KEY_JUMP[rabbitIndex]) ) && !_disableControls ) 
					|| _controlOverride == "JUMP")
				{
					jump();
				}						
			}
			
			animate();
			
			setMovementVariables();
			
			super.update();
			
/*			trace  ("DRAG:" + drag.x.toString() + "; " + 
					"MOVE_SPEED:" + _moveSpeed.toString() + "; " + 
					"GRAVITY:" + acceleration.y.toString() + ";; " + 
					"IS_GROUNDED: " + _isGrounded + "; " + 
					"IS_SLIDING: " + _isSliding + "; " + 
					"IS_RUNNING: " + _isRunning + "; " + 
					"IS_SWIMMING: " + _isSwimming + "; " + 
					"IS_FLOATING: " + _isFloating
				   );
*/
		}
	}

}