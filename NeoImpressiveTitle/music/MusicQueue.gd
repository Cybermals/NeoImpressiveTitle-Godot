tool
extends StreamPlayer

export (StringArray) var songs = StringArray() setget set_songs

var current_song = 0


func _ready():
	# Populate song queue if empty
	if not songs.size():
		songs = StringArray([
		    "Ambience1",
		    "Ambience2",
		    "Ambience3",
		    "Ambience4",
		    "Ambience5"
		])
		
	# Start playing the songs
	play()
	
	
func set_songs(value):
	songs = value
	
	# Reset everything
	stop()
	current_song = 0
	
	# Start playing the first song
	if songs.size():
		_on_MusicQueue_finished()


func _on_MusicQueue_finished():
	# Play next song
	current_song += 1
	
	if current_song >= songs.size():
		current_song = 0
		
	set_stream(load("res://music/{0}.ogg".format([songs[current_song]])))
	play()
