var rng
var map_size
var rooms

func _init(prng, psize):
	rng = prng
	map_size = psize

func make_dungeon(times):
	var base = make_base(map_size.x, map_size.y)
	rooms = []
	divide(base, Vector2(), map_size-Vector2(1,1), times, 2, .5)
	return base

func divide(base, from, to, times, times_hall, horizontal):
	var size = to - from
	if (size.x <= 4 and size.y <= 4) or times <= 0:
		rooms.append([from, to])
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
		var wall = rng.randi_range(from.y+2, to.y-2)
		fill(base, Vector2(from.x, wall-gap), Vector2(to.x, wall+gap), 1)
		divide(base, Vector2(from.x, from.y), Vector2(to.x, wall-gap), times-1, times_hall-1, horizontal_roll+.2)
		divide(base, Vector2(from.x, wall+gap), Vector2(to.x, to.y), times-1, times_hall-1, horizontal_roll+.2)
		if times_hall > 0:
			rooms.append([Vector2(from.x, wall-gap), Vector2(to.x, wall+gap)])
			fill(base, Vector2(from.x, wall), Vector2(to.x, wall), 0)
			doorCandidates.append([0, from.x, wall-gap, to.x, wall-gap])
			doorCandidates.append([0, from.x, wall+gap, to.x, wall+gap])
			doorCandidates.append([0, from.x, wall-gap, to.x, wall+gap])
		else:
			doorCandidates.append([0, from.x, wall, to.x, wall])
	else: #vertical
		var wall = rng.randi_range(from.x+2, to.x-2)
		fill(base, Vector2(wall-gap, from.y), Vector2(wall+gap, to.y), 1)
		divide(base, Vector2(from.x, from.y), Vector2(wall-gap, to.y), times-1, times_hall-1, horizontal_roll-.2)
		divide(base, Vector2(wall+gap, from.y), Vector2(to.x, to.y), times-1, times_hall-1, horizontal_roll-.2)
		if times_hall > 0:
			rooms.append([Vector2(wall-gap, from.y), Vector2(wall+gap, to.y)])
			fill(base, Vector2(wall, from.y), Vector2(wall, to.y), 0)
			doorCandidates.append([1, wall-gap, from.y, wall-gap, to.y])
			doorCandidates.append([1, wall+gap, from.y, wall+gap, to.y])
			doorCandidates.append([1, wall-gap, from.y, wall+gap, to.y])
		else:
			doorCandidates.append([1, wall, from.y, wall, to.y])
	for doorCandidate in doorCandidates:
		var doors = []
		if doorCandidate[0] == 0:
			for i in range(doorCandidate[1]+1, doorCandidate[3]):
				if base[doorCandidate[2]][i] == 1 and base[doorCandidate[2]+1][i] == 0 and base[doorCandidate[2]-1][i] == 0:
					doors.append(Vector2(i, doorCandidate[2]))
		else:
			for i in range(doorCandidate[2]+1, doorCandidate[4]):
				if base[doorCandidate[2]][i] == 1 and base[i][doorCandidate[1]+1] == 0 and base[i][doorCandidate[1]-1] == 0:
					doors.append(Vector2(doorCandidate[1], i))
		if !doors.empty():
			var t = doors[rng.randi_range(0, len(doors)-1)]
			base[t.y][t.x] = 2


func fill(base, from, to, val):
	for y in range(from.y, to.y+1):
		for x in range(from.x, to.x+1):
			base[y][x] = val

func make_base(sx, sy):
	var base = []
	for _y in range(sy):
		var row = []
		for _x in range(sx):
			row.append(0)
		base.append(row)
	return base

func make_random(sx, sy):
	var base = []
	for _y in range(sy):
		var row = []
		for _x in range(sx):
			row.append(rng.randf())
		base.append(row)
	return base
		
func interpolate(arg1, arg2, alpha):
	return arg1 * (1 - alpha) + alpha * arg2


func invert(base):
	var width = len(base[0])
	var height = len(base)
	for i in range(height):
		for j in range(width):
			base[i][j] = 1 - base[i][j]
	return base


func make_border(base):
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
