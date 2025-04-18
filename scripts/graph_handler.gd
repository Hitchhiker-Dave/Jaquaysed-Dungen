extends Control
class_name GraphManager

#var declaration
@onready var nodes : Array = []

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
	print("Generating New Nodes")
	var x : float = 0
	var y : float = 0
	var padding : float = nodeRadius * 2
	for i in nodeCount:
		print("Coords[", i, "]: ", coords[i])
		'''x = randf_range((coords[i][0] * width) + (width/3), 
			(coords[i][0] * width) + (width * (2/3)))
		y = randf_range((coords[i][1] * height), 
		(coords[i][1] * height) + height)'''
		x = coords[i][0] * (width) + padding
		y = coords[i][1] * (height) + padding
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
	generateNodes(grid_coords, grid_width, grid_height)
	
	return

#delete all stored nodes in graph
func deleteNodes() -> void:
	for node : MyGraphNode in nodes:
		node.delete()
	nodes.clear()
	return

#test printout of all nodes in storage
func printNodes() -> void:
	for node : MyGraphNode in nodes:
		node.printNode()
		
	return
