tool
extends ConfirmationDialog


func _ready():
	pass
	
	
func set_source_path(path):
	get_node("SourceDialog").set_current_path(path)
	
	
func get_source_path():
	return get_node("SourceDialog").get_current_path()
	
	
func set_dest_path(path):
	get_node("DestDialog").set_current_path(path)
	
	
func get_dest_path():
	return get_node("DestDialog").get_current_path()


func _on_SourceButton_pressed():
	get_node("SourceDialog").popup_centered()


func _on_DestButton_pressed():
	get_node("DestDialog").popup_centered()
	
	
func _on_SourceDialog_file_selected(path):
	get_node("Content/Inputs/Source").set_text(path)


func _on_DestDialog_file_selected(path):
	get_node("Content/Inputs/Destination").set_text(path)
