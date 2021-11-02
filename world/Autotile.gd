const orientations = [0, 10, 16, 22]#Z-,Z+,X-,X+

const autotile_map = [
	[[0,1,1,1],[1,0,1,1],[1,1,0,1],[1,1,1,0]],
	[[0,0,1,1],[0,0,1,1],[1,1,0,0],[1,1,0,0]],
	[[0,1,1,0],[1,0,0,1],[0,1,0,1],[1,0,1,0]],
	[[0,0,1,0],[0,0,0,1],[0,1,0,0],[1,0,0,0]],
	[[1,1,1,1]],
	[[0,0,0,0]],
]
var autotile_map_to

var gridmap
var map
var size

func _init(p, pmap):
	gridmap = p
	map = pmap
	size = Vector2(len(map[0])-1, len(map)-1)
	autotile_map_to = [
		gridmap.wallsplit,
		gridmap.wall,
		gridmap.wallcorner,
		gridmap.wallend,
		gridmap.wallcross,
		gridmap.wallsingle,
	]

func autotile():
	var wall_autotiles = []
	var autotile
	var walls = G.world.SEMIWALLTILES
	for x in range(0, size.x+1, 2):
		for y in range(0, size.y+1, 2):
			var at = map[y][x]
			if at in walls:
				autotile = set_autotile(walls, x, y, autotile_map)
				if autotile:
					wall_autotiles.append(autotile)
	for cell in wall_autotiles:
		var x = cell[0]
		var y = cell[1]
		var tile
		if map[y][x] == 'D':
			if check_adjacent(map, x, y, '#', 2):
				tile = gridmap.fencedoor
			else:
				tile = gridmap.door
		elif map[y][x] == '=':
			if check_adjacent(map, x, y, '#', 2):
				tile = gridmap.fencewindow
			else:
				tile = gridmap.window
		else:
			tile = autotile_map_to[cell[2]]
		gridmap.set_cell_item(x/2, 0, y/2, tile, orientations[cell[3]])

func set_autotile(compare, x, y, dict):
	var adj = [0,0,0,0]
	if y > 0 and map[y-1][x] in compare:
		adj[0] = 1
	if y < size.y and map[y+1][x] in compare:
		adj[1] = 1
	if x > 0 and map[y][x-1] in compare:
		adj[2] = 1
	if x < size.x and map[y][x+1] in compare:
		adj[3] = 1
	var count = 0
	var orientation
	for v in dict:
		orientation = 0
		for sidereqs in v:
			if is_matching(adj, sidereqs):
				return [x, y, count, orientation]
			orientation += 1
		count += 1

func is_matching(adj, req):
	for i in range(4):
		if adj[i] != req[i]:
			return false
	return true

func check_adjacent(base, x, y, tile, dist=1):
	if base[y][x] == tile or\
		(y+dist < len(base) and base[y+dist][x] == tile) or\
		(y-dist >= 0 and base[y-dist][x] == tile) or\
		(x+dist < len(base[0]) and base[y][x+dist] == tile) or\
		(x-dist >= 0 and base[y][x-dist] == tile):
			return true
	return false
