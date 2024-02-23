extends Control

signal back
signal start_campaign(campaign)


func _ready():
	# Initialize the campaign list
	for i in range(25):
		get_node("Panel/CampaignList").add_item("Campaign {0}".format([i]))
		
		
func _on_CampaignList_item_selected(index):
	# Enable start button
	get_node("Panel/StartButton").set_disabled(false)


func _on_BackButton_pressed():
	Logger.log_info("CampaignScreen", "Returing to title screen...")
	emit_signal("back")


func _on_StartButton_pressed():
	var campaign_id = get_node("Panel/CampaignList").get_selected_items()[0]
	var campaign = get_node("Panel/CampaignList").get_item_text(campaign_id)
	Logger.log_info("CampaignScreen", "Starting campaign '{0}'...".format([campaign]))
	emit_signal("start_campaign", campaign)
