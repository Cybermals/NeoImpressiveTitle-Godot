tool
extends Spatial

export (Material) var material setget set_material


func _ready():
	# Set the material for all terrain chunks
	set_material(material)
	
	
func set_material(value):
	material = value
	
	# Set the material for all terrain chunks
	for child in get_children():
		# Is this child a mesh instance
		if child.get_type() == "MeshInstance":
			child.set_material_override(value)
