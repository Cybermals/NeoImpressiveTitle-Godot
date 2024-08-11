tool
extends SpatialSamplePlayer

export (String) var sfx = ""


func _ready():
	# Start the sound effect
	play(sfx)
