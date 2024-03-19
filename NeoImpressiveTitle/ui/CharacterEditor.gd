extends Control

signal back
signal delete
signal save(data)


func _ready():
	# Test character data loading code
	# load_character({"size":1.2, "markings":{"body":13, "tail":5, "head":8}, "shape":{"tufts":7, "body":0, "wings":1, "mane":5, "tail":5, "head":1}, "name":"DylanCheetah", "colors":{"ears":"ffff9eed", "underfur":"ffffffff", "markings":"ff000000", "nose":"ffff97ee", "pelt":"ffffe300", "eyes":"ffffacfb", "below_eyes":"ffffb900", "tailtip":"ff000000", "above_eyes":"ffffe300"}})
	pass


func _on_Size_value_changed(value):
	get_node("Panel/TabContainer/Size/SizeView").set_text(str(value))


func _on_BackButton_pressed():
	Logger.log_info("CharacterEditor", "Returning to character select screen...")
	emit_signal("back")
	
	
func _on_DeleteButton_pressed():
	Logger.log_info("CharacterEditor", "Deleting character...")
	emit_signal("delete")
	
	
func load_character(data):
	Logger.log_info("CharacterEditor", "Loading character...")
	
	# Set input values
	get_node("Panel/CharacterName").set_text(data["name"])
	get_node("Panel/TabContainer/Shape/Body").select(data["shape"]["body"])
	get_node("Panel/TabContainer/Shape/Head").select(data["shape"]["head"])
	get_node("Panel/TabContainer/Shape/Mane").select(data["shape"]["mane"])
	get_node("Panel/TabContainer/Shape/Tail").select(data["shape"]["tail"])
	get_node("Panel/TabContainer/Shape/Wings").select(data["shape"]["wings"])
	get_node("Panel/TabContainer/Shape/Tufts").select(data["shape"]["tufts"])
	get_node("Panel/TabContainer/Markings/Inputs/HeadMarkings").select(data["markings"]["head"])
	get_node("Panel/TabContainer/Markings/Inputs/BodyMarkings").select(data["markings"]["body"])
	get_node("Panel/TabContainer/Markings/Inputs/TailMarkings").select(data["markings"]["tail"])
	get_node("Panel/TabContainer/Colors/Content/Inputs/PeltColor").set_color(Color(data["colors"]["pelt"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/UnderfurColor").set_color(Color(data["colors"]["underfur"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/NoseColor").set_color(Color(data["colors"]["nose"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/AboveEyesColor").set_color(Color(data["colors"]["above_eyes"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/BelowEyesColor").set_color(Color(data["colors"]["below_eyes"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/EarColor").set_color(Color(data["colors"]["ears"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/TailtipColor").set_color(Color(data["colors"]["tailtip"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/EyeColor").set_color(Color(data["colors"]["eyes"]))
	get_node("Panel/TabContainer/Colors/Content/Inputs/MarkingsColor").set_color(Color(data["colors"]["markings"]))
	get_node("Panel/TabContainer/Size/Size").set_value(data["size"])


func save_character():
	Logger.log_info("CharacterEditor", "Saving character...")
	
	# Collect character data and save the character
	var data = {
	    "name": get_node("Panel/CharacterName").get_text(),
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
	        "pelt": get_node("Panel/TabContainer/Colors/Content/Inputs/PeltColor").get_color().to_html(),
	        "underfur": get_node("Panel/TabContainer/Colors/Content/Inputs/UnderfurColor").get_color().to_html(),
	        "nose": get_node("Panel/TabContainer/Colors/Content/Inputs/NoseColor").get_color().to_html(),
	        "above_eyes": get_node("Panel/TabContainer/Colors/Content/Inputs/AboveEyesColor").get_color().to_html(),
	        "below_eyes": get_node("Panel/TabContainer/Colors/Content/Inputs/BelowEyesColor").get_color().to_html(),
	        "ears": get_node("Panel/TabContainer/Colors/Content/Inputs/EarColor").get_color().to_html(),
	        "tailtip": get_node("Panel/TabContainer/Colors/Content/Inputs/TailtipColor").get_color().to_html(),
	        "eyes": get_node("Panel/TabContainer/Colors/Content/Inputs/EyeColor").get_color().to_html(),
	        "markings": get_node("Panel/TabContainer/Colors/Content/Inputs/MarkingsColor").get_color().to_html()
	    },
	    "size": get_node("Panel/TabContainer/Size/Size").get_value()
	}
	emit_signal("save", data)
	
	
func _on_SaveButton_pressed():
	save_character()
