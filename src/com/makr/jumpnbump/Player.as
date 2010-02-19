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
		
		// current killCount (for doublekill, etc.)
		public var killCount:int = 0;

		public var particleTimer:Number = 0;
	
		private var _jumpReady:Boolean = false;
		private var _jumpAbort:Boolean = false;
		
		private var _isGrounded:Boolean = false;
		private var _isSliding:Boolean = false;
		private var _isRunning:Boolean = false;
		private var _isSwimming:Boolean = false;
		private var _isFloating:Boolean = false;		
		
		public var hasDrowned:Boolean = false;
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
		
		public function springJump():void
		{
			velocity.y = -390.625;
			_jumpReady = false;
			_jumpAbort = false;
		}
		
		public function bounceJump():void
		{
			velocity.y = -velocity.y;
			if (velocity.y > -256)
				velocity.y = -256;
			y -= 0.1;			// This is a hack to allow for the situation where a player is standing still and another jumps into him from below.
			
			_jumpAbort = true;
		}

		public function isRunning():Boolean { return _isRunning; }
		
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
			
				var topTileEdge:Number = y - (y % 16);
				PlayState.gParticles.add(new Splash(x, topTileEdge));
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
		
		public override function reset(X:Number, Y:Number):void
		{
			x = X;
			y = Y;
			
			exists = true;
			active = true;	// unmarks player for respawn
			visible = true;
			dead = false;	// lets player be controlled again.
			
			_swimTimer = 0;
			hasDrowned = false;
			_respawnTimer = 0;
			particleTimer = 0;
			
			if (Math.random() > 0.5)
				facing = LEFT;
			else
				facing = RIGHT;
				
			color = 0xffffff;
			_jumpReady = true;
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
            maxVelocity.x = 1000;
            maxVelocity.y = 1000;
            // Set the player health
            health = 1;
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
		
		private function move(Facing:uint):void
		{
			// begin defining movement speeds
			const ICE_SPEED_CHANGE_DIRECTION:Number = 1 * 60 * FlxG.elapsed;
			const ICE_SPEED:Number = ICE_SPEED_CHANGE_DIRECTION * 0.75 * 60 * FlxG.elapsed;
			const NORMAL_SPEED_CHANGE_DIRECTION:Number = 16 * 60 * FlxG.elapsed;
			const NORMAL_SPEED:Number = NORMAL_SPEED_CHANGE_DIRECTION * 0.75 * 60 * FlxG.elapsed;
			const MAX_SPEED:Number = 96;
			// end defining movement speeds
			
			facing = Facing;
			var S:int;	// the sign of any variables. this is -1 or 1 depending on the direction we're facing
			
			if (facing == LEFT)
				S = -1;
			else if (facing == RIGHT)
				S = 1;
			
			if (_isSliding) 
			{ // if below is ice,
				if (velocity.x*S < 0)
					velocity.x += ICE_SPEED_CHANGE_DIRECTION*S;
				else
					velocity.x += ICE_SPEED*S; // otherwise, apply 0.01171875px force left
			} 
			else 
			{	// NOT ON ICE:
				if (velocity.x*S < 0)
					velocity.x += NORMAL_SPEED_CHANGE_DIRECTION*S;
				else
					velocity.x += NORMAL_SPEED*S;
			}
			
			if (velocity.x*S > MAX_SPEED)	// max x velocity is 1.5px per frame
				velocity.x = MAX_SPEED*S;
				
			_isRunning = true;
		}
		
		private function steer(ActionLeft:Boolean, ActionRight:Boolean, ActionUp:Boolean):void
		{
			// begin defining movement speeds
			const GROUND_DECELERATION:Number = 16 * 60 * FlxG.elapsed;
			const NORMAL_JUMP:Number = 275; // was 273.4375 but that value was not enough for low framerates
			const NORMAL_JUMP_DECELERATION:Number = 32 * 60 * FlxG.elapsed;
			const NORMAL_GRAVITY:Number = 12 * 60 * FlxG.elapsed;
			const NORMAL_MAX_Y_SPEED:Number = 320;
			
			const WATER_JUMP:Number = 196; // was 192 but that value was not enough for low framerates
			const WATER_BUOYANCY:Number = 1.5 * 60 * FlxG.elapsed;
			const WATER_MAX_Y_SPEED:Number = 64;
			// end defining movement speeds

			if (ActionLeft && ActionRight)	// if both movement keys are pressed, continue going in the current direction
			{
				if (facing == RIGHT && ActionRight) 
					move(RIGHT);
				else if (facing == LEFT && ActionLeft) 
					move(LEFT);
			} 
			else if (ActionLeft) 
				move(LEFT);
			else if (ActionRight) 
				move(RIGHT);
			else if (!ActionLeft && !ActionRight)
			{	// no movement keys pressed
				_isRunning = false;

			
				if (_isGrounded && !_isSliding)
				{
					// slow the player down if he isn't holding a movement key
					if (velocity.x < 0) 
					{
						velocity.x += GROUND_DECELERATION;
						if (velocity.x > 0)
							velocity.x = 0;
					} 
					else 
					{
						velocity.x -= GROUND_DECELERATION;
						if (velocity.x < 0)
							velocity.x = 0;
					}
				}
			}
			
			// Jumping!
			if (_jumpReady && ActionUp) 
			{
				if (_isGrounded) 
				{
					velocity.y = -NORMAL_JUMP;
					_jumpReady = false;
					_jumpAbort = true;
					FlxG.play(SoundJump);
				}
				// jump out of water
				if (_isFloating) 
				{
					velocity.y = -WATER_JUMP;
					setFloating(false);
					_jumpReady = false;
					_jumpAbort = true;
					FlxG.play(SoundJump);
				}
			}
			/* fall down by gravity */
			if (!ActionUp) 
			{
				_jumpReady = true;
				if (!_isFloating && !_isSwimming && velocity.y < 0 && _jumpAbort == 1) 
				{
					velocity.y += NORMAL_JUMP_DECELERATION;
					if (velocity.y > 0)
						velocity.y = 0;
				}
			}
			
			// if most if the player is underwater
			if (_isSwimming) 
			{
				/* slowly move up to water surface */
				velocity.y -= WATER_BUOYANCY;
				
				// limit max y-velocity to 64
				if (velocity.y < -WATER_MAX_Y_SPEED)
					velocity.y = -WATER_MAX_Y_SPEED;
				if (velocity.y > WATER_MAX_Y_SPEED)
					velocity.y = WATER_MAX_Y_SPEED;
			} 
			else if (!_isFloating) 
			{
					velocity.y += NORMAL_GRAVITY; // add normal gravity
					if (velocity.y > NORMAL_MAX_Y_SPEED)	// max downward velocity is 320
						velocity.y = NORMAL_MAX_Y_SPEED;
			}
		}
		
		private function animate():void
		{
			// animate!
			var _apexThreshold:int = 36;	// the vertical downward velocity where the apex animation is played (-[value] - [value])
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
		
		public override function update():void
		{
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
			
			var actionLeft:Boolean = false;
			var actionRight:Boolean = false;
			var actionUp:Boolean = false;
			
			if (!_disableControls)
			{
				actionLeft = FlxG.keys.pressed(_KEY_LEFT[rabbitIndex]);
				actionRight = FlxG.keys.pressed(_KEY_RIGHT[rabbitIndex]);
				actionUp = FlxG.keys.pressed(_KEY_JUMP[rabbitIndex]);
			}
			
			if (_controlOverride)
			{
				actionLeft = (_controlOverride == "LEFT");
				actionRight = (_controlOverride == "RIGHT");
				actionUp = (_controlOverride == "JUMP");
			}

			
			// if direction key is pressed
			if (actionLeft || actionRight)
				_isRunning = true;
			else
				_isRunning = false;

				
			steer(actionLeft, actionRight, actionUp);
			
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
					hasDrowned = true;
				}

			}
			else
			{
				_swimTimer = 0;
				if (color == 0x80C1F3)
					color = 0xffffff;
			}

			
			animate();
			
			super.update();
			
			
		}
	}
}