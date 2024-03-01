extends Control

signal finished


func _ready():
	pass


func _on_AnimationPlayer_finished():
	Logger.log_info("SplashScreen", "Splash screen finished.")
	emit_signal("finished")
