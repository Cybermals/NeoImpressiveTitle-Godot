tool
extends Spatial

export (Mesh) var mesh setget set_mesh
export (Array) var instances = [] setget set_instances


func _ready():
	pass
	
	
func set_mesh(value):
	mesh = value
	update_instances()
	
	
func set_instances(value):
	instances = value
	update_instances()
	
	
func update_instances():
	# Skip instance update if no mesh
	if mesh == null:
		return
		
	# Defer instance update if not fully loaded
	if not has_node("MeshInstance"):
		call_deferred("update_instances")
		return
		
	# Create new group mesh
	var group_mesh = Mesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(mesh.get_surface_count()):
		st.set_material(mesh.surface_get_material(i))
		
		for instance in instances:
			st.append_from(mesh, i, instance)
			
		st.commit(group_mesh)
			
	get_node("MeshInstance").set_mesh(group_mesh)
