extends Graph
class_name Kruskal

var Edges:Array[Edge]

var pathVerticesPosition=[]
var pathEdges=[]
	
func sortEdgesbyWeight(edges:Array[Edge]):#BubbleSort
	for i in range(edges.size()):
		for j in range(i+1,edges.size()):
			if edges[i].Length > edges[j].Length:
				var temp = edges[i]
				edges[i] = edges[j]
				edges[j] = temp
	return edges
static func MinimimSpanningTree(edges:Array[Edge])->Kruskal:
	var minimum_spanning_tree = Kruskal.new()
	minimum_spanning_tree.Edges = edges
	minimum_spanning_tree.pathEdges = minimum_spanning_tree.KruskalMST()
	return minimum_spanning_tree
func findVertices(edges:Array[Edge])->Array[Vertex]:
	var vertices :Array[Vertex]
	for e in edges:
		var isExistU := false
		var isExistV := false
		for v in vertices:
			if e.U.Equals(v):
				isExistU = true
			if e.V.Equals(v):
				isExistV = true
		if !isExistU:
			vertices.append(e.U)
		if !isExistV:
			vertices.append(e.V)
	return vertices
 
class subset:
	var parent:int
	var rank:int 
func find(subsets:Array[subset],i:int)->int: 
	if (subsets[i].parent != i): 
		subsets[i].parent = find(subsets, subsets[i].parent) 
	return subsets[i].parent
func Union(subsets:Array[subset], x:int, y:int): 
		var xroot:int = find(subsets, x) 
		var yroot:int = find(subsets, y)
		if (subsets[xroot].rank < subsets[yroot].rank): 
			subsets[xroot].parent = yroot 
		elif (subsets[xroot].rank > subsets[yroot].rank): 
			subsets[yroot].parent = xroot 
		else:
			subsets[yroot].parent = xroot 
			subsets[xroot].rank+=1
func findVertexIndex(vertices:Array[Vertex],vertex:Vertex)->int:
	for i in range(vertices.size()):
		if vertex.Equals(vertices[i]):
			return i
	return -1
func KruskalMST():
	var subsets:Array[subset]
	var vertices :Array[Vertex] = findVertices(Edges)
	var V = vertices.size()
	Edges = sortEdgesbyWeight(Edges)
	for v in range(V):
		subsets.append(subset.new())
		subsets[v].parent = v; 
		subsets[v].rank = 0; 
	var i:=0 #iterator for sorted edges
	var e:=0 #index var for result
	var result =[]
	while e < V-1:
		var next_edge = Edges[i]
		i+=1
		var x = find(subsets,findVertexIndex(vertices,next_edge.U))#-------------------------------------------------
		var y = find(subsets,findVertexIndex(vertices,next_edge.V))
		if x!=y:
			result.append(next_edge)
			e+=1
			Union(subsets,x,y)
	return result
