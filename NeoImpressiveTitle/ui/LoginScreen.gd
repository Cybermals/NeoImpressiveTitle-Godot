extends Control

signal login(username, password)
signal create_account
signal change_password
signal back


func _ready():
	pass


func _on_LoginButton_pressed():
	Logger.log_info("LoginScreen", "Logging in...")
	
	var username = get_node("Panel/Inputs/TextInputs/Username").get_text()
	var password = get_node("Panel/Inputs/TextInputs/Password").get_text()
	emit_signal("login", username, password)


func _on_NewAccountButton_pressed():
	Logger.log_info("LoginScreen", "Creating new account...")
	emit_signal("create_account")


func _on_ChangePasswordButton_pressed():
	Logger.log_info("LoginScreen", "Changing password...")
	emit_signal("change_password")


func _on_BackButton_pressed():
	Logger.log_info("LoginScreen", "Returning to title screen...")
	emit_signal("back")
