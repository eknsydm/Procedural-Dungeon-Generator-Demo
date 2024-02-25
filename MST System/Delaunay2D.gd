extends Graph
class_name Delaunay2D

static func AlmostEqual(x:float, y:float)->bool:
	const EPSILON = 0.0001
	return abs(x - y) <= EPSILON * abs(x + y) * 2 or abs(x - y) < 0.0

static func AlmostEqualVertex(left:Vertex, right:Vertex)->bool:
	return AlmostEqual(left.Position.x, right.Position.x) && AlmostEqual(left.Position.y, right.Position.y)

var Vertices:Array[Vertex]  
var Edges:Array[Edge] 
var Triangles:Array[Triangle]

static func Triangulate(vertices:Array[Vertex])->Delaunay2D:
	var delaunay = Delaunay2D.new()
	delaunay.Vertices = vertices
	delaunay.getTriangulate()
	return delaunay

func getTriangulate()->void:
	var minX :float = Vertices[0].Position.x
	var minY :float = Vertices[0].Position.y
	var maxX := minX
	var maxY := minY
	for vertex in Vertices:
		if vertex.Position.x < minX: minX = vertex.Position.x
		if vertex.Position.x > maxX: maxX = vertex.Position.x
		if vertex.Position.y < minY: minY = vertex.Position.y
		if vertex.Position.y > maxY: maxY = vertex.Position.y
	var dx := maxX-minX
	var dy := maxY-minY
	var deltaMax := minf(dx,dy)*2
	
	var p1 := Vertex.new(Vector2(minX-1,minY-1))
	var p2 := Vertex.new(Vector2(minX-1,maxY+deltaMax))
	var p3 := Vertex.new(Vector2(maxX+deltaMax,minY-1))
	
	Triangles.append(Triangle.new(p1,p2,p3))
	for vertex in Vertices:
		var polygon :Array[Edge]
		for t in Triangles:
			if t.CircumCircleContains(vertex.Position):
				t.isBad = true
				polygon.append(Edge.new(t.A,t.B))
				polygon.append(Edge.new(t.B,t.C))
				polygon.append(Edge.new(t.C,t.A))
#Triangles isBad
		var clearTriangles :Array[Triangle]
		for t in Triangles:
			if !t.isBad:
				clearTriangles.append(t)
		Triangles = clearTriangles
		for i in range(polygon.size()):
			for j in range(i+1,polygon.size()):
				if AlmostEqualEdge(polygon[i],polygon[j]):
					polygon[i].isBad=true
					polygon[j].isBad=true
#Polygon isBad
		var clearPolygon :Array[Edge]
		for e in polygon:
			if !e.isBad:
				clearPolygon.append(e)
		polygon = clearPolygon
		for edge in polygon:
			Triangles.append(Triangle.new(edge.U, edge.V, vertex));
#Triangles remove super-Tri
	var clearTriangles :Array[Triangle]
	#print("CT before",Triangles.size())
	for t in Triangles:
		if !(t.ContainsVertex(p1.Position) or t.ContainsVertex(p2.Position) or t.ContainsVertex(p3.Position)):
			clearTriangles.append(t)
	#print("CT after",clearTriangles.size())
	Triangles = clearTriangles
	#print("Final:",Triangles.size())
	var edge_set = {}
	
	for t in Triangles:
		var newEdges = [Edge.new(t.A, t.B),
						Edge.new(t.B, t.C),
						Edge.new(t.C, t.A)]
		for newEdge in newEdges:
			var equal:bool = false
			for e in Edges:
				if newEdge.Equals(e):
					equal=true
					break
			if !equal:
				Edges.append(newEdge)

static func AlmostEqualEdge(left:Edge, right:Edge)->bool:
	return (Delaunay2D.AlmostEqualVertex(left.U, right.U) and Delaunay2D.AlmostEqualVertex(left.V, right.V) or 
			Delaunay2D.AlmostEqualVertex(left.U, right.V) and Delaunay2D.AlmostEqualVertex(left.V, right.U))
class Triangle:
	
	var A:Vertex
	var B:Vertex
	var C:Vertex
	var isBad:bool
		
	func _init(a:Vertex,b:Vertex,c:Vertex):
		A=a
		B=b
		C=c
	func ContainsVertex(v:Vector2)->bool:
		return (v.distance_to(A.Position)<0.01 or 
				v.distance_to(B.Position)<0.01 or 
				v.distance_to(C.Position)<0.01)
	func CircumCircleContains(v:Vector2)->bool:
		var a:=A.Position
		var b:=B.Position
		var c:=C.Position
		
		var ab :=a.length_squared()
		var cd :=b.length_squared()
		var ef :=c.length_squared()
		
		var circumX = (ab * (c.y - b.y) + cd * (a.y - c.y) + ef * (b.y - a.y)) / (a.x * (c.y - b.y) + b.x * (a.y - c.y) + c.x * (b.y - a.y))
		var circumY = (ab * (c.x - b.x) + cd * (a.x - c.x) + ef * (b.x - a.x)) / (a.y * (c.x - b.x) + b.y * (a.x - c.x) + c.y * (b.x - a.x))
		
		var circum := Vector2(circumX/2,circumY/2)
		var circumRadius :float= (a-circum).length_squared()
		var dist:float = (v-circum).length_squared()
		return dist <= circumRadius
