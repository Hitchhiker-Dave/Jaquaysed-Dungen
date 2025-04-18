extends Node2D

#get children/components
@onready var graph_handler: GraphManager = $GraphHandler
#temp vars until I set up the flexbox enviroment for Graph Handler
@onready var map_div_width : float = DisplayServer.window_get_size().x
@onready var map_div_height : float = DisplayServer.window_get_size().y

#var declaration
@export var roomCount : int = 10 ##number of rooms generated, max 100
@onready var radius : float = maxf(4.0, minf(map_div_width, map_div_height) / (roomCount * 2))

func _ready() -> void:
	graph_handler.nodeCount = mini(roomCount, 100)
	graph_handler.map_width = map_div_width
	graph_handler.map_height = map_div_height
	graph_handler.nodeRadius = radius
	graph_handler.newMap()
	return

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("new_map")):
		graph_handler.deleteNodes()
		graph_handler.newMap()
	return
