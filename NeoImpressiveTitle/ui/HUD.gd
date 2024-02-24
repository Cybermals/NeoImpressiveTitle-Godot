extends Control

signal send_message(type, message)


func _ready():
	pass
	
	
func show_chat():
	# Hide the show chat button and show the chat box
	get_node("ShowChatButton").hide()
	get_node("ChatBox").show()
	
	
func hide_chat():
	# Hide the chat box and show the show chat button
	get_node("ChatBox").hide()
	get_node("ShowChatButton").show()
	
	
func send_message():
	# Send the message, clear the chat input, and remove focus from the chat
	# input
	var type = get_node("ChatBox/ChatMode").get_selected()
	var message = get_node("ChatBox/ChatInputPanel/ChatInput").get_text()
	emit_signal("send_message", type, message)
	get_node("ChatBox/ChatInputPanel/ChatInput").clear()
	get_node("ChatBox/ChatInputPanel/ChatInput").notification(Control.NOTIFICATION_FOCUS_EXIT)


func _on_ShowChatButton_pressed():
	show_chat()


func _on_HideChatButton_pressed():
	hide_chat()


func _on_SayButton_pressed():
	send_message()


func _on_ChatInput_text_entered(text):
	send_message()
