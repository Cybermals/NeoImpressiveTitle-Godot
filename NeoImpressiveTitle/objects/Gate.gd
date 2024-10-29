tool
extends Area

export (String) var destination = ""
export (Vector3) var dest_vec
export (Material) var material setget set_material


func _ready():
	# Force gate material update
	material = material
	
	
func set_material(value):
	material = value
	
	if not has_node("Portal/Portal"):
		return
		
	get_node("Portal/Portal").set_material_override(value)
