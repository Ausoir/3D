var host
var tgt
var stop

func _init(phost):
	host = phost
	tgt = host

func run(args):
	if args[0] == "t":
		return args[1]
	elif args[0] == "v":
		if args[1] == "host":
			return host
		elif args[1] == "tgt":
			var t = host
			host = tgt
			return t
		elif args[1] == "parent":
			return host.get_parent()
		elif args[1] == "controller":
			return host.controller
		elif args[1] == "usepos":
			return host.get_interact_position()
		elif args[1] == "frontpos":
			return host.get_adjacent(0, args[2])
		elif args[1] == "add":
			return tgt + args[2]
		elif args[1] == "holder":
			return host.holder
		elif args[1] == "weapon":
			return host.weapon
		elif args[1] == "pos":
			return host.global_transform.origin
		elif args[1] == "transform":
			if !host.is_inside_tree():
				return Transform()
			return host.global_transform
		elif args[1] == "spawnpoint":
			return host.get_spawnpoint(args[2])
		elif args[1] == "snap":
			return G.world.snap_to_tile(tgt)
	elif args[0] == "r":
		if args[1] == "int":
			return G.rng.randi_range(args[2], args[3])
		elif args[1] == "cmd":
			var chosen = args[2][G.rng.randi_range(0, len(args[2])-1)]
			return G.cmds([["t",tgt]]+chosen, host)
	elif args[0] == "run":
		return G.cmds(args[1], tgt)
	elif args[0] == "!if":
		if tgt == args[1]:
			stop = true
	elif args[0] == "if":
		if tgt != args[1]:
			stop = true
	elif args[0] == "req":
		var player = G.get_unit_player(host)
		if player:
			if !player.require_resource(false, args[1]):
				stop = true
	elif args[0] == "cost":
		var player = G.get_unit_player(host)
		if player:
			if len(args) > 3:
				player.add_resource(-args[1], -args[2], true)
			else:
				player.add_resource(-args[1], -args[2])
	elif args[0] == "order":
		tgt.set_tasks(args[1])
	elif args[0] == "ability":
		tgt.set_ability(args[1])
	elif args[0] == "trigger":
		if len(args) == 1: #Used only on Factory.door
			tgt.trigger(host)
		else:
			tgt.trigger(args[1])
	elif args[0] == "wield":
		host.set_weapon(tgt)
	elif args[0] == "offhand":
		host.set_offhand(tgt)
	elif args[0] == "equip":
		if "part" in tgt.properties:
			host.set_armor(tgt)
		else:
			host.set_weapon(tgt)
	elif args[0] == "unequip":
		host.unset_armor(args[1])
	elif args[0] == "unstate":
		tgt.status.remove_state(args[1])
	elif args[0] == "state":
		tgt.status.add_state(tgt, args[1], args[2])
	elif args[0] == "particle":
		G.make_particle(args[1],tgt,args[2])
	elif args[0] == "oncall":
		if args[1] == "onmake":
			host.onmake = args[2]
		elif args[1] == "onwork":
			host.onwork = args[2]
		elif args[1] == "onuse":
			host.onuse = args[2]
		elif args[1] == "onswing":
			host.onswing = args[2]
	elif args[0] == "alert":
		var nearby_units = G.world.get_units_near(args[1], args[2])
		for unit in nearby_units:
			unit.controller.hear(args[1])
	elif args[0] == "setwork":
		if len(args) == 1:
			host.progress_bar = null
		else:
			host.set_work(args[1])
			host.set_progress_bar(args[2])
	elif args[0] == "getobj":
		return G.world.get_item_type_at(args[1], tgt, 0)
	elif args[0] == "task":
		tgt.set_task()
		tgt.set_tasks(args[1])
	elif args[0] == "seed":
		tgt.set_seed(args[1])
	elif args[0] == "make":
		var newitem = G.factory.make(args[1])
		if newitem == null:
			newitem = G.factory.make_unit(args[1])
		if tgt is Transform:
			newitem.transform = tgt.translated(newitem.translation)
		elif tgt is Vector3:
			newitem.translate(tgt)
		newitem.on_make()
		return newitem
	elif args[0] == "drop":
		G.drop(tgt, [tgt])
	elif args[0] == "die":
		if tgt:
			tgt.die()
		else:
			return null
	elif args[0] == "damage":
		if tgt:
			tgt.damage(args[1])
	elif args[0] == "menu":
		G.ui.display(args[1], tgt)
	elif args[0] == "message":
		G.message(args[1])
	elif args[0] == "claim":
		G.factions[args[1]].add(tgt)
		return tgt
	elif args[0] == "rotate":
		var t
		if len(args) > 1:
			t = Transform().looking_at(args[1], Vector3.UP)
		else:
			t = Transform().looking_at(Vector3(G.rng.randf_range(-1,1),0,G.rng.randf_range(-1,1)), Vector3.UP)
		tgt.transform.basis = t.basis.orthonormalized()
	elif args[0] == "tile":
		G.world.set_tile_at(tgt, args[1])
	elif args[0] == "iftile":
		if G.world.get_tile_at(tgt) != args[1]:
			stop = true
		return tgt
	elif args[0] == "tilespace":
		if !G.world.is_tile_vacant(tgt):
			stop = true
			if args[1] == true:
				G.message("Insufficient space!")
	elif args[0] == "build":
		var pos = args[2]
		var ortho = [Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK][args[3]]
		return G.cmds([["t",pos],["tilespace",false],["t",Transform().translated(pos).looking_at(ortho+pos, Vector3.UP)],["make",args[1]]], null)
	return tgt
