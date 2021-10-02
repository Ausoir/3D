extends Spatial

const particles = {
	"blood": preload("res://assets/particles/Blood.tscn"),
	"dust": preload("res://assets/particles/Dust.tscn"),
	"smoke": preload("res://assets/particles/Smoke.tscn"),
	"splinter": preload("res://assets/particles/Splinter.tscn"),
	"repair": preload("res://assets/particles/Repair.tscn"),
	"spark": preload("res://assets/particles/Spark.tscn"),
}
const class_item = preload("res://objects/Item.gd")
const command = preload("res://classes/Command.gd")
var ui
var factory
var FACTION = preload("res://classes/Faction.gd")
var enemy
var you
var younit
var world
var space
var tick_events = []
var factions = [
	FACTION.new(0),
	FACTION.new(1),
	FACTION.new(2),
]
var frame = 0

var rng = RandomNumberGenerator.new()


func _init():
	factory = preload("res://classes/Factory.gd").new()


func initialize(pworld):
	ui = preload("res://interface/Interface.tscn").instance()
	G.world = pworld
	G.space = pworld.get_world().direct_space_state
	G.you = pworld.get_node("Units/Player")
	G.younit = G.you.get_node("Pilot/Unit")
	G.enemy = pworld.get_node("Enemy")
	factory._ready()
	pworld.others.add_child(ui)


func on_hour(hour):
	for faction in factions:
		faction.on_hour(hour)


func _process(_delta):
	frame += 1
	if frame > 8:
		if len(tick_events) > 0:
			var event = tick_events.pop_back()
			if event.is_valid():
				event.call_func()
		frame = 0


func make_particle(arg, pos, lifetime):
	if arg in particles:
		var r = particles[arg].instance()
		r.transform.origin = pos
		r.duration = lifetime
		r.emitting = true
		world.others.add_child(r)
		return r
	print("G.make_particles can't find ", arg)


func rid(arg, remove=true):
	if arg.get_parent() == world.objects:
		world.objects.remove_child(arg)
		if remove:
			arg.queue_free()


func drop(arg, exc):
	var pos = arg.transform.origin
	var r = space.intersect_ray(pos + Vector3(0, 1, 0), pos + Vector3(0, -40, 0), exc, 0b00000000000000000001)
	if r and r.position:
		arg.transform.origin = r.position
	return arg


func roll(arg):
	var r = 0
	if "d" in arg:
		var dices = arg.split("d")
		for _i in range(int(dices[0])):
			r += G.rng.randi_range(1, int(dices[1]))
	else:
		r = int(arg)
	return r


func dir_to_offset(orientation, rot):
	var offsetx = 0
	var offsetz = 0
	if orientation == 0:
		offsetz = 1
	elif orientation == 16:
		offsetx = -1
	elif orientation == 10:
		offsetz = -1
	elif orientation == 22:
		offsetx = 1
	if rot == 0:
		return Vector2(offsetx, offsetz)
	elif rot == -1:
		return Vector2(offsetz, -offsetx)
	elif rot == 1:
		return Vector2(-offsetz, offsetx)
	elif rot == 2:
		return Vector2(-offsetx, -offsetz)


func message(msg):
	ui.message(msg)


func cmds(args, host):
	var c = command.new(host)
	for arg in args:
		c.tgt = c.run(arg)
		if c.stop:
			break
	return c.tgt

func cmd(arg, host):
	var c = command.new(host)
	return c.run(arg)
