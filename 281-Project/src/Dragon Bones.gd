extends StaticBody2D

#Check main for the detection of dragon bones.
#The oil rig placement radius is determined in the global.gd file. Default = 2

func _ready():
	#Get the tile map
	var tilemap = get_parent().get_parent().get_node("Navigation2D").get_node("TileMap")
	#Add the location of the dragon bones to the location list in tilemap
	tilemap.dragonBonesLocations.append(tilemap.world_to_map(self.position))
