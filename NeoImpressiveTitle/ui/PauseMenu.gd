extends Control

signal resume_game
signal show_settings
signal restart_game
signal quit_game


func _ready():
	pass


func _on_ResumeButton_pressed():
	Logger.log_info("PauseMenu", "Resuming game...")
	emit_signal("resume_game")


func _on_SettingsButton_pressed():
	Logger.log_info("PauseMenu", "Switching to settings dialog...")
	emit_signal("show_settings")


func _on_RestartButton_pressed():
	Logger.log_info("PauseMenu", "Restarting game...")
	emit_signal("restart_game")


func _on_QuitButton_pressed():
	Logger.log_info("PauseMenu", "Quitting game...")
	emit_signal("quit_game")
