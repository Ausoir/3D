extends "res://objects/Building.gd"


func on_make():
	if dat.g("loot"):
		var loot = G.level.get_loot(dat.v.loot)
		if loot:
			var pos = get_spawnpoint(0)
			G.cmds([["t",pos],["make",loot],["rotate"]], self)
