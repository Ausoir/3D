extends Node


var rng
var map_size

func _init(prng, psize):
	rng = prng
	map_size = psize

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


func make_smooth(base, level):
	var w = len(base[0])
	var h = len(base)
	var map = []
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
			var top = interpolate(base[sample1][sample3], base[sample2][sample3], horizontal_blend)
			var bot = interpolate(base[sample1][sample4], base[sample2][sample4], horizontal_blend)
			row.append(interpolate(top, bot, vertical_blend))
		map.append(row)
	return map
		
func interpolate(arg1, arg2, alpha):
	return arg1 * (1 - alpha) + alpha * arg2

func make_perlin(sx, sy):
	var base = make_random(sx, sy)
	var map = make_base(sx, sy)
	var levels = 4
	var max_value = 0
	for i in range(1, levels):
		max_value += float(1)/i
	for level in range(1, levels):
		var graph = make_smooth(base, level)
		for y in range(sy):
			for x in range(sx):
				map[y][x] += graph[y][x] * 1/level
	for y in range(sy):
		for x in range(sx):
			map[y][x] /= max_value
	return map

func smooth_edges(base, val):
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


func radialize(base):
	var width = len(base[0])
	var height = len(base)
	var center_x = int(width * .5)
	var center_y = int(height * .5)
	for i in range(height):
		for j in range(width):
			var val_y = pow(float(i - center_y) / center_y, 2)
			var val_x = pow(float(j - center_x) / center_x, 2)
			var val = min(1, (1-sqrt(val_x+val_y)) * 4)
			base[i][j] = val * base[i][j]
	return base


func invert(base):
	var width = len(base[0])
	var height = len(base)
	for i in range(height):
		for j in range(width):
			base[i][j] = 1 - base[i][j]
	return base
