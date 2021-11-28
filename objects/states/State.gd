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
	elif name == "charm":
		particle = G.make_particle("light", host.global_transform.origin, 9999)
		host.dat.a("charmed", host.controller.faction)
		host.controller.faction = 1
	elif name == "ghost":
		host.body_mesh.set_material_override(G.factory.Transparent)
		if host.weapon:
			host.weapon.set_material_override(G.factory.Transparent)
		if host.offhand:
			host.offhand.set_material_override(G.factory.Transparent)
		if host.helm:
			host.helm.set_material_override(G.factory.Transparent)
	elif name == "night vision":
		G.world.get_node("WorldEnvironment").environment.set_ambient_light_energy(1)
	lifetime = plifetime


func die():
	if name == "night vision":
		G.world.get_node("WorldEnvironment").environment.set_ambient_light_energy(0)
	elif name == "charm":
		host.controller.faction = host.dat.g("charmed")
		host.dat.d("charmed")
	elif name == "ghost":
		host.body_mesh.set_material_override(null)
		if host.weapon:
			host.weapon.set_material_override(null)
		if host.offhand:
			host.offhand.set_material_override(null)
		if host.helm:
			host.helm.set_material_override(null)
	if particle and is_instance_valid(particle):
		particle.queue_free()


func update():
	if name == "haste":
		host.move_speed.x = host.move_speed.y * 1.5
	elif name == "snare":
		host.move_speed.x = 0
	elif name == "ghost":
		host.velocity.y = 2 - host.transform.origin.y
	elif name == "slowfall":
		if host.velocity.y < 0:
			host.velocity.y *= .7
	if particle:
		particle.transform.origin = host.global_transform.origin
	if G.time.second:
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
