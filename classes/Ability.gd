extends Node

const START = 0
const CASTING = 1
const END = 2

func perform(ability, unit, end=false):
	if ability:
		if unit.cast > 0:
			var hand_pos = unit.get_hand_position()
			G.make_particle("cast fail", hand_pos, 1).follow(unit)
			unit.set_state("hit", true)
		elif unit.cast == -1:
			if end:
				return
			unit.cast = -2
			call(ability, unit, START)
		elif unit.cast == -2:
			if end:
				var cd = call(ability, unit, END)
				unit.cast = max(0, cd / (1 + unit.focus*.1))
				unit.experience(ability, G.rng.randi_range(0, cd))
			else:
				call(ability, unit, CASTING)

func debug(unit, mode):
	if mode == END:
		G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
		unit.transform.origin.y -= 2
#		G.cmds([["t", unit.get_hand_position()],["make","digger"],["state","snare",9999]], null)
	return 2

func flurry(unit, mode):
	if mode == END:
		unit.set_state("flurry", true)
	return 12

func cateye(unit, mode):
	if mode == END:
		G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
		var power = unit.cast*4
		G.cmds([["v","host"],["state","night vision",power]], unit)
	return 12

func light(unit, mode):
	if mode == END:
		G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
		G.cmds([["v","host"],["state","light",60]], unit)
	return 12

func haste(unit, mode):
	if mode == END:
		G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
		G.cmds([["v","host"],["state","haste",60]], unit)
	return 16

func passwall(unit, mode):
	if mode == END:
		var unit_pos = unit.get_interact_position()
		var hand_pos = unit.get_hand_position()
		var collision = G.space.intersect_ray(unit_pos, hand_pos, [], 0b00000000000000000001)
		if collision:
			G.make_particle("cast silent", hand_pos, 1).follow(unit)
			var destination = hand_pos + unit.transform.basis.z * 4
			var groundCheck = G.space.intersect_ray(destination, destination + Vector3(0,-4,0), [], 0b00000000000000000001)
			if groundCheck:
				var tween = unit.get_node("Tween")
				tween.interpolate_property(unit, "translation",
						unit.translation, unit.translation + unit.transform.basis.z*2, 6,
						Tween.TRANS_QUAD, Tween.EASE_OUT)
				tween.start()
				unit.set_state("special", true)
				unit.state_lock = true
			else:
				G.make_particle("cast fail", hand_pos, 1).follow(unit)
		else:
			G.make_particle("cast fail", hand_pos, 1).follow(unit)
	return 16

func missile(unit, mode):
	if mode == END:
		var hand_pos = unit.get_hand_position()
		G.make_particle("cast", hand_pos, 1).follow(unit)
		for _i in range(3):
			var projectile = G.factory.misc_data["missile"].instance()
			projectile.faction = unit.controller.faction
			projectile.transform.origin = hand_pos
			G.world.others.add_child(projectile)
			projectile.shoot(unit.transform.basis.z)
			projectile.onhit = [["hit", "$h", projectile.transform.origin, 6, ["magic"]]]
	return 3

func rune(unit, _mode):
	var hand_pos = unit.get_hand_position()
	G.make_particle("cast", hand_pos, 1).follow(unit)
	var projectile = G.factory.misc_data["charge"].instance()
	G.world.others.add_child(projectile)
	projectile.shoot(hand_pos, unit.transform.basis.z)
	return 3

func lightning(unit, mode):
	if mode == START:
		var hand_pos = unit.get_hand_position()
		G.make_particle("cast", hand_pos, 1).follow(unit)
		var target = G.find_target_los(hand_pos, 81, unit.controller.faction, unit)
		var projectile = G.factory.misc_data["lightning"].instance()
		G.world.others.add_child(projectile)
		projectile.shoot(unit, hand_pos, target)
	return 4

func clairvoyance(unit, mode):
	if !unit.controller.get('id'):
		return 99
	if mode == START:
		var hand_pos = unit.get_hand_position()
		G.make_particle("cast silent", hand_pos, 1).follow(unit)
		unit.controller.get_node("CameraAnimation").play("Vision")
	elif mode == CASTING:
		if !unit.status.has_state("night vision"):
			G.cmds([["v","host"],["state","night vision",0]], unit)
		unit.controller.camera.rotation.x = 1
		unit.controller.camera.rotation.z = 0
	elif mode == END:
		unit.controller.get_node("CameraAnimation").play("Unvision")
	return 2

func phantom(unit, mode):
	if mode == END:
		var hand_pos = unit.get_hand_position()
		if unit.weapon:
			G.make_particle("cast", hand_pos, 1).follow(unit)
			var summon = G.cmds([["t",hand_pos],["make","phantom"],["rotate"],["v","controller","$t"],["faction",1]], null)
			G.cmds([["v","host"],["state","light",9999]], summon.unit)
			summon.follow = unit
			summon.unit.body_mesh.set_material_override(load("res://assets/materials/mat_transparent.tres"))
			summon.unit.set_weapon(unit.set_weapon(null))
			summon.unit.set_collision_layer_bit(1, 0)
		else:
			G.make_particle("cast fail", hand_pos, 1).follow(unit)
	return 2

func charm(unit, mode):
	if mode == END:
		var hand_pos = unit.get_hand_position()
		G.make_particle("cast", hand_pos, 1).follow(unit)
		var projectile = G.factory.misc_data["missile"].instance()
		projectile.faction = unit.controller.faction
		projectile.transform.origin = hand_pos
		G.world.others.add_child(projectile)
		projectile.shoot(unit.transform.basis.z)
		projectile.onhit = [["v","host"],["state","charm",20]]
	return 2

func invisibility(unit, mode):
	if mode == END:
		var hand_pos = unit.get_hand_position()
		G.make_particle("cast", hand_pos, 1).follow(unit)
		G.cmds([["v","host"],["state","ghost",24]], unit)
	return 2

func stars(unit, mode):
	var hand_pos = unit.get_hand_position()
	if mode == START:
		G.make_particle("cast", hand_pos, 1).follow(unit)
	elif mode == CASTING and G.time.eighth_second:
		if unit.state_time > 3:
			unit.set_state("hit", true)
		else:
			var projectile = G.factory.misc_data["beam"].instance()
			projectile.faction = unit.controller.faction
			projectile.transform.origin = hand_pos
			G.world.others.add_child(projectile)
			projectile.shoot(unit.transform.basis.z)
			projectile.onhit = [["hit", "$h", projectile.transform.origin, 1, ["magic"]]]
	return 3
