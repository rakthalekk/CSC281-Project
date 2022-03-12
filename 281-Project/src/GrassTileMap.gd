extends TileMap

# Declare member variables here. Examples:
var rng = RandomNumberGenerator.new()
var fieldWidth = 11
var fieldLength = 63
var stoneTileID = 3
var grassTileID = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate():
	
	#Floor Grass Generation
	for x in range(fieldLength):
		for y in range(fieldWidth):
			var tilex = rng.randi_range(0, 15)
			if (tilex < 15):
				tilex = 0
			else:
				tilex = 1
			var tiley = rng.randi_range(0, 6)
			if (tiley < 5):
				tiley = 0
			elif (tiley == 5):
				tiley = 1
			elif (tiley > 5):
				tiley = 2
			set_cell(x, y, grassTileID, false, false, false, Vector2(tilex, tiley))
	
	
	#Floor Stone Generation
	for x in range(4, fieldLength-4):
		for y in range(4, fieldWidth-5):
			var stonerandom = rng.randi_range(1, 50)#rng.randi_range(1, 200)
			if (stonerandom == 1):
				var plusX = 0
				var plusY = 0
				var randomDirection
				var maxAmount = rng.randi_range(10, 30)
				for amount in range(7, maxAmount):
					randomDirection = rng.randi_range(0, 3)
					match randomDirection:
						0:
							plusX += 1
						1:
							plusX -= 1
						2:
							plusY += 1
						3:
							plusY -= 1
					if (plusX > 4):
						plusX = 0
					if (plusY > 4):
						plusY = 0
					set_cell(x + plusX, y + plusY, stoneTileID, false, false, false, Vector2(0, 0))
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
	# Add the Border
#	for x in range(-5, fieldLength+5):
#		for y in range(-5, fieldWidth+5):
#			if((x < 0 or x > fieldLength-1) or (y < 0 or y > fieldWidth)):
#				set_cell(x, y, 2, false, false, false, Vector2(x, y))
