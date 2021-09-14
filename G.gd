extends Spatial

const particles = {
	"blood": preload("res://objects/particles/Blood.tscn"),
	"dust": preload("res://objects/particles/Dust.tscn"),
	"smoke": preload("res://objects/particles/Smoke.tscn"),
	"splinter": preload("res://objects/particles/Splinter.tscn"),
	"repair": preload("res://objects/particles/Repair.tscn"),
}
const class_item = preload("res://objects/Item.gd")
const command = preload("res://objects/Command.gd")
onready var item = preload("res://objects/Spawn.gd").new()
var you
var younit
var world
var space
var resource = {"mana": 10, "food": 10}

var rng = RandomNumberGenerator.new()


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
	var r = space.intersect_ray(pos + Vector3(0, 1, 0), pos + Vector3(0, -40, 0), exc, 0b00000000000000000011)
	world.objects.add_child(arg)
	if r and r.position:
		arg.transform.origin = r.position
	return arg


func spawn_and_add(arg, pos):
	var newitem = item.make_unit(arg)
	newitem.transform.origin = pos
	world.units.add_child(newitem)
	return newitem


func add_resource(mana, food):
	resource["mana"] += mana
	resource["food"] += food
	you.get_node("Interface").display_gather(mana, food)
	you.get_node("Interface").update_resources()


func require_resource(spend, mana, food):
	if resource["mana"] - mana >= 0:
		if resource["food"] - food >= 0:
			if spend:
				add_resource(-mana, -food)
			return true
		message("Not enough food!")
		return false
	message("Not enough mana!")
	return false


func message(msg):
	you.get_node("Interface").message(msg)


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
