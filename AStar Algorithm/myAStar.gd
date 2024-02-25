extends Node
class_name myAStar


const DIAGONAL_COST = 140
const STRAIGHT_COST = 10
static func findPath(mode:bool,tilemap:TileMap,startCoor:Vector2i,targetCoor:Vector2i)->Array[Vector2i]:
	var startNode := myAStarNode.new(startCoor)
	var targetNode := myAStarNode.new(targetCoor)
	startNode.G = 0
	startNode.H = startNode.GetDistance(targetNode)
	startNode.CalculateF()
	var openList : Array[myAStarNode] = [startNode]
	var closedList : Array[myAStarNode]  = []
	var max_count = 300
	while !openList.is_empty():
		var currentIndex := 0
		for i in range(openList.size()):
			if (openList[i].F < openList[currentIndex].F or 
				openList[i].F == openList[currentIndex].F and openList[i].H < openList[currentIndex].H):
				currentIndex = i
		closedList.append(openList[currentIndex])
		var current :myAStarNode = openList.pop_at(currentIndex)
		if current.Equal(targetNode):
			var currentPathTile := current
			var path:Array[Vector2i]
			var count = 200
			while !currentPathTile.Equal(startNode):#---------------------------------------------
				path.append(currentPathTile.coor)
				currentPathTile = currentPathTile.Connection
			return path
		for neighbor in getNeighbors(mode,tilemap,current):
			if !neighbor.checkExistIn(closedList):
				var inSearch = neighbor.checkExistIn(openList)
				var costToNeighbor = current.G + current.GetDistance(neighbor)
				if !inSearch or costToNeighbor < neighbor.G:
					neighbor.G = costToNeighbor
					neighbor.Connection = current
					if !inSearch:
						neighbor.H = neighbor.GetDistance(targetNode)
						openList.append(neighbor)
		max_count-=1
		if max_count<0:
			print("path doesn't exist",openList.pop_back().coor,targetCoor)
			break
	return []
static func getNeighbors(mode:bool,tilemap:TileMap,n:myAStarNode)->Array[myAStarNode]:
	var neighborList:Array[myAStarNode]
	for i in [-1,1]:
		var neighborX = myAStarNode.new(Vector2i(n.coor.x+i,n.coor.y))
		var neighborY = myAStarNode.new(Vector2i(n.coor.x,n.coor.y+i))
		if checkWalkable(mode,tilemap,neighborX):
			neighborList.append(neighborX)
		if checkWalkable(mode,tilemap,neighborY):
			neighborList.append(neighborY)
	return neighborList

static func checkWalkable(mode:bool,tilemap:TileMap,n:myAStarNode)->bool:
	if mode==true and tilemap.get_cell_atlas_coords(1,n.coor) == Vector2i(0,1):
		return false
	return true
class myAStarNode:
	func _init(_coor:Vector2i):
		coor = _coor
	var coor:Vector2i
	var G:int
	var H:int
	var F:int
	var Connection:myAStarNode 
	func CalculateF(): F = H+G
	func GetDistance(n:myAStarNode)->float:
		var xDistance = abs(n.coor.x - coor.x)
		var yDistance = abs(n.coor.y - coor.y)
		var remaining = abs(xDistance-yDistance)
		return min(xDistance,yDistance)*DIAGONAL_COST + remaining*STRAIGHT_COST 
	func Equal(n:myAStarNode):
		return coor == n.coor
	func checkExistIn(nodes:Array[myAStarNode])->bool:
		var exist := false
		for n in nodes:
			if self.Equal(n):
				exist = true
				break
		return exist

		
