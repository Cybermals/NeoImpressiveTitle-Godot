tool
extends Spatial

export (bool) var freeze_time setget set_freeze_time


func _ready():
	# Apply settings
	get_node("Sun").set_project_shadows(Globals.get("NeoIT/shadows"))
	
	# Force state update
	freeze_time = freeze_time
	
	
func set_freeze_time(value):
	freeze_time = value
	
	if not has_node("AnimationPlayer"):
		return
	
	if value:
		get_node("AnimationPlayer").stop()
		
	else:
		get_node("AnimationPlayer").play("DayNightCycle")
