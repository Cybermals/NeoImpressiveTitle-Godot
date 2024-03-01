extends Control

signal start_new_game
signal start_multiplayer
signal quit

export (String, MULTILINE) var changelog


func _ready():
	# Set changelog and make it read-only
	get_node("Changelog").set_text(changelog)
	get_node("Changelog").set_readonly(true)


func _on_NewGameButton_pressed():
	Logger.log_info("TitleScreen", "Starting new game...")
	emit_signal("start_new_game")


func _on_MultiplayerButton_pressed():
	Logger.log_info("TitleScreen", "Starting multiplayer...")
	emit_signal("start_multiplayer")


func _on_QuitButton_pressed():
	Logger.log_info("TitleScreen", "Quitting...")
	emit_signal("quit")
