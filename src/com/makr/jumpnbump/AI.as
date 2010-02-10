package com.makr.jumpnbump 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.flixel.*;

	public class AI
	{
		private var _tileMap:Array;
		private var _waypoints:Array;
		private var _mapDimensions:Point = new Point(22, 16);
		
		private var _path:Array;
		
		private var _currentTile:int;
		private var _targetTile:int;
		
		public var rabbitIndex:uint;
		
		private function toIndex(X:int, Y:int):int	{ return  limit(0,_mapDimensions.y-1, Y) * _mapDimensions.x + limit(0,_mapDimensions.x-1, X); }
		private function toCoordinates(Index:int):Point	{ return new Point(Index % _mapDimensions.x, int(Index / _mapDimensions.x)); }
		
		// returns absolute value, faster than Math.abs()	
		private function getAbsValue(x:Number):Number { return (x < 0) ? -x : x; }
		private function limit(X:Number, Min:Number, Max:Number):Number
		{
			var num:Number = X;
			num = (num < Min) ? Min : num;
			num = (num > Max) ? Max : num;
			return num; 
		}

		public function AI(RabbitIndex:uint, LevelTileMap:FlxTilemap) 
		{
			rabbitIndex = RabbitIndex;
			var x:int, y:int;
			_path = new Array();			
			
			/// START creating the map
			_tileMap = new Array();
			_waypoints = new Array();
			
			// filling it with tiles that are either free to use or not
			for (x = 0; x < _mapDimensions.x; x++) 
			{
				for (y = 0; y < _mapDimensions.y; y++) 
				{
					_tileMap[toIndex(x, y)] = new Object();
					_tileMap[toIndex(x, y)].free = (LevelTileMap.getTileByIndex(toIndex(x, y)) < LevelTileMap.collideIndex) ? 1 : 0;
				}
			}
			
			// fill map with more information on tiles (isWalkable, isSpring, isWater, isIce)
			
			for (x = 0; x < 22; x++) 
			{
				for (y = 1; y < 16; y++) 
				{
					if (LevelTileMap.getTileByIndex(toIndex(x, y - 1)) < LevelTileMap.collideIndex &&	// tile above is noncolliding
						LevelTileMap.getTileByIndex(toIndex(x, y)) >= LevelTileMap.collideIndex)		// current tile is colliding
						_tileMap[toIndex(x, y - 1)].isWalkable = true;									// mark above tile as walkable
					
					// water
					if (LevelTileMap.getTileByIndex(toIndex(x, y - 1)) == 0 &&	// above Tile is VOID 
						LevelTileMap.getTileByIndex(toIndex(x, y)) == 1)		// current tile is WATER
					{
						_tileMap[toIndex(x, y)].isWalkable = true;				// mark current tile (^= water surface) as walkable
					}
					
					
					// waypoints!
					if (LevelTileMap.getTileByIndex(toIndex(x, y - 1)) < LevelTileMap.collideIndex &&	// above tile is noncolliding
						LevelTileMap.getTileByIndex(toIndex(x, y)) >= LevelTileMap.collideIndex &&		// current tile is colliding 
																										// AND either one of the tiles next to the current is noncollidiong
						(LevelTileMap.getTileByIndex(toIndex(x - 1, y)) < LevelTileMap.collideIndex || LevelTileMap.getTileByIndex(toIndex(x + 1, y)) < LevelTileMap.collideIndex))
					{
							_waypoints.push(toIndex(x, y - 1));
							_tileMap[toIndex(x, y-1)].isWaypoint = true;
					}
				}
			}
		}
		
		private function resetPathfindingVariables():void
		{
			// initialize pathfinding values as false or 0
			for each (var tile:Object in _tileMap) 
			{
					tile.F = tile.G = tile.H = tile.parent = -1;
					tile.inOpenList = false;
					tile.inClosedList = false
			}
			if (_path.length > 0)
				_path.splice(0, _path.length);
		}
		
		private function calculateHCost(currentTileIndex:int, targetTileIndex:int):int
		{
			var currentTilePosition:Point = toCoordinates(currentTileIndex);
			var targetTilePosition:Point = toCoordinates(targetTileIndex);

			var distanceX:int = getAbsValue(currentTilePosition.x - targetTilePosition.x);
			var distanceY:int = getAbsValue(currentTilePosition.y - targetTilePosition.y);
			
			return (distanceX + distanceY) * 10;
		}

		private function calculateGCost(currentTileIndex:int):int
		{
			var parentTileIndex:int = _tileMap[currentTileIndex].parent;
			
			if (parentTileIndex == -1)
				trace("AI ERROR in calculateGCost(): Current Tile does not have a Parent!");
			if (_tileMap[parentTileIndex].G == -1)
				trace("AI ERROR in calculateGCost(): Parent does not have G-Cost calculated!");

			var currentTilePosition:Point = toCoordinates(currentTileIndex);
			var parentTilePosition:Point = toCoordinates(parentTileIndex);

			var distanceX:int = currentTilePosition.x - parentTilePosition.x;
			var distanceY:int = currentTilePosition.y - parentTilePosition.y;
			
			if (getAbsValue(distanceX) > 1 && getAbsValue(distanceX) < -1)
				trace("AI ERROR in calculateGCost(): Parent x-distance greater than 1! Parent is "+parentTileIndex+", Current Tile is "+currentTileIndex);
			if (getAbsValue(distanceY) > 1 && getAbsValue(distanceY) < -1)
				trace("AI ERROR in calculateGCost(): Parent y-distance greater than 1!");
			if (getAbsValue(distanceX) == 0 && getAbsValue(distanceY) == 0)
				trace("AI ERROR in calculateGCost(): Parent distance is 0!");

			var gCost:int = _tileMap[parentTileIndex].G;


			// standard costs

			if (getAbsValue(distanceX) != 0 && getAbsValue(distanceY) != 0)	// diagonal
				gCost += 14;

			else if (getAbsValue(distanceX) != 0 || getAbsValue(distanceY) != 0) // straight 
				gCost += 10;
			
			return gCost;		}

		private function getOpenListIndices():Array
		{
			var openListIndices:Array = new Array();
			
			for (var i:int = 0; i < _tileMap.length; i++) 
			{
				if (_tileMap[i].inOpenList == true)
					openListIndices.push(i);
			}
			
			return openListIndices;
		}

		private function getLowestCostOpenListIndex():int
		{
			var openListIndices:Array = getOpenListIndices();
			var lowestCostIndex:int;
			var lowestCost:int = 10000;
			for (var i:int = 0; i < openListIndices.length; i++) 
			{
				if (_tileMap[openListIndices[i]].F < lowestCost)
				{
					lowestCost = _tileMap[openListIndices[i]].F;
					lowestCostIndex = openListIndices[i];
				}
			}
			
			return lowestCostIndex;
		}

		
		private function getClosedListIndices():Array
		{
			var closedListIndices:Array = new Array();
			
			for (var i:int = 0; i < _tileMap.length; i++) 
			{
				if (_tileMap[i].inClosedList == true)
					closedListIndices.push(i);
			}
			
			return closedListIndices;
		}

		public function findPathThroughWaypoints(startIndex:int, endIndex:int):Array
		{
			resetPathfindingVariables();
			
			/// START A* pathfinding algorithm
			// we start by putting the current tile in the open list and calculating F, G and H costs for it
			_tileMap[startIndex].inOpenList = true;
			// G is movement cost from start point
			_tileMap[startIndex].G = 0;
			// H is estimated movement cost to end point
			_tileMap[startIndex].H = calculateHCost(startIndex, endIndex);
			// F = G + H
			_tileMap[startIndex].F = _tileMap[startIndex].G + _tileMap[startIndex].H;
			
			
			var finishedPathfinding:Boolean = false;
			// if the target is not reachable, skip pathfinding
			if (!_tileMap[endIndex].free)
				finishedPathfinding = true;
				
			var currentTile:int = -1;
			while (!finishedPathfinding)
			{
				// Look for the lowest F cost Tile on the open list. We refer to this as the currentTile.
				currentTile = getLowestCostOpenListIndex();
				
				// Switch it to the closed list.
				_tileMap[currentTile].inOpenList = false;
				_tileMap[currentTile].inClosedList = true;
				
				// For each of the 8 tiles adjacent to this current square …
				var currentTilePosition:Point = toCoordinates(currentTile);
				var adjacentTiles:Array = new Array();
				
				// top row
				if (currentTilePosition.y != 0)
				{
					if (currentTilePosition.x != 0)
						adjacentTiles.push(toIndex(currentTilePosition.x - 1, 	currentTilePosition.y - 1));
					adjacentTiles.push(toIndex(currentTilePosition.x, 			currentTilePosition.y - 1));
					if (currentTilePosition.x != _mapDimensions.x - 1)
						adjacentTiles.push(toIndex(currentTilePosition.x + 1, 	currentTilePosition.y - 1));
					
				}
				
				// middle row
				if (currentTilePosition.x != 0)
					adjacentTiles.push(toIndex(currentTilePosition.x - 1, 	currentTilePosition.y));
				if (currentTilePosition.x != _mapDimensions.x - 1)
					adjacentTiles.push(toIndex(currentTilePosition.x + 1, 	currentTilePosition.y));
				
				// bottom row
				if (currentTilePosition.y != _mapDimensions.y - 1)
				{
					if (currentTilePosition.x != 0)
						adjacentTiles.push(toIndex(currentTilePosition.x - 1, 	currentTilePosition.y + 1));
					adjacentTiles.push(toIndex(currentTilePosition.x, 			currentTilePosition.y + 1));
					if (currentTilePosition.x != _mapDimensions.x - 1)
						adjacentTiles.push(toIndex(currentTilePosition.x + 1, 	currentTilePosition.y + 1));
				}
				
				for each (var adjacentTile:int in adjacentTiles) 
				{
					// *	If it is not free or if it is on the closed list, ignore it. Otherwise do the following.
					// If it isn’t on the open list, 
					if (_tileMap[adjacentTile].inOpenList == false && _tileMap[adjacentTile].free == true && _tileMap[adjacentTile].inClosedList == false)		
					{
						// add it to the open list.
						_tileMap[adjacentTile].inOpenList = true;
						// Make the current tile the parent of this square.
						_tileMap[adjacentTile].parent = currentTile;	
							
						// Record the F, G, and H costs of the square. 
						_tileMap[adjacentTile].G = calculateGCost(adjacentTile);
						_tileMap[adjacentTile].H = calculateHCost(adjacentTile, _targetTile);
						_tileMap[adjacentTile].F = _tileMap[adjacentTile].G + _tileMap[adjacentTile].H;
					}
					
					// If it is on the open list already,
					else if (_tileMap[adjacentTile].inOpenList == true && _tileMap[adjacentTile].free == true && _tileMap[adjacentTile].inClosedList == false)		
					{
							// check to see if this path to that square is better, using G cost as the measure.
						var oldParent:int = _tileMap[adjacentTile].parent;
						var oldGCost:int = _tileMap[adjacentTile].G;
						_tileMap[adjacentTile].parent = currentTile;
						var newGCost:int = calculateGCost(adjacentTile);
						
						// A lower G cost means that this is a better path. 
						if (newGCost < oldGCost)
						{
							_tileMap[adjacentTile].G = newGCost;
							_tileMap[adjacentTile].F = _tileMap[adjacentTile].G + _tileMap[adjacentTile].H;
						}
						else
							_tileMap[adjacentTile].parent = oldParent;
					}
				}
				adjacentTiles.splice(0, adjacentTiles.length);
				
				
				// Stop when you:
				
				// *	Add the target square to the closed list, in which case the path has been found (see note below), or
				if (_tileMap[endIndex].inClosedList == true)
					finishedPathfinding = true;
					
				// * 	Fail to find the target square, and the open list is empty. In this case, there is no path.   
				if (getOpenListIndices().length == 0)
					finishedPathfinding = true;
			}
			
			// Save the path. Working backwards from the target tile, go from each tile to its parent tile until you reach the starting square. That is your path. 
			var finishedPathbuilding:Boolean = false;
			var currentPathTile:int = endIndex;
			while (!finishedPathbuilding)
			{
				_path.push(toCoordinates(currentPathTile));
				
				currentPathTile = _tileMap[currentPathTile].parent;
				
				if (currentPathTile == -1 || currentPathTile == startIndex)
					finishedPathbuilding = true;
			}
			
			// and reverse it to be able to use it
			_path.reverse();
			/// END A* pathfinding algorithm
			
			return _path;
		}
		
	
		public function findPathBetweenTiles(startIndex:int, endIndex:int):Array
		{
			var path:Array = new Array();
			
			resetPathfindingVariables();
			
			/// START A* pathfinding algorithm
			// we start by putting the current tile in the open list and calculating F, G and H costs for it
			_tileMap[startIndex].inOpenList = true;
			// G is movement cost from start point
			_tileMap[startIndex].G = 0;
			// H is estimated movement cost to end point
			_tileMap[startIndex].H = calculateHCost(startIndex, endIndex);
			// F = G + H
			_tileMap[startIndex].F = _tileMap[startIndex].G + _tileMap[startIndex].H;
			
			
			var finishedPathfinding:Boolean = false;
			// if the target is not reachable, skip pathfinding
			if (!_tileMap[endIndex].free)
				finishedPathfinding = true;
				
			var currentTile:int = -1;
			while (!finishedPathfinding)
			{
				// Look for the lowest F cost Tile on the open list. We refer to this as the currentTile.
				currentTile = getLowestCostOpenListIndex();
				
				// Switch it to the closed list.
				_tileMap[currentTile].inOpenList = false;
				_tileMap[currentTile].inClosedList = true;
				
				// For each of the 8 tiles adjacent to this current square …
				var currentTilePosition:Point = toCoordinates(currentTile);
				var adjacentTiles:Array = new Array();
				
				// top row
				if (currentTilePosition.y != 0)
				{
					if (currentTilePosition.x != 0)
						adjacentTiles.push(toIndex(currentTilePosition.x - 1, 	currentTilePosition.y - 1));
					adjacentTiles.push(toIndex(currentTilePosition.x, 			currentTilePosition.y - 1));
					if (currentTilePosition.x != _mapDimensions.x - 1)
						adjacentTiles.push(toIndex(currentTilePosition.x + 1, 	currentTilePosition.y - 1));
					
				}
				
				// middle row
				if (currentTilePosition.x != 0)
					adjacentTiles.push(toIndex(currentTilePosition.x - 1, 	currentTilePosition.y));
				if (currentTilePosition.x != _mapDimensions.x - 1)
					adjacentTiles.push(toIndex(currentTilePosition.x + 1, 	currentTilePosition.y));
				
				// bottom row
				if (currentTilePosition.y != _mapDimensions.y - 1)
				{
					if (currentTilePosition.x != 0)
						adjacentTiles.push(toIndex(currentTilePosition.x - 1, 	currentTilePosition.y + 1));
					adjacentTiles.push(toIndex(currentTilePosition.x, 			currentTilePosition.y + 1));
					if (currentTilePosition.x != _mapDimensions.x - 1)
						adjacentTiles.push(toIndex(currentTilePosition.x + 1, 	currentTilePosition.y + 1));
				}
				
				for each (var adjacentTile:int in adjacentTiles) 
				{
					// *	If it is not free or if it is on the closed list, ignore it. Otherwise do the following.
					// If it isn’t on the open list, 
					if (_tileMap[adjacentTile].inOpenList == false && _tileMap[adjacentTile].free == true && _tileMap[adjacentTile].inClosedList == false)		
					{
						// add it to the open list.
						_tileMap[adjacentTile].inOpenList = true;
						// Make the current tile the parent of this square.
						_tileMap[adjacentTile].parent = currentTile;	
							
						// Record the F, G, and H costs of the square. 
						_tileMap[adjacentTile].G = calculateGCost(adjacentTile);
						_tileMap[adjacentTile].H = calculateHCost(adjacentTile, _targetTile);
						_tileMap[adjacentTile].F = _tileMap[adjacentTile].G + _tileMap[adjacentTile].H;
					}
					
					// If it is on the open list already,
					else if (_tileMap[adjacentTile].inOpenList == true && _tileMap[adjacentTile].free == true && _tileMap[adjacentTile].inClosedList == false)		
					{
							// check to see if this path to that square is better, using G cost as the measure.
						var oldParent:int = _tileMap[adjacentTile].parent;
						var oldGCost:int = _tileMap[adjacentTile].G;
						_tileMap[adjacentTile].parent = currentTile;
						var newGCost:int = calculateGCost(adjacentTile);
						
						// A lower G cost means that this is a better path. 
						if (newGCost < oldGCost)
						{
							_tileMap[adjacentTile].G = newGCost;
							_tileMap[adjacentTile].F = _tileMap[adjacentTile].G + _tileMap[adjacentTile].H;
						}
						else
							_tileMap[adjacentTile].parent = oldParent;
					}
				}
				adjacentTiles.splice(0, adjacentTiles.length);
				
				
				// Stop when you:
				
				// *	Add the target square to the closed list, in which case the path has been found (see note below), or
				if (_tileMap[endIndex].inClosedList == true)
					finishedPathfinding = true;
					
				// * 	Fail to find the target square, and the open list is empty. In this case, there is no path.   
				if (getOpenListIndices().length == 0)
					finishedPathfinding = true;
			}
			
			// Save the path. Working backwards from the target tile, go from each tile to its parent tile until you reach the starting square. That is your path. 
			var finishedPathbuilding:Boolean = false;
			var currentPathTile:int = endIndex;
			while (!finishedPathbuilding)
			{
				path.push(toCoordinates(currentPathTile));
				
				currentPathTile = _tileMap[currentPathTile].parent;
				
				if (currentPathTile == -1 || currentPathTile == startIndex)
					finishedPathbuilding = true;
			}
			
			// and reverse it to be able to use it
			path.reverse();
			/// END A* pathfinding algorithm
			
			return path;
		}
		
		public function update(CurrentTile:Point, TargetTile:Point):Array
		{
			var newCurrent:int = toIndex(limit(CurrentTile.x, 0, _mapDimensions.x-1), 	limit(CurrentTile.y, 0, _mapDimensions.y-1));
			var newTarget:int =  toIndex(limit(TargetTile.x, 0, _mapDimensions.x - 1), 	limit(TargetTile.y, 0, _mapDimensions.y - 1));
			
			

			if (_targetTile != newTarget || _currentTile != newCurrent)
			{
				_targetTile = newTarget;
				_currentTile = newCurrent;
				_path = findPathThroughWaypoints(_currentTile, _targetTile);
			}

			return _path;
		}
		
		public function drawDebugImage():void
		{
			var x:int, y:int;
			
			var debugImage:BitmapData = new BitmapData(_mapDimensions.x, _mapDimensions.y);
			
			var debugImageMatrix:Matrix = new Matrix();
			debugImageMatrix = new Matrix();
			debugImageMatrix.identity();
			debugImageMatrix.scale(16, 16);

			// basic map (free=black, solid=blue)
			var color:uint = 0x000000;
			for (y = 0; y < _mapDimensions.y ; y++) 
				for (x = 0; x < _mapDimensions.x ; x++) 
				{
					if (!_tileMap[toIndex(x, y)].free)
						color = 0xffffff;
					else
						color = 0x000000;

					if (_tileMap[toIndex(x, y)].isWalkable)
						color = 0x222222;
					if (_tileMap[toIndex(x, y)].isWaypoint)
						color = 0xffff00;
					
					if (_tileMap[toIndex(x, y)].inOpenList)
						color = 0x008800
					if (_tileMap[toIndex(x, y)].inClosedList)
						color = 0x000088

					
					debugImage.setPixel(x, y, color);
				}
			
			// path
			for each (var pathPoint:Point in _path) 
				debugImage.setPixel(pathPoint.x, pathPoint.y, 0xff9900);

			// current and target positions
			debugImage.setPixel(toCoordinates(_targetTile).x, toCoordinates(_targetTile).y, 0xff0000);
			debugImage.setPixel(toCoordinates(_currentTile).x, toCoordinates(_currentTile).y, 0x00ff00);
			
			FlxG.buffer.draw(debugImage, debugImageMatrix, new ColorTransform(1, 1, 1, 0.5), "normal");
		}
	}

}