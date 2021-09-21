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
		elif args[1] == "usepos":
			return host.get_interact_position()
		elif args[1] == "frontpos":
			return host.get_adjacent(0, args[2])
		elif args[1] == "holder":
			return host.holder
		elif args[1] == "weapon":
			return host.weapon
		elif args[1] == "pos":
			return host.global_transform.origin
		elif args[1] == "transform":
			return host.global_transform
		elif args[1] == "snap":
			return G.world.snap_to_tile(tgt)
	elif args[0] == "!if":
		if tgt == args[1]:
			stop = true
	elif args[0] == "if":
		if tgt != args[1]:
			stop = true
	elif args[0] == "req":
		if !G.require_resource(false, args[1], args[2]):
			stop = true
	elif args[0] == "cost":
		G.add_resource(-args[1], -args[2])
	elif args[0] == "state":
		tgt.status.add_state(tgt, args[1], args[2])
	elif args[0] == "setwork":
		tgt.set_work(args[1])
		tgt.set_progress_bar()
	elif args[0] == "getobj":
		return G.world.get_item_type_at(args[1], tgt, 0)
	elif args[0] == "make":
		var newitem = G.item.make(args[1])
		newitem.global_transform = tgt
		if len(args) > 2:
			newitem.faction = args[2]
		G.world.objects.add_child(newitem)
		newitem.on_make()
		return newitem
	elif args[0] == "spawn":
		var newitem = G.item.make_unit(args[1])
		newitem.transform.origin = tgt
		G.world.units.add_child(newitem)
		return newitem
	elif args[0] == "damage":
		if tgt:
			tgt.damage(args[1])
	elif args[0] == "menu":
		G.you.ui.display(args[1], G.younit)
	elif args[0] == "message":
		G.message(args[1])
	elif args[0] == "furnish":
		var building = G.world.get_tile_at(tgt)
		if building >= 990:
			if G.world.get_item_type_at("furniture", tgt, 0) == null:
				G.cmds([["t",tgt],["blueprint", args[1], args[2], args[3]],["state", "work", 999999]], host)
				return true
			else:
				G.message("Insufficient space!")
		else:
			G.message("Must be inside!")
	elif args[0] == "tile":
		G.world.set_tile_at(tgt, args[1])
	elif args[0] == "tilespace":
		if !G.world.is_tile_vacant(tgt):
			stop = true
			if args[1] == true:
				G.message("Insufficient space!")
	elif args[0] == "build":
		return G.cmds([["t",tgt],["tilespace",true],["t",tgt],["blueprint", args[1], args[2], args[3]],["t",tgt],["tile",999]], host)
	elif args[0] == "blueprint":
		var faction = 0
		if len(args) > 3:
			faction = args[3]
		var blueprint = G.item.make_blueprint(args[1], args[2], faction)
		G.world.objects.add_child(blueprint)
		var face = host.global_transform.basis.z
		if face.x > .7 and abs(face.z) <= .7:
			blueprint.look_at(Vector3.LEFT, Vector3.UP)
		elif abs(face.x) <= .7 and face.z > .7:
			blueprint.look_at(Vector3.FORWARD, Vector3.UP)
		elif face.x < -.7 and abs(face.z) <= .7:
			blueprint.look_at(Vector3.RIGHT, Vector3.UP)
		elif abs(face.x) <= .7 and face.z < -.7:
			blueprint.look_at(Vector3.BACK, Vector3.UP)
		blueprint.orthonormalize()
		blueprint.transform.origin = tgt
		return blueprint
