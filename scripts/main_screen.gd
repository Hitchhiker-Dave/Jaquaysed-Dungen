extends Node2D

#get children/components
@onready var background: ColorRect = $Background
@onready var graph_handler: GraphManager = %GraphHandler
@onready var line_edit: LineEdit = %LineEdit
@onready var main_container: MarginContainer = $MainContainer

#var declaration
@export var roomCount : int = 10 ##number of rooms generated, max 100
@onready var maxRooms : int = 100

func _ready() -> void:
	#set background and main ui size
	main_container.size = DisplayServer.window_get_size()
	background.size = DisplayServer.window_get_size()
	
	#set up manual ui padding
	var hpad : int = mini(DisplayServer.window_get_size().x, 10)
	var vpad : int = mini(DisplayServer.window_get_size().y, 20)
	
	main_container.add_theme_constant_override("margin_top", vpad)
	main_container.add_theme_constant_override("margin_bottom", vpad)
	main_container.add_theme_constant_override("margin_left", hpad)
	main_container.add_theme_constant_override("margin_right", hpad)
	
	#set up graph handler
	graph_handler.nodeCount = mini(roomCount, maxRooms)
	return

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("new_map")):
		graph_handler.deleteNodes()
		graph_handler.newMap()
	return

func _on_button_button_up() -> void:
	graph_handler.deleteNodes()
	graph_handler.newMap()

func _on_line_edit_focus_exited() -> void:
	graph_handler.nodeCount = mini(maxi(line_edit.text.to_int(), 1), maxRooms)
	line_edit.text = str(graph_handler.nodeCount)
