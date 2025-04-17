extends Control
class_name MyGraphNode

#get children/components
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var collider: CollisionShape2D = $Area2D/collider

#var declaration
@onready var neighbors : Array = []
@onready var value : int = 0
@onready var radius : float = 4.0
#either list of bools or enums for special rooms 

func _ready() -> void:
	@warning_ignore("unsafe_property_access")
	sprite_2d.texture.width = radius
	@warning_ignore("unsafe_property_access")
	sprite_2d.texture.height = radius
	value = randi_range(1, 6) #temp values, emulated d6

func setRadius(r : float) -> void:
	@warning_ignore("unsafe_property_access")
	sprite_2d.texture.width = r
	@warning_ignore("unsafe_property_access")
	sprite_2d.texture.height = r
	@warning_ignore("unsafe_property_access")
	collider.shape.radius = r * 2
	radius = r
	return

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

#Delete Node
func delete() -> void:
	#remove reference to current node from adjacency list in other nodes
	for adjNode : MyGraphNode in neighbors:
		adjNode.neighbors.erase(self)
	queue_free()
	return

#functions for getting room types

#TODO: Replace w/ actual algorithm that pushes nodes apart w/out going off screen
#Prevent overlap by "pushing" nodes away; hacky solution
func _on_area_2d_area_entered(_area: Area2D) -> void:
	var diameter : float = radius * 2
	self.global_position -= (Vector2(randi_range(-1,1), randi_range(-1,1)) * diameter)
	
	var screenX : float = DisplayServer.window_get_size().x
	var screenY : float = DisplayServer.window_get_size().y
	if(self.global_position.x - radius < 0): self.global_position.x = diameter
	if(self.global_position.y < 0): self.global_position.y = diameter
	if(self.global_position.x > screenX): self.global_position.x = screenX - diameter
	if(self.global_position.y > screenY): self.global_position.y = screenY - diameter
	return
