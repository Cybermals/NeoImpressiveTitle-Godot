extends Control

signal previous_character
signal next_character
signal back
signal start_game
signal new_character
signal edit_character


func _ready():
	pass


func _on_PreviousButton_pressed():
	Logger.log_info("CharacterSelectScreen", "Loading previous character...")
	emit_signal("previous_character")


func _on_NextButton_pressed():
	Logger.log_info("CharacterSelectScreen", "Loading next character...")
	emit_signal("next_character")


func _on_BackButton_pressed():
	Logger.log_info("CharacterSelectScreen", "Returning to title screen...")
	emit_signal("back")


func _on_StartButton_pressed():
	Logger.log_info("CharacterSelectScreen", "Starting game...")
	emit_signal("start_game")


func _on_NewButton_pressed():
	Logger.log_info("CharacterSelectScreen", "Creating a new character...")
	emit_signal("new_character")


func _on_EditButton_pressed():
	Logger.log_info("CharacterSelectScreen", "Editing existing character...")
	emit_signal("edit_character")
