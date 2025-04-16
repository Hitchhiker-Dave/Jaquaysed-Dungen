extends Control

#var declaration
@onready var nodes : Array = []

#testing/temp var declaration
@onready var nodeCount : int = 10
@onready var screen_height : int = DisplayServer.window_get_size().x
@onready var screen_width : int = DisplayServer.window_get_size().y

#object declaration
@export var node_instance : PackedScene

func _ready() -> void:
	nodes = get_children()
	print("Screen Dimensions: ", screen_height, ", ", screen_width)
	generateNodes(nodeCount)
	printNodes()
	return

#add new node to random position in scene
func addNode() -> void:
	var newNode : Control = node_instance.instantiate()
	add_child(newNode)
	newNode.global_position.x = randi_range(0, screen_height - 1)
	newNode.global_position.y = randi_range(0, screen_width - 1)
	nodes.push_back(newNode)
	#logic for if a node is too close to another node
	return

func generateNodes(count : int) -> void:
	for i in count:
		addNode()
	return

#test printout of all nodes in storage
func printNodes() -> void:
	for node : MyGraphNode in nodes:
		node.printNode()
		
	return
