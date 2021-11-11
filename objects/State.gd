var host
var name = "none"
var lifetime = 1
var particle


func _init(phost, ptype, plifetime):
	host = phost
	name = ptype
	if name == "work":
		particle = G.make_particle("repair", host.global_transform.origin, 9999)
	elif name == "haste":
		particle = G.make_particle("repair", host.global_transform.origin, 9999)
	elif name == "regen":
		particle = G.make_particle("repair", host.global_transform.origin, 9999)
	elif name == "light":
		particle = G.make_particle("light", host.global_transform.origin, 9999)
	elif name == "night vision":
		G.world.get_node("WorldEnvironment").environment.set_ambient_light_energy(1)
	lifetime = plifetime


func die():
	if name == "night vision":
		G.world.get_node("WorldEnvironment").environment.set_ambient_light_energy(0)
	if particle and is_instance_valid(particle):
		particle.queue_free()


func update(second):
	if name == "haste":
		host.move_speed.x = host.move_speed.y * 1.5
	elif name == "slowfall":
		if host.velocity.y < 0:
			host.velocity.y *= .7
	if particle:
		particle.transform.origin = host.global_transform.origin
	if second:
		if name == "work":
			host.work -= 1
		elif name == "regen":
			host.health.x = min(host.health.x + 1, host.health.y)
		if lifetime < 999999:
			lifetime -= 1
			if lifetime <= 0:
				if particle:
					particle.queue_free()
				return true
