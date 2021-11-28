extends Spatial

const BLOCK = 4
const HALFBLOCK = 2
const Y_FIX = 2
const particles = {
	"debug": preload("res://objects/particles/Debug.tscn"),
	"hit": preload("res://objects/particles/Hit.tscn"),
	"blood": preload("res://objects/particles/Blood.tscn"),
	"dust": preload("res://objects/particles/Dust.tscn"),
	"smoke": preload("res://objects/particles/Smoke.tscn"),
	"splinter": preload("res://objects/particles/Splinter.tscn"),
	"repair": preload("res://objects/particles/Repair.tscn"),
	"spark": preload("res://objects/particles/Spark.tscn"),
	"light": preload("res://objects/particles/Light.tscn"),
	"shock": preload("res://objects/particles/Shock.tscn"),
	"overcharge": preload("res://objects/particles/Overcharge.tscn"),
	"cast": preload("res://objects/particles/Cast.tscn"),
	"cast silent": preload("res://objects/particles/Cast_silent.tscn"),
	"cast fail": preload("res://objects/particles/Cast_fail.tscn"),
	"recharged": preload("res://objects/particles/Recharged.tscn"),
	"charmed": preload("res://objects/particles/Charmed.tscn"),
}
const Properties = preload("res://classes/Properties.gd")
const Command = preload("res://classes/Command.gd")
const Interface_Damage = preload("res://interface/damage.tscn")
var skills = preload("res://classes/Ability.gd").new()
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

var rng = preload("res://classes/Random.gd").new()


func _init():
	factory = preload("res://classes/Factory.gd").new()

func _process(delta):
	time.on_process(delta)


func initialize(pworld):
	ui = preload("res://interface/Interface.tscn").instance()
	world = pworld
	space = pworld.get_world().direct_space_state
	pworld.others.add_child(ui)


func get_player(idx):
	for player in world.players.get_children():
		if player.id == idx:
			return player


func get_unit_player(unit):
	for player in world.players.get_children():
		if player.unit == unit:
			return player


func make_particle(arg, pos, lifetime):
	if arg in particles:
		var r = particles[arg].instance()
		r.transform.origin = pos + r.translation
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
	if arg is int:
		r = G.rng.randi_range(1, arg)
	elif "d" in arg:
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

func find_target_los(pos, radius_sq, faction, exc):
	for obj in G.world.units.get_children():
		var objpos = obj.get_view_position()
		if (objpos-pos).length_squared() < radius_sq and obj.controller.faction != faction:
			var collision = G.space.intersect_ray(pos, objpos, [exc, obj], 32)
			if not collision:
				return obj

func dec2base2(value):
	var r = ""
	while (value > 0):
		r = str(value & 1) + r
		value = (value >> 1)
	return len(r)

func display_damage(pos, dmg, clr=null):
	var label = Interface_Damage.instance()
	world.others.add_child(label)
	label.transform.origin = pos
	label.display(dmg, clr)
