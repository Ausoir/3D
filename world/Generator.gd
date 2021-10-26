var rng
var map_size
var base


func _init(prng, psize):
	rng = prng
	map_size = psize

func set_heightmap(size, map):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(size.x, size.y, false, 4)
	image.fill(Color(0, 0, 0))
	image.lock()
	for x in range(size.x+1):
		for y in range(size.y+1):
			var val = float(floor(map[y][x] * 3)) / 3
			image.set_pixel(x, y, Color(val, val, val))
	texture.create_from_image(image)
	#$Map.get_surface_material(0).albedo_texture = texture

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


func make_smooth(map, level):
	var w = len(map[0])
	var h = len(map)
	var r = []
	var period = 2 << level
	var frequency = 1.0 / period
	for y in range(h):
		var sample1 = int(y / period) * period
		var sample2 = int((sample1 + period) % h)
		var horizontal_blend = (y - sample1) * frequency
		var row = []
		for x in range(w):
			var sample3 = int(x / period) * period
			var sample4 = int((sample3 + period) % w)
			var vertical_blend = (x - sample3) * frequency
			var top = interpolate(map[sample1][sample3], map[sample2][sample3], horizontal_blend)
			var bot = interpolate(map[sample1][sample4], map[sample2][sample4], horizontal_blend)
			row.append(interpolate(top, bot, vertical_blend))
		r.append(row)
	return r
		
func interpolate(arg1, arg2, alpha):
	return arg1 * (1 - alpha) + alpha * arg2

func make_perlin(sx, sy):
	var r = make_random(sx, sy)
	var map = make_base(sx, sy, 0)
	var levels = 4
	var max_value = 0
	for i in range(1, levels):
		max_value += float(1)/i
	for level in range(1, levels):
		var graph = make_smooth(r, level)
		for y in range(sy):
			for x in range(sx):
				map[y][x] += graph[y][x] * 1/level
	for y in range(sy):
		for x in range(sx):
			map[y][x] /= max_value
	return map

func smooth_edges(val):
	var width = len(base[0])
	var height = len(base)
	for y in range(height):
		for i in range(val):
			base[y][i] *= float(i)/val
			base[y][width-i-1] *= float(i)/val
	for x in range(width):
		for i in range(val):
			base[i][x] *= float(i)/val
			base[height-i-1][x] *= float(i)/val
	return base


func radialize():
	var width = len(base[0])
	var height = len(base)
	var center_x = int(width * .5)
	var center_y = int(height * .5)
	for i in range(height):
		for j in range(width):
			var val_y = pow(float(i - center_y) / center_y, 2)
			var val_x = pow(float(j - center_x) / center_x, 2)
			var val = min(1, (1-sqrt(val_x+val_y)) * 12)
			base[i][j] = val * base[i][j]
	return base


func invert():
	var width = len(base[0])
	var height = len(base)
	for i in range(height):
		for j in range(width):
			base[i][j] = 1 - base[i][j]
	return base


func fill(from, to, val):
	for y in range(from.y, to.y+1):
		for x in range(from.x, to.x+1):
			base[y][x] = val


func make_border(val):
	for i in range(len(base)):
		base[i][0] = val
		base[i][len(base[0])-1] = val
	for i in range(len(base[0])):
		base[0][i] = val
		base[len(base)-1][i] = val
	return base


func check_adjacent(x, y, tile):
	if base[y][x] == tile or\
		(y+1 < len(base) and base[y+1][x] == tile) or\
		(y-1 >= 0 and base[y-1][x] == tile) or\
		(x+1 < len(base[0]) and base[y][x+1] == tile) or\
		(x-1 >= 0 and base[y][x-1] == tile):
			return true
	return false


func get_possible_sides(x, y, valid):
	var r = []
	if base[y+1][x] == valid:
		r.append(0)
	if base[y-1][x] == valid:
		r.append(10)
	if base[y][x-1] == valid:
		r.append(16)
	if base[y][x+1] == valid:
		r.append(22)
	return r
