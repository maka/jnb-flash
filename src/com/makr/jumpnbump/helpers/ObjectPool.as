package com.makr.jumpnbump.helpers 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import flash.utils.getTimer;
	
	public class ObjectPool extends FlxGroup
	{
		// minimal number of available objects after shrinking is (shrinkBuffer * poolSize)
		private var _shrinkBuffer:Number;
		
		public var poolSize:uint;
		public var poolClass:Class;
		public var firstAvailIndex:uint;
		
		public var cleanupMS:int = 0, cleanupNUM:int = 0;
		
		public var tmpMembers:Array;
		
		public function ObjectPool(PoolClass:Class, PoolSize:uint, ShrinkBuffer:Number = 1) 
		{
			poolClass = PoolClass;
			poolSize = PoolSize;
			_shrinkBuffer = ShrinkBuffer;
			
			tmpMembers = [];

			firstAvailIndex = 0;
			
			growPool();
		}
		
		public function growPool():void
		{
			for (var i:int = 0; i < poolSize; i++) 
			{
				members[members.length] = new poolClass();
			}
		}
		
		public function checkPool():Boolean
		{
			for (var i:int = 0; i < members.length; i++) 
			{
				if (i < firstAvailIndex && members[i].exists == false )
					return false;
					
				else if (i >= firstAvailIndex && members[i].exists == true )
					return false;
			}
			
			return true;
		}
		
		public function cleanupPool():void
		{
			cleanupNUM += members.length;
			var timer:uint = getTimer();

			var membersLength:uint = members.length;

			// clear temporary arrays
			tmpMembers = members.concat();
			firstAvailIndex = 0;

			// separate unavailable and available objects
			var ptr:int = membersLength - 1;
			for each (var currentObj:FlxObject in members) 
			{
				if (currentObj.exists == true)
					tmpMembers[firstAvailIndex++] = currentObj;
				else
					tmpMembers[ptr--] = currentObj;
			}
			

			// intended poolsize is the number of unavailable objects + a buffer of free objects, rounded up to the nearest poolsize unit
			var intendedSize:int = Math.ceil(firstAvailIndex / poolSize + _shrinkBuffer) * poolSize;
			tmpMembers.length = Math.min(intendedSize, membersLength);

			members = tmpMembers.concat();
			
			tmpMembers.length = 0;
			
			cleanupMS += getTimer() - timer;
			
			if (String(poolClass) == "[class Gib]")
				trace(membersLength + "," + (getTimer() - timer));
		}
		
		public override function getFirstAvail():FlxObject
		{
			// if the firstAvailIndex has hit the end of the array,
			// first check if the array is in order
			
			if (firstAvailIndex == members.length || 	// if the firstAvailIndex has hit the end of the array OR
				FlxObject(members[firstAvailIndex]).exists)		// if the first available Object is in fact not available, something is wrong
			{
				if (checkPool())	// if the pool is in order
					growPool();		// expand it
				else
					cleanupPool();	// otherwise clean it up
			}
			
			return FlxObject(members[firstAvailIndex++]);
		}

		public override function render():void
		{
			var currentObject:FlxObject;
			
			for (var objIndex:int = 0; objIndex < firstAvailIndex; objIndex++) 
			{
				currentObject = members[objIndex] as FlxObject;
				if((currentObject != null) && currentObject.exists && currentObject.visible)
					currentObject.render();
			}
		}

	}
}