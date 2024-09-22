tool
extends EditorImportPlugin

const GRASS_THRESHOLD = .9

const MapImportDialog = preload("MapImportDialog.tscn")
const ErrorDialog = preload("ErrorDialog.tscn")
const Sky = preload("res://environments/Sky.tscn")
const MusicQueue = preload("res://music/MusicQueue.tscn")
const TerrainScript = preload("res://maps/Terrain.gd")
const MapPortal = preload("res://objects/Portal.tscn")
const portal_material = preload("res://meshes/scenery/materials/Portal.tres")
const Gate = preload("res://objects/Gate.tscn")
const WaterPlane = preload("res://objects/WaterPlane.tscn")
const IcePlane = preload("res://objects/IcePlane.tscn")
const Ceiling = preload("res://meshes/scenery/Ceiling.scn")
const Billboard = preload("res://objects/Billboard.tscn")
const SphereWall = preload("res://objects/SphereWall.tscn")
const InvertedSphereWall = preload("res://objects/InvertedSphereWall.tscn")
const BoxWall = preload("res://objects/BoxWall.tscn")
const InvertedBoxWall = preload("res://objects/InvertedBoxWall.tscn")
const CollBox = preload("res://objects/CollBox.tscn")
const CollSphere = preload("res://objects/CollSphere.tscn")
const SpatialSFX = preload("res://sfx/SpatialSFX.tscn")
const grass = preload("res://meshes/scenery/Grass.tres")
const MapMetadata = preload("res://maps/MapMetadata.tscn")

var map_import_dlg = null
var error_dlg = null

var _base_control


func _init(base_control):
	_base_control = base_control
	
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
	var map_name = from.get_source_path(0).get_file().replace(".world", "")
	var root = Spatial.new()
	root.set_name(map_name)
	
	# Map metadata
	var map_metadata = MapMetadata.instance()
	root.add_child(map_metadata)
	map_metadata.set_owner(root)
	
	# Add sky
	var sky = Sky.instance()
	root.add_child(sky)
	sky.set_owner(root)
	
	# Add music queue
	var music_queue = MusicQueue.instance()
	music_queue.set_volume_db(20)
	root.add_child(music_queue)
	music_queue.set_owner(root)
	
	# Add raycast to calculate terrain height. This node should not be saved
	# as part of the scene.
	var raycast = RayCast.new()
	raycast.set_cast_to(Vector3(0, -1024, 0))
	root.add_child(raycast)
	
	# Temporarily add root node to editor scene for performing physics
	# calculations
	_base_control.add_child(root)
	
	# Load world file sections
	var world = File.new()
	var sections
	
	if world.open(from.get_source_path(0), File.READ):
		error_dlg.set_text("Failed to open '{0}'.".format([from.get_source_path(0)]))
		error_dlg.popup_centered()
		return
		
	sections = world.get_as_text().split("[", false)
	world.close()
	# print(sections)
	
	# Parse world file sections
	var foliage = {}
	var terrain_size
	
	for section in sections:
		# Parse section
		var lines = section.split("\n")
		
		# Terrain?
		if lines[0].begins_with("Initialize"):
			var terrain_name = from.get_source_path(0).get_file().replace(".world", "")
			var Terrain = load("res://meshes/terrain/{0}.scn".format([terrain_name]))
			var config = load_terrain_config("{0}/{1}".format([from.get_source_path(0).get_base_dir(), lines[1]]))
			terrain_size = config["size"]
			var material = config["material"]
			var spawn_pos = lines[4].split_floats(" ")
			
			if terrain_size == null:
				error_dlg.set_text("Failed to open '{0}'.".format([lines[1]]))
				error_dlg.popup_centered()
				return
			
			var terrain = Terrain.instance()
			terrain.set_name("Terrain")
			terrain.set_translation(Vector3(terrain_size.x * .5, terrain_size.y * .05, terrain_size.z * .5))
			terrain.set_scale(Vector3(terrain_size.x * .5, terrain_size.y * .5, terrain_size.z * .5))
			terrain.set_script(TerrainScript)
			terrain.material = material
			root.add_child(terrain)
			terrain.set_owner(root)
			
			var spawn_point = Position3D.new()
			spawn_point.set_name("SpawnPoint")
			spawn_point.set_translation(Vector3(spawn_pos[0], spawn_pos[2], spawn_pos[1]) * .1)
			root.add_child(spawn_point)
			spawn_point.set_owner(root)
			
			raycast.set_translation(Vector3(0, -terrain_size.y, 0))
			
		# Portal?
		elif lines[0].begins_with("Portal"):
			var pos = lines[1].split_floats(" ")
			var size = float(lines[2])
			var destination = lines[3]
			var portal = MapPortal.instance()
			portal.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			portal.set_scale(Vector3(size, size, size) * .1)
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
			gate.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			gate.set_scale(Vector3(4, 4, 4))
			gate.material = load("res://objects/materials/{0}.tres".format([mat_name]))
			gate.destination = destination
			gate.dest_vec = dest_vec
			root.add_child(gate)
			gate.set_owner(root)
			
		# Water Plane?
		elif lines[0].begins_with("WaterPlane"):
			var pos = lines[1].split_floats(" ")
			var scaleX = float(lines[2])
			var scaleZ = float(lines[3])
			var mat_name = lines[4] if lines.size() > 4 else ""
			var sound = lines[5] if lines.size() > 5 else ""
			var is_solid = (lines.size() > 6 and lines[6] == "true")
			var mat = load("res://objects/materials/{0}.tres".format([mat_name.replace("/", "-")])) if mat_name != "" else null
			var plane = IcePlane.instance() if is_solid else WaterPlane.instance()
			plane.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			plane.set_scale(Vector3(scaleX * 25, 1, scaleZ * 25))
			
			if mat != null:
				plane.material = mat
				
			root.add_child(plane)
			plane.set_owner(root)
			
			if sound != "":
				var sfx = SpatialSFX.instance()
				sfx.sfx = sound.replace(".wav", "")
				plane.add_child(sfx)
				sfx.set_owner(root)
			
		# Object?
		elif lines[0].begins_with("Object"):
			var object_name = lines[1].replace(".mesh", "")
			var pos = lines[2].split_floats(" ")
			var scale = lines[3].split_floats(" ")
			var rot = lines[4].split_floats(" ")
			var sound = lines[5] if lines.size() > 5 else ""
			var mat_name = lines[6] if lines.size() > 6 else ""
			var mat = load("res://meshes/scenery/materials/{0}.tres".format([mat_name.replace("/", "-")])) if mat_name != "" else null
			var MapObject = load("res://meshes/scenery/{0}.scn".format([object_name]))
			
			if MapObject == null:
				continue
				
			var obj = MapObject.instance()
			obj.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			obj.set_scale(Vector3(scale[0], scale[1], scale[2]) * .1)
			obj.set_rotation_deg(Vector3(rot[0], rot[1], rot[2]))
			
			for child in obj.get_children():
				if child.get_type() == "MeshInstance":
					child.set_material_override(mat)
					
			root.add_child(obj)
			obj.set_owner(root)
					
			if sound != "":
				var sfx = SpatialSFX.instance()
				sfx.sfx = sound.replace(".wav", "")
				obj.add_child(sfx)
				sfx.set_owner(root)
			
		# Particle System?
		elif lines[0].begins_with("Particle"):
			var particle_name = lines[1].replace(".particle", "")
			var pos = lines[2].split_floats(" ")
			var sound = lines[3] if lines.size() > 3 else ""
			var MapParticle = load("res://particles/{0}.tscn".format([particle_name]))
			
			if MapParticle == null:
				continue
				
			var particle = MapParticle.instance()
			particle.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			root.add_child(particle)
			particle.set_owner(root)
			
			if sound != "":
				var sfx = SpatialSFX.instance()
				sfx.sfx = sound.replace(".wav", "")
				particle.add_child(sfx)
				sfx.set_owner(root)
			
		# Weather cycle?
		elif lines[0].begins_with("WeatherCycle"):
			var weather_name = lines[1]
			var Weather = load("res://weather/{0}.tscn".format([weather_name]))
			
			if Weather == null:
				continue
				
			var weather = Weather.instance()
			root.add_child(weather)
			weather.set_owner(root)
			
		# Interior?
		elif lines[0].begins_with("Interior"): # TODO: Load sky color
			var ceiling_height = float(lines[1])
			var mat_name = lines[2]
			var sky_color = lines[3].split_floats(" ")
			var mat = load("res://objects/materials/{0}.tres".format([mat_name.replace("/", "-")])) if mat_name != "" else null
			var ceiling = Ceiling.instance()
			ceiling.set_scale(Vector3(terrain_size.x / 2, 1, terrain_size.z))
			
			for child in ceiling.get_children():
				if child.get_type() == "MeshInstance":
					child.set_material_override(mat)
			
			root.add_child(ceiling)
			ceiling.set_owner(root)
			
		# Light?
		elif lines[0].begins_with("Light"):
			var pos = lines[1].split_floats(" ")
			var color = lines[2].split_floats(" ")
			var light = OmniLight.new()
			light.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			light.set_color(Light.COLOR_DIFFUSE, Color(color[0], color[1], color[2]))
			root.add_child(light)
			light.set_owner(root)
		
		# Billboard?
		elif lines[0].begins_with("Billboard"):
			var pos = lines[1].split_floats(" ")
			var scale = lines[2].split_floats(" ")
			var mat_name = lines[3]
			var mat = load("res://objects/materials/{0}.tres".format([mat_name.replace("/", "-")])) if mat_name != "" else null
			var billboard = Billboard.instance()
			billboard.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			billboard.set_scale(Vector3(scale[0], scale[1], 1) * .1)
			billboard.set_material_override(mat)
			root.add_child(billboard)
			billboard.set_owner(root)
			
		# Sphere wall?
		elif lines[0].begins_with("SphereWall"):
			var pos = lines[1].split_floats(" ")
			var radius = float(lines[2])
			var is_inside = (lines[3] == "true")
			var sphere_wall = InvertedSphereWall.instance() if is_inside else SphereWall.instance()
			sphere_wall.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			sphere_wall.set_scale(Vector3(radius, radius, radius) * .1)
			root.add_child(sphere_wall)
			sphere_wall.set_owner(root)
			
		# Box wall?
		elif lines[0].begins_with("BoxWall"):
			var pos = lines[1].split_floats(" ")
			var size = lines[2].split_floats(" ")
			var is_inside = (lines[3] == "true")
			var box_wall = InvertedBoxWall.instance() if is_inside else BoxWall.instance()
			box_wall.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			box_wall.set_scale(Vector3(size[0], 512, size[1]) * .1)
			root.add_child(box_wall)
			box_wall.set_owner(root)
			
		# Map effect?
		elif lines[0].begins_with("MapEffect"):
			map_metadata.map_effect = lines[1]
			
		# Grass?
		elif lines[0].begins_with("Grass"):var mat_name = lines[1]
			var grass_map_name = lines[2]
			var grass_color_map_name = lines[3]
			
			# Load grass material and grass map
			var mat = load("res://meshes/scenery/materials/{0}.tres".format([mat_name]))
			var grass_map = load("res://maps/images/{0}".format([grass_map_name]))
			
			if grass_map == null:
				continue
				
			# Generate grass
			generate_grass(grass_map.get_data(), mat, terrain_size, raycast, root)
			
		# Random trees?
		elif lines[0].begins_with("RandomTrees"):
			var trees = [
			    lines[1].replace(".mesh", ""), 
			    lines[2].replace(".mesh", ""), 
			    lines[3].replace(".mesh", "")
			]
			var tree_cnt = int(lines[4])
			
			for i in range(tree_cnt):
				var tree = trees[rand_range(0, trees.size())]
				var pos = [
				    rand_range(0, terrain_size.x),
				    0,
				    rand_range(0, terrain_size.z)
				]
				pos[1] = get_height(raycast, pos[0], pos[2]) * .1
				
				if not foliage.has(tree):
					foliage[tree] = []
					
				foliage[tree].push_back({
				    "pos": pos,
				    "scale": [.1, .1, .1],
				    "rot": [0, 0, 0]
				})
				
		# Random bushes?
		elif lines[0].begins_with("RandomBushes"):
			var bushes = [
			    lines[1].replace(".mesh", ""), 
			    lines[2].replace(".mesh", ""), 
			    lines[3].replace(".mesh", "")
			]
			var bush_cnt = int(terrain_size.x * .5)
			
			for i in range(bush_cnt):
				var bush = bushes[rand_range(0, bushes.size())]
				var pos = [
				    rand_range(0, terrain_size.x),
				    0,
				    rand_range(0, terrain_size.z)
				]
				pos[1] = get_height(raycast, pos[0], pos[2]) * .1
				
				if not foliage.has(bush):
					foliage[bush] = []
					
				foliage[bush].push_back({
				    "pos": pos,
				    "scale": [.1, .1, .1],
				    "rot": [0, 0, 0]
				})
				
		# Trees or new trees?
		elif (lines[0].begins_with("Trees") or 
		      lines[0].begins_with("NewTrees")):
			var is_new = lines[0].begins_with("NewTrees")
			lines.remove(0)
			
			for line in lines:
				if line == "":
					continue
					
				load_trees("{0}/{1}".format([map_name, line]), foliage, 
				    is_new, raycast)
				
		# Bushes or new bushes?
		elif (lines[0].begins_with("Bushes") or
		      lines[0].begins_with("NewBushes")):
			var is_new = lines[0].begins_with("NewBushes")
			lines.remove(0)
			
			for line in lines:
				if line == "":
					continue
					
				load_bushes("{0}/{1}".format([map_name, line]), foliage, 
				    is_new, raycast)
				
		# Floating bushes or new floating bushes?
		elif (lines[0].begins_with("FloatingBushes") or
		      lines[0].begins_with("NewFloatingBushes")):
			var is_new = lines[0].begins_with("NewFloatingBushes")
			lines.remove(0)
			
			for line in lines:
				if line == "":
					continue
					
				load_floating_bushes("{0}/{1}".format([map_name, line]), 
				    foliage, is_new, raycast)
				
		# Collision boxes?
		elif lines[0].begins_with("CollBox"):
			var pos = lines[1].split_floats(" ")
			var size = lines[2].split_floats(" ")
			var collbox = CollBox.instance()
			collbox.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			collbox.set_scale(Vector3(size[0], size[1], size[2]) * .1)
			root.add_child(collbox)
			collbox.set_owner(root)
			
		# Collision spheres?
		elif lines[0].begins_with("CollSphere"):
			var pos = lines[1].split_floats(" ")
			var radius = float(lines[2])
			var collsphere = CollSphere.instance()
			collsphere.set_translation(Vector3(pos[0], pos[1], pos[2]) * .1)
			collsphere.set_scale(Vector3(radius, radius, radius) * .1)
			root.add_child(collsphere)
			collsphere.set_owner(root)
			
		# Spawn critters?
		elif lines[0].begins_with("SpawnCritters"): # TODO: Need to implement this
			OS.alert("Critter spawns not implemented yet!", "Warning")
			
		# Freeze time?
		elif lines[0].begins_with("FreezeTime"):
			sky.freeze_time = true
			
		# Music?
		elif lines[0].begins_with("Music"):
			lines.remove(0)
			music_queue.songs = lines
				
	# Optimize foliage
	for key in foliage.keys():
		# Build optimized foliage
		var parts = key.split(";")
		var mesh_name = parts[0]
		var mat_name = parts[1] if parts.size() > 1 else ""
		build_foliage(mesh_name, mat_name, foliage[key], terrain_size, root)
		
	# Remove root node from editor scene
	_base_control.remove_child(root)
	
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
			size.x = float(line.split("=")[1]) * .1
			
		# World size Z
		elif line.begins_with("PageWorldZ"):
			size.z = float(line.split("=")[1]) * .1
			
		# Maximum terrain height
		elif line.begins_with("MaxHeight"):
			size.y = float(line.split("=")[1])
			
		# Terrain material
		elif line.begins_with("CustomMaterial"):
			var mat_name = line.split("=")[1].replace("Terrain/", "")
			material = load("res://maps/materials/{0}.tres".format([mat_name]))
			
		# Get next line
		line = file.get_line()
			
	file.close()
	return {"heightmap": heightmap, "size": size, "material": material}
	
	
func get_height(raycast, x, y):
	raycast.set_translation(Vector3(x, 512, y))
	raycast.force_raycast_update()
	return raycast.get_collision_point().y * 10
	
	
func load_trees(tree_cfg, foliage, new, raycast):
	# Open tree config file
	var file = File.new()
	
	if file.open("res://private/maps/{0}".format([tree_cfg]), File.READ):
		print("ERROR: Failed to open 'res://private/maps/{0}'".format([tree_cfg]))
		return
		
	# Parse tree config file
	var sections = file.get_as_text().split("[", false)
	
	for section in sections:
		# Parse mesh and material
		var lines = section.split("\n", false)
		var mesh_name = lines[0].replace(".mesh", "").replace("]", "")
		lines.remove(0)
		
		# Parse instances
		if not foliage.has(mesh_name):
			foliage[mesh_name] = []
		
		for line in lines:
			var parts = line.split(";")
			var pos = parts[0].split_floats(" ")
			var scale = parts[1].split_floats(" ") if parts.size() > 1 else FloatArray([1, 1, 1])
			var rot = parts[2].split_floats(" ") if parts.size() > 2 else FloatArray([0, 0, 0])
			
			if new:
				foliage[mesh_name].push_back({
				    "pos": Vector3(pos[0], pos[1], pos[2]) * .1,
				    "scale": Vector3(scale[0], scale[1], scale[2]) * .1,
				    "rot": Vector3(rot[0], rot[1], rot[2]) if rot.size() > 1 else Vector3(0, rot[0], 0)
				})
				
			else:
				foliage[mesh_name].push_back({
				    "pos": Vector3(pos[0], get_height(raycast, pos[0] * .1, pos[1] * .1), pos[1]) * .1,
				    "scale": Vector3(scale[0], scale[0], scale[0]) * .1,
				    "rot": Vector3(0, rot[0], 0)
				})
	
	file.close()
	
	
func load_bushes(bush_cfg, foliage, new, raycast):
	# Open bush config file
	var file = File.new()
	
	if file.open("res://private/maps/{0}".format([bush_cfg]), File.READ):
		print("ERROR: Failed to open 'res://private/maps/{0}'".format([bush_cfg]))
		return
		
	# Parse bush config file
	var sections = file.get_as_text().split("[", false)
	
	for section in sections:
		# Parse mesh and material
		var lines = section.split("\n", false)
		var mesh_name = lines[0].replace(".mesh", "").replace("]", "")
		lines.remove(0)
		
		# Parse instances
		if not foliage.has(mesh_name):
			foliage[mesh_name] = []
		
		for line in lines:
			var parts = line.split(";")
			var pos = parts[0].split_floats(" ")
			var scale = parts[1].split_floats(" ") if parts.size() > 1 else FloatArray([1, 1, 1])
			var rot = parts[2].split_floats(" ") if parts.size() > 2 else FloatArray([0, 0, 0])
			
			if new:
				foliage[mesh_name].push_back({
				    "pos": Vector3(pos[0], pos[1], pos[2]) * .1,
				    "scale": Vector3(scale[0], scale[1], scale[2]) * .1,
				    "rot": Vector3(rot[0], rot[1], rot[2]) if rot.size() > 1 else Vector3(0, rot[0], 0)
				})
				
			else:
				foliage[mesh_name].push_back({
				    "pos": Vector3(pos[0], get_height(raycast, pos[0] * .1, pos[1] * .1), pos[1]) * .1,
				    "scale": Vector3(scale[0], scale[0], scale[0]) * .1,
				    "rot": Vector3(0, rot[0], 0)
				})
	
	file.close()
	
	
func load_floating_bushes(bush_cfg, foliage, new, raycast):
	# Open bush config file
	var file = File.new()
	
	if file.open("res://private/maps/{0}".format([bush_cfg]), File.READ):
		print("ERROR: Failed to open 'res://private/maps/{0}'".format([bush_cfg]))
		return
		
	# Parse bush config file
	var sections = file.get_as_text().split("[", false)
	
	for section in sections:
		# Parse mesh and material
		var lines = section.split("\n", false)
		var mesh_name = lines[0].replace(".mesh", "").replace("]", "")
		lines.remove(0)
		
		# Parse instances
		if not foliage.has(mesh_name):
			foliage[mesh_name] = []
		
		for line in lines:
			var parts = line.split(";")
			var pos = parts[0].split_floats(" ")
			var scale = parts[1].split_floats(" ") if parts.size() > 1 else FloatArray([1, 1, 1])
			var rot = parts[2].split_floats(" ") if parts.size() > 2 else FloatArray([0, 0, 0])
			
			if new:
				foliage[mesh_name].push_back({
				    "pos": Vector3(pos[0], pos[1], pos[2]) * .1,
				    "scale": Vector3(scale[0], scale[1], scale[2]) * .1,
				    "rot": Vector3(rot[0], rot[1], rot[2])
				})
				
			else:
				foliage[mesh_name].push_back({
				    "pos": Vector3(pos[0], pos[1], pos[2]) * .1,
				    "scale": Vector3(scale[0], scale[0], scale[0]) * .1,
				    "rot": Vector3(0, rot[0], 0)
				})
	
	file.close()
	
	
func build_foliage(mesh_name, mat_name, instances, terrain_size, root):
	# Load the object to use as a multimesh
	var MapObject = load("res://meshes/scenery/{0}.scn".format([mesh_name]))
	
	if MapObject == null:
		return null
		
	# Load material
	var mat = load("res://meshes/scenery/materials/{0}.tres".format([mat_name.replace("/", "-")])) if mat_name != "" else null
	
	# Add foliage instances
	for instance in instances:
		# Get instance attribs
		var pos = instance["pos"]
		var scale = instance["scale"]
		var rot = instance["rot"]
		
		# Add instance
		var obj = MapObject.instance()
		obj.set_translation(Vector3(pos[0], pos[1], pos[2]))
		obj.set_scale(Vector3(scale[0], scale[1], scale[2]))
		obj.set_rotation_deg(Vector3(rot[0], rot[1], rot[2]))
		
		for child in obj.get_children():
			if child.get_type() == "MeshInstance":
				child.set_material_override(mat)
		
		root.add_child(obj)
		obj.set_owner(root)
		
	return
		
	# Note: Using multimeshes failed to work. Maybe try again later?
	# Instance the object and extract the first mesh in it
	var obj = MapObject.instance()
	var base_scale = Vector3(1, 1, 1)
	var mesh = null
	
	for child in obj.get_children():
		if child.get_type() == "MeshInstance":
			base_scale = child.get_scale() * .1
			mesh = child.get_mesh()
			break
			
	obj.queue_free()
	
	if mesh == null:
		return
		
	# Preallocate foliage chunks
	var chunks = []
	
	for i in range(64):
		chunks.push_back(null)
		
	# Process instances
	var cell_size = terrain_size * .125
	var spatial = Spatial.new()
	
	for instance in instances:
		# Get instance attribs
		var pos = instance["pos"]
		var scale = instance["scale"]
		var rot = instance["rot"]
		pos = Vector3(pos[0], pos[1], pos[2])
		scale = Vector3(scale[0], scale[1], scale[2])
		rot = Vector3(rot[0], rot[1], rot[2])
		
		# Calculate chunk pos and index
		var chunk_pos = pos / cell_size
		var i = int(chunk_pos.z) * 8 + int(chunk_pos.x)
		
		# Create chunk if necessary
		if chunks[i] == null:
			var multimesh = MultiMesh.new()
			multimesh.set_mesh(mesh)
			chunks[i] = MultiMeshInstance.new()
			chunks[i].set_name("Foliage")
			chunks[i].set_multimesh(multimesh)
			root.add_child(chunks[i])
			chunks[i].set_owner(root)
		
		# Add instance
		var multimesh = chunks[i].get_multimesh()
		multimesh.set_instance_count(multimesh.get_instance_count() + 1)
		spatial.set_translation(pos * .1)
		spatial.set_scale(base_scale * scale * .1)
		spatial.set_rotation_deg(rot)
		multimesh.set_instance_transform(multimesh.get_instance_count() - 1, 
		    spatial.get_transform())
		
	# Generate chunk bounding boxes
	for chunk in chunks:
		if chunk != null:
			chunk.get_multimesh().generate_aabb()
			
	return
	
	
func generate_grass(grass_map, mat, terrain_size, raycast, root):
	# Calculate scale factor
	var grass_map_size = Vector3(
	    grass_map.get_width(),
	    0,
	    grass_map.get_height()
	)
	var scale_factor = terrain_size / grass_map_size
	
	# Build grass chunks
	for cz in range(grass_map_size.z / 64):
		for cx in range(grass_map_size.x / 64):
			generate_grass_chunk(cx, cz, grass_map.get_rect(Rect2(cx * 64, cz * 64, 64, 64)), mat, scale_factor, raycast, root)
	
	
func generate_grass_chunk(cx, cz, grass_map, mat, scale_factor, raycast, root):
	# Build grass chunk
	var pos = Vector3(cx * 64, 0, cz * 64)
	var patches = 0
	var grass_chunk = MultiMesh.new()
	grass_chunk.set_mesh(grass)
	
	for z in range(0, 64, 2):
		for x in range(0, 64, 2):
			if grass_map.get_pixel(x, z).g > GRASS_THRESHOLD:
				patches += 1
				grass_chunk.set_instance_count(patches)
				var transform = Transform()
				transform.origin = Vector3(x * scale_factor.x, get_height(raycast, (pos.x + x) * scale_factor.x, (pos.z + z) * scale_factor.z) * .1, z * scale_factor.z)
				grass_chunk.set_instance_transform(patches - 1, transform)
				
	grass_chunk.generate_aabb()
				
	# Create grass chunk instance
	var grass_chunk_inst = MultiMeshInstance.new()
	grass_chunk_inst.set_name("Grass")
	grass_chunk_inst.set_multimesh(grass_chunk)
	grass_chunk_inst.set_translation(pos)
	root.add_child(grass_chunk_inst)
	grass_chunk_inst.set_owner(root)
	
	
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
