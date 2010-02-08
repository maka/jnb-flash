package com.makr.jumpnbump

{
	import adobe.utils.CustomActions;
	import com.makr.jumpnbump.objects.Dust;
	import com.makr.jumpnbump.objects.Splash;
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Player	extends FlxSprite
	{
		// witch level
		[Embed(source = '../../../../data/levels/witch/rabbit.png')] private var ImgPlayerWitch:Class;
		
		// original level
		[Embed(source = '../../../../data/levels/original/sounds.swf', symbol="Death")] private var SoundDeathOriginal:Class;
		[Embed(source = '../../../../data/levels/original/sounds.swf', symbol="Jump")] private var SoundJumpOriginal:Class;
		[Embed(source = '../../../../data/levels/original/rabbit.png')] private var ImgPlayerOriginal:Class;
	
		
		private var SoundDeath:Class;
		private var SoundJump:Class;
		private var ImgPlayer:Class;

		
		// controls for all players
		private static const _KEY_LEFT:Array = ["LEFT", "A", "J", "NUMPAD_FOUR"];
		private static const _KEY_RIGHT:Array = ["RIGHT", "D", "L", "NUMPAD_SIX"];
		private static const _KEY_JUMP:Array = ["UP", "W", "I", "NUMPAD_EIGHT"];
		
		// current rabbit id [0-3]
		public var rabbitIndex:uint;

		// current x-movement force
		public var movementX:Number = 0;
		public var particleTimer:Number = 0;
	
		private static const _DEFAULT_GRAVITY:int = 560;
		
		// different speeds for different tiles
		private static const _GROUND_SPEED:int = 750;
		private static const _WATER_SPEED:int = _GROUND_SPEED;
		private static const _AIR_SPEED:int = _GROUND_SPEED;
		private static const _ICE_SPEED:int = 50;
		
		// different friction as well
		private static const _GROUND_DRAG:int = 500;
		private static const _WATER_DRAG:int = 10;
		private static const _AIR_DRAG:int = 0;
		private static const _ICE_DRAG:int = 0;

		private var _moveSpeed:int = _GROUND_SPEED;
		
		private var _floatJumpPower:Number = 175;   // power of a normal jump (slightly more than 3 tiles)
		private var _jumpPower:Number = 245;   // power of a normal jump (slightly more than 3 tiles)
		private var _springPower:Number = 340;  // power of a spring jump (slightly more than 6 tiles)
		private var _bouncePower:Number = 160;   // power of the bounce off a killed bunny
		private var _bounceAndJumpPower:Number = 245;   // power of the bounce AND jump off a killed bunny
		
		private var _max_health:int = 1;
		
		private var _isGrounded:Boolean = false;
		private var _isSliding:Boolean = false;
		private var _isRunning:Boolean = false;
		private var _isSwimming:Boolean = false;
		private var _isFloating:Boolean = false;		
		
		private var _wantsToJump:Boolean = false;
		
		private var _swimTimer:Number = 0;
		private var _flashTimer:Number = 0;
		private var _respawnTimer:Number = 0;
		private static const _RESPAWN_TIME:Number = 0.15;
		
		private var _disableControls:Boolean = false;
		private var _controlOverride:String = "";
		
		public override function kill():void
		{
			/*
			 * Explanation of the various values for death/existence:
			 * 
			 * visible: decides if the object is rendered.
			 * 			the player should always be rendered
			 * exists: "a kind of global on/off switch" (?)
			 * 			see above, player is always on
			 * dead:	general: skips collision detection if true.
			 * 			in this class: dead players only play the death animation, they do not move at all and can not be controlled
			 * 			we use this when a player has been killed.
			 * 			SET TRUE TO PLAY DEATH ANIMATION AND START RESPAWN TIMER
			 * 
			 * active:	general: does not call update() if false
			 * 			we use this to mark players for respawning
			 * 			SET FALSE TO MARK PLAYER FOR RESPAWN!
			 * 
			 * 
			 */
			if (dead)
			{
				trace("WARNING: Player: !!! kill() called on Player "+rabbitIndex+" who is already dead !!!");
				return;
			}
			dead = true;
			velocity.x = 0;
			velocity.y = 0;
            acceleration.y = 0;
			FlxG.play(SoundDeath);				
		}
		
		public function jump(spring:Boolean = false, bounce:Boolean = false):void
		{
			if (bounce)				// bounce does not depend on anything, so it is being handled first
			{
				if (FlxG.keys.pressed(_KEY_JUMP[rabbitIndex]))	// bounce higher if jump button is pressed at the same time
					velocity.y = -_bounceAndJumpPower;
				else
					velocity.y = -_bouncePower;
				y -= 0.1;			// This is a hack to allow for the situation where a player is standing still and another jumps into him from below.
									// Without this line, the player above does not bounce.
									// Is Issue with Flixel hit detection? (HitFloor sets velocity.y=0)
				return;
			}
			
			if (!_isGrounded && !_isFloating/* && !_isSwimming */)	// other kinds of jump do depend on being grounded
				return;
				
			if (spring)				// spring jump (6 tiles)
			    velocity.y += -_springPower;
			else if (_isFloating)	// jump out of water (1 tile)
			{
				velocity.y += -_floatJumpPower;
				setFloating(false);	// stop floating (restore gravity);
			}
			else					// normal jump (3 tiles)
			{
				velocity.y += -_jumpPower;
				FlxG.play(SoundJump);
			}
			
			_wantsToJump = false;
		}
		
		public function isGrounded():Boolean { return _isGrounded; }
		public function setGrounded(isGrounded:Boolean):void
		{
			if (_isGrounded == isGrounded)	// return if value is already set
				return;
			_isGrounded = isGrounded;		// set value
			
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

		public function getControlOverride():String { return _controlOverride; }
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
			exists = true;
			active = true;	// unmarks player for respawn
			visible = true;
			dead = false;	// lets player be controlled again.
			
			_respawnTimer = 0;
			particleTimer = 0;
			
			last.x = x = X;
			last.y = y = Y;

			if (Math.random() > 0.5)
				facing = LEFT;
			else
				facing = RIGHT;
				
			color = 0xffffff;
			acceleration.y = _DEFAULT_GRAVITY;

		
		}
		
		public function Player(newRabbitIndex:uint, X:Number, Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "witch":
					SoundDeath = SoundDeathOriginal;
					SoundJump = SoundJumpOriginal;
					ImgPlayer = ImgPlayerWitch;
					break;

				case "original":
				default:
					SoundDeath = SoundDeathOriginal;
					SoundJump = SoundJumpOriginal;
					ImgPlayer = ImgPlayerOriginal;
					break;
			}

			
			rabbitIndex = newRabbitIndex;
			
			super(X, Y);
			
			loadGraphic(ImgPlayer, true, true, 19, 19); // load player sprite (is animated, is reversible, is 19x19)
			
		    // Max speeds
            maxVelocity.x = 77;
            maxVelocity.y = 400;
            // Set the player health
            health = 1;
            // Gravity
            acceleration.y = _DEFAULT_GRAVITY;            
            // Drag
            drag.x = _GROUND_DRAG;
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
				drag.x = _GROUND_DRAG;
			}
				
			// on ice
			if (_isGrounded && _isSliding)
			{
				_moveSpeed = _ICE_SPEED;
				drag.x = _ICE_DRAG;
			}
			
			// in the air
			if (!_isGrounded && !_isFloating && !_isSwimming)
			{
				_moveSpeed = _AIR_SPEED;
				drag.x = _AIR_DRAG;
			}

			// swimming
			if (_isSwimming && !_isFloating)
			{
				_moveSpeed = _WATER_SPEED;
				drag.x = _WATER_DRAG;
				acceleration.y = -60;
			}

			// floating
			if (!_isSwimming && _isFloating)
			{
				_moveSpeed = _WATER_SPEED;
				drag.x = _WATER_DRAG;
				acceleration.y = 0;
			}

			// out of water
			if (!_isSwimming && !_isFloating)
			{
				acceleration.y = _DEFAULT_GRAVITY;
			}

		}
		
		private function animate():void
		{
			// animate!
			var _apexThreshold:int = 30;	// the vertical downward velocity where the apex animation is played (-[value] - [value])
			var _downfastThreshold:int = 100;	// the vertical downward velocity where the downfast animation is played ([value] - ∞)

			 // not on the ground (in air or water)
			if (_isGrounded == false)
			{
				// going up
				if (velocity.y < _apexThreshold)
					play("up");
					
				// at the apex of a jump or dive
				if ((velocity.y < 0 ? -velocity.y : velocity.y) < _apexThreshold)
					play("apex");
					
				// going down
				if (velocity.y > _apexThreshold && velocity.y < _downfastThreshold)
					play("down");
					
				// going down quickly
				if (velocity.y >= _downfastThreshold)
					play("downfast");
			}
			
			// on the ground, running
			else if (_isRunning == true)
				play("normal");
			
			// on the ground, doing nothing
			else
				play("idle");

		}
		
		override public function update():void
		{
			movementX = 0;
			
			// if dead, play death animation and count down to respawn
			if (dead)
			{
				_respawnTimer += FlxG.elapsed;
				play("dead");
				super.update();
				
				if (_respawnTimer > _RESPAWN_TIME)
					active = false;	// mark player for respawn

				return;
			}
			
			// handle input
			
			// if direction key is pressed
			if ((( FlxG.keys.pressed(_KEY_LEFT[rabbitIndex]) || FlxG.keys.pressed(_KEY_RIGHT[rabbitIndex]) ) && !_disableControls ) || 
				_controlOverride == "LEFT" || _controlOverride == "RIGHT" )
			{
				_isRunning = true;
				
				if (((FlxG.keys.pressed(_KEY_LEFT[rabbitIndex]) ) && !_disableControls ) || 
					_controlOverride == "LEFT")
				{
					facing = LEFT;
					movementX -= _moveSpeed * FlxG.elapsed;
				}
				else if (((FlxG.keys.pressed(_KEY_RIGHT[rabbitIndex]) ) && !_disableControls ) || 
					_controlOverride == "RIGHT")
				{
					facing = RIGHT;
					movementX += _moveSpeed * FlxG.elapsed;                
				}
			}
			else
			{
				_isRunning = false
			}
			if ((FlxG.keys.justPressed(_KEY_JUMP[rabbitIndex]) && !_disableControls ))
				_wantsToJump = true;
			if ((FlxG.keys.justReleased(_KEY_JUMP[rabbitIndex]) && !_disableControls ) && _controlOverride != "JUMP")
				_wantsToJump = false;
			
			if ((_wantsToJump && (_isGrounded || _isFloating)) ||_controlOverride == "JUMP")
				jump();
				
			
			// handle drowning
			if (_isSwimming)
			{
				_swimTimer += FlxG.elapsed;
				
				if (_swimTimer > 6.5)		// 6.5 seconds underwater, start flashing at 2 Hertz
				{
					_flashTimer += FlxG.elapsed;
					
					while (_flashTimer >= 0.5) 
						_flashTimer -= 0.5;
					
					if (_flashTimer <= 0.25)
						color = 0x80C1F3;
					if (_flashTimer > 0.25)
						color = 0xffffff;
				}
				if (_swimTimer > 8.5)	// 8.5 seconds underwater, flash at 4 Hertz
				{
					_flashTimer += FlxG.elapsed;
					
					while (_flashTimer >= 0.25) 
					{
						_flashTimer -= 0.25;
					}
						
					if (_flashTimer <= 0.125)
						color = 0x80C1F3;
					if (_flashTimer > 0.125)
						color = 0xffffff;
				}
				if (_swimTimer > 10)	// 10 seconds underwater, drown.
				{
					color = 0x80C1F3;
					if (FlxG.levels[0] == "lotf" && FlxG.score == rabbitIndex)	// lose LOTF status when drowned
						FlxG.score = -1;			
					kill();
				}

			}
			else
			{
				_swimTimer = 0;
				if (color == 0x80C1F3)
					color = 0xffffff;
			}

			
			// apply movement to velocity
			velocity.x += movementX;
			
			animate();
			
			setMovementVariables();
			
			super.update();
		}
	}

}