tool
extends EditorImportPlugin

const MapImportDialog = preload("MapImportDialog.tscn")
const ErrorDialog = preload("ErrorDialog.tscn")
const default_env = preload("res://environments/Default.tres")
const TerrainScript = preload("res://maps/Terrain.gd")
const MapPortal = preload("res://objects/Portal.tscn")
const portal_material = preload("res://meshes/scenery/materials/Portal.tres")
const Gate = preload("res://objects/Gate.tscn")
const WaterPlane = preload("res://objects/WaterPlane.tscn")
const IcePlane = preload("res://objects/IcePlane.tscn")
const Ceiling = preload("res://meshes/scenery/Ceiling.scn")
const Billboard = preload("res://objects/Billboard.tscn")
const SphereWall = preload("res://objects/SphereWall.tscn")
const BoxWall = preload("res://objects/BoxWall.tscn")
const CollBox = preload("res://objects/CollBox.tscn")
const CollSphere = preload("res://objects/CollSphere.tscn")

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
	
	# Add default environment
	var env = WorldEnvironment.new()
	env.set_environment(default_env)
	root.add_child(env)
	env.set_owner(root)
	
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
	var foliage = {}
	
	for section in sections:
		# Parse section
		var lines = section.split("\n")
		var heightmap
		var terrain_size
		
		# Terrain?
		if lines[0].begins_with("Initialize"):
			var terrain_name = from.get_source_path(0).get_file().replace(".world", "")
			var Terrain = load("res://meshes/terrain/{0}.scn".format([terrain_name]))
			var config = load_terrain_config("{0}/{1}".format([from.get_source_path(0).get_base_dir(), lines[1]]))
			var heightmap_name = config["heightmap"]
			heightmap = load("res://private/meshes/terrain/images/{0}".format([heightmap_name]))
			print(heightmap)
			terrain_size = config["size"]
			var material = config["material"]
			var spawn_pos = lines[4].split_floats(" ")
			
			if terrain_size == null:
				error_dlg.set_text("Failed to open '{0}'.".format([lines[1]]))
				error_dlg.popup_centered()
				return
			
			var terrain = Terrain.instance()
			terrain.set_name("Terrain")
			terrain.set_translation(Vector3(terrain_size.x / 2, terrain_size.y / 20, terrain_size.z / 2))
			terrain.set_scale(Vector3(terrain_size.x / 2, terrain_size.y / 2, terrain_size.z / 2))
			terrain.set_script(TerrainScript)
			terrain.material = material
			root.add_child(terrain)
			terrain.set_owner(root)
			
			var spawn_point = Position3D.new()
			spawn_point.set_name("SpawnPoint")
			spawn_point.set_translation(Vector3(spawn_pos[0], spawn_pos[2], spawn_pos[1]) / 10)
			root.add_child(spawn_point)
			spawn_point.set_owner(root)
			
		# Portal?
		elif lines[0].begins_with("Portal"):
			var pos = lines[1].split_floats(" ")
			var size = float(lines[2])
			var destination = lines[3]
			var portal = MapPortal.instance()
			portal.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			portal.set_scale(Vector3(size, size, size) / 10)
			portal.material = portal_material
			portal.destination = destination
			root.add_child(portal)
			portal.set_owner(root)
			
		# Gate?
		elif lines[0].begins_with("Gate"):
			var mat_name = lines[1]
			var pos = lines[2].split_floats(" ")
			var destination = lines[3]
			var dest_pos = lines[4].split_floats(" ")
			var dest_vec = Vector3(dest_pos[0], 0, dest_pos[1]) if dest_pos.size() == 2 else Vector3(dest_pos[0], dest_pos[1], dest_pos[2])
			var gate = Gate.instance()
			gate.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			gate.set_scale(Vector3(4, 4, 4))
			gate.material = load("res://objects/materials/{0}.tres".format([mat_name]))
			gate.destination = destination
			gate.dest_vec = dest_vec
			root.add_child(gate)
			gate.set_owner(root)
			
		# Water Plane?
		elif lines[0].begins_with("WaterPlane"): # TODO: Load material and sound
			var pos = lines[1].split_floats(" ")
			var scaleX = float(lines[2])
			var scaleZ = float(lines[3])
			var mat_name = lines[4] if lines.size() > 4 else ""
			var sound = lines[5] if lines.size() > 5 else ""
			var is_solid = (lines.size() > 6 and lines[6] == "true")
			var plane = IcePlane.instance() if is_solid else WaterPlane.instance()
			plane.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			plane.set_scale(Vector3(scaleX * 10, 1, scaleZ * 10))
			root.add_child(plane)
			plane.set_owner(root)
			
		# Object?
		elif lines[0].begins_with("Object"): # TODO: Load material and sound
			var object_name = lines[1].replace(".mesh", "")
			var pos = lines[2].split_floats(" ")
			var scale = lines[3].split_floats(" ")
			var rot = lines[4].split_floats(" ")
			var sound = lines[5] if lines.size() > 5 else ""
			var mat_name = lines[6] if lines.size() > 6 else ""
			var MapObject = load("res://meshes/scenery/{0}.scn".format([object_name]))
			
			if MapObject == null:
				continue
				
			var obj = MapObject.instance()
			obj.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			obj.set_scale(Vector3(scale[0], scale[1], scale[2]) / 10)
			obj.set_rotation_deg(Vector3(rot[0], rot[1], rot[2]))
			root.add_child(obj)
			obj.set_owner(root)
			
		# Particle System?
		elif lines[0].begins_with("Particle"): # TODO: Load sound
			var particle_name = lines[1].replace(".particle", "")
			var pos = lines[2].split_floats(" ")
			var sound = lines[3] if lines.size() > 3 else ""
			var MapParticle = load("res://particles/{0}.tscn".format([particle_name]))
			
			if MapParticle == null:
				continue
				
			var particle = MapParticle.instance()
			particle.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			root.add_child(particle)
			particle.set_owner(root)
			
		elif lines[0].begins_with("WeatherCycle"):
			var weather_name = lines[1]
			# TODO: Load the weather cycle. Maybe use AnimationPlayer?
			
		elif lines[0].begins_with("Interior"): # TODO: Load material and sky color
			var ceiling_height = float(lines[1])
			var mat_name = lines[2]
			var sky_color = lines[3].split_floats(" ")
			var ceiling = Ceiling.instance()
			ceiling.set_scale(Vector3(terrain_size.x / 2, 1, terrain_size.z))
			root.add_child(ceiling)
			ceiling.set_owner(root)
			
		elif lines[0].begins_with("Light"):
			var pos = lines[1].split_floats(" ")
			var color = lines[2].split_floats(" ")
			var light = OmniLight.new()
			light.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			light.set_color(Light.COLOR_DIFFUSE, Color(color[0], color[1], color[2]))
			root.add_child(light)
			light.set_owner(root)
			
		elif lines[0].begins_with("Billboard"): # TODO: Load material
			var pos = lines[1].split_floats(" ")
			var scale = lines[2].split_floats(" ")
			var mat_name = lines[3]
			var billboard = Billboard.instance()
			billboard.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			billboard.set_scale(Vector3(scale[0], scale[1], 1) / 10)
			root.add_child(billboard)
			billboard.set_owner(root)
			
		elif lines[0].begins_with("SphereWall"): # TODO: Need to implement inverted sphere collisions
			var pos = lines[1].split_floats(" ")
			var radius = float(lines[2])
			var is_inside = (lines[3] == "true")
			var sphere_wall = SphereWall.instance()
			sphere_wall.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			sphere_wall.set_scale(Vector3(radius, radius, radius) / 10)
			root.add_child(sphere_wall)
			sphere_wall.set_owner(root)
			
		elif lines[0].begins_with("BoxWall"): # TODO: Need to implement inverted box collisions
			var pos = lines[1].split_floats(" ")
			var size = lines[2].split_floats(" ")
			var is_inside = (lines[3] == "true")
			var box_wall = BoxWall.instance()
			box_wall.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			box_wall.set_scale(Vector3(size[0], size[1], size[2]) / 10)
			root.add_child(box_wall)
			box_wall.set_owner(root)
			
		elif lines[0].begins_with("MapEffect"): # TODO: Need to implement this somehow
			var map_effect = lines[1]
			
		elif lines[0].begins_with("Grass"): # TODO: Need to implement this
			var mat_name = lines[1]
			var grass_map = lines[2]
			var grass_color_map = lines[3]
			
		elif lines[0].begins_with("RandomTrees"):
			var trees = [lines[1], lines[2], lines[3]]
			var tree_cnt = int(lines[4])
			foliage[trees[0]] = Vector3Array()
			foliage[trees[1]] = Vector3Array()
			foliage[trees[2]] = Vector3Array()
			var tree
			
			for i in range(tree_cnt):
				tree = trees[rand_range(0, trees.size())]
				# TODO: Generate random position and set the height based on the heightmap
				
		elif lines[0].begins_with("RandomBushes"):
			var bushes = [lines[1], lines[2], lines[3]]
			var bush_cnt = int(lines[4])
			foliage[bushes[0]] = Vector3Array()
			foliage[bushes[1]] = Vector3Array()
			foliage[bushes[2]] = Vector3Array()
			var bush
			
			for i in range(bush_cnt):
				bush = bushes[rand_range(0, bushes.size())]
				# TODO: Generate random position and set the height based on the heightmap
				
		elif (lines[0].begins_with("Trees") or 
		      lines[0].begins_with("NewTrees")):
			lines.remove(0)
			
			for line in lines:
				load_trees(line, foliage)
				
		elif (lines[0].begins_with("Bushes") or
		      lines[0].begins_with("NewBushes")):
			lines.remove(0)
			
			for line in lines:
				load_bushes(line, foliage)
				
		elif (lines[0].begins_with("FloatingBushes") or
		      lines[0].begins_with("NewFloatingBushes")):
			lines.remove(0)
			
			for line in lines:
				load_floating_bushes(line, foliage)
				
		elif lines[0].begins_with("CollBox"):
			var pos = lines[1].split_floats(" ")
			var size = lines[2].split_floats(" ")
			var collbox = CollBox.instance()
			collbox.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			collbox.set_scale(Vector3(size[0], size[1], size[2]) / 10)
			root.add_child(collbox)
			collbox.set_owner(root)
			
		elif lines[0].begins_with("CollSphere"):
			var pos = lines[1].split_floats(" ")
			var radius = float(lines[2])
			var collsphere = CollSphere.instance()
			collsphere.set_translation(Vector3(pos[0], pos[1], pos[2]) / 10)
			collsphere.set_scale(Vector3(radius, radius, radius) / 10)
			root.add_child(collsphere)
			collsphere.set_owner(root)
			
		elif lines[0].begins_with("SpawnCritters"): # TODO: Need to implement this
			pass
			
		elif lines[0].begins_with("FreezeTime"): # TODO: Need to implement this
			pass
			
		elif lines[0].begins_with("Music"): # TODO: Need to implement this
			pass
				
	# Optimize foliage
	# TODO: Use MultiMesh nodes here
			
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
	var heightmap = ""
	var size = Vector3(1, 1, 1)
	var material = null
	
	while not file.eof_reached():
		# Heightmap
		if line.begins_with("Heightmap.image"):
			heightmap = line.split("=")[1]
			
		# World size X
		elif line.begins_with("PageWorldX"):
			size.x = float(line.split("=")[1]) / 10
			
		# World size Z
		elif line.begins_with("PageWorldZ"):
			size.z = float(line.split("=")[1]) / 10
			
		# Maximum terrain height
		elif line.begins_with("MaxHeight"):
			size.y = float(line.split("=")[1])
			
		# Terrain material
		elif line.begins_with("CustomMaterial"):
			var mat_name = line.split("=")[1].replace("Terrain/", "")
			material = load("res://maps/materials/{0}.tres".format([mat_name]))
			
		# Get next line
		line = file.get_line()
			
	return {"heightmap": heightmap, "size": size, "material": material}
	
	
func load_trees(tree_cfg, foliage):
	pass
	
	
func load_bushes(bush_cfg, foliage):
	pass
	
	
func load_floating_bushes(bush_cfg, foliage):
	pass
	
	
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
