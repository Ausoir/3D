extends "res://objects/Building.gd"


func on_make():
	if "loot" in properties:
		var loot = G.level.get_loot(properties.loot)
		if loot:
			var pos = get_spawnpoint(0)
			G.cmds([["t",pos],["make",loot],["rotate"]], self)
