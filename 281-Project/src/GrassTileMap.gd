extends TileMap

# Static Variables
var BURROW = preload("res://src/Burrow.tscn")
var FAIRYLOG = preload("res://src/Fairy Log.tscn")
var DRAGONBONES = preload("res://src/Dragon Bones.tscn")
var FAIRYLOGVARS = preload("res://src/Fairy Dust Tree.gd")
var DRAGONBONESVARS = preload("res://src/Dragon Bones.gd")
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

# Random Map Gen?
export(bool) var randomizeMap = true

# Field Size Variables
var fieldWidth = 64 #Y Variable
var fieldLength = 64 #X Variable
var filter = true #Smooths out map generation a bit and clear
var filterPower = 4 #2 is normal filtering, 4 is max filtering.
#Boss limits on field are controlled in its own scene

# Border Variables
var border = false
var borderSize = 5

#lake variables
export(bool) var lakes = true
var noise_map

# path Variables
var pathCount = 2
export(bool) var paths = true
var canSpawnOnRoad = false #controls things spawning on the road

#Misc Variables
var maxTries = 100 #Maximum tries that the engine will try spawning the min number of something before giving up

# Burrow Variables
export(bool) var burrows = true #Spawn burrows randomly
var regionSize = 8 #region size squares of the burrows
var bossRegionSqare = 2 #Size of boss region to not spawn burrows in
var maxBurrowsPerSquare = 1 #The number of burrows that can spawn in a single square area
var minChance = 0.25 #2/8 At the start of the map, this is the chance of burrows spawning
var maxChance = 0.5 #6/8At the back part of the map
var minBurrowsSpawned = 20 #Spawn at least this many burrows
var maxBurrowsSpawned = 25 #Spawn at most this many burrows - use -1 for no limit

# Fairy Log Variables
export(bool) var fairyLogs = true #Spawn Fairy Logs randomly
var fairyLogRegionSize = 8 #region size squares of the fairy logs to spawn in
var fairyLogBorder = 2 #Border Size to account for log size
var fairyLogMinChance = 0.15 #Min chance for a fairy log to spawn when at the start Y
var fairyLogMaxChance = 0.35 #Max chacne for a fairy log to spawn when at the end of the map
var fairyLogStartY = 21#fieldWidth/3 #At what point in the map fairy logs start spawning
var maxFairyLogsPerSquare = 1 #The number of fairy logs that can spawn in a single square area
var minFairyLogsSpawned = 1 #Spawn at least this many fairy logs
var maxFairyLogsSpawned = -1 #Spawn at most this many fairy logs - use -1 for no limit

# Dragon Bones Variables
export(bool) var dragonBones = true #Spawn Dragon Bones randomly
var dragonBonesRegionSize = 16 #region size squares of the Dragon Bones to spawn in
var dragonBonesBorder = 4 #Border Size to account for dragon bones size
var dragonBonesMinChance = 0.05 #Min chance for Dragon Bones to spawn when at the start Y
var dragonBonesMaxChance = 0.15 #Max chacne for Dragon Bones to spawn when at the end of the map
var dragonBonesStartY = 48#fieldWidth/3 #At what point in the map Dragon Bones start spawning
var maxDragonBonesPerSquare = 1 #The number of Dragon Bones that can spawn in a single square area
var minDragonBonesSpawned = 2 #Spawn at least this many dragon bones
var maxDragonBonesSpawned = -1 #Spawn at most this many dragon bones - use -1 for no limit

#Calculated/Generated Variables for use within scripts -- NOT FOR MODIFYING
#These contain Vector2s
var burrowLocations = [] #Locations of burrows that have spawned to check for burrow placement
var logLocations = [] #Locations of logs that have been spawned for updating tile navigation
var dragonBonesLocations = [] #Locations of dragon bones that have been spawned for checking for placement
var dragonBonesSpawnedCount = 0 #Keeps track of the number of dragon bones spawned

#var debug = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.difficulty == 0:
		minBurrowsSpawned = 15
		maxBurrowsSpawned = 20
	elif Global.difficulty == 2:
		minBurrowsSpawned = 25
		maxBurrowsSpawned = 30

	if randomizeMap:
		rng.randomize()
		generate2()
	#Check for anomalies
	#for locations in [burrowLocations, logLocations, dragonBonesLocations]: #These are all arrays of Vector2s
#	for entityLocation in burrowLocations: #These are Vector2s
#		print("Burrow Check: " + str(canSpawnObject(world_to_map(entityLocation))) + " at " + str(world_to_map(entityLocation)))
#	for entityLocation in logLocations: #These are Vector2s
#		print("Log Check: " + str(canSpawnObject(world_to_map(entityLocation), FAIRYLOGVARS.getTileAreaCoverage())) + " at " + str(world_to_map(entityLocation)))
#	debug = true
#	for entityLocation in dragonBonesLocations: #These are Vector2s
#		print("DragonBones Check: " + str(canSpawnObject(world_to_map(entityLocation),DRAGONBONESVARS.getTileAreaCoverage())) + " at " + str(world_to_map(entityLocation)))

#This function will create a burrow at the specified tile
func createBurrow(tileX, tileY):
	#print("Creating Burrow...")
	var inst = BURROW.instance()
	inst.position = map_to_world(Vector2(tileX, tileY))
	burrowLocations.append(inst.position)
	get_parent().get_parent().get_node("Burrows").call_deferred("add_child", inst)
	#print("Spawn Location: " + str(map_to_world(Vector2(tileX, tileY))))
	#print(str(get_parent().get_parent().get_children()))

#This function will create a fairyLog at the specified tile
func createFairyLog(tileX, tileY):
	var inst = FAIRYLOG.instance()
	inst.position = map_to_world(Vector2(tileX, tileY))
	logLocations.append(inst.position)
	get_parent().get_parent().get_node("Entities").call_deferred("add_child", inst)
	#print("Spawn Location: " + str(map_to_world(Vector2(tileX, tileY))))
	#print("Spawn Location: " + str(Vector2(tileX, tileY)))
	#print(str(get_parent().get_parent().get_children()))

#This function will create Dragon Bones at the specified tile
func createDragonBones(tileX, tileY):
	#Places the bones at the bottom right corner of them
	var inst = DRAGONBONES.instance()
	inst.position = map_to_world(Vector2(tileX, tileY))
	dragonBonesLocations.append(inst.position) #--> Moved to "Dragon Bones.gd" Vector2(tileX, tileY)
	get_parent().get_parent().get_node("Bones").call_deferred("add_child", inst)
	#print("Spawn Location: " + str(map_to_world(Vector2(tileX, tileY))))
	dragonBonesSpawnedCount += 1
	#print("Spawn Location: " + str(Vector2(tileX, tileY)))
	#print(str(get_parent().get_parent().get_children()))

# Checks whether the spot under the burrow is water or not, to determine if it can spawn
func canSpawnObject(loc: Vector2, tileRange = []): #loc is the coordinates of a tile 
	#tileRange is [[min tile],[max tile]]
	#Check for if it's in a clearing
	if(isInClearing(loc[0], loc[1])):
		return false
	#Check if the location is near water or covering a path
	if(tileRange != []):
		for x in range(tileRange[0][0],tileRange[1][0] + 1): #Plus 1 so inclusive of last index
			for y in range(tileRange[0][1],tileRange[1][1] + 1): #Plus 1 so inclusive of last index
				#print("range min: " + tileRange[0] + " range max: " + tileRange[1])
				#Make sure nothing spawns on lake tiles
				if(get_cellv(loc + Vector2(x,y)) == waterTileID):
					return false
				#Check to make sure that nothing is spawning on the roads
				if(!canSpawnOnRoad):
					if(get_cellv(loc + Vector2(x,y)) == pathTileID):
						return false
	else:
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
		if(!canSpawnOnRoad):
			if(get_cellv(loc + Vector2(0,0)) == pathTileID
			|| get_cellv(loc + Vector2(1,0)) == pathTileID
			|| get_cellv(loc + Vector2(1,1)) == pathTileID
			|| get_cellv(loc + Vector2(0,1)) == pathTileID
			|| get_cellv(loc + Vector2(-1,1)) == pathTileID
			|| get_cellv(loc + Vector2(-1,0)) == pathTileID
			|| get_cellv(loc + Vector2(-1,-1)) == pathTileID
			|| get_cellv(loc + Vector2(0,-1)) == pathTileID
			|| get_cellv(loc + Vector2(1,-1)) == pathTileID):
				return false
	#Check the location for an entity
	##Check that entities aren't colliding with other entities
	#Check for conflict with burrows
	var size = [[0,0],[0,0]]
	for entityLocation in burrowLocations: #These are Vector2s
		var r1x = loc[0] + -1 #min
		var l1x = loc[0] + 1 #max
		var r1y = loc[1] + -1 #min
		var l1y = loc[1] + 1 #max
		var r2x = world_to_map(entityLocation)[0] + size[0][0] #min
		var l2x = world_to_map(entityLocation)[0] + size[1][0] #max
		var r2y = world_to_map(entityLocation)[1] + size[0][1] #min
		var l2y = world_to_map(entityLocation)[1] + size[1][1] #max
		if(tileRange != []):
			#Change the "+ 1" if the burrow gets a sizing
			r1x = loc[0] + tileRange[0][0] #min
			l1x = loc[0] + tileRange[1][0] #max
			r1y = loc[1] + tileRange[0][1] #min
			l1y = loc[1] + tileRange[1][1] #max
		if !( (r1x + (l1x - r1x) < r2x)  || (r1x > r2x + (l2x - r2x))
			|| (r1y + (l1y - r1y) < r2y) || (r1y > r2y + (l2y - r2y)) ):
				return false
	#Check for conflict with fairy logs
	size = FAIRYLOGVARS.getTileAreaCoverage()
	for entityLocation in logLocations: #These are Vector2s
		var r1x = loc[0] + -1 #min
		var l1x = loc[0] + 1 #max
		var r1y = loc[1] + -1 #min
		var l1y = loc[1] + 1 #max
		var r2x = world_to_map(entityLocation)[0] + size[0][0] #min
		var l2x = world_to_map(entityLocation)[0] + size[1][0] #max
		var r2y = world_to_map(entityLocation)[1] + size[0][1] #min
		var l2y = world_to_map(entityLocation)[1] + size[1][1] #max
		if(tileRange != []):
			r1x = loc[0] + tileRange[0][0] #min
			l1x = loc[0] + tileRange[1][0] #max
			r1y = loc[1] + tileRange[0][1] #min
			l1y = loc[1] + tileRange[1][1] #max
		if !( (r1x + (l1x - r1x) < r2x)  || (r1x > r2x + (l2x - r2x))
			|| (r1y + (l1y - r1y) < r2y) || (r1y > r2y + (l2y - r2y)) ):
				return false
	#Check for conflict with dragon bones
	size = DRAGONBONESVARS.getTileAreaCoverage()
	for entityLocation in dragonBonesLocations: #These are Vector2s
		var r1x = loc[0] + -1 #min
		var l1x = loc[0] + 1 #max
		var r1y = loc[1] + -1 #min
		var l1y = loc[1] + 1 #max
		var r2x = world_to_map(entityLocation)[0] + size[0][0] #min
		var l2x = world_to_map(entityLocation)[0] + size[1][0] #max
		var r2y = world_to_map(entityLocation)[1] + size[0][1] #min
		var l2y = world_to_map(entityLocation)[1] + size[1][1] #max
		if(tileRange != []):
			r1x = loc[0] + tileRange[0][0] #min
			l1x = loc[0] + tileRange[1][0] #max
			r1y = loc[1] + tileRange[0][1] #min
			l1y = loc[1] + tileRange[1][1] #max
		if !( (r1x + (l1x - r1x) < r2x)  || (r1x > r2x + (l2x - r2x))
			|| (r1y + (l1y - r1y) < r2y) || (r1y > r2y + (l2y - r2y)) ):
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
		var pathX = -1
		for a in range (pathCount):
			if pathX == -1:
				pathX = rng.randi_range(5, fieldWidth - 5)
			else:
				pathX = (pathX + ( fieldWidth - 10 / 2 )) % (fieldWidth - 10) + 5
			for y in range (fieldLength):
				for i in range (-1, 2):
					for j in range (-1, 2):
						if(y + j < fieldLength && y + j > -1):
							set_cell(pathX + i, y + j, pathTileID, false, false, false, Vector2(0, 0))
							tallGrassReference.set_cell(pathX + i, y + j, -1, false, false, false, Vector2(0, 0))
				if pathX > 5:
					if pathX < fieldWidth - 5:
						pathX += rng.randi_range(-1, 1)
					else:
						pathX += -1
				else:
					pathX += 1
	
	#Filter some noise from map generation - Stops individual blocks and single block beam shoots?
	if(filter):
		filterGeneration(self)
		filterGeneration(tallGrassReference)
	
	update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
	tallGrassReference.update_bitmask_region(Vector2(0, 0), Vector2(fieldLength, fieldWidth))
	
	##Generate Entities
	
	#Generate Burrows
	if(burrows):
		if(maxBurrowsSpawned < 0):
			#Set to basically infinity if no max is given
			maxBurrowsSpawned = int(9223372036854775807)
		var tries = 0 #Tracks the tries the game takes to spawn dragon bones
		#Ensures that dragon bones are spawned the min number of times
		while(burrowLocations.size() <= minBurrowsSpawned && tries < maxTries): 
			tries += 1 #increments tries
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
							var spawnLoc = Vector2(x*regionSize + rng.randi_range(0,regionSize-1),actualY*regionSize + rng.randi_range(0,regionSize-1))
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
											spawnLoc = Vector2(x*regionSize + rng.randi_range(0,regionSize-1), actualY*regionSize + rng.randi_range(0,regionSize-1))
										else:
											var spawnNear = true
											#Check to see if burrows are near each other
											#Spreads burrows spawns out more
											for burrowLocation in burrowLocations:
												var burrow_map_coord = world_to_map(burrowLocation)
												#Check Surrounding 3x3
												if((burrow_map_coord[0] + 1 >= spawnLoc[0] && burrow_map_coord[0] - 1 <= spawnLoc[0])
												&& (burrow_map_coord[1] + 1 >= spawnLoc[1] && burrow_map_coord[1] - 1 <= spawnLoc[1])):
													if(rng.randf() <= 1): 
														spawnNear = false
														i -= 1
														break
												#Check Surrounding 5x5
												elif((burrow_map_coord[0] + 2 >= spawnLoc[0] && burrow_map_coord[0] - 2 <= spawnLoc[0])
												&& (burrow_map_coord[1] + 2 >= spawnLoc[1] && burrow_map_coord[1] - 2 <= spawnLoc[1])):
													if(rng.randf() <= 0.8): 
														spawnNear = false
														i -= 1
														break
												elif((burrow_map_coord[0] + 3 >= spawnLoc[0] && burrow_map_coord[0] - 3 <= spawnLoc[0])
												&& (burrow_map_coord[1] + 3 >= spawnLoc[1] && burrow_map_coord[1] - 3 <= spawnLoc[1])):
													if(rng.randf() <= 0.6): 
														spawnNear = false
														i -= 1
														break
												elif((burrow_map_coord[0] + 4 >= spawnLoc[0] && burrow_map_coord[0] - 4 <= spawnLoc[0])
												&& (burrow_map_coord[1] + 4 >= spawnLoc[1] && burrow_map_coord[1] - 4 <= spawnLoc[1])):
													if(rng.randf() <= 0.4): 
														spawnNear = false
														i -= 1
														break
											#Spawn the bunnies if they can spawn
											if(spawnNear):
												#Spawn the burrow if it's in a valid space
												createBurrow(spawnLoc[0], spawnLoc[1])
												break #Stop the for loop since the burrow was created
					if(burrowLocations.size() >= maxBurrowsSpawned):
						break
				if(burrowLocations.size() >= maxBurrowsSpawned):
					break
			if(burrowLocations.size() >= maxBurrowsSpawned):
				break

	#Generate Fairy Logs
	if(fairyLogs):
		if(maxFairyLogsSpawned < 0):
			#Set to basically infinity if no max is given
			maxFairyLogsSpawned = int(9223372036854775807)
		var tries = 0 #Tracks the tries the game takes to spawn dragon bones
		#Ensures that dragon bones are spawned the min number of times
		while(logLocations.size() < minFairyLogsSpawned && tries < maxTries): 
			tries += 1 #increments tries
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
	#					#Player Spawn Area - Don't spawn anything in it -- BOXES 3,4
	#					if((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y == 0):
	#						# This is the spawn area-- Do not put anything here
	#						pass
	#					elif((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y >= (fieldWidth/regionSize)-2):
	#						# Don't spawn burrows in the boss area
	#						pass
	#					else:
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
										var spawnLoc = Vector2(x + rng.randi_range(-ceil(fairyLogRegionSize/2),ceil(fairyLogRegionSize/2)),actualY + rng.randi_range(-ceil(fairyLogRegionSize/2),ceil(fairyLogRegionSize/2)))
										#Try up to 32 times to place the fairy log
										for i in range(32):
											# Check if the log is spawning outside of the border
											if(spawnLoc[0] < fairyLogBorder || spawnLoc[1] < fairyLogBorder 
												|| spawnLoc[0] >= fieldLength - fairyLogBorder || spawnLoc[1] >= fieldWidth - fairyLogBorder):
													spawnLoc = Vector2(x + rng.randi_range(-ceil(fairyLogRegionSize/2),ceil(fairyLogRegionSize/2)),actualY + rng.randi_range(-ceil(fairyLogRegionSize/2),ceil(fairyLogRegionSize/2)))
											# Check if the fairy log can spawn
											elif(!canSpawnObject(spawnLoc, FAIRYLOGVARS.getTileAreaCoverage())):
											#if(get_cellv(spawnLoc) == waterTileID):
												#Try again if the spot it was attempted to be placed on is water
												spawnLoc = Vector2(x + rng.randi_range(-ceil(fairyLogRegionSize/2),ceil(fairyLogRegionSize/2)),actualY + rng.randi_range(-ceil(fairyLogRegionSize/2),ceil(fairyLogRegionSize/2)))
											else:
												var spawnNear = true
												#Check to see if burrows are near each other
												#Spreads burrows spawns out more
												for logLocation in logLocations:
													var log_map_coord = world_to_map(logLocation)
													#Check Surrounding 3x3
													var outerSize = 1
													if((log_map_coord[0] + FAIRYLOGVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && log_map_coord[0] - FAIRYLOGVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
													&& (log_map_coord[1] + FAIRYLOGVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && log_map_coord[1] - FAIRYLOGVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
														if(rng.randf() <= 0.8): 
															spawnNear = false
															i -= 1
															break
													#Check Surrounding 5x5
													outerSize = 2
													if((log_map_coord[0] + FAIRYLOGVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && log_map_coord[0] - FAIRYLOGVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
													&& (log_map_coord[1] + FAIRYLOGVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && log_map_coord[1] - FAIRYLOGVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
														if(rng.randf() <= 0.6): 
															spawnNear = false
															i -= 1
															break
													#Check Surrounding 7x7
													outerSize = 3
													if((log_map_coord[0] + FAIRYLOGVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && log_map_coord[0] - FAIRYLOGVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
													&& (log_map_coord[1] + FAIRYLOGVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && log_map_coord[1] - FAIRYLOGVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
														if(rng.randf() <= 0.4): 
															spawnNear = false
															i -= 1
															break
												#	outerSize = 4
												#	if((log_map_coord[0] + FAIRYLOGVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && log_map_coord[0] - FAIRYLOGVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
												#	&& (log_map_coord[1] + FAIRYLOGVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && log_map_coord[1] - FAIRYLOGVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
												#		if(rng.randf() <= 0.2): 
												#			spawnNear = false
												#			i -= 1
												#			break
												#Spawn the logs if they can spawn
												if(spawnNear):
													#Spawn the fairy log if it's in a valid space
													createFairyLog(spawnLoc[0], spawnLoc[1])
													tries = 0 #reset the tries
													break #Stop the for loop since the fairy log was created
										if(logLocations.size() >= maxFairyLogsSpawned):
											break
					if(logLocations.size() >= maxFairyLogsSpawned):
						break
				if(logLocations.size() >= maxFairyLogsSpawned):
					break
			if(logLocations.size() >= maxFairyLogsSpawned):
				break

	#Generate Dragon Bones
	if(dragonBones):
		if(maxDragonBonesSpawned < 0):
			#Set to basically infinity if no max is given
			maxDragonBonesSpawned = int(9223372036854775807)
		var tries = 0 #Tracks the tries the game takes to spawn dragon bones
		#Ensures that dragon bones are spawned the min number of times
		while(dragonBonesLocations.size() < minDragonBonesSpawned && tries < maxTries): 
			tries += 1 #increments tries
			#Squares in the X direction
			for x in range(dragonBonesBorder, fieldLength - dragonBonesBorder):
				#Squares in the Y direction
				for y in range(dragonBonesBorder, fieldWidth - dragonBonesBorder):
					#Acount for board orientation
					var actualY = fieldWidth - 1 - y
					## Quadratic Equation Difficulty Scaling
					var chance = ((dragonBonesMaxChance-dragonBonesMinChance)/pow(fieldLength - dragonBonesStartY, 2.0))*pow(y, 2.0) + dragonBonesMinChance
					# Check Scaling by min/max
					if(y <= dragonBonesStartY):
						chance = 0
					elif(chance < dragonBonesMinChance):
						chance = dragonBonesMinChance
					elif(chance > dragonBonesMaxChance):
						chance = dragonBonesMaxChance
					#Should be the size of the region, since it's a square region
					if(rng.randf() <= 1/pow(dragonBonesRegionSize, 2.0)):
#						#Player Spawn Area - Don't spawn anything in it -- BOXES 3,4
#						if((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y == 0):
#							# This is the spawn area-- Do not put anything here
#							pass
#						elif((x == ((fieldLength / regionSize)/2)-1 || x == (fieldLength / regionSize)/2 + 0) && y >= (fieldWidth/regionSize)-2):
#							# Don't spawn burrows in the boss area
#							pass
#						else:
							#RNG to determine if it will spawn
							var rng_val = rng.randf()
							#Determine if the dragonBones will spawn
							#print("RNG VAL: " + str(rng_val) + " AND CHANCE: " + str(chance) + " - " + str(Vector2(x, y)))
							if(rng_val <= chance):
								#Spawn at least 1, and then chance spawn as many as needed
								for spawns in range(maxDragonBonesPerSquare):
									var willSpawn = true
									if(spawns > 0):
										#Run the RNG to spawn another one
										rng_val = rng.randf()
										#Scale chance
										chance = ((dragonBonesMaxChance-dragonBonesMinChance)/pow(fieldLength - dragonBonesStartY, 2.0))*pow(y, 2.0) + fairyLogMinChance
										# Check Scaling by min/max
										if(actualY <= dragonBonesStartY):
											chance = 0
										elif(chance < dragonBonesMinChance):
											chance = dragonBonesMinChance
										elif(chance > dragonBonesMaxChance):
											chance = dragonBonesMaxChance
										#Check if the chance is good to spawn another one
										if(rng_val <= chance):
												willSpawn = true
										else:
												willSpawn = false
									if(willSpawn):
										#Initial spawn location
										var spawnLoc = Vector2(x + rng.randi_range(-ceil(dragonBonesRegionSize/2),ceil(dragonBonesRegionSize/2)),actualY + rng.randi_range(-ceil(dragonBonesRegionSize/2),ceil(dragonBonesRegionSize/2)))
										#Try up to 32 times to place the fairy log
										for i in range(32):
											# Check if the log is spawning outside of the border
											if(spawnLoc[0] < dragonBonesBorder || spawnLoc[1] < dragonBonesBorder
												|| spawnLoc[0] >= fieldLength - dragonBonesBorder - 1 || spawnLoc[1] >= fieldWidth - dragonBonesBorder):
													spawnLoc = Vector2(x + rng.randi_range(-ceil(dragonBonesRegionSize/2),ceil(dragonBonesRegionSize/2)),actualY + rng.randi_range(-ceil(dragonBonesRegionSize/2),ceil(dragonBonesRegionSize/2)))
											# Check if the dragon bones can spawn
											elif(!canSpawnObject(spawnLoc, DRAGONBONESVARS.getTileAreaCoverage())):
												#Try again if the spot it was attempted to be placed on is water
												spawnLoc = Vector2(x + rng.randi_range(-ceil(dragonBonesRegionSize/2),ceil(dragonBonesRegionSize/2)),actualY + rng.randi_range(-ceil(dragonBonesRegionSize/2),ceil(dragonBonesRegionSize/2)))
											else:
												var spawnNear = true
												#Check to see if burrows are near each other
												#Spreads burrows spawns out more
												for dragonBonesLocation in dragonBonesLocations:
													var dragonBones_map_coord = world_to_map(dragonBonesLocation)
													#Check Surrounding 3x3
													var outerSize = 1
													if((dragonBones_map_coord[0] + DRAGONBONESVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && dragonBones_map_coord[0] - DRAGONBONESVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
													&& (dragonBones_map_coord[1] + DRAGONBONESVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && dragonBones_map_coord[1] - DRAGONBONESVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
														if(rng.randf() <= 0.8): 
															spawnNear = false
															i -= 1
															break
													#Check Surrounding 5x5
													outerSize = 2
													if((dragonBones_map_coord[0] + DRAGONBONESVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && dragonBones_map_coord[0] - DRAGONBONESVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
													&& (dragonBones_map_coord[1] + DRAGONBONESVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && dragonBones_map_coord[1] - DRAGONBONESVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
														if(rng.randf() <= 0.6): 
															spawnNear = false
															i -= 1
															break
													#Check Surrounding 7x7
													outerSize = 3
													if((dragonBones_map_coord[0] + DRAGONBONESVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && dragonBones_map_coord[0] - DRAGONBONESVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
													&& (dragonBones_map_coord[1] + DRAGONBONESVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && dragonBones_map_coord[1] - DRAGONBONESVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
														if(rng.randf() <= 0.4): 
															spawnNear = false
															i -= 1
															break
													#Check Surrounding 9x9
												#	outerSize = 1
												#	if((dragonBones_map_coord[0] + DRAGONBONESVARS.getTileAreaCoverage()[1][0] + outerSize >= spawnLoc[0] && dragonBones_map_coord[0] - DRAGONBONESVARS.getTileAreaCoverage()[0][0] - outerSize <= spawnLoc[0])
												#	&& (dragonBones_map_coord[1] + DRAGONBONESVARS.getTileAreaCoverage()[1][1] + outerSize >= spawnLoc[1] && dragonBones_map_coord[1] - DRAGONBONESVARS.getTileAreaCoverage()[0][1] - outerSize <= spawnLoc[1])):
												#		if(rng.randf() <= 0.2): 
												#			spawnNear = false
												#			i -= 1
												#			break
												#Spawn the dragon bones if they can spawn
												if(spawnNear):
													#Spawn the dragon bones if it's in a valid space
													createDragonBones(spawnLoc[0], spawnLoc[1])
													tries = 0 #reset the tries
													break #Stop the for loop since the burrow was created
										if(dragonBonesLocations.size() >= maxDragonBonesSpawned):
											break
					if(dragonBonesLocations.size() >= maxDragonBonesSpawned):
						break
				if(dragonBonesLocations.size() >= maxDragonBonesSpawned):
					break
			if(dragonBonesLocations.size() >= maxDragonBonesSpawned):
				break
