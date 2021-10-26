extends "res://objects/Building.gd"


func trigger(_arg):
	if "loot" in properties:
		if has_node("TriggerAnimation"):
			var animation = $TriggerAnimation
			animation.play(animation.get_animation_list()[0])
		if properties.loot is Array:
			var loot = properties.loot[G.rng.rand_arr(properties.loot)]
			G.cmds([["v","pos"],["make",loot]], self)
		elif properties.loot is String:
			var loot = G.level.get_loot(properties.loot)
			if loot:
				G.cmds([["v","pos"],["make",loot]], self)
		properties.erase("loot")
		onuse = null
