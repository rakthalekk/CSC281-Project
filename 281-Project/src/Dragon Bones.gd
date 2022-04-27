extends StaticBody2D

#Check main for the detection of dragon bones.
#The oil rig placement radius is determined in the global.gd file. Default = 2

#Get tile area covered- relative to tile spawnpoint
static func getTileAreaCoverage():
	var tileAreaMin = [-2,-2] #Top left corner of the object #ACTUAL SIZE: [-2, -2]
	var tileAreaMax = [1,1] #Bottom right corner of the object #ACTUAL SIZE: [1, 1]
	return [tileAreaMin,tileAreaMax]

func _ready():
	#Get the tile map
	var tilemap = get_parent().get_parent().get_node("Navigation2D").get_node("TileMap")
	#Add the location of the dragon bones to the location list in tilemap (if not already added from script)
	if(tilemap.dragonBonesLocations.find(self.position) != -1):
		tilemap.dragonBonesLocations.append(tilemap.world_to_map(self.position))
