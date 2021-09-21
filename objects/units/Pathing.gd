class_name Pathing


var target
var pathing_length = 16
var pathing_times = 8
var open
var closed = []
var closest
var result = []
var next_reset = 0
var heuristic_threshold = 0
var world


func _init(arg):
	world = arg


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
	if node.pos == target:
		return node
	var achieved = (node.pos - target).length()
	if achieved < (closest.pos - target).length():
		closest = node
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
	heuristic_threshold = (hostpos - target).length() * 2 + 4
	open = [pathnode.new(null, hostpos)]
	closed = []
	closest = open[0]


func debug_trace():
	for draw in open:
		G.make_particle("smoke", to_tile_pos(draw.pos), 3)


func to_tile_coord(vec):
	return world.tilemap.world_to_map(vec)


func to_tile_pos(vec):
	return world.tilemap.map_to_world(vec.x, vec.y, vec.z)


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
		#debug_trace()
		if not done and next_reset > pathing_times: #Out of reach
			done = closest
		if done:
			next_reset = 0
			result = []
			while done.parent:
				#G.make_particle("smoke", to_tile_pos(done.pos), 3)
				done = done.parent
				if done.pos == hostpos:
					break
				#G.make_particle("smoke", to_tile_pos(done.pos), 3)
				result.insert(0, to_tile_pos(done.pos))
		return result


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
			#G.make_particle("smoke", to_tile_pos(done.pos), 3)
			result.insert(0, to_tile_pos(done.pos))
		return result


func get_routes(pos):
	var sender = world.tilemap.get_cell_item(pos.x, pos.y, pos.z)
	var ways = routes_check_send(sender, pos)
	var r = []
	for way in ways:
		var route = routes_check_receive(pos, way)
		if route:
			r.append(route)
	return r


func get_direction_routes(orientation, open_type):
	var r = []
	var entrance
	if orientation == -1:
		return [[-1,0,0], [1,0,0], [0,0,-1], [0,0,1]]
	elif orientation == 0:
		entrance = [0,0,1]
	elif orientation == 10:
		entrance = [0,0,-1]
	elif orientation == 16:
		entrance = [-1,0,0]
	elif orientation == 22:
		entrance = [1,0,0]
	if entrance:
		r.append(entrance)
		if open_type == 1:
			r.append([entrance[2],0,-entrance[0]])
		elif open_type == 2:
			r.append([-entrance[2],0,entrance[0]])
		elif open_type == 3:
			r.append([entrance[2],0,-entrance[0]])
			r.append([-entrance[2],0,entrance[0]])
		elif open_type == 4:
			r.append([entrance[0]*-1,0,entrance[2]*-1])
		elif open_type == 5:
			r.append([entrance[0]*-1,0,entrance[2]*-1])
			r.append([entrance[2],0,-entrance[0]])
		elif open_type == 6:
			r.append([entrance[0]*-1,0,entrance[2]*-1])
			r.append([-entrance[2],0,entrance[0]])
		elif open_type == 7:
			r.append([entrance[0]*-1,0,entrance[2]*-1])
			r.append([entrance[2],0,-entrance[0]])
			r.append([-entrance[2],0,entrance[0]])
	return r


func routes_check_send(sender, pos):
	var r = []
	if sender >= 990:
		var sender_orientation = world.tilemap.get_cell_item_orientation(pos[0], pos[1], pos[2])
		var sender_open_type = sender % 10
		r.append_array(get_direction_routes(sender_orientation, sender_open_type))
	elif sender == world.tilemap.dirtslope or sender == 980:
		var sender_orientation = world.tilemap.get_cell_item_orientation(pos[0], pos[1], pos[2])
		if sender_orientation == 0:#Z-
			r.append_array([[0,1,-1],[0,0,1]])
		elif sender_orientation == 10:#Z+
			r.append_array([[0,1,1],[0,0,-1]])
		elif sender_orientation == 16:#X-
			r.append_array([[-1,1,0],[1,0,0]])
		elif sender_orientation == 22:#X+
			r.append_array([[1,1,0],[-1,0,0]])
	elif sender == world.tilemap.dirttunnel:
		var sender_orientation = world.tilemap.get_cell_item_orientation(pos[0], pos[1], pos[2])
		if sender_orientation == 0 or sender_orientation == 10:#Z-
			r = [[0,0,-1],[0,0,1]]
		elif sender_orientation == 16 or sender_orientation == 22:#X-
			r = [[-1,0,0],[1,0,0]]
	else:
		r = [[-1,0,0], [1,0,0], [0,0,-1], [0,0,1]]
	return r


func routes_check_receive(pos, direction):
	var newpos = [pos.x+direction[0],pos.y+direction[1],pos.z+direction[2]]
	var receiver = world.tilemap.get_cell_item(newpos[0], newpos[1], newpos[2])
	if receiver >= 990:
		var orientation = world.tilemap.get_cell_item_orientation(newpos[0], newpos[1], newpos[2])
		var receiver_open_type = receiver % 10
		var routes = get_direction_routes(orientation, receiver_open_type)
		var receive_direction = [direction[0]*-1,direction[1]*-1,direction[2]*-1]
		for route in routes:
			if receive_direction[0] == route[0] and receive_direction[2] == route[2]:
				return newpos
	elif receiver == world.tilemap.dirtslope or receiver == 980:
		var tile_orientation = world.tilemap.get_cell_item_orientation(newpos[0], newpos[1], newpos[2])
		if (tile_orientation == 0 and direction==[0,0,-1]) or\
			(tile_orientation == 10 and direction==[0,0,1]) or\
			(tile_orientation == 16 and direction==[-1,0,0]) or\
			(tile_orientation == 22 and direction==[1,0,0]):
			return newpos
	elif receiver == 981:
		var tile_orientation = world.tilemap.get_cell_item_orientation(newpos[0], newpos[1], newpos[2])
		if (tile_orientation == 0 and direction[2] == 1) or\
			(tile_orientation == 10 and direction[2] == -1) or\
			(tile_orientation == 16 and direction[0] == 1) or\
			(tile_orientation == 22 and direction[0] == -1):
			return [newpos[0], newpos[1]-1, newpos[2]]
	else:
		var heightmap = world.dirtmap[newpos[0]][newpos[2]]
		var tileunder = world.tilemap.get_cell_item(newpos[0], newpos[1]-1, newpos[2])
		if heightmap == newpos[1]:
			if tileunder == world.tilemap.dirtslope:
				return [newpos[0], newpos[1]-1, newpos[2]]
			else:
				return newpos
		elif receiver == world.tilemap.dirttunnel: #Check if tunnel
			var tileunder_orientation = world.tilemap.get_cell_item_orientation(newpos[0], newpos[1], newpos[2])
			if ((tileunder_orientation == 0 or tileunder_orientation == 10) and\
				(direction == [0,0,-1] or direction==[0,0,1])) or\
				((tileunder_orientation == 16 or tileunder_orientation == 22) and\
				(direction==[1,0,0] or direction==[-1,0,0])):
				return [newpos[0], newpos[1], newpos[2]]
		elif receiver == -1: #Check if landable
			if tileunder >= 980:
				return newpos
