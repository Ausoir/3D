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
		if get_child_count() == 1:
			queue_free()
		else:
			get_node(node_name).queue_free()
			return true
	return false

func get_spawnpoint(idx):
	return $Spawn.get_child(idx).global_transform
