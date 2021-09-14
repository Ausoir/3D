var state = load("res://objects/State.gd")

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
	elif args[0] == "if":
		if tgt != args[1]:
			stop = true
	elif args[0] == "cost":
		G.add_resource(-args[1], -args[2])
	elif args[0] == "state":
		var status = state.new(tgt, args[1], args[2])
		tgt.states.append(status)
	elif args[0] == "make":
		var newitem = G.item.make(args[1])
		newitem.global_transform = tgt
		G.world.objects.add_child(newitem)
		newitem.on_make()
		return newitem
	elif args[0] == "damage":
		tgt.damage(args[1])
	elif args[0] == "furnish":
		var snappos = G.world.snap_to_tile(tgt)
		var building = G.world.get_item_type_at("building", snappos, 0)
		if building and building.item_name == "building":
			if G.world.get_item_type_at("furniture", snappos, 0) == null:
				G.cmds([["t",snappos],["blueprint", args[1], args[2]],["state", "work", 999999]], host)
				return true
			else:
				G.message("Insufficient space!")
		else:
			G.message("Must be inside!")
	elif args[0] == "build":
		var snappos = G.world.snap_to_tile(tgt)
		if G.world.is_vacant(tgt) and G.world.get_item_type_at("building", snappos, 0) == null:
			G.cmds([["t",snappos],["blueprint", args[1], args[2]]], host)
			return true
		else:
			G.message("Insufficient space!")
	elif args[0] == "blueprint":
		var blueprint = G.item.make_blueprint(args[1], args[2])
		G.world.objects.add_child(blueprint)
		var face = host.global_transform.basis.z
		if face.x > .7 and abs(face.z) <= .7:
			blueprint.look_at(Vector3.RIGHT, Vector3.UP)
		elif abs(face.x) <= .7 and face.z > .7:
			blueprint.look_at(Vector3.BACK, Vector3.UP)
		elif face.x < -.7 and abs(face.z) <= .7:
			blueprint.look_at(Vector3.LEFT, Vector3.UP)
		elif abs(face.x) <= .7 and face.z < -.7:
			blueprint.look_at(Vector3.FORWARD, Vector3.UP)
		blueprint.orthonormalize()
		blueprint.transform.origin = tgt
		return blueprint
