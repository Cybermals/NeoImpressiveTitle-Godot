tool
extends Spatial


func _ready():
	# Apply settings
	get_node("Sun").set_project_shadows(Globals.get("NeoIT/shadows"))
	
	# Start playing the day-night cycle
	get_node("AnimationPlayer").play("DayNightCycle")
