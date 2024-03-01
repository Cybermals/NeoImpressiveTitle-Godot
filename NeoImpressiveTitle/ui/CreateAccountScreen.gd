extends Control

signal create_account(username, password, confirm_password, email)
signal back

var is_username_valid = false
var is_password_valid = false
var is_email_valid = false

var email_regex = RegEx.new()


func _ready():
	# Initialize email regex
	email_regex.compile("^[a-zA-Z_]+@[a-zA-Z_]+\\.[a-zA-Z]+$")
	
	
func validate_inputs():
	# If all inputs are valid, enable the create account button. Otherwise,
	# disable it.
	var enable = is_username_valid and is_password_valid and is_email_valid
	get_node("Panel/Buttons/CreateAccountButton").set_disabled(not enable)


func _on_Username_text_changed(text):
	# Is the new username not empty
	is_username_valid = (text.length() > 0)
	validate_inputs()


func _on_Password_text_changed(text):
	# Is the password not empty and equal to the confirm password?
	var confirm_pswd = get_node("Panel/Inputs/TextInputs/ConfirmPassword").get_text()
	is_password_valid = (text.length() > 0 and text == confirm_pswd)
	validate_inputs()


func _on_ConfirmPassword_text_changed(text):
	# Is the confirm password not empty and equal to the confirm password?
	var pswd = get_node("Panel/Inputs/TextInputs/Password").get_text()
	is_password_valid = (text.length() > 0 and pswd == text)
	validate_inputs()


func _on_Email_text_changed(text):
	# Is the email address valid?
	is_email_valid = (email_regex.find(text) > -1)
	validate_inputs()


func _on_CreateAccountButton_pressed():
	Logger.log_info("CreateAccountScreen", "Creating account...")
	
	var username = get_node("Panel/Inputs/TextInputs/Username").get_text()
	var password = get_node("Panel/Inputs/TextInputs/Password").get_text()
	var confirm_password = get_node("Panel/Inputs/TextInputs/ConfirmPassword").get_text()
	var email = get_node("Panel/Inputs/TextInputs/Email").get_text()
	emit_signal("create_account", username, password, confirm_password, email)


func _on_BackButton_pressed():
	Logger.log_info("CreateAccountScreen", "Returning to login screen...")
	emit_signal("back")
