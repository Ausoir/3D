class_name Pathing


const BLOCK = 2
const HALFBLOCK = BLOCK / 2
const ORTHO = [Vector3(-BLOCK-HALFBLOCK,0,0),Vector3(BLOCK+HALFBLOCK,0,0),Vector3(0,0,-BLOCK-HALFBLOCK),Vector3(0,0,BLOCK+HALFBLOCK)]
var target
var height = 0
var pathing_length = 16
var pathing_times = 36
var open
var closed = []
var closest
var closestLength = 999
var result = []
var next_reset = 0
var heuristic_threshold = 0


class pathnode:
	var parent
	var pos
	var g = 0
	var h = 0
	var f = 0
	var mode = 0

	func _init(pparent, pnode):
		parent = pparent
		pos = pnode
		
	func set_h(destination):
		h = (pos - destination).length()


func check_loop(loop, pos):
	for i in loop:
		if i.pos == pos:
			return i


func iterate(node):
	var index = 0
	for k in range(open.size()):
		var v = open[k]
		if v.f < node.f:
			index = k
			node = v
	open.remove(index)
	closed.append(node)
	var achieved = (node.pos - target).length()
	if achieved < 1.4:
		return node
	if achieved < closestLength:
		closest = node
		closestLength = achieved
	var options = get_routes(node.pos)
	for i in options:
		var pos = Vector3(i[0], i[1], i[2])
		if check_loop(closed, pos):
			continue
		var conflict = check_loop(open, pos)
		if conflict:
			if node.g + 1 <= conflict.g:
				conflict.parent = node
				conflict.g = node.g + 1 
				conflict.set_h(target)
				conflict.f = conflict.h + conflict.g
			continue
		var new = pathnode.new(node, pos)
		new.g = node.g + 1
		new.set_h(target)
		new.f = new.h + new.g
		#if new.h < heuristic_threshold:
		open.append(new)
	return null


func reset(hostpos):
	#heuristic_threshold = (hostpos - target).length() * 2 + 4
	open = [pathnode.new(null, hostpos)]
	closed = []
	closest = open[0]
	result = []
	next_reset = 0


func update(hostposv, targetv):	
	target = to_tile_coord(targetv)
	var hostpos = to_tile_coord(hostposv)
	if not result:
		var done = null
		if next_reset == 0:
			reset(hostpos)
			next_reset = 1
		else:
			next_reset += 1
		for _i in range(pathing_length):
			if open:
				done = iterate(open[0])
				if done != null:
					break
			else:
				break
		#for draw in open:
		#	G.make_particle("smoke", to_tile_pos(draw.pos), 3)
		if not done and next_reset > pathing_times: #Out of reach
			done = closest
		if done:
			next_reset = 0
			result = []
			while done.parent:
				#G.make_particle("smoke", to_tile_pos(done.pos), 2)
				done = done.parent
				if done.pos == hostpos:
					break
				result.insert(0, to_tile_pos(done.pos))
		return result

func to_tile_coord(vec):
	return ((vec + Vector3(HALFBLOCK,HALFBLOCK,HALFBLOCK)) / BLOCK).floor()

func to_tile_pos(vec):
	return vec * BLOCK

func update_nodes(hostposv):
	var done = closest
	if done:
		var hostpos = to_tile_coord(hostposv)
		result = [to_tile_pos(done.pos)]
		while done.parent:
			if done.parent.pos == hostpos:
				done.parent = null
				break
			done = done.parent
			#G.make_particle("debug", to_tile_pos(done.pos), 3)
			result.insert(0, to_tile_pos(done.pos))
		return result


func get_routes(pos):
	var ways = []
	var vec = Vector3(pos.x*BLOCK, pos.y*BLOCK, pos.z*BLOCK)
	if check_ray(vec, ORTHO[0]):
		ways.append(pos + Vector3.LEFT)
	if check_ray(vec, ORTHO[1]):
		ways.append(pos + Vector3.RIGHT)
	if check_ray(vec, ORTHO[2]):
		ways.append(pos + Vector3.FORWARD)
	if check_ray(vec, ORTHO[3]):
		ways.append(pos + Vector3.BACK)
	return ways

func check_ray(vec, add):
	vec = Vector3(vec.x, height, vec.z)
	var added = vec + add
	var r = G.space.intersect_ray(vec, added, [], 0b00000000000000100011)
	return r.empty()

func get_routes_debug(vec):
	var pos = to_tile_coord(vec)
	return str(get_routes(pos)) + " : " + str(pos)
