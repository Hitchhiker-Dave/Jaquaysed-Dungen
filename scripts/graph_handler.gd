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
func addNode() -> void:
	var newNode : MyGraphNode = node_instance.instantiate()
	add_child(newNode)
	newNode.setRadius(nodeRadius)
	newNode.global_position.x = randf_range((newNode.radius * 2), 
		(map_width - (newNode.radius * 2)-  1))
	newNode.global_position.y = randf_range((newNode.radius * 2), 
		(map_height - (newNode.radius * 2) - 1))
	nodes.push_back(newNode)
	#logic for if a node is too close to another node
	return

#initialize n nodes in nodeCount
func generateNodes() -> void:
	for i in nodeCount:
		addNode()
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
