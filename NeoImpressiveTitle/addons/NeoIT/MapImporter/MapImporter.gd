tool
extends EditorImportPlugin

const MapImportDialog = preload("MapImportDialog.tscn")
const ErrorDialog = preload("ErrorDialog.tscn")

var map_import_dlg = null
var error_dlg = null


func _init(base_control):
	# Create map import dialog
	map_import_dlg = MapImportDialog.instance()
	map_import_dlg.connect("confirmed", self, "_on_MapImportDialog_confirmed")
	base_control.add_child(map_import_dlg)
	
	# Create error dialog
	error_dlg = ErrorDialog.instance()
	base_control.add_child(error_dlg)


static func get_name():
	return "it_map"


func get_visible_name():
	return "IT Map"
	
	
func can_reimport_multiple_files():
	return false
	
	
func import_dialog(from):
	# Display import dialog
	# print("Importing '{0}'...".format([from]))
	map_import_dlg.set_source_path(from)
	map_import_dlg.popup_centered()
	
	
func import(path, from):
	# If the resource is loaded, resuse it. Otherwise, create a new resource.
	var res
	
	if ResourceLoader.has(path):
		res = load(path)
		
	else:
		res = PackedScene.new()
		
	# Create root node
	var root = Spatial.new()
	root.set_name(from.get_source_path(0).get_file().replace(".world", ""))
	
	# Load world file sections
	var world = File.new()
	var sections
	
	if world.open(from.get_source_path(0), File.READ):
		error_dlg.set_text("Failed to open '{0}'.".format([from.get_source_path(0)]))
		error_dlg.popup_centered()
		return
		
	sections = world.get_as_text().split("[", false)
	# print(sections)
	
	# Parse world file sections
	for section in sections:
		# Parse section
		var lines = section.split("\n")
		
		# Terrain?
		if lines[0].begins_with("Initialize"):
			var terrain_name = from.get_source_path(0).get_file().replace(".world", "")
			var Terrain = load("res://meshes/terrain/{0}.scn".format([terrain_name]))
			var size = load_terrain_config("{0}/{1}".format([from.get_source_path(0).get_base_dir(), lines[1]]))
			
			if size == null:
				error_dlg.set_text("Failed to open '{0}'.".format([lines[1]]))
				error_dlg.popup_centered()
				return
			
			var terrain = Terrain.instance()
			terrain.set_scale(size)
			root.add_child(terrain)
			terrain.set_owner(root)
			
	# Set import metadata
	res.set_import_metadata(from)
			
	# Save imported map
	res.pack(root)
	
	if ResourceSaver.save(path, res):
		error_dlg.set_text("Failed to save '{0}'.".format([path]))
		error_dlg.popup_centered()
	
	
func load_terrain_config(path):
	# Parse terrain config
	var file = File.new()
	
	if file.open(path, File.READ):
		return null
		
	var line = file.get_line()
	var size = Vector3(1, 1, 1)
	
	while not file.eof_reached():
		# World size X
		if line.begins_with("PageWorldX"):
			size.x = float(line.split("=")[1]) / 10
			
		# World size Z
		elif line.begins_with("PageWorldZ"):
			size.z = float(line.split("=")[1]) / 10
			
		# Maximum terrain height
		elif line.begins_with("MaxHeight"):
			size.y = float(line.split("=")[1])
			
		# Get next line
		line = file.get_line()
			
	return size
	
	
func _on_MapImportDialog_confirmed():
	# print("Source: {0}\nDest: {1}".format([map_import_dlg.get_source_path(), map_import_dlg.get_dest_path()]))
	
	# Build import metadata
	var file = File.new()
	var path = map_import_dlg.get_source_path()
	var rmd = ResourceImportMetadata.new()
	rmd.set_editor("it_map")
	rmd.add_source(path, file.get_md5(path))
	
	# Import map
	import(map_import_dlg.get_dest_path(), rmd)
