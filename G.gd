extends Spatial

const BLOCK = 4
const HALFBLOCK = 2
const particles = {
	"blood": preload("res://assets/particles/Blood.tscn"),
	"dust": preload("res://assets/particles/Dust.tscn"),
	"smoke": preload("res://assets/particles/Smoke.tscn"),
	"splinter": preload("res://assets/particles/Splinter.tscn"),
	"repair": preload("res://assets/particles/Repair.tscn"),
	"spark": preload("res://assets/particles/Spark.tscn"),
	"light": preload("res://assets/particles/Light.tscn"),
	"overcharge": preload("res://assets/particles/Overcharge.tscn"),
	"debug": preload("res://assets/particles/Debug.tscn"),
}
const Command = preload("res://classes/Command.gd")
const Faction = preload("res://classes/Faction.gd")
const font = preload("res://assets/font_message.tres")
var skills = preload("res://objects/units/Ability.gd").new()
var time = preload("res://classes/Time.gd").new()
var ui
var factory
var enemy
var you
var younit
var world
var level
var space
var controllers = []
var factions = [
	Faction.new(0),
	Faction.new(1),
	Faction.new(2),
]

var rng = preload("res://classes/Random.gd").new()


func _init():
	factory = preload("res://classes/Factory.gd").new()

func _process(delta):
	time.on_process(delta)


func initialize(pworld):
	ui = preload("res://interface/Interface.tscn").instance()
	G.world = pworld
	G.space = pworld.get_world().direct_space_state
	factory._ready()
	pworld.others.add_child(ui)


func get_player(idx):
	for player in world.players.get_children():
		if player.id == idx:
			return player


func get_unit_player(unit):
	for player in world.players.get_children():
		if player.unit == unit:
			return player


func on_hour(hour):
	for faction in factions:
		faction.on_hour(hour)


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
	if world != null and is_instance_valid(world):
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


func orientation_to_dir(orientation):
	if orientation == 0:
		return 2
	elif orientation == 16:
		return 1
	elif orientation == 10:
		return 0
	elif orientation == 22:
		return 3


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
	if ui:
		ui.message(msg)


func cmds(args, host):
	var c = Command.new(host)
	for arg in args:
		c.tgt = c.run(arg)
		if c.stop:
			break
	return c.tgt

func cmd(arg, host):
	var c = Command.new(host)
	return c.run(arg)
