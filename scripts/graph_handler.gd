extends Control
class_name GraphManager

#var declaration
@onready var nodes : Array = []
var visibleEdges : Array = []

#testing/temp var declaration
@onready var nodeCount : int = 10
@onready var nodeRadius : float = 10.0
@onready var minRadius : float = 8.0

#object declaration
@export var node_instance : PackedScene

func _ready() -> void:  
	return

#add new node to random position in scene; look up that Rogue-like Talk about RNG- the one where they
#talk about splitting the screen into distributed chunks before placing rooms
func addNode(x : float, y : float) -> void:
	var newNode : MyGraphNode = node_instance.instantiate()
	add_child(newNode)
	newNode.setRadius(nodeRadius)
	newNode.global_position.x = x
	newNode.global_position.y = y
	nodes.push_back(newNode)
	return

##place nodeCount nodes onto screen
func generateNodes(coords : Array, width : float, height : float) -> void:
	#print("Generating New Nodes")
	var min_width : float = get_parent().global_position.x
	var min_height : float = get_parent().global_position.y
	var x : float = 0
	var y : float = 0
	var padding : float = nodeRadius 
	
	for i in nodeCount:    
		#print("Coords[", i, "]: ", coords[i])
		x = min((coords[i][0] * width) + min_width + padding 
			+ randf_range((-1 * width / 4.0), (width / 4.0)), 
			(width * nodeCount) + min_width - (padding))
		if x < padding + min_width: x = padding + min_width
		
		y = min((coords[i][1] * height) + min_height + padding 
			+ randf_range((-1 * height / 4.0), (height / 4.0)),
			(height * nodeCount) + min_height - (padding))
		if y < padding + (min_height * 1.5): y = padding + (min_height * 1.1)
		
		addNode(x, y)
	return

#psuedo BSP-> do math to generate a list of n x n coords, then use a rand coord *
#the sub grid's dimensions (x = padding + screen_x / n, y = padding + screen_y / n) to get a valid 
#range for placing a node. make sure to pop the used coords to prevent potential overlap 
func newMap() -> void:
	#var declaration
	var map_size : Vector2 = (get_parent_area_size())
	var grid_coords : Array = []
	var grid_width : float = map_size[0] / nodeCount
	var grid_height : float = map_size[1] / nodeCount
	nodeRadius = maxf(minRadius, minf(map_size[0], map_size[1]) / (nodeCount * 2))
	
	#initialize valid grid coords
	for y in range(nodeCount):
		for x in range(nodeCount):
			grid_coords.append([x, y])
	
	grid_coords.shuffle()
	#Place nodes via pseudo BSP
	generateNodes(grid_coords, grid_width, grid_height)
	#printNodes()
	
	#Delaunay triangulation
	var del_grid : Array = triangulate()
	del_grid.sort()

	#Find MST
	var map_paths : Array = createMST(del_grid)
	
	#Set Start, Goal, & Encounter Nodeson Files\Oracle\Java\javapath\javac.exe
	
	
	#Find remaining edges in del_grid
	map_paths = addExtraEdges(map_paths, del_grid)
	
	#Set Treasure Nodes
	
	
	#Start Graph Re-write
	
	#update screen
	drawEdges(map_paths)
	return

func addExtraEdges(map_array : Array, possible_edges : Array) -> Array:
	#Find remaining edges in del_grid
	var remaining_edges : Array = possible_edges.duplicate(true)
	for edge : Array in possible_edges:
		if(edge[0] in map_array):
			remaining_edges.erase(edge)
	
	#Add floor( 2(room - 1) / 3) Extra Edges
	var extra : int = ceili( ((nodeCount * 2.0) / 3.0))
	
	for i in range(remaining_edges.size() - 1, 0, -1):
		if extra <= 0: break
		map_array.append(remaining_edges[i][0])
		extra -= 1
	return map_array

##Delaunay triangulation via converting nodes list into format usable by godot's
##built in delaunay triangulation function; returns list of edges from a
##the grid: [ [Node A, Node B], Edge Length ]
func triangulate() -> Array:
	#convert nodes into a valid PackedVector2Array
	var nodeCoords : PackedVector2Array = []
	for node : MyGraphNode in nodes:
		nodeCoords.append(node.position)
	
	#input converted nodes into a delaunay triangulation grid; specifically, it
	#returns an array of indices where each 3 nodes form the triangle
	var tri_grid : PackedInt32Array = Geometry2D.triangulate_delaunay(nodeCoords)
	
	#convert triangulation into usable list of edges + distances (non repeating)
	var edges : Array = []
	var A : MyGraphNode
	var B : MyGraphNode
	var C : MyGraphNode
	for i in range(tri_grid.size()):
		#Tri = A - B - C - A
		if (((i + 1) % 3) == 0):
			A = nodes[tri_grid[i-2]]
			B = nodes[tri_grid[i-1]]
			C = nodes[tri_grid[i]]
			
			#append A-B
			if([ [ A, B ], abs(A.position.distance_to(B.position)) ] not in edges and 
			[ [ B, A ], abs(A.position.distance_to(B.position)) ] not in edges):
				edges.append([ [ A, B ], abs(A.position.distance_to(B.position)) ])
				
			#append B-C
			if([ [ B, C ], abs(B.position.distance_to(C.position)) ] not in edges and 
			[ [ C, B ], abs(B.position.distance_to(C.position)) ] not in edges):
				edges.append([ [ B, C ], abs(B.position.distance_to(C.position)) ])
				
			#append C-A
			if([ [ C, A ], abs(C.position.distance_to(A.position)) ] not in edges and 
			[ [ A, C ], abs(C.position.distance_to(A.position)) ] not in edges):
				edges.append([ [ C, A ], abs(C.position.distance_to(A.position)) ])
	
	return edges

##Form an MST through a variation of Kruskal's algorithm:
##https://en.wikipedia.org/wiki/Kruskal%27s_algorithm 
func createMST(edges : Array) -> Array:
	var mst : Array = []
	var maxEdges : int = nodeCount - 1
	var A : MyGraphNode
	var B : MyGraphNode
	
	##iterate through sorted edge list
	for edge : Array in edges:
		#early return if the max possible edges has been reached
		if(mst.size() >= maxEdges): return mst
		A = edge[0][0]
		B = edge[0][1]
		
		#check if adding current edge won't cause a cycle
		if(self.doBFS(A, B) == false): 
			mst.append(edge[0]) #append edge to MST list
			#update node neighbors/adj lists
			A.addNeighbor(B)
			B.addNeighbor(A)
	
	return mst

##Perform a BFS using the starting node's adjencies list. Returns true
##if path to target node was found, and false otherwise 
func doBFS(start : MyGraphNode, target : MyGraphNode) -> bool:
	var queue : Array = [] #queue of nodes to search through
	#initialize array of bools
	var visited : Array = []
	for i in range(nodeCount):
		visited.append(false)
	
	queue.append(start)
	visited[nodes.find(start)] = true
	
	#iteratte through verts
	var current : MyGraphNode
	while(queue.size() > 0):
		current = queue.pop_front() #get new node from queue
		if(current == target): return true #check if it's the target
		for adj : MyGraphNode in current.getNeighbors(): #if not, add adj to queue
			if(visited[nodes.find(adj)] == false):
				visited[nodes.find(adj)] = true
				queue.push_back(adj)
	
	return false #path to target not found

#delete all stored nodes in graph
func deleteNodes() -> void:
	for node : MyGraphNode in nodes:
		node.delete()
	nodes.clear()
	return

#draw lines from a list of edges and a given color (fixed for now)
func drawEdges(edges : Array) -> void:
	visibleEdges = edges
	queue_redraw()
	return

#test printout of all nodes in storage 
func printNodes() -> void:
	for node : MyGraphNode in nodes:
		node.printNode()
		
	return

func _draw() -> void:
	var posA : Vector2
	var posB : Vector2
	for i in range(visibleEdges.size()):
		posA = visibleEdges[i][0].position
		posB = visibleEdges[i][1].position
		draw_line(posA, posB, Color.GRAY, maxf(0.05, nodeRadius / 4.0))
		
	return
