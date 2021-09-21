extends "res://objects/buildings/Building.gd"

var connection = 0

func on_make():
	update_tiles()
	G.tick_events.append(funcref(self, 'open_walls'))


func update_tiles():
	var face = global_transform.basis.z
	if abs(face.x) <= .7 and face.z < -.7:
		direction = 0
	elif face.x > .7 and abs(face.z) <= .7:
		direction = 16
	elif abs(face.x) <= .7 and face.z > .7:
		direction = 10
	elif face.x < -.7 and abs(face.z) <= .7:
		direction = 22
	tile_type = 990+connection
	G.world.set_tile_at(translation, tile_type, direction)


func open_neighbor_walls(x,y,z):
	var items = G.world.get_items_at(transform.origin + Vector3(x*6,y,z*6),0)
	if items:
		for i in items:
			if i.get("tile_type"):
				i.open_walls(false)


func open_walls(recurse=true):
	var pos = G.world.tilemap.world_to_map(transform.origin)
	var offset = G.dir_to_offset(direction, 0)
	if G.world.tilemap.get_cell_item(pos.x+offset.x,pos.y,pos.z+offset.y) >= 980:
		if has_node("Door") and is_instance_valid($Door):
			$Door.queue_free()
			$StaticBody/Door.queue_free()
			if recurse:
				open_neighbor_walls(offset.x,0,offset.y)
	offset = G.dir_to_offset(direction, 2)
	if G.world.tilemap.get_cell_item(pos.x+offset.x,pos.y,pos.z+offset.y) >= 980:
		if has_node("WallB") and is_instance_valid($WallB):
			connection += 4
			$WallB.queue_free()
			$StaticBody/Back.queue_free()
			if recurse:
				open_neighbor_walls(offset.x,0,offset.y)
	offset = G.dir_to_offset(direction, 1)
	if G.world.tilemap.get_cell_item(pos.x+offset.x,pos.y,pos.z+offset.y) >= 980:
		if has_node("WallR") and is_instance_valid($WallR):
			connection += 2
			$WallR.queue_free()
			$StaticBody/Right.queue_free()
			if recurse:
				open_neighbor_walls(offset.x,0,offset.y)
	offset = G.dir_to_offset(direction, -1)
	if G.world.tilemap.get_cell_item(pos.x+offset.x,pos.y,pos.z+offset.y) >= 980:
		if has_node("WallL") and is_instance_valid($WallL):
			connection += 1
			$WallL.queue_free()
			$StaticBody/Left.queue_free()
			if recurse:
				open_neighbor_walls(offset.x,0,offset.y)
	if G.world.tilemap.get_cell_item(pos.x,pos.y-1,pos.z) >= 980:
		if has_node("Floor") and is_instance_valid($Floor):
			$Floor.queue_free()
			$StaticBody/Floor.queue_free()
	tile_type = 990+connection
	G.world.set_tile_at(translation, tile_type, direction)


func get_direction(pos, rot):
	var offsetx
	var offsetz
	if direction == 0:
		offsetx = 0
		offsetz = 1
	elif direction == 16:
		offsetx = -1
		offsetz = 0
	elif direction == 10:
		offsetx = 0
		offsetz = -1
	elif direction == 22:
		offsetx = 1
		offsetz = 0
	if rot == 0:
		return G.world.tilemap.get_cell_item(pos.x+offsetx,pos.y,pos.z+offsetz)
	elif rot == -1:
		return G.world.tilemap.get_cell_item(pos.x+offsetz,pos.y,pos.z-offsetx)
	elif rot == 1:
		return G.world.tilemap.get_cell_item(pos.x-offsetz,pos.y,pos.z+offsetx)
	elif rot == 2:
		return G.world.tilemap.get_cell_item(pos.x-offsetx,pos.y,pos.z-offsetz)
