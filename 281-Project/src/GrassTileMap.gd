extends TileMap

# Static Variables
var BURROW = preload("res://src/Burrow.tscn")
var TALLGRASS = preload("res://src/TallGrass.gd")
var perlin = preload("res://src/softnoise.gd")
var rng = RandomNumberGenerator.new()
var startX = 0
var startY = 0
var grassTileID = 2
var stoneTileID = 3
var grassNoNavID = 4
var stoneNoNavID = 5
var pathTileID = 7
var waterTileID = 8
var pathNoNavID = 9

# Field Size Variables
var fieldWidth = 64
var fieldLength = 64

# Border Variables
var border = false
var borderSize = 5

#lake variables
var lakes = true
var noise_map

# path Variables
var pathCount = 4
var paths = true

# Burrow Variables
var burrows = true #Spawn burrows randomly
var regionSize = 8 #region size squares of the burrows
var bossRegionSqare = 2 #Size of boss region to not spawn burrows in
var maxBurrowsPerSquare = 1 #The number of burrows that can spawn in a single square area
var minChance = 0.05 #2/8 At the start of the map, this is the chance of burrows spawning
var maxChance = 0.5 #6/8At the back part of the map


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate()

#This function will create a burrow at the specified tile
func createBurrow(tileX, tileY):
	#print("Creating Burrow...")
	var inst = BURROW.instance()
	inst.position = map_to_world(Vector2(tileX, tileY))
	get_parent().get_parent().get_node("Burrows").call_deferred("add_child", inst)
	#print("Spawn Location: " + str(map_to_world(Vector2(tileX, tileY))))
	#print(str(get_parent().get_parent().get_children()))

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
			set_cell(startX + x, startY + y, grassTileID, false, false, false, Vector2(tilex, tiley))
	
	
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
					set_cell(startX + (x + plusX), startY + (y + plusY), stoneTileID, false, false, false, Vector2(0, 0))
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))

	#Lakes
	if(lakes):
		noise_map = perlin.SoftNoise.new(1700)
		for x in range (fieldLength):
			for y in range (fieldWidth):
				var rand = noise_map.openSimplex2D(x/8.0, y/8.0)
				if( rand < -0.3 ):
					set_cell(x, y, waterTileID, false, false, false, Vector2(0, 0))
	
	#Tall Grass
	
	#Paths
	if(paths):
		for a in range (pathCount):
			var pathX = rng.randi_range(1, fieldWidth)
			for y in range (fieldLength):
				for i in range (-1, 2):
					for j in range (-1, 2):
						set_cell(pathX + i, y + j, pathTileID, false, false, false, Vector2(0, 0))
				pathX += rng.randi_range(-1, 1)
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
	
	#Remove Small Lakes
	if(lakes):
		for x in range (fieldLength):
			for y in range (fieldWidth):
				var count = 0
				for i in range (-1, 2):
					for j in range (-1, 2):
						if( get_cell(x + i, y + j) == waterTileID ):
							count = count + 1
				if(count < 3 && count > 1):
					set_cell(x, y, grassTileID, false, false, false, Vector2(0, 0))
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))

	# Add the Border
	if(border):
		for x in range(-borderSize, fieldLength+borderSize):
			for y in range(-borderSize, fieldWidth+borderSize):
				if((x < 0 or x > fieldLength - 1) or (y < 0 or y > fieldWidth - 1)):
					set_cell(startX + x, startY + y, 6, false, false, false, Vector2(x, y))

	#Generate Burrows
	if(burrows):
		#Squares in the X direction
		for x in range(fieldLength / regionSize):
			#Squares in the Y direction
			for y in range(fieldWidth / regionSize):
				#Acount for board orientation
				var actualY = (((fieldWidth / regionSize) - 1) - y)
				## Quadratic Equation Difficulty Scaling
				var chance = pow(y/7.0, 2.0) + 0.1
				## Square Root Equation Difficulty Scaling
				# var chance = sqrt(y/8.75)
				
				# Check Scaling by min/max
				if(chance < minChance):
					chance = minChance
					print("Chance: " + str(chance))
				elif(chance > maxChance):
					chance = maxChance
				
				#Player Spawn Area - Don't spawn anything in it -- BOXES 3,4
				if((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y == 0):
					# This is the spawn area-- Do not put anything here
					pass
				elif((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y >= (fieldWidth/regionSize)-2):
					# Don't spawn burrows in the boss area
					pass
				elif (get_cell(x*8 + regionSize/2, actualY*8 + regionSize/2) == waterTileID):
					print("no burrows?")
				else:
					#RNG to determine if it will spawn
					var rng_val = rng.randf() #rng.randi_range(1, 8) #VALUES ARE INCLUSIVE
					#print("(" + str(x) + ", " + str(y) + ") + = " + str(val))
					
					#Determine if the burrow will spawn
					if(rng_val <= chance):
						#print("Spawning Burrow in square: " + "(" + str(x) + ", " + str(y) + ")" + " with coords: " + "(" + str(map_to_world(Vector2(x*8 + regionSize/2, actualY*8 + regionSize/2))[0]) + ", " + str(map_to_world(Vector2(x*8 + regionSize/2, actualY*8 + regionSize/2))[1]) + ")")
						#Uncomment Uone of the below createBurrow methods
						##Spawn the burrow in the middle of the square
						createBurrow(x*8 + regionSize/2,actualY*8 + regionSize/2)
						##Spawn the burrows anywhere within the square
						#createBurrow(x*8 + rng.randi_range(0,7),y*8 + rng.randi_range(0,7))
