tool
extends Area

export (Material) var material
export (String) var destination = "" setget set_destination


func _ready():
	pass
	
	
func set_destination(value):
	destination = value
	
	# Try to load portal texture
	var tex = load("res://maps/images/portal{0}.png".format([value]))
	
	if tex == null:
		# Maybe the texture is JPEG format?
		tex = load("res://maps/images/portal{0}.jpg".format([value]))
		
		if tex == null:
			# Fallback on the default portal texture
			return
			
	# Set the portal material
	var mat = material.duplicate()
	mat.set_shader_param("base", tex)
	get_node("Portal/Portal").set_material_override(mat)
