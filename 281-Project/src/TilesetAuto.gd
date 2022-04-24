tool
extends TileSet

var grassTileID = 2
var stoneTileID = 3
var grassNoNavID = 4
var stoneNoNavID = 5
var pathTileID = 7
var waterTileID = 8
var pathNoNavID = 9

var binds = {
	grassTileID: [grassNoNavID],
	grassNoNavID: [grassTileID],
	stoneTileID: [stoneNoNavID],
	stoneNoNavID: [stoneTileID],
	pathTileID: [pathNoNavID],
	pathNoNavID: [pathTileID]
}

func _is_tile_bound(drawn_id, neighbor_id):
	if drawn_id in binds:
		return neighbor_id in binds[drawn_id]
	return false
