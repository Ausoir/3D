extends "res://objects/Item.gd"

var tile_type = 900


func on_make():
	.on_make()
	update_tiles()


func update_tiles():
	G.world.set_tile_at(translation, tile_type)


func die():
	clear_tiles()
	for child in G.world.objects.get_children():
		if child.get("tile_type") and child != self:
			if child.translation == translation:
				child.update_tiles()
	.die()


func clear_tiles():
	G.world.set_tile_at(translation, -1)


func get_spawnpoint(idx):
	return $Spawn.get_child(idx).global_transform.origin
