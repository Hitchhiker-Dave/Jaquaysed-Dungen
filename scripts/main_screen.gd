extends Node2D

#get children/components
@onready var background: ColorRect = $Background
@onready var graph_handler: GraphManager = %GraphHandler
@onready var ui_box: CenterContainer = $UI_Box
@onready var line_edit: LineEdit = $UI_Box/HBoxContainer/LineEdit

#temp vars until I set up the flexbox enviroment for Graph Handler
@onready var map_div_width : float = DisplayServer.window_get_size().x 
@onready var map_div_height : float = DisplayServer.window_get_size().y * (3.0/4.0)
@onready var ui_div_height : float = DisplayServer.window_get_size().y * (7.0/8.0)
 
#var declaration
@export var roomCount : int = 10 ##number of rooms generated, max 100
@onready var radius : float = maxf(2.0, minf(map_div_width, map_div_height) / (roomCount * 2))

func _ready() -> void:
	background.size = DisplayServer.window_get_size()
	ui_box.position.y = ui_div_height
	
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

func _on_button_button_up() -> void:
	graph_handler.deleteNodes()
	graph_handler.newMap()

func _on_line_edit_text_submitted(new_text: String) -> void:
	graph_handler.nodeCount = mini(maxi(new_text.to_int(), 1), 100)
	line_edit.text = str(graph_handler.nodeCount)
