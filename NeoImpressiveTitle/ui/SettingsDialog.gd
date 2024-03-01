extends Control

signal save(data)


func _ready():
	pass
	
	
func load_settings(data):
	# Load all settings
	get_node("Panel/ScrollContainer/Inputs/Music/MusicVolume").set_value(data["musicVolume"])
	get_node("Panel/ScrollContainer/Inputs/GUISound/GUISoundVolume").set_value(data["guiSoundVolume"])
	get_node("Panel/ScrollContainer/Inputs/Sound/SoundVolume").set_value(data["soundVolume"])
	get_node("Panel/ScrollContainer/Inputs/Shadows").set_pressed(data["shadows"])
	get_node("Panel/ScrollContainer/Inputs/BloomEffect").set_pressed(data["bloomEffect"])
	get_node("Panel/ScrollContainer/Inputs/PagedGeometry").set_pressed(data["pagedGeometry"])
	get_node("Panel/ScrollContainer/Inputs/ViewDistance/ViewDistance").set_value(data["viewDistance"])
	get_node("Panel/ScrollContainer/Inputs/UseTablet").set_pressed(data["useTablet"])
	get_node("Panel/ScrollContainer/Inputs/MouseSensitivity/MouseSensitivity").set_value(data["mouseSensitivity"])
	get_node("Panel/ScrollContainer/Inputs/GeneralNameDisplay/GeneralNameDisplay").select(data["generalNameDisplay"])
	get_node("Panel/ScrollContainer/Inputs/LocalNameDisplay/LocalNameDisplay").select(data["localNameDisplay"])
	get_node("Panel/ScrollContainer/Inputs/ChannelButtonBlink").set_pressed(data["channelButtonBlink"])
	get_node("Panel/ScrollContainer/Inputs/RunMode/RunMode").select(data["runMode"])
	get_node("Panel/ScrollContainer/Inputs/DoubleJump").set_pressed(data["doubleJump"])
	get_node("Panel/ScrollContainer/Inputs/AutoLipsync").set_pressed(data["autoLipSync"])
	get_node("Panel/ScrollContainer/Inputs/UseWindowCursor").set_pressed(data["useWindowCursor"])
	
	
func save_settings():
	# Get all settings
	var data = {
	    "musicVolume": get_node("Panel/ScrollContainer/Inputs/Music/MusicVolume").get_value(),
	    "guiSoundVolume": get_node("Panel/ScrollContainer/Inputs/GUISound/GUISoundVolume").get_value(),
	    "soundVolume": get_node("Panel/ScrollContainer/Inputs/Sound/SoundVolume").get_value(),
	    "shadows": get_node("Panel/ScrollContainer/Inputs/Shadows").is_pressed(),
	    "bloomEffect": get_node("Panel/ScrollContainer/Inputs/BloomEffect").is_pressed(),
	    "pagedGeometry": get_node("Panel/ScrollContainer/Inputs/PagedGeometry").is_pressed(),
	    "viewDistance": get_node("Panel/ScrollContainer/Inputs/ViewDistance/ViewDistance").get_value(),
	    "useTablet": get_node("Panel/ScrollContainer/Inputs/UseTablet").is_pressed(),
	    "mouseSensitivity": get_node("Panel/ScrollContainer/Inputs/MouseSensitivity/MouseSensitivity").get_value(),
	    "generalNameDisplay": get_node("Panel/ScrollContainer/Inputs/GeneralNameDisplay/GeneralNameDisplay").get_selected(),
	    "localNameDisplay": get_node("Panel/ScrollContainer/Inputs/LocalNameDisplay/LocalNameDisplay").get_selected(),
	    "channelButtonBlink": get_node("Panel/ScrollContainer/Inputs/ChannelButtonBlink").is_pressed(),
	    "runMode": get_node("Panel/ScrollContainer/Inputs/RunMode/RunMode").get_selected(),
	    "doubleJump": get_node("Panel/ScrollContainer/Inputs/DoubleJump").is_pressed(),
	    "autoLipSync": get_node("Panel/ScrollContainer/Inputs/AutoLipsync").is_pressed(),
	    "useWindowCursor": get_node("Panel/ScrollContainer/Inputs/UseWindowCursor").is_pressed()
	}
	
	# Save the data
	emit_signal("save", data)


func _on_SaveButton_pressed():
	Logger.log_info("SettingsDialog", "Saving settings...")
	save_settings()
