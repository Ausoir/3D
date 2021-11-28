extends "res://objects/Building.gd"

func trigger(_arg):
	var lootTable = dat.g("loot")
	if lootTable:
		var rotpos = transform
		if has_node("Spawn"):
			rotpos = get_spawnpoint(0)
		if has_node("TriggerAnimation"):
			var animation = $TriggerAnimation
			animation.play(animation.get_animation_list()[0])
		if lootTable is Array:
			var loot = lootTable[G.rng.rand_arr(lootTable)]
			G.cmds([["t",rotpos],["make",loot]], self)
		elif lootTable is String:
			var loot = G.level.get_loot(lootTable)
			if loot:
				G.cmds([["t",rotpos],["make",loot]], self)
		G.cmds([["alert",rotpos.origin,3]], self)
		dat.d("loot")
		dat.a("onuse", null)
