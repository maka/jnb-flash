package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class Player	extends FlxSprite
	{
		// witch level
		[Embed(source = '../../../../../data/levels/witch/rabbit.png')] private var _imgPlayerWitch:Class;
		
		// original level
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Death")] private var _soundDeathOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Jump")] private var _soundJumpOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/rabbit.png')] private var _imgPlayerOriginal:Class;
	
		
		private var _soundDeath:Class;
		private var _soundJump:Class;
		private var _imgPlayer:Class;

		
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
			FlxG.play(_soundDeath);				
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

		public function get isRunning():Boolean { return _isRunning; }
		
		public function get isSwimming():Boolean { return _isSwimming; }
		public function set isSwimming(State:Boolean):void
		{
			if (_isSwimming == State)	// return if value is already set
				return;
				
			_isSwimming = State;		// set value
			
			if (State == true)			// set vertical velocity to 0
			{
				_isFloating = false;
			}
		}

		public function get isFloating():Boolean { return _isFloating; }
		public function set isFloating(State:Boolean):void
		{
			if (_isFloating == State)	// return if value is already set
				return;
				
			_isFloating = State;		// set value
			
			if (State == true)			// set vertical velocity to 0
			{
				_isSwimming = false;	// not swimming anymore
				velocity.y = 0;
			}
		}

		public function get isSliding():Boolean { return _isSliding; }
		public function set isSliding(State:Boolean):void
		{
			if (_isSliding == State)	// return if value is already set
				return;
				
			_isSliding = State;			// set value
		}

		public function disableControls(Disabled:Boolean = true):void
		{
			if (_disableControls == Disabled)	// return if value is already set
				return;
				
			_disableControls = Disabled;			// set value
		}

		public function overrideControls(Override:String):void
		{
			if (_controlOverride == Override)	// return if value is already set
				return;
				
			_controlOverride = Override;			// set value
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
		
		public function Player(RabbitIndex:uint, X:Number, Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "witch":
					_soundDeath = _soundDeathOriginal;
					_soundJump = _soundJumpOriginal;
					_imgPlayer = _imgPlayerWitch;
					break;

				case "original":
				default:
					_soundDeath = _soundDeathOriginal;
					_soundJump = _soundJumpOriginal;
					_imgPlayer = _imgPlayerOriginal;
					break;
			}

			rabbitIndex = RabbitIndex;
			
			super(X, Y);
			
			loadGraphic(_imgPlayer, true, true, 19, 19); // load player sprite (is animated, is reversible, is 19x19)
			
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
			var aO:uint = RabbitIndex * 9;
			
			// set animations for everything the bunny can do
		
			addAnimation("idle", [0+aO]);
			addAnimation("run", [0+aO, 1+aO, 2+aO, 3+aO], 15);
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
			// begin movement speeds
			const ICE_SPEED_CHANGE_DIRECTION:Number = 1 * 60 * FlxG.elapsed;
			const ICE_SPEED:Number = ICE_SPEED_CHANGE_DIRECTION * 0.75 * 60 * FlxG.elapsed;
			
			const NORMAL_SPEED_CHANGE_DIRECTION:Number = 16 * 60 * FlxG.elapsed;
			const NORMAL_SPEED:Number = NORMAL_SPEED_CHANGE_DIRECTION * 0.75 * 60 * FlxG.elapsed;
			
			const MAX_SPEED:Number = 96;
			
			var speed:Number, speedChangeDirection:Number;
			
			if (_isSliding)	// on ice
			{
				speed = ICE_SPEED;
				speedChangeDirection = ICE_SPEED_CHANGE_DIRECTION;
			} 
			else	// not on ice
			{
				speed = NORMAL_SPEED;
				speedChangeDirection = NORMAL_SPEED_CHANGE_DIRECTION;
			}
			
			this.facing = Facing;
			var S:int;	// the sign of any variables. this is -1 or 1 depending on the direction we're facing
			
			if (facing == LEFT)
				S = -1;
			else if (facing == RIGHT)
				S = 1;
			
			if (velocity.x*S < 0)
				velocity.x += speedChangeDirection*S;
			else
				velocity.x += speed*S;
			
			if (velocity.x*S > MAX_SPEED)	// max x velocity is 1.5px per frame
				velocity.x = MAX_SPEED*S;
				
			_isRunning = true;
		}
		
		private function steer(ActionLeft:Boolean, ActionRight:Boolean, ActionUp:Boolean):void
		{
			// movement speeds
			const GROUND_DECELERATION:Number = 16 * 60 * FlxG.elapsed;
			const NORMAL_JUMP:Number = 275; // was 273.4375 but that value was not enough for low framerates
			const NORMAL_JUMP_DECELERATION:Number = 32 * 60 * FlxG.elapsed;
			const NORMAL_GRAVITY:Number = 12 * 60 * FlxG.elapsed;
			const NORMAL_MAX_Y_SPEED:Number = 320;
			
			const WATER_JUMP:Number = 196; // was 192 but that value was not enough for low framerates
			const WATER_BUOYANCY:Number = 1.5 * 60 * FlxG.elapsed;
			const WATER_MAX_Y_SPEED:Number = 64;

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
			else if (!ActionLeft && !ActionRight)	// no movement keys pressed
			{
				_isRunning = false;
			
				if (onFloor && !_isSliding)	// slow the player down if he isn't holding a movement key
				{
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
				if (onFloor) 
				{
					velocity.y = -NORMAL_JUMP;
					_jumpReady = false;
					_jumpAbort = true;
					FlxG.play(_soundJump);
				}
				// jump out of water
				if (_isFloating) 
				{
					velocity.y = -WATER_JUMP;
					isFloating = false;
					_jumpReady = false;
					_jumpAbort = true;
					FlxG.play(_soundJump);
				}
			}
			if (!ActionUp)	// jump key isn't pressed, decelerate.
			{
				_jumpReady = true;
				if (!_isFloating && !_isSwimming && velocity.y < 0 && _jumpAbort == 1) 
				{
					velocity.y += NORMAL_JUMP_DECELERATION;
					if (velocity.y > 0)
						velocity.y = 0;
				}
			}
			
			if (_isSwimming) // underwater
			{
				// slowly move up to water surface
				velocity.y -= WATER_BUOYANCY;
				
				// limit max y-velocity
				if (velocity.y < -WATER_MAX_Y_SPEED)
					velocity.y = -WATER_MAX_Y_SPEED;
				if (velocity.y > WATER_MAX_Y_SPEED)
					velocity.y = WATER_MAX_Y_SPEED;
			} 
			
			if (!_isSwimming && !_isFloating) // apply gravity outside of water
			{
					velocity.y += NORMAL_GRAVITY;
					if (velocity.y > NORMAL_MAX_Y_SPEED)
						velocity.y = NORMAL_MAX_Y_SPEED;
			}
		}
		
		private function animate():void
		{
			const APEX_THRESHOLD:int = 36;	// the vertical downward velocity where the apex animation is played (-[value] - [value])
			const DOWNFAST_THRESHOLD:int = 100;	// the vertical downward velocity where the downfast animation is played ([value] - ∞)

			 // not on the ground (in air or water)
			if (!onFloor)
			{
				// going up
				if (velocity.y < APEX_THRESHOLD)
					play("up");
					
				// at the apex of a jump or dive
				if (Math.abs(velocity.y) < APEX_THRESHOLD)
					play("apex");
					
				// going down
				if (velocity.y > APEX_THRESHOLD && velocity.y < DOWNFAST_THRESHOLD)
					play("down");
					
				// going down quickly
				if (velocity.y >= DOWNFAST_THRESHOLD)
					play("downfast");
			}
			
			// on the ground, running
			else if (_isRunning == true)
				play("run");
			
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
			
			// can't slide if we're not on the floor
			if (!onFloor)
				isSliding = false;
			
			
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
						_flashTimer -= 0.25;
						
					if (_flashTimer <= 0.125)
						color = 0x80C1F3;
					if (_flashTimer > 0.125)
						color = 0xffffff;
				}
				if (_swimTimer > 10)	// 10 seconds underwater, drown.
				{
					color = 0x80C1F3;
					if (FlxG.levels[0] == "lotf" && FlxG.scores[1] == rabbitIndex)	// lose LOTF status when drowned
						FlxG.scores[1] = -1;			
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