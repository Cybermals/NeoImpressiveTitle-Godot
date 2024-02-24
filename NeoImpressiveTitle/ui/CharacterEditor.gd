extends Control

signal back
signal delete
signal save(data)


func _ready():
	pass


func _on_Size_value_changed(value):
	get_node("Panel/TabContainer/Size/SizeView").set_text(str(value))


func _on_BackButton_pressed():
	Logger.log_info("CharacterEditor", "Returning to character select screen...")
	emit_signal("back")
	
	
func _on_DeleteButton_pressed():
	Logger.log_info("CharacterEditor", "Deleting character...")
	emit_signal("delete")


func _on_SaveButton_pressed():
	Logger.log_info("CharacterEditor", "Saving character...")
	
	# Collect character data and save the character
	var data = {
	    "shape": {
	        "body": get_node("Panel/TabContainer/Shape/Body").get_selected(),
	        "head": get_node("Panel/TabContainer/Shape/Head").get_selected(),
	        "mane": get_node("Panel/TabContainer/Shape/Mane").get_selected(),
	        "tail": get_node("Panel/TabContainer/Shape/Tail").get_selected(),
	        "wings": get_node("Panel/TabContainer/Shape/Wings").get_selected(),
	        "tufts": get_node("Panel/TabContainer/Shape/Tufts").get_selected()
	    },
	    "markings": {
	        "head": get_node("Panel/TabContainer/Markings/Inputs/HeadMarkings").get_selected(),
	        "body": get_node("Panel/TabContainer/Markings/Inputs/BodyMarkings").get_selected(),
	        "tail": get_node("Panel/TabContainer/Markings/Inputs/TailMarkings").get_selected()
	    },
	    "colors": {
	        "pelt": get_node("Panel/TabContainer/Colors/Inputs/PeltColor").get_color().to_html(),
	        "underfur": get_node("Panel/TabContainer/Colors/Inputs/UnderfurColor").get_color().to_html(),
	        "nose": get_node("Panel/TabContainer/Colors/Inputs/NoseColor").get_color().to_html(),
	        "above_eyes": get_node("Panel/TabContainer/Colors/Inputs/AboveEyesColor").get_color().to_html(),
	        "below_eyes": get_node("Panel/TabContainer/Colors/Inputs/BelowEyesColor").get_color().to_html(),
	        "ears": get_node("Panel/TabContainer/Colors/Inputs/EarColor").get_color().to_html(),
	        "tailtip": get_node("Panel/TabContainer/Colors/Inputs/TailtipColor").get_color().to_html(),
	        "eyes": get_node("Panel/TabContainer/Colors/Inputs/EyeColor").get_color().to_html()
	    },
	    "size": get_node("Panel/TabContainer/Size/Size").get_value()
	}
	emit_signal("save", data)
