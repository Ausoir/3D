extends "res://objects/Item.gd"


func on_make():
	.on_make()
	open_walls()

func open_walls():
	pass

func rid(node_name):
	var node = get_node(node_name)
	if node != null and is_instance_valid(node):
		node.queue_free()
		if has_node("StaticBody/"+node_name):
			get_node("StaticBody/"+node_name).queue_free()
			return true
	return false

func get_spawnpoint(idx):
	return $Spawn.get_child(idx).global_transform.origin
