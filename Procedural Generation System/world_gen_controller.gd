extends Node2D

@onready var tilemap = $TileMap
@export var settings:world_settings

var _drawDelunay = []
var _drawMST = []
var commandHistory :CommandHistory
func _ready():
	commandHistory = CommandHistory.new()
func _draw():
	print("DRAW")
	if _drawDelunay.size()!=0 and _drawMST.size()!=0:
		for e in _drawDelunay:
			draw_line(e.V.Position,e.U.Position,Color.RED,1)
		for e in _drawMST:
			draw_line(e.V.Position,e.U.Position,Color.BLUE,4)
func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			queue_redraw()
class command_clear extends command:
	var rigidRooms:Array[RigidBody2D]
	var parent_node:Node
	func _init(_parent_node):
		parent_node=_parent_node
	func execute():
		for c in parent_node.get_children():
			if c is RigidBody2D:
				rigidRooms.append(c)
				parent_node.remove_child(c)
	func undo():
		for r in rigidRooms:
			parent_node.add_child(r)
class command_MakeCorridors extends command:
	var vertices : Array[Delaunay2D.Vertex]
	var tilemap: TileMap
	var delaunay
	var kruskal
	func _init(_tilemap:TileMap,_verticesPositions:Array[Vector2]):
		vertices = makeVertices(_verticesPositions)
		tilemap =_tilemap
	func makeVertices(_verticesPositions:Array[Vector2])->Array[Delaunay2D.Vertex]:
		var vertices :Array[Delaunay2D.Vertex]
		for p in _verticesPositions:
			vertices.append(Delaunay2D.Vertex.new(p))
		return vertices
	func execute():
		delaunay = Delaunay2D.Triangulate(vertices)
		kruskal = Kruskal.MinimimSpanningTree(delaunay.Edges)
		for e in kruskal.pathEdges:
			tilemap_generator.hallwayGeneration(tilemap,e.U.Position,e.V.Position)
	func undo():
		tilemap.clear_layer(2)
		tilemap.add_layer(2)

class command_MakeTileMap extends command:
	var tilemap:TileMap
	var parent:Node
	func _init(_tilemap,_parent):
		tilemap = _tilemap
		parent = _parent
	func execute():
		for c in parent.get_children():
			if c is RigidBody2D:
				tilemap_generator.roomGeneration(tilemap,c)
	func undo():
		tilemap_generator.clearTilemap(tilemap)

class command_SpawnRooms extends command:
	var rigidRoom = preload("res://tscn/rigid_room.tscn")
	var parent_node:Node
	var room_count:int
	var spawn_radius:int
	var min_room_size:int
	var max_room_size:int 
	var rigidRooms:Array[RigidBody2D]
	var roomlocations:Array[Vector2]
	func _init(_parent_node,_spawn_radius,_room_count,_min_room_size,_max_room_size):
		parent_node = _parent_node
		room_count = _room_count
		spawn_radius = _spawn_radius
		min_room_size = _min_room_size
		max_room_size = _max_room_size
	func execute():
		print(room_count)
		for i in range(room_count):
			var newRigidRoom :RigidBody2D= rigidRoom.instantiate()
			newRigidRoom.position = getRandomPointInRadius(parent_node.position,spawn_radius)
			newRigidRoom.get_child(0).scale = getRandomRoomSize()
			parent_node.add_child(newRigidRoom)
			rigidRooms.append(newRigidRoom)
	func undo():
		if !rigidRooms.is_empty():
			for c in rigidRooms:
				c.free()
	func getRandomRoomSize()->Vector2i:
		var rectangleWH := Vector2i(min_room_size + randi() % (max_room_size+1 - min_room_size),
								min_room_size + randi() % (max_room_size+1 - min_room_size))
		return rectangleWH
	func getRoomLocations():
		for c in parent_node.get_children():
			if c is RigidBody2D:
				roomlocations.append(c.position)

	func getRandomPointInRadius(centerCoor:Vector2i,radius:int)->Vector2i:
		var r = radius * sqrt(randf_range(0,1)) #square of rand for cpf^[-1]
		var theta = randf_range(0,1) * 2 * PI
		return Vector2i(
			centerCoor.x + r*cos(theta),
			centerCoor.y + r*sin(theta)
		)



func _on_undo_pressed():
	commandHistory.Undo()
func _on_rigid_count_value_changed(value):
	settings.room_count = value
func _on_minimum_size_value_changed(value):
	settings.min_room_size = value
func _on_maximum_size_value_changed(value):
	settings.max_room_size = value
func _on_button_rigid_room_pressed():
	TEMP_clear_all()
	var c = command_SpawnRooms.new(self,
								settings.spawn_radius,
								settings.room_count,
								settings.min_room_size,
								settings.max_room_size)
	commandHistory.AddCommand(c)
	await get_tree().create_timer((0.005)*settings.room_count).timeout
	commandHistory.AddCommand(command_MakeTileMap.new(tilemap,self))
	c.getRoomLocations()
	
	c = command_MakeCorridors.new(tilemap,c.roomlocations)
	await commandHistory.AddCommand(c)
	_drawMST = c.kruskal.pathEdges
	_drawDelunay = c.delaunay.Edges
	commandHistory.AddCommand(command_clear.new(self))

func TEMP_clear_all():
	_drawDelunay = []
	_drawMST = []
	queue_redraw()
	for c in get_children():
		if c is RigidBody2D:
			c.free()
	for l in tilemap.get_layers_count():
		tilemap.remove_layer(l)
		tilemap.add_layer(l)


func _on_show_triangulation_pressed():
	queue_redraw()


func _on_spawn_radius_value_changed(value):
	settings.spawn_radius = value
