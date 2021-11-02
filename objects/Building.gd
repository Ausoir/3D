extends "res://objects/Item.gd"


func on_make():
	.on_make()
	open_walls()

func open_walls():
	pass

func resize(variance):
	var rnd = G.rng.randf_range(1-variance, 1+variance)
	global_scale(Vector3(rnd,rnd,rnd))

func rid(node_name):
	if has_node(node_name):
		var node = get_node(node_name)
		if is_instance_valid(node):
			node.queue_free()
			if has_node("StaticBody/"+node_name):
				get_node("StaticBody/"+node_name).queue_free()
				return true
	return false

func get_spawnpoint():
	var child = G.rng.rand_arr($Spawn.get_children())
	return child.global_transform
