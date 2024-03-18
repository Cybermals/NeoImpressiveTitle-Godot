extends Control

signal send_message(type, message)
signal set_home
signal go_home
signal reset_home
signal set_dimension(id)
signal save_bio(text)
signal message_friend(name)
signal locate_friend(name)
signal remove_friend(name)
signal unblock_user(name)
signal stash_item(name)
signal drop_item(name)
signal delete_item(name)
signal equip_item(name)
signal set_primary_action(name)
signal set_secondary_action(name)
signal set_emote(name)
signal leave_party

export (Color) var general_chat_color
export (Color) var local_chat_color
export (Color) var party_chat_color
export (Color) var whisper_chat_color
export (Color) var system_chat_color
export (ImageTexture) var OnlineIcon
export (ImageTexture) var OfflineIcon

enum ChatMode {
    General,
    Local,
    Party,
    Whisper,
    System
}
enum FriendCmd {
    Message,
    Where,
    Remove
}
enum BlockCmd {
    Remove
}
enum ItemCmd {
    Stash,
    Drop,
    Delete
}
enum StashCmd {
    Equip
}

var is_bio_modified = false


func _ready():
	# Fill the chat history with sample data
	add_chat_text(ChatMode.General, "DylanCheetah", "General Chat")
	add_chat_text(ChatMode.Local, "DylanCheetah", "Local Chat")
	add_chat_text(ChatMode.Party, "DylanCheetah", "Party Chat")
	add_chat_text(ChatMode.Whisper, "DylanCheetah", "Whisper Chat")
	add_chat_text(ChatMode.System, "", "System Message")
	
	# Fill friend and block lists with sample data
	for i in range(20):
		get_node("FriendsDialog/FriendList").add_item("Friend {0}".format([i]), OnlineIcon if i % 4 else OfflineIcon)
		
	for i in range(20):
		get_node("FriendsDialog/BlockList").add_item("Enemy {0}".format([i]))
		
	# Fill item list with sample data
	for i in range(20):
		get_node("ItemsDialog/Items").add_item("Item {0}".format([i]))
		
	# Fill stash item list with sample data
	for i in range(20):
		get_node("StashDialog/Stash").add_item("Stashed Item {0}".format([i]))
		
	# Fill party list with sample data
	for i in range(20):
		get_node("PartyDialog/Party").add_item("Party Member {0}".format([i]))
	
	
func show_chat():
	# Hide the show chat button and show the chat box
	get_node("ShowChatButton").hide()
	get_node("ChatBox").show()
	
	
func hide_chat():
	# Hide the chat box and show the show chat button
	get_node("ChatBox").hide()
	get_node("ShowChatButton").show()
	
	
func add_chat_text(mode, user, text):
	# Choose text color based on chat mode
	var color
	
	if mode == ChatMode.General:
		color = general_chat_color
	
	elif mode == ChatMode.Local:
		color = local_chat_color
		
	elif mode == ChatMode.Party:
		color = party_chat_color
		
	elif mode == ChatMode.Whisper:
		color = whisper_chat_color
		
	elif mode == ChatMode.System:
		color = system_chat_color
		
	# Set the text color and add the text followed by a new line
	get_node("ChatBox/ChatHistoryPanel/ChatHistory").push_color(color)
	
	if mode == ChatMode.System:
		get_node("ChatBox/ChatHistoryPanel/ChatHistory").add_text(text)
		
	else:
		get_node("ChatBox/ChatHistoryPanel/ChatHistory").add_text("<{0}> {1}".format([user, text]))
		
	get_node("ChatBox/ChatHistoryPanel/ChatHistory").newline()
	get_node("ChatBox/ChatHistoryPanel/ChatHistory").pop()
	
	
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
	# Toggle actions and emotes dialog visibility
	if get_node("ActionsAndEmotesDialog").is_visible():
		get_node("ACtionsAndEmotesDialog").hide()
		
	else:
		get_node("ActionsAndEmotesDialog").show()


func _on_PartyButton_pressed():
	# Toggle party dialog visiblity
	if get_node("PartyDialog").is_visible():
		get_node("PartyDialog").hide()
		
	else:
		get_node("PartyDialog").show()


func _on_StashButton_pressed():
	# Toggle stash dialog visibility
	if get_node("StashDialog").is_visible():
		get_node("StashDialog").hide()
		
	else:
		get_node("StashDialog").show()


func _on_SetHomeButton_pressed():
	Logger.log_info("HUD", "Setting home...")
	emit_signal("set_home")


func _on_GoHomeButton_pressed():
	Logger.log_info("HUD", "Going home...")
	emit_signal("go_home")


func _on_ResetHomeButton_pressed():
	Logger.log_info("HUD", "Resetting home...")
	emit_signal("reset_home")


func _on_Dimension_item_selected(ID):
	Logger.log_info("HUD", "Switching to dimension {0}...".format([ID]))
	emit_signal("set_dimension", ID)


func _on_Bio_text_changed():
	# Set bio modification flag
	is_bio_modified = true


func _on_BioDialog_hide():
	# Is the bio text modified?
	if is_bio_modified:
		# Save the modified bio
		Logger.log_info("HUD", "Saving bio...")
		var text = get_node("BioDialog/Bio").get_text()
		emit_signal("save_bio", text)
		
		# Clear bio modification flag
		is_bio_modified = false


func _on_FriendList_item_selected(index):
	# Display the friend list context menu at the mouse position
	var mouse_pos = get_global_mouse_pos()
	get_node("FriendsDialog/FriendCtxMenu").set_global_pos(mouse_pos)
	get_node("FriendsDialog/FriendCtxMenu").popup()


func _on_BlockList_item_selected(index):
	# Display the block list context menu at the mouse position
	var mouse_pos = get_global_mouse_pos()
	get_node("FriendsDialog/BlockCtxMenu").set_global_pos(mouse_pos)
	get_node("FriendsDialog/BlockCtxMenu").popup()


func _on_FriendCtxMenu_item_pressed(ID):
	# Get selected friend
	var idx = get_node("FriendsDialog/FriendList").get_selected_items()[0]
	var friend = get_node("FriendsDialog/FriendList").get_item_text(idx)
	
	# Message friend?
	if ID == FriendCmd.Message:
		Logger.log_info("HUD", "Messaging friend {0}...".format([friend]))
		emit_signal("message_friend", friend)
		
	# Get friend location?
	elif ID == FriendCmd.Where:
		Logger.log_info("HUD", "Getting location of {0}...".format([friend]))
		emit_signal("locate_friend", friend)
		
	# Remove friend
	elif ID == FriendCmd.Remove:
		Logger.log_info("HUD", "Removing friend {0}...".format([friend]))
		emit_signal("remove_friend", friend)


func _on_BlockCtxMenu_item_pressed(ID):
	# Get selected blocked user
	var idx = get_node("FriendsDialog/BlockList").get_selected_items()[0]
	var user = get_node("FriendsDialog/BlockList").get_item_text(idx)
	
	# Remove blocked user
	if ID == BlockCmd.Remove:
		Logger.log_info("HUD", "Unblocking {0}...".format([user]))
		emit_signal("unblock_user", user)


func _on_Items_item_selected(index):
	# Display item context menu at mouse position
	var mouse_pos = get_global_mouse_pos()
	get_node("ItemsDialog/ItemCtxMenu").set_global_pos(mouse_pos)
	get_node("ItemsDialog/ItemCtxMenu").popup()


func _on_ItemCtxMenu_item_pressed(ID):
	# Get selected item
	var idx = get_node("ItemsDialog/Items").get_selected_items()[0]
	var item = get_node("ItemsDialog/Items").get_item_text(idx)
	
	# Stash item?
	if ID == ItemCmd.Stash:
		Logger.log_info("HUD", "Stashing item {0}...".format([item]))
		emit_signal("stash_item", item)
		
	# Drop item?
	elif ID == ItemCmd.Drop:
		Logger.log_info("HUD", "Dropping item {0}...".format([item]))
		emit_signal("drop_item", item)
		
	# Delete item?
	elif ID == ItemCmd.Delete:
		Logger.log_info("HUD", "Deleting item {0}...".format([item]))
		emit_signal("delete_item", item)


func _on_Stash_item_selected(index):
	# Display stash context menu at mouse position
	var mouse_pos = get_global_mouse_pos()
	get_node("StashDialog/StashCtxMenu").set_global_pos(mouse_pos)
	get_node("StashDialog/StashCtxMenu").popup()


func _on_StashCtxMenu_item_pressed(ID):
	# Get selected stash item
	var idx = get_node("StashDialog/Stash").get_selected_items()[0]
	var item = get_node("StashDialog/Stash").get_item_text(idx)
	
	# Equip item?
	if ID == StashCmd.Equip:
		Logger.log_info("HUD", "Equipping item {0}...".format([item]))
		emit_signal("equip_item", item)


func _on_PrimaryAction_item_selected(ID):
	# Set the primary action
	var action = get_node("ActionsAndEmotesDialog/ActionsAndEmotes/PrimaryAction").get_item_text(ID)
	Logger.log_info("HUD", "Setting primary action to {0}...".format([action]))
	emit_signal("set_primary_action", action)


func _on_SecondaryAction_item_selected(ID):
	# Set the secondary action
	var action = get_node("ActionsAndEmotesDialog/ActionsAndEmotes/SecondaryAction").get_item_text(ID)
	Logger.log_info("HUD", "Setting secondary action to {0}...".format([action]))
	emit_signal("set_secondary_action", action)


func _on_Emote_item_selected(ID):
	# Set the emote
	var emote = get_node("ActionsAndEmotesDialog/ActionsAndEmotes/Emote").get_item_text(ID)
	Logger.log_info("HUD", "Setting emote to {0}...".format([emote]))
	emit_signal("set_emote", emote)


func _on_LeavePartyButton_pressed():
	Logger.log_info("HUD", "Leaving current party...")
	emit_signal("leave_party")
