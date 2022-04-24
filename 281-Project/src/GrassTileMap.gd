extends TileMap

# Static Variables
var BURROW = preload("res://src/Burrow.tscn")
var FAIRYLOG = preload("res://src/Fairy Log.tscn")
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
onready var tallGrassReference = get_node("../../TallGrass")
onready var entitiesReference = get_node("../../Entities") #Check here for conflicting logs
onready var burrowsReference = get_node("../../Burrows") #Check here for conflicting burrows

# Field Size Variables
var fieldWidth = 64 #Y Variable
var fieldLength = 64 #X Variable
var filter = true #Smooths out map generation a bit and clear
var filterPower = 4 #2 is normal filtering, 4 is max filtering.

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
var minChance = 0.25 #2/8 At the start of the map, this is the chance of burrows spawning
var maxChance = 0.5 #6/8At the back part of the map

# Fairy Log Variables
var fairyLogs = true #Spawn Fairy Logs randomly
var fairyLogRegionSize = 8 #region size squares of the fairy logs to spawn in
var fairyLogMinChance = 0.15 #Min chance for a fairy log to spawn when at the start Y
var fairyLogMaxChance = 0.35 #Max chacne for a fairy log to spawn when at the end of the map
var fairyLogStartY = 21#fieldWidth/3 #At what point in the map fairy logs start spawning
var maxFairyLogsPerSquare = 1 #The number of fairy logs that can spawn in a single square area

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate2()

#This function will create a burrow at the specified tile
func createBurrow(tileX, tileY):
	#print("Creating Burrow...")
	var inst = BURROW.instance()
	inst.position = map_to_world(Vector2(tileX, tileY))
	get_parent().get_parent().get_node("Burrows").call_deferred("add_child", inst)
	#print("Spawn Location: " + str(map_to_world(Vector2(tileX, tileY))))
	#print(str(get_parent().get_parent().get_children()))

#This function will create a fairyLog at the specified tile
func createFairyLog(tileX, tileY):
	#print("Creating Burrow...")
	var inst = FAIRYLOG.instance()
	inst.position = map_to_world(Vector2(tileX, tileY))
	get_parent().get_parent().get_node("Entities").call_deferred("add_child", inst)
	#print("Spawn Location: " + str(map_to_world(Vector2(tileX, tileY))))
	#print("Spawn Location: " + str(Vector2(tileX, tileY)))
	#print(str(get_parent().get_parent().get_children()))

# Checks whether the spot under the burrow is water or not, to determine if it can spawn
func canSpawnObject(loc: Vector2):
	#Check for if it's in a clearing
	if(isInClearing(loc[0], loc[1])):
		return false
	#Check if the location is near water
	if(get_cellv(loc + Vector2(0,0)) == waterTileID
		|| get_cellv(loc + Vector2(1,0)) == waterTileID
		|| get_cellv(loc + Vector2(1,1)) == waterTileID
		|| get_cellv(loc + Vector2(0,1)) == waterTileID
		|| get_cellv(loc + Vector2(-1,1)) == waterTileID
		|| get_cellv(loc + Vector2(-1,0)) == waterTileID
		|| get_cellv(loc + Vector2(-1,-1)) == waterTileID
		|| get_cellv(loc + Vector2(0,-1)) == waterTileID
		|| get_cellv(loc + Vector2(1,-1)) == waterTileID):
		return false
	#Check the location for an entity
	var pos = map_to_world(loc)
	var singleBlockDistance = 64
	for entity in entitiesReference.get_children():
		if(abs(entity.position[0] - pos[0]) < singleBlockDistance && abs(entity.position[1] - pos[1]) < singleBlockDistance):
			return false
	for burrow in burrowsReference.get_children():
		if(abs(burrow.position[0] - pos[0]) < singleBlockDistance && abs(burrow.position[1] - pos[1]) < singleBlockDistance):
			return false
	return true

#This function checks the X/Y to see if it's in the player spawn zone or boss area
func isInClearing(tileX, tileY):
	#Check if in player spawn area
	if(((tileX > (fieldLength/2)-regionSize-1) && (tileX < (fieldLength/2)+regionSize-1)) && (tileY < regionSize)):
		return true
	#Check if in boss spawn area
	elif(((tileX > (fieldLength/2)-regionSize-1) && (tileX < (fieldLength/2)+regionSize-1)) && (tileY > fieldWidth-2*regionSize-1)):
		return true
	#Returns false if block is not in clearing
	return false

#Filter some noise from map generation - Stops individual blocks and weird small block formations
func filterGeneration(tilemap):
	#Filter from bottom left to top right
	for dir in range(filterPower): #Do 4 for max filtering, 2 for normal filtering
		for x in range(0, fieldLength - 0):
			match dir: #Match number order for pattern
				0: #Bottom Left to top right
					pass #Do nothing because this is normal
				1: #Top Right to bottom left
					x = fieldLength - 2 - x
				2: #Bottom right to top left
					x = fieldLength - 2 - x
				3: #Top left to bottom right
					pass #Do nothing because this is normal
			for y in range(0, fieldWidth - 0):
				match dir: #Match number order for pattern
					0: #Bottom Left to top right
						pass #Do nothing because this is normal
					1: #Top Right to bottom left
						y = fieldWidth - 2 - y
					2: #Bottom right to top left
						pass #Do nothing because this is normal
					3: #Top left to bottom right
						y = fieldWidth - 2 - y
				var actualY = fieldWidth - 1 - y
				#CHECK IF THE BLOCK IS A LONELY BLOCK (sticks out from group)
				#Get the cell id
				var cell = tilemap.get_cell(x, actualY)
				#Check nearby blocks (in cardinal directions) for > 1 buddy block
				var buddies = {}
				#Add buddies to dictionary
				for i in [tilemap.get_cell(x + 1, actualY + 0), 
							tilemap.get_cell(x + 0, actualY + 1), 
							tilemap.get_cell(x + 0, actualY + -1),
							tilemap.get_cell(x + -1, actualY + 0)]:
					if(buddies.has(i)):
						#Add to the count if it's in the dictionary
						buddies[i] += 1
					else:
						#Add to dictionary if not in it
						buddies[i] = 1
				#Check buddy count
				if(!buddies.has(cell) || buddies[cell] < 2):
					#print("FILTERED")
					#If buddy count is < 1 -> filter
					#Find the most common nearby block to replace it with
					var mostFrequent = buddies.keys()[0] #Start with the first one
					for checkBlockID in buddies.keys():
						if(buddies[checkBlockID] > buddies[mostFrequent] || mostFrequent < 0):
							mostFrequent = checkBlockID
					#Replace with new block
					tilemap.set_cell(startX + x, startY + actualY, mostFrequent)

func generate2():
	var noise = OpenSimplexNoise.new()
	noise.seed = rng.randi() #323412
	noise.octaves = 4
	noise.period = 15#8#0.05
	noise.lacunarity = 1.5#2.0
	noise.persistence = 0.75#0.5
	
	# Generate terrain
	for x in range(fieldLength):
		for y in range(fieldWidth):
			var actualY = fieldWidth - 1 - y
			var genVal = noise.get_noise_2d(float(x), float(y))
			#genVal goes from [-1,1]
			if(isInClearing(x, actualY) || genVal < 0): #Generate grass
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
				set_cell(startX + x, startY + actualY, grassTileID, false, false, false, Vector2(tilex, tiley))
			elif(genVal < 0.1): #Generate Tall Grass
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
				set_cell(startX + x, startY + actualY, grassTileID, false, false, false, Vector2(tilex, tiley))
				tallGrassReference.set_cell(startX + x, startY + actualY, 0)
			elif(genVal < 0.2): #Generate Water
				set_cell(startX + x, startY + actualY, waterTileID)
			else: #Generate Stone
				set_cell(startX + x, startY + actualY, stoneTileID)

	#Paths
	if(paths):
		for a in range (pathCount):
			var pathX = rng.randi_range(1, fieldWidth)
			for y in range (fieldLength):
				for i in range (-1, 2):
					for j in range (-1, 2):
						set_cell(pathX + i, y + j, pathTileID, false, false, false, Vector2(0, 0))
						tallGrassReference.set_cell(pathX + i, y + j, -1, false, false, false, Vector2(0, 0))
				pathX += rng.randi_range(-1, 1)
	
	#Filter some noise from map generation - Stops individual blocks and single block beam shoots?
	if(filter):
		filterGeneration(self)
		filterGeneration(tallGrassReference)
	
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
	tallGrassReference.update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
	
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
				elif(chance > maxChance):
					chance = maxChance
				
				#Player Spawn Area - Don't spawn anything in it -- BOXES 3,4
				if((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y == 0):
					# This is the spawn area-- Do not put anything here
					pass
				elif((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y >= (fieldWidth/regionSize)-2):
					# Don't spawn burrows in the boss area
					pass
				#elif (get_cell(x*8 + regionSize/2, actualY*8 + regionSize/2) == waterTileID):
				#	print("no burrows?")
				else:
					#RNG to determine if it will spawn
					var rng_val = rng.randf() #rng.randi_range(1, 8) #VALUES ARE INCLUSIVE
					#print("(" + str(x) + ", " + str(y) + ") + = " + str(val))
					
					#Determine if the burrow will spawn
					if(rng_val <= chance):
						#print("Spawning Burrow in square: " + "(" + str(x) + ", " + str(y) + ")" + " with coords: " + "(" + str(map_to_world(Vector2(x*8 + regionSize/2, actualY*8 + regionSize/2))[0]) + ", " + str(map_to_world(Vector2(x*8 + regionSize/2, actualY*8 + regionSize/2))[1]) + ")")
						#Uncomment Uone of the below createBurrow methods
						##Spawn the burrow in the middle of the square
				#		createBurrow(x*8 + regionSize/2,actualY*8 + regionSize/2)
						##Spawn the burrows anywhere within the square -- ALSO CHECK TO NOT SPAWN ON WATER
						#createBurrow(x*8 + rng.randi_range(8),y*8 + rng.randi_range(8))
						#Initial spawn location
						var spawnLoc = Vector2(x*8 + rng.randi_range(0,7),actualY*8 + rng.randi_range(0,7))
						#Try up to 32 times to place the spawner
						for spawns in range(maxBurrowsPerSquare):
							var willSpawn = true
							if(spawns > 0):
								#Run the RNG to spawn another one
								rng_val = rng.randf()
								#Scale chance
								chance = pow(y/7.0, 2.0) + 0.1
								# Check Scaling by min/max
								if(chance < minChance):
									chance = minChance
								elif(chance > maxChance):
									chance = maxChance
								#Check if the chance is good to spawn another one
								if(rng_val <= chance):
										willSpawn = true
								else:
										willSpawn = false
							if(willSpawn):
								for i in range(32):
									# Check if the burrow can spawn
									if(!canSpawnObject(spawnLoc)):
									#if(get_cellv(spawnLoc) == waterTileID):
										#Try again if the spot it was attempted to be placed on is water
										spawnLoc = Vector2(x*8 + rng.randi_range(0,7), actualY*8 + rng.randi_range(0,7))
									else:
										#Spawn the burrow if it's in a valid space
										createBurrow(spawnLoc[0], spawnLoc[1])
										break #Stop the for loop since the burrow was created
	#Generate Fairy Logs
	if(fairyLogs):
		#Border Size to account for log size
		var fairyLogBorder = 2
		#Squares in the X direction
		for x in range(fairyLogBorder, fieldLength - fairyLogBorder):
			#Squares in the Y direction
			for y in range(fairyLogBorder, fieldWidth - fairyLogBorder):
				#Acount for board orientation
				var actualY = fieldWidth - 1 - y
				## Quadratic Equation Difficulty Scaling
				var chance = ((fairyLogMaxChance-fairyLogMinChance)/pow(fieldLength - fairyLogStartY, 2.0))*pow(y, 2.0) + fairyLogMinChance
				# Check Scaling by min/max
				if(y <= fairyLogStartY):
					chance = 0
				elif(chance < fairyLogMinChance):
					chance = fairyLogMinChance
				elif(chance > fairyLogMaxChance):
					chance = fairyLogMaxChance
				#Should be the size of the region, since it's a square region
				if(rng.randf() <= 1/pow(fairyLogRegionSize, 2.0)):
					#Player Spawn Area - Don't spawn anything in it -- BOXES 3,4
					if((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y == 0):
						# This is the spawn area-- Do not put anything here
						pass
					elif((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y >= (fieldWidth/regionSize)-2):
						# Don't spawn burrows in the boss area
						pass
					else:
						#RNG to determine if it will spawn
						var rng_val = rng.randf()
						#Determine if the burrow will spawn
						#print("RNG VAL: " + str(rng_val) + " AND CHANCE: " + str(chance) + " - " + str(Vector2(x, y)))
						if(rng_val <= chance):
							#Spawn at least 1, and then chance spawn as many as needed
							for spawns in range(maxFairyLogsPerSquare):
								var willSpawn = true
								if(spawns > 0):
									#Run the RNG to spawn another one
									rng_val = rng.randf()
									#Scale chance
									chance = ((fairyLogMaxChance-fairyLogMinChance)/pow(fieldLength - fairyLogStartY, 2.0))*pow(y, 2.0) + fairyLogMinChance
									# Check Scaling by min/max
									if(actualY <= fairyLogStartY):
										chance = 0
									elif(chance < fairyLogMinChance):
										chance = fairyLogMinChance
									elif(chance > fairyLogMaxChance):
										chance = fairyLogMaxChance
									#Check if the chance is good to spawn another one
									if(rng_val <= chance):
											willSpawn = true
									else:
											willSpawn = false
								if(willSpawn):
									#Initial spawn location
									var spawnLoc = Vector2(x + rng.randi_range(-4,4),actualY + rng.randi_range(-4,4))
									#Try up to 32 times to place the fairy log
									for i in range(32):
										# Check if the log is spawning outside of the border
										if(spawnLoc[0] < fairyLogBorder || spawnLoc[1] < fairyLogBorder 
											|| spawnLoc[0] >= fieldLength - fairyLogBorder || spawnLoc[1] >= fieldWidth - fairyLogBorder):
												spawnLoc = Vector2(x + rng.randi_range(-4,4),actualY + rng.randi_range(-4,4))
										# Check if the burrow can spawn
										if(!canSpawnObject(spawnLoc)):
										#if(get_cellv(spawnLoc) == waterTileID):
											#Try again if the spot it was attempted to be placed on is water
											spawnLoc = Vector2(x + rng.randi_range(-4,4),actualY + rng.randi_range(-4,4))
										else:
											#Spawn the burrow if it's in a valid space
											createFairyLog(spawnLoc[0], spawnLoc[1])
											break #Stop the for loop since the burrow was created
		
		"""
		var rng_val = rng.randf()
		var chance = ((fairyLogMaxChance-fairyLogMaxChance)/pow(fieldLength, 2.0))*pow(y, 2.0) + fairyLogMinChance
		# Check Scaling by min/max
		if(chance < fairyLogMinChance):
			chance = fairyLogMinChance
		elif(chance > fairyLogMaxChance):
			chance = fairyLogMaxChance
		if(rng_val <= chance):
				willSpawn = true
		else:
				willSpawn = false
	"""

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
