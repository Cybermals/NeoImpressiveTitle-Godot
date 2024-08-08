tool
extends Area

export (String) var destination = ""
export (Vector3) var dest_vec
export (Material) var material = null setget set_material


func _ready():
	pass
	
	
func set_material(value):
	material = value
	
	if not has_node("Portal/Portal"):
		call_deferred("set_material", value)
		return
		
	get_node("Portal/Portal").set_material_override(value)
