extends Control
class_name MyGraphNode

#get children/components
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label

#var declaration
@onready var neighbors : Array = []
@onready var value : int = 0
@onready var radius : int = 0
#either list of bools or enums for special rooms 


func _ready() -> void:
	radius = 64
	value = randi_range(1, 6) #temp values, emulated d6

func printNode() -> void:
	print("Id: ", self)
	print("Value: ", value)
	print("Coods: ", position)
	print("Adj: ", neighbors)
	print("") #lazy newline call
	return

#Add a node to the end of the list of adjacent nodes
func addNeighbor(node : MyGraphNode) -> void:
	neighbors.append(node)
	return

#Get entire list of adjacent nodes
func getNeighbors() -> Array:
	return neighbors

#Count number of adjacent nodes
func countNeighbors() -> int:
	return neighbors.size()

#functions for getting room types
