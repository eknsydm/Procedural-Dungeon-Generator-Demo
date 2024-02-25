extends Node
class_name Graph

class Vertex:
	var Position:Vector2
	func _init(position:Vector2):
		Position=position
	func Equals(vertex:Vertex):
		return Position == vertex.Position
class Edge:
	var U:Vertex
	var V:Vertex
	var Length:float
	var isBad:bool
	func _init(u:Vertex,v:Vertex):
		U=u
		V=v
		Length = U.Position.distance_to(V.Position)
	func Equals(e:Edge)->bool:
		return (U.Equals(e.U) and V.Equals(e.V) or
				U.Equals(e.V) and V.Equals(e.U))



