extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rng = RandomNumberGenerator.new()
var stones = [[]]

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate():
	
	#Floor Grass Generation
	for x in range(63):
		for y in range(63):
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
			set_cell(x, y, 0, false, false, false, Vector2(tilex, tiley))
	
	
	#Floor Stone Generation
	stones = create_2d_array(64, 64, 1)
	for x in range(9, 53):
		for y in range(9, 53):
			var stonerandom = rng.randi_range(1, 200)
			if (stonerandom == 1):
				stones[y][x] = 0
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
					stones[y + plusY][x + plusX] = 0
	placeStone()

func placeStone():
	for x in range(63):
		for y in range(63):
			if (stones[y][x] == 0):
				var bin1 = stones[y][x + 1] 
				var bin4 = stones[y + 1][x]
				var bin3 = stones[y][x - 1]
				var bin2 = stones[y - 1][x]
				var total = (2 * bin2 + 1 * bin1 + 8 * bin4 + 4 * bin3)
				set_cell(x, y, 1, false, false, false, Vector2( total % 4, total / 4))

func create_2d_array(width, height, value):
	var a = []
	for y in range(height):
		a.append([])
		a[y].resize(width)
		for x in range(width):
			a[y][x] = value
	return a
