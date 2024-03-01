extends Control


func _ready():
	# Show sample alert
	display_alert("Hello World!")
	
	
func display_alert(msg):
	# Set the alert message and show the alert for up to 5 seconds
	get_node("PopupPanel/MessageLabel").set_text(msg)
	get_node("PopupPanel").popup_centered()
	get_node("Timer").start()


func _on_Timer_timeout():
	# Hide the alert
	get_node("PopupPanel").hide()
