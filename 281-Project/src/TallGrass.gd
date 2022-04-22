extends TileMap

var fieldWidth = 64
var fieldLength = 64

var perlin = preload("res://src/softnoise.gd")
var noise_map

func _ready():
	noise_map = perlin.SoftNoise.new()
	generate()

func generate():
	for x in range (fieldLength):
		for y in range (fieldWidth):
			var rand = noise_map.openSimplex2D(x/8.0, y/8.0)
			if( rand > 0.5 ):
				set_cell(x, y, 0, false, false, false, Vector2(0, 0))
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
