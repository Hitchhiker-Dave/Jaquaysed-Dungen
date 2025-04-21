extends Control
class_name GraphManager

#var declaration
@onready var nodes : Array = []
var visibleEdges : Array = []

#testing/temp var declaration
@onready var nodeCount : int = 10
@onready var map_width : float 
@onready var map_height : float
@onready var nodeRadius : float = 4.0

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
	var x : float = 0
	var y : float = 0
	var padding : float = nodeRadius 
	for i in nodeCount:    
		#print("Coords[", i, "]: ", coords[i])
		x = min(coords[i][0] * width + padding + randf_range(-1 * width / 4.0, width / 4.0), 
			width * nodeCount - (padding / 2.0))
		if x < (padding / 2.0): x = padding / 2.0
		
		y = min(coords[i][1] * height + padding + randf_range(-1 * height / 4.0, height / 4.0),
			height * nodeCount - (padding / 2.0))
		if y < (padding / 2.0): y = padding / 2.0
		
		addNode(x, y)
	return

#psuedo BSP-> do math to generate a list of n x n coords, then use a rand coord *
#the sub grid's dimensions (x = padding + screen_x / n, y = padding + screen_y / n) to get a valid 
#range for placing a node. make sure to pop the used coords to prevent potential overlap 
func newMap() -> void:
	#var declaration
	var grid_coords : Array = []
	var grid_width : float = map_width / nodeCount
	var grid_height : float = map_height / nodeCount
	
	#initialize valid grid coords
	for y in range(nodeCount):
		for x in range(nodeCount):
			grid_coords.append([x, y])
	
	grid_coords.shuffle()
	#Place nodes via pseudo BSP
	generateNodes(grid_coords, grid_width, grid_height)
	printNodes()
	
	#Delaunay triangulation
	var del_grid : Array = triangulate()
	del_grid.sort()
	drawEdges(del_grid)

	#MST
	#Set Start, Goal, & Encounter Nodes
	#Add Edges
	#Set Treasure Nodes
	#Start Graph Re-write
	return

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
	for i in range(visibleEdges.size()):
		draw_line(visibleEdges[i][0][0].position, visibleEdges[i][0][1].position,
		Color.GRAY , nodeRadius / 4.0)
		
	return
