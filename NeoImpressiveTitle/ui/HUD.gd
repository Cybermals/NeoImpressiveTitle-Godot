extends Control

signal send_message(type, message)

export (ImageTexture) var OnlineIcon
export (ImageTexture) var OfflineIcon


func _ready():
	# Fill friend and block lists with sample data
	for i in range(20):
		get_node("FriendsDialog/FriendList").add_item("Friend {0}".format([i]), OnlineIcon if i % 4 else OfflineIcon)
		
	for i in range(20):
		get_node("FriendsDialog/BlockList").add_item("Enemy {0}".format([i]))
		
	# Fill item list with sample data
	for i in range(20):
		get_node("ItemsDialog/ItemList").add_item("Item {0}".format([i]))
		
	# Fill stash item list with sample data
	for i in range(20):
		get_node("StashDialog/ItemList").add_item("Stashed Item {0}".format([i]))
	
	
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


func _on_HomeButton_pressed():
	# Toggle home dialog visibility
	if get_node("HomeDialog").is_visible():
		get_node("HomeDialog").hide()
		
	else:
		get_node("HomeDialog").show()


func _on_BioButton_pressed():
	# Toggle bio dialog visibility
	if get_node("BioDialog").is_visible():
		get_node("BioDialog").hide()
		
	else:
		get_node("BioDialog").show()


func _on_FriendsButton_pressed():
	# Toggle friends dialog visibility
	if get_node("FriendsDialog").is_visible():
		get_node("FriendsDialog").hide()
		
	else:
		get_node("FriendsDialog").show()


func _on_ItemsButton_pressed():
	# Toggle items dialog visibility
	if get_node("ItemsDialog").is_visible():
		get_node("ItemsDialog").hide()
		
	else:
		get_node("ItemsDialog").show()


func _on_ActionsButton_pressed():
	pass # replace with function body


func _on_PartyButton_pressed():
	pass # replace with function body


func _on_StashButton_pressed():
	# Toggle stash dialog visibility
	if get_node("StashDialog").is_visible():
		get_node("StashDialog").hide()
		
	else:
		get_node("StashDialog").show()
