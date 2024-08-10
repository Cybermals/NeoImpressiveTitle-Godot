tool
extends Area

export (Material) var material setget set_material


func _ready():
	pass
	
	
func set_material(value):
	material = value
	
	# Have the child nodes been loaded?
	if not has_node("Plane"):
		call_deferred("set_material", value)
		return
		
	# Set plane material
	if typeof(value) == TYPE_STRING:
		return
		
	get_node("Plane").set_material_override(value)
