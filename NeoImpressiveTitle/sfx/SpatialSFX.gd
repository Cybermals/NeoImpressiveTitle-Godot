tool
extends SpatialSamplePlayer

const remaps = {
    "click": "Click",
    "draw": "Draw",
    "fireloop": "FireLoop",
    "ghostloop": "GhostLoop",
    "hawkcall": "HawkCall",
    "healhit": "HealHit",
    "hit": "Hit",
    "lava1": "Lava1",
    "mantacall": "MantaCall",
    "quake": "Quake",
    "rain1": "Rain1",
    "roar1": "Roar1",
    "roar2": "Roar2",
    "rungrass": "RunGrass",
    "splash": "Splash",
    "thunder1": "Thunder1",
    "thunder2": "Thunder2",
    "walkgrass": "WalkGrass",
    "water1": "Water1",
    "waterwade": "WaterWade",
    "waterfall": "Waterfall",
    "wind1": "Wind1"
}

export (String) var sfx = ""


func _ready():
	# Start the sound effect
	play(remaps[sfx] if remaps.has(sfx) else sfx)
