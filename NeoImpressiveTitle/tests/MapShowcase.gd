extends Spatial


func _ready():
	# Enable event processing
	set_process_input(true)
	
	
func _input(event):
	# Key event?
	if event.type == InputEvent.KEY:
		# Enter key?
		if event.scancode == KEY_RETURN:
			# Play camera flyover
			get_node("AnimationPlayer").play("CameraFlyover")
