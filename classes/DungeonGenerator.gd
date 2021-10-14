extends "res://classes/Generator.gd"

var vaults = preload("res://world/Vaults.gd").new()
var biome
var sector_borders
var sectors
var rooms
var objects


func _init(prng, psize).(prng, psize):
	pass

func make_dungeon(times, halls):
	biome = make_perlin(map_size.x, map_size.y)
	base = make_base(map_size.x, map_size.y, '.')
	sector_borders = []
	sectors = {}
	rooms = []
	objects = make_base(map_size.x, map_size.y, null)
	divide(Vector2(), map_size-Vector2.ONE, times, halls, .5)
	return base

func make_rooms(departments):
	for room in rooms:
		var doors = 0
		for y in range(room[1].y, room[2].y+1):
			if base[y][room[1].x] == 'D':
				doors += 1
			if base[y][room[2].x] == 'D':
				doors += 1
		for x in range(room[1].x, room[2].x+1):
			if base[room[1].y][x] == 'D':
				doors += 1
			if base[room[2].y][x] == 'D':
				doors += 1
		var sector = get_sector(Vector2(room[1].x + 1, room[1].y + 1))
		if sector != null:
			sectors[sector] = ""
		room.append(sector)
		room.append(doors)

	var tpartments = departments[0].duplicate()
	var fillpartments = departments[1]
	tpartments.shuffle()
	for s in sectors:
		var department = tpartments.pop_back()
		if department != null:
			sectors[s] = department
		else:
			sectors[s] = rng.rand_arr(fillpartments)

	for room in rooms: #name, from, to, sector, door
		make_terrain(room)
		continue
		if room[3] == null: #halls
			make_hall(room)
		elif sectors[room[3]] == "living":
			make_living(room)
		elif sectors[room[3]] == "storage":
			make_storage(room)
		elif sectors[room[3]] == "defense":
			make_defense(room)
		elif sectors[room[3]] == "lab":
			make_defense(room)

func make_defense(room):
	for y in range(room[1].y+1, room[2].y):
		for x in range(room[1].x+1, room[2].x):
			if base[y][x] == '.':
				var objs = ["beds", "bed cluster", "barrels", "crates"]
				var obj = objs[rng.randi_range(0, len(objs)-1)]
				place_object(obj, x, y)

func make_living(room):
	for y in range(room[1].y+1, room[2].y):
		for x in range(room[1].x+1, room[2].x):
			if base[y][x] == '.':
				var objs = ["table", "large table", "pots", "beds", "bed cluster", "bookcase", "bookcase", "barrels"]
				var obj = objs[rng.randi_range(0, len(objs)-1)]
				place_object(obj, x, y)

func make_storage(room):
	for y in range(room[1].y+1, room[2].y):
		for x in range(room[1].x+1, room[2].x):
			if base[y][x] == '.':
				var objs = ["chest", "crates", "crates", "crates", "crates", "barrels", "barrels", null, null]
				var obj = objs[rng.randi_range(0, len(objs)-1)]
				place_object(obj, x, y)

func place_object(obj, x, y):
	if obj == "chest" or obj == "crates" or obj == "barrels" or obj == "bookcase":
		if base[y][x] == '.':
			var possibleSides = get_possible_sides(x, y, 'W')
			if !possibleSides.empty():
				objects[y][x] = [obj, rng.rand_arr(possibleSides)]
	elif obj == "pots" or obj == "beds":
		if base[y][x] == '.':
			var possibleSides = get_possible_sides(x, y, 'W')
			if len(possibleSides) >= 2:
				objects[y][x] = [obj, rng.rand_arr(possibleSides)]
	elif obj == "bed cluster":
		if base[y][x] == '.' and !check_adjacent(x, y, 'W') and !check_adjacent(x, y, 'D'):
			var possibleSides = get_possible_sides(x, y, '.')
			if len(possibleSides) >= 4:
				objects[y][x] = [obj, rng.rand_arr(possibleSides)]
	elif obj == "table" or obj == "large table":
		if base[y][x] == '.' and !check_adjacent(x, y, 'D') and !check_adjacent_object(x, y, obj):
			var possibleSides = get_possible_sides(x, y, '.')
			if len(possibleSides) >= 1:
				objects[y][x] = [obj, rng.rand_arr(possibleSides)]
	if objects[y][x] != null:
		base[y][x] = ','

func make_hall(room):
	var size = room[2] - room[1]
	if size.y <= 4:
		for x in range(room[1].x+1, room[2].x-1, 5):
			if rng.randi_range(0, 1) == 0:
				if base[room[1].y][x] == 'W' and base[room[1].y][x+1] == 'W':
					objects[room[1].y][x] = ["torch", 10]
			else:
				if base[room[2].y][x] == 'W' and base[room[2].y][x-1] == 'W':
					objects[room[2].y][x] = ["torch", 0]
	elif size.x <= 4:
		for y in range(room[1].y+1, room[2].y-1, 5):
			if rng.randi_range(0, 1) == 0:
				if base[y][room[1].x] == 'W' and base[y-1][room[1].x] == 'W':
					objects[y][room[1].x] = ["torch", 16]
			else:
				if base[y][room[2].x] == 'W' and base[y+1][room[2].x] == 'W':
					objects[y][room[2].x] = ["torch", 22]

func make_terrain(room):
	if rng.randi_range(0, 1) >= 0:
		vaults.make_vault(rng, base, room[1], room[2])
	else:
		var size = room[2] - room[1]
		if size.x >= 3 and size.y >= 3:
			var gapsizex = int(size.x/3)
			var gapsizey = int(size.y/3)
			var gaprx = rng.randi_range(1, 2)
			var gapry = rng.randi_range(1, 2)
			var gapx = rng.randi_range(0, gapsizex)
			var gapy = rng.randi_range(0, gapsizey)
			var gapx2 = rng.randi_range(1 if gapx == 0 else 0, gapsizex)
			var gapy2 = rng.randi_range(1 if gapy == 0 else 0, gapsizey)
			if gaprx == gapry and gaprx == 1:
				gapx = max(1, gapx)
				gapy = max(1, gapy)
				gapx2 = max(1, gapx2)
				gapy2 = max(1, gapy2)
			for y in range(room[1].y+gapy+1, room[2].y-gapy2, gapry):
				for x in range(room[1].x+gapx+1, room[2].x-gapx2, gaprx):
					if base[y][x] != 'D' and !check_adjacent(x, y, 'D'):
						if rng.randi_range(1, 9) == 9:
							base[y][x] = '#'
						else:
							base[y][x] = 'W'

func divide(from, to, times, times_hall, horizontal):
	var size = to - from
	if (size.x <= 4 and size.y <= 4) or times <= 0:
		if size.x > 6 or size.y > 6:
			if abs(size.x-size.y) > (size.x+size.y)/2:
				rooms.append(["long", from, to])
			else:
				rooms.append(["large", from, to])
		else:
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
		fill(Vector2(from.x, wall-gap), Vector2(to.x, wall+gap), 'W')
		divide(Vector2(from.x, from.y), Vector2(to.x, wall-gap), times-1, times_hall-1, 0)
		divide(Vector2(from.x, wall+gap), Vector2(to.x, to.y), times-1, times_hall-1, 0)
		if gap > 0:
			rooms.append(["hall", Vector2(from.x, wall-gap), Vector2(to.x, wall+gap)])
			fill(Vector2(from.x, wall), Vector2(to.x, wall), '.')
			doorCandidates.append([0, from.x, wall-gap, to.x, wall-gap])
			doorCandidates.append([0, from.x, wall+gap, to.x, wall+gap])
			if times_hall == 1:
				sector_borders.append([Vector2(from.x, from.y), Vector2(to.x, wall-gap)])
				sector_borders.append([Vector2(from.x, wall+gap), Vector2(to.x, to.y)])
		else:
			doorCandidates.append([0, from.x, wall, to.x, wall])
	else: #vertical
		var wall = rng.randi_range(from.x+2+gap, to.x-2-gap)
		fill(Vector2(wall-gap, from.y), Vector2(wall+gap, to.y), 'W')
		divide(Vector2(from.x, from.y), Vector2(wall-gap, to.y), times-1, times_hall-1, 1)
		divide(Vector2(wall+gap, from.y), Vector2(to.x, to.y), times-1, times_hall-1, 1)
		if gap > 0:
			rooms.append(["hall", Vector2(wall-gap, from.y), Vector2(wall+gap, to.y)])
			fill(Vector2(wall, from.y), Vector2(wall, to.y), '.')
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
				if base[doorCandidate[2]+1][i] == '.' and base[doorCandidate[2]-1][i] == '.':
					doors.append(Vector2(i, doorCandidate[2]))
		else:
			for i in range(doorCandidate[2]+1, doorCandidate[4]):
				if base[i][doorCandidate[1]+1] == '.' and base[i][doorCandidate[1]-1] == '.':
					doors.append(Vector2(doorCandidate[1], i))
		if doors.empty():
			print("Door couldn't be placed: ", doorCandidate)
		else:
			var t = doors[rng.randi_range(0, len(doors)-1)]
			base[t.y][t.x] = 'D'

func get_sector(pos):
	var count = 1
	for sector in sector_borders:
		if pos.x >= sector[0].x and pos.x <= sector[1].x and\
			pos.y >= sector[0].y and pos.y <= sector[1].y:
			return count
		count += 1


func check_adjacent_object(x, y, tile):
	if objects[y][x] != null:
		if objects[y][x][0] == tile or\
			(y+1 < len(objects) and objects[y+1][x][0] == tile) or\
			(y-1 >= 0 and objects[y-1][x][0] == tile) or\
			(x+1 < len(objects[0]) and objects[y][x+1][0] == tile) or\
			(x-1 >= 0 and objects[y][x-1][0] == tile):
				return true
	return false
