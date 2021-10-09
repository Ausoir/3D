var rng
var map_size
var base
var sector_borders
var sectors
var rooms
var objects

func _init(prng, psize):
	rng = prng
	map_size = psize

func make_dungeon(times, halls):
	base = make_base(map_size.x, map_size.y, 0)
	sector_borders = []
	sectors = {}
	rooms = []
	objects = make_base(map_size.x, map_size.y, null)
	divide(Vector2.ONE, map_size-Vector2(2,2), times, halls, .5)
	return base

func make_rooms(departments):
	for room in rooms:
		var doors = 0
		for y in range(room[1].y, room[2].y+1):
			if base[y][room[1].x] == 2:
				doors += 1
			if base[y][room[2].x] == 2:
				doors += 1
		for x in range(room[1].x, room[2].x+1):
			if base[room[1].y][x] == 2:
				doors += 1
			if base[room[2].y][x] == 2:
				doors += 1
		var sector = get_sector(Vector2(room[1].x + 1, room[1].y + 1))
		if sector != null:
			sectors[sector] = ""
		room.append(sector)
		room.append(doors)
		print(room)

	var tpartments = departments[0].duplicate()
	var fillpartments = departments[1]
	tpartments.shuffle()
	for s in sectors:
		var department = tpartments.pop_back()
		if department != null:
			sectors[s] = department
		else:
			sectors[s] = fillpartments[rng.randi_range(0, len(fillpartments)-1)]
	print(sectors)

	for room in rooms: #name, from, to, sector, door
		make_terrain(room)
		if room[0] == "hall":
			make_hall(room)
		elif sectors[room[3]] == "storage":
			make_storage(room)

func make_storage(room):
	pass

func make_hall(room):
	var size = room[2] - room[1]
	if size.y <= 4:
		for x in range(room[1].x+2, room[2].x-1, 5):
			if rng.randi_range(0, 1) == 0:
				objects[room[1].y][x] = ["torch", 10]
			else:
				objects[room[2].y][x] = ["torch", 0]
	elif size.x <= 4:
		for y in range(room[1].y+2, room[2].y-1, 5):
			if rng.randi_range(0, 1) == 0:
				objects[y][room[1].x] = ["torch", 16]
			else:
				objects[y][room[2].x] = ["torch", 22]

func make_terrain(room):
	var size = room[2] - room[1]
	if size.x >= 3 and size.y >= 3:
		var gapsizex = int(size.x/3)
		var gapsizey = int(size.y/3)
		var gaprx = rng.randi_range(1, 3)
		var gapry = rng.randi_range(1, 3)
		var gapx = rng.randi_range(0, gapsizex)
		var gapy = rng.randi_range(0, gapsizey)
		var gapx2 = rng.randi_range(1 if gapx == 0 else 0, gapsizex)
		var gapy2 = rng.randi_range(1 if gapy == 0 else 0, gapsizey)
		if gaprx == gapry and gaprx == 1:
			gapx = max(1, gapx)
			gapy = max(1, gapy)
		for y in range(room[1].y+gapy+1, room[2].y-gapy2, gapry):
			for x in range(room[1].x+gapx+1, room[2].x-gapx2, gaprx):
				if !check_adjacent(x, y, 2):
					base[y][x] = 1

func divide(from, to, times, times_hall, horizontal):
	var size = to - from
	if (size.x <= 4 and size.y <= 4) or times <= 0:
		rooms.append(["room", from, to])
		return times <= 0
	elif size.x <= 4:
		horizontal = 1
	elif size.y <= 4:
		horizontal = 0
	var doorCandidates = []
	var horizontal_roll = rng.randf()
	var gap = 0
	if times_hall > 0:
		gap = 1
	if horizontal_roll < horizontal: #horizontal
		var wall = rng.randi_range(from.y+2+gap, to.y-2-gap)
		fill(Vector2(from.x, wall-gap), Vector2(to.x, wall+gap), 1)
		divide(Vector2(from.x, from.y), Vector2(to.x, wall-gap), times-1, times_hall-1, 0)
		divide(Vector2(from.x, wall+gap), Vector2(to.x, to.y), times-1, times_hall-1, 0)
		if gap > 0:
			rooms.append(["hall", Vector2(from.x, wall-gap), Vector2(to.x, wall+gap)])
			fill(Vector2(from.x, wall), Vector2(to.x, wall), 0)
			doorCandidates.append([0, from.x, wall-gap, to.x, wall-gap])
			doorCandidates.append([0, from.x, wall+gap, to.x, wall+gap])
			if times_hall == 1:
				sector_borders.append([Vector2(from.x, from.y), Vector2(to.x, wall-gap)])
				sector_borders.append([Vector2(from.x, wall+gap), Vector2(to.x, to.y)])
		else:
			doorCandidates.append([0, from.x, wall, to.x, wall])
	else: #vertical
		var wall = rng.randi_range(from.x+2+gap, to.x-2-gap)
		fill(Vector2(wall-gap, from.y), Vector2(wall+gap, to.y), 1)
		divide(Vector2(from.x, from.y), Vector2(wall-gap, to.y), times-1, times_hall-1, 1)
		divide(Vector2(wall+gap, from.y), Vector2(to.x, to.y), times-1, times_hall-1, 1)
		if gap > 0:
			rooms.append(["hall", Vector2(wall-gap, from.y), Vector2(wall+gap, to.y)])
			fill(Vector2(wall, from.y), Vector2(wall, to.y), 0)
			doorCandidates.append([1, wall-gap, from.y, wall-gap, to.y])
			doorCandidates.append([1, wall+gap, from.y, wall+gap, to.y])
			if times_hall == 1:
				sector_borders.append([Vector2(from.x, from.y), Vector2(wall-gap, to.y)])
				sector_borders.append([Vector2(wall+gap, from.y), Vector2(to.x, to.y)])
		else:
			doorCandidates.append([1, wall, from.y, wall, to.y])
	for doorCandidate in doorCandidates:
		var doors = []
		if doorCandidate[0] == 0:
			for i in range(doorCandidate[1]+1, doorCandidate[3]):
				if base[doorCandidate[2]+1][i] == 0 and base[doorCandidate[2]-1][i] == 0:
					doors.append(Vector2(i, doorCandidate[2]))
		else:
			for i in range(doorCandidate[2]+1, doorCandidate[4]):
				if base[i][doorCandidate[1]+1] == 0 and base[i][doorCandidate[1]-1] == 0:
					doors.append(Vector2(doorCandidate[1], i))
		if doors.empty():
			print("Door couldn't be placed: ", doorCandidate)
		else:
			var t = doors[rng.randi_range(0, len(doors)-1)]
			base[t.y][t.x] = 2


func fill(from, to, val):
	for y in range(from.y, to.y+1):
		for x in range(from.x, to.x+1):
			base[y][x] = val

func make_base(sx, sy, val):
	var r = []
	for _y in range(sy):
		var row = []
		for _x in range(sx):
			row.append(val)
		r.append(row)
	return r

func make_random(sx, sy):
	var r = []
	for _y in range(sy):
		var row = []
		for _x in range(sx):
			row.append(rng.randf())
		r.append(row)
	return r
		
func interpolate(arg1, arg2, alpha):
	return arg1 * (1 - alpha) + alpha * arg2


func invert(base):
	var width = len(base[0])
	var height = len(base)
	for i in range(height):
		for j in range(width):
			base[i][j] = 1 - base[i][j]
	return base


func make_border():
	for i in range(len(base)):
		base[i][0] = 1
		base[i][len(base[0])-1] = 1
	for i in range(len(base[0])):
		base[0][i] = 1
		base[len(base)-1][i] = 1
	return base

func set_heightmap(size, map):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(size.x, size.y, false, 4)
	image.fill(Color(0, 0, 0))
	image.lock()
	for x in range(size.x):
		for y in range(size.y):
			var val = float(floor(map[y][x] * 3)) / 3
			image.set_pixel(x, y, Color(val, val, val))
	texture.create_from_image(image)
	#$Map.get_surface_material(0).albedo_texture = texture

func check_adjacent(x, y, tile):
	if base[y][x] == tile or\
		(y+1 < len(base) and base[y+1][x] == tile) or\
		(y-1 >= 0 and base[y-1][x] == tile) or\
		(x+1 < len(base[0]) and base[y][x+1] == tile) or\
		(x-1 >= 0 and base[y][x-1] == tile):
			return true
	return false

func get_sector(pos):
	var count = 1
	for sector in sector_borders:
		if pos.x >= sector[0].x and pos.x <= sector[1].x and\
			pos.y >= sector[0].y and pos.y <= sector[1].y:
			return count
		count += 1
