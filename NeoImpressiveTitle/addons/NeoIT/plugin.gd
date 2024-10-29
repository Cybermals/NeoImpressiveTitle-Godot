tool
extends EditorPlugin

const MapImporter = preload("MapImporter/MapImporter.gd")

var map_importer


func _enter_tree():
	map_importer = MapImporter.new(get_base_control())
	add_import_plugin(map_importer)
	
	
func _exit_tree():
	remove_import_plugin(map_importer)
