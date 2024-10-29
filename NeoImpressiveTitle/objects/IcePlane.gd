tool
extends StaticBody

export (Material) var material setget set_material


func _ready():
	pass
	
	
func set_material(value):
	material = value
	return
	
	# Have the child nodes been loaded?
	if not has_node("Plane"):
		call_deferred("set_material", value)
		return
		
	# Set plane material
	get_node("Plane").set_material_override(value)
