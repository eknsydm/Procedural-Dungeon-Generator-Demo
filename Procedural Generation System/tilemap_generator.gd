extends Node
class_name tilemap_generator

const emptyTileAtlas = Vector2i(0,0)
const wallTileAtlas = Vector2i(0,1)
const pathTileAtlas = Vector2i(1,0)
const groundTileAtlas = Vector2i(1,1)
static func doorGeneration(tilemap:TileMap,path:Array[Vector2i]):
	var doorCoors:Array[Vector2i]
	for i in range(path.size()-1,0,-1):
		if tilemap.get_cell_source_id(1,path[i])!=-1:
			tilemap.set_cell(1,path[i],0,emptyTileAtlas)
			doorCoors.append(path[i])
			break
	for i in range(0,path.size()):
		if tilemap.get_cell_source_id(1,path[i])!=-1:
			tilemap.set_cell(1,path[i],0,emptyTileAtlas)
			doorCoors.append(path[i])
			break
	return doorCoors
static func hallwayGeneration(tilemap:TileMap,startcoor:Vector2,endcoor:Vector2):
	var tileStartCoor = tilemap.local_to_map(startcoor)
	var tileEndCoor = tilemap.local_to_map(endcoor)
	var path = myAStar.findPath(false,tilemap,tileStartCoor,tileEndCoor)
	var doorsCoors :Array[Vector2i]= doorGeneration(tilemap,path)
	if doorsCoors.size()==2:
		path = myAStar.findPath(true,tilemap,doorsCoors[0],doorsCoors[1])
	for tilecoor in path:
		if tilemap.get_cell_source_id(0,tilecoor)==-1: #checks floor
			if tilemap.get_cell_source_id(1,tilecoor)==-1: #checks wall
				tilemap.set_cell(2,tilecoor,0,pathTileAtlas)
			else:
				pass
				#tilemap.set_cell(1,tilecoor,0,emptyTileAtlas)
static func roomGeneration(tilemap:TileMap,roomRigid:RigidBody2D):
	var collision :CollisionShape2D = roomRigid.get_child(0)
	var upperleftCorner = roomRigid.position - Vector2(collision.shape.size.x*collision.scale.x/2,collision.shape.size.y*collision.scale.y/2)
	var wallCoors :Array[Vector2i]
	var floorCoors :Array[Vector2i]
	for x in range(1,collision.scale.x):#----------------------------------------------------------
		for y in range(1,collision.scale.y):
			var tilepos := tilemap.local_to_map((upperleftCorner))+Vector2i(x,y)
			if (x == 1 or x == collision.scale.x - 1 or
				y ==  1 or y == collision.scale.y - 1):
					wallCoors.append(tilepos)
			else:
				floorCoors.append(tilepos)
	wallGeneration(tilemap,wallCoors)
	floorGeneration(tilemap,floorCoors)
static func wallGeneration(tilemap:TileMap,wallCoors:Array[Vector2i]):
	for c in wallCoors:
		tilemap.set_cell(1,c,0,wallTileAtlas)
static func floorGeneration(tilemap:TileMap,floorCoors:Array[Vector2i]):
	for c in floorCoors:
		tilemap.set_cell(0,c,0,groundTileAtlas)
static func clearTilemap(tilemap:TileMap):
	for i in range(tilemap.get_layers_count()):
		tilemap.remove_layer(i)
		tilemap.add_layer(i)
