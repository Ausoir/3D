extends Node

func perform(ability, unit):
	if unit.state == "special":
		if unit.cast >= 1:
			var cd = call(ability, unit)
			if cd != null:
				unit.cast = -cd / (1 + unit.focus*.1)

func debug(unit):
	G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
	var power = unit.cast*4
	if unit.cast >= 2:
		unit.transform.origin.y -= 2
	else:
		G.cmds([["v","host"],["state","night vision",power]], unit)
		G.cmds([["v","host"],["state","light",power],["v","host"],["state","haste",24],["v","host"],["state","slowfall",3]], unit)
	return 6

func flurry(unit):
	unit.set_state("flurry", true)
	return 12

func cateye(unit):
	G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
	var power = unit.cast*4
	G.cmds([["v","host"],["state","night vision",power]], unit)
	return power*4

func light(unit):
	G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
	G.cmds([["v","host"],["state","light",unit.cast*4]], unit)
	return 12

func haste(unit):
	G.make_particle("cast", unit.get_hand_position(), 1).follow(unit)
	G.cmds([["v","host"],["state","haste",unit.cast*4]], unit)
	return 16

func passwall(unit):
	var unit_pos = unit.get_interact_position()
	var hand_pos = unit.get_hand_position()
	G.make_particle("cast", hand_pos, 1).follow(unit)
	var collision = G.space.intersect_ray(unit_pos, hand_pos, [], 0b00000000000000000001)
	if collision:
		var destination = hand_pos + unit.transform.basis.z * 4
		var groundCheck = G.space.intersect_ray(destination, destination + Vector3(0,-4,0), [], 0b00000000000000000001)
		if groundCheck:
			var tween = unit.get_node("Tween")
			tween.interpolate_property(unit, "translation",
					unit.translation, unit.translation + unit.transform.basis.z*3, 8,
					Tween.TRANS_QUAD, Tween.EASE_OUT)
			tween.start()
			unit.set_state("special", true)
			unit.state_lock = true
	return 4
