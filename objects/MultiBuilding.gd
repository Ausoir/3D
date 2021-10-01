extends "res://objects/Building.gd"


func update_tiles():
	.update_tiles()
	var face = global_transform.basis.z
	var cdir = 0
	if abs(face.x) <= .7 and face.z < -.7:
		direction = 0
	elif face.x > .7 and abs(face.z) <= .7:
		direction = 16
		cdir = 1
	elif abs(face.x) <= .7 and face.z > .7:
		direction = 10
		cdir = 2
	elif face.x < -.7 and abs(face.z) <= .7:
		direction = 22
		cdir = 3
	var directions = [0, 16, 10, 22]
	for tile in $Tile.get_children():
		var vec = tile.global_transform.origin
		var v = tile.name.split("-")
		if v[0] == '2':
			var pos = G.world.world_to_map(vec)
			G.world.make("mineral", pos.x, pos.y, pos.z)
		elif v[0] == '1':
			if vec.y > 6:
				G.world.set_tile_at(vec, G.world.tilemap.dirt)
			else:
				G.world.set_tile_at(vec, G.world.tilemap.beach)
		elif v[0] == '0':
			G.world.set_tile_at(vec, -1)
		else:
			var dir = (cdir + int(v[1])) % 4
			G.world.set_tile_at(vec, int(v[0]), directions[dir])
