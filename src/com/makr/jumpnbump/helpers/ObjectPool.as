package com.makr.jumpnbump.helpers 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxU;
	
	public class ObjectPool extends FlxGroup
	{
		// minimal number of available objects after shrinking is (shrinkBuffer * poolSize)
		private var _shrinkBuffer:Number;
		
		public var poolSize:uint;
		public var poolClass:Class;
		public var firstAvailIndex:uint;
		
		public function ObjectPool(PoolClass:Class, PoolSize:uint, ShrinkBuffer:Number = 0.5) 
		{
			poolClass = PoolClass;
			poolSize = PoolSize;
			_shrinkBuffer = ShrinkBuffer;
			
			firstAvailIndex = 0;
			
			growPool();
		}
		
		public function growPool():void
		{
			for (var i:int = 0; i < poolSize; i++) 
			{
				add(new poolClass());
			}
		}
		
		public function checkPool():Boolean
		{
			for (var i:int = 0; i < members.length; i++) 
			{
				if ((i < firstAvailIndex && members[i].exists == false ) ||
					(i >= firstAvailIndex && members[i].exists == true ))
					return false;
			}
			
			return true;
		}
		
		public function cleanupPool(Shrink:Boolean = true):void
		{
			var availObjs:Array = new Array();
			var unavailObjs:Array = new Array();
			
			for each (var currentObj:FlxObject in members) 
			{
				if (currentObj.exists == true)
					unavailObjs.push(currentObj);
				else
					availObjs.push(currentObj);
			}
			
			// shrinking the pool
			if (Shrink)
			{
				// sizeReduction is the number of available objects (minus shrinkBuffer), expressed in full Poolsizes
				var availObjsSize:uint = availObjs.length;
				var sizeReduction:Number = Math.floor((availObjsSize / poolSize) - _shrinkBuffer);
				if (sizeReduction > 0)
					availObjs = availObjs.slice(0, availObjsSize - (sizeReduction * poolSize));
			}
			
			// apply the cleaned up version of the pool (unavailable Objects, then available Objects)
			members = unavailObjs.concat(availObjs);
			
			// set firstAvailIndex to new first available object
			firstAvailIndex = unavailObjs.length;
		}


		public override function getFirstAvail():FlxObject
		{
			// if the firstAvailIndex has hit the end of the array,
			// first check if the array is in order
			
			if (firstAvailIndex == members.length || 	// if the firstAvailIndex has hit the end of the array
				members[firstAvailIndex].exists)		// if the first available Object is in fact not available, something is wrong
			{
				if (checkPool())
					growPool();
				else
					cleanupPool();
			}
			
			return members[firstAvailIndex++] as FlxObject; 
		}
	}
}