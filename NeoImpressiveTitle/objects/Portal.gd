tool
extends Area

export (Material) var material
export (String) var destination = "" setget set_destination


func _ready():
	# Force portal destination update
	destination = destination
	
	
func set_destination(value):
	destination = value
	
	# Have the child nodes been loaded yet?
	if not has_node("Portal/Portal"):
		return
		
	# Try to load portal texture
	var tex_path = "res://maps/images/portal{0}.png".format([value])
	var tex = null
	var dir = Directory.new()
	
	if not dir.file_exists(tex_path):
		tex_path = tex_path.replace(".png", ".jpg")
		
	tex = load(tex_path)
		
	if tex == null:
		# Fallback on the default portal texture
		return
		
	# Set the portal material
	var mat = material.duplicate()
	mat.set_shader_param("base", tex)
	get_node("Portal/Portal").set_material_override(mat)
