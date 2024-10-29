extends Spatial


func _ready():
	set_fixed_process(true)
	
	
func _fixed_process(delta):
	get_node("KinematicBody").move(Vector3(.1, 0, 0))
