package com.makr.jumpnbump.objects
{
	import flash.geom.Point;
	import org.flixel.*;	

	
	public class RabbitDummy extends FlxSprite
	{
		// witch level
		[Embed(source = '../../../../../data/levels/witch/rabbit.png')] private var _imgPlayerWitch:Class;
		
		// original level
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Death")] private var _soundDeathOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/rabbit.png')] private var _imgPlayerOriginal:Class;
	
		
		private var _soundDeath:Class;
		private var _imgPlayer:Class;
		
		// current rabbit id [0-3]
		public var rabbitIndex:uint;
		
		public var timer:Number;
		
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
				trace("WARNING: RabbitDummy: !!! kill() called on RabbitDummy who is already dead !!!");
				return;
			}
			
			exists = false;
			active = false;
			visible = false;
			
			velocity.x = 0;
			velocity.y = 0;
            acceleration.y = 0;
			FlxG.play(_soundDeath);				
		}
		

		public override function reset(X:Number, Y:Number):void
		{
			x = X;
			y = Y;
			
			exists = true;
			active = true;	// unmarks player for respawn
			visible = true;
			dead = false;	// lets player be controlled again.
		}
		
		public function RabbitDummy():void
		{
			switch (FlxG.levels[1])
			{
				case "witch":
					_soundDeath = _soundDeathOriginal;
					_imgPlayer = _imgPlayerWitch;
					break;

				case "original":
				default:
					_soundDeath = _soundDeathOriginal;
					_imgPlayer = _imgPlayerOriginal;
					break;
			}

			super(0, 0);
			
			loadGraphic(_imgPlayer, true, true, 19, 19); // load player sprite (is animated, is reversible, is 19x19)
			
		    // Max speeds
            maxVelocity.x = 96;
            // Set the player health
            health = 1;
            // set bounding box
            width = 15;
            height = 15;
            offset.x = 2;
            offset.y = 4;
			
			// the sprites face right by default
			facing = RIGHT;
			
			exists = false;
			active = false;
			visible = false;
		}
		
		public function activate(RabbitIndex:uint, X:Number, Y:Number, Xvel:Number, Yvel:Number):void
		{
			reset(X, Y);
			
			velocity.x = Xvel;
			velocity.y = Yvel;
			
			timer = 0.5 + Math.random() * 2;
			
			rabbitIndex = RabbitIndex
			
			// set animationOffset to use the right graphics
			
			// set animations for everything the bunny can do
		
			var aO:uint;
			for (var rI:int = 0; rI < 4; rI++) 
			{
				aO = rI * 9;
				addAnimation("idle"+rI, [0+aO]);
				addAnimation("up"+rI, [4+aO]);
				addAnimation("apex"+rI, [5+aO]);
				addAnimation("down"+rI, [6+aO]);
				addAnimation("downfast"+rI, [6+aO, 7+aO], 10);
				addAnimation("dead"+rI, [8 + aO]);
			}
			
		}
		
		private function animate():void
		{
			const APEX_THRESHOLD:int = 36;	// the vertical downward velocity where the apex animation is played (-[value] - [value])
			const DOWNFAST_THRESHOLD:int = 100;	// the vertical downward velocity where the downfast animation is played ([value] - ∞)

			if (velocity.x < 0)
				facing = LEFT;
			if (velocity.x > 0)
				facing = RIGHT;
			
			 // not on the ground (in air or water)
			if (!onFloor)
			{
				// going up
				if (velocity.y < APEX_THRESHOLD)
					play("up"+rabbitIndex);
					
				// at the apex of a jump or dive
				if (Math.abs(velocity.y) < APEX_THRESHOLD)
					play("apex"+rabbitIndex);
					
				// going down
				if (velocity.y > APEX_THRESHOLD && velocity.y < DOWNFAST_THRESHOLD)
					play("down"+rabbitIndex);
					
				// going down quickly
				if (velocity.y >= DOWNFAST_THRESHOLD)
					play("downfast"+rabbitIndex);
			}
			
			// on the ground, doing nothing
			else
				play("idle"+rabbitIndex);

		}
		
		public override function update():void
		{
			const NORMAL_GRAVITY:Number = 132 * FlxG.elapsed;

			timer -= FlxG.elapsed;
						
			velocity.y += NORMAL_GRAVITY;
			
			animate();
			
			super.update();
		}
	}
}