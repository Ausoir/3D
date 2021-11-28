extends "res://objects/units/Pilot.gd"

const UNSTUCKING = 4
const CHASING = 3
const PATHING = 2
const SEARCHING = 1
const IDLE = 0

var item_type = "unit"
var target
var alertness = IDLE
var sight_range = 12
var last_pos = Vector3.ZERO
var search_pos

var Pathing = preload("res://objects/units/Pathing.gd")
var pathing

var npc_search = preload("res://assets/audio/npc_search.wav")
var follow

func _init(unit):
	pathing = Pathing.new()
	assign(unit)

func update_target(to_pos, thought=false):
	if to_pos != null:
		var unit_pos = unit.get_interact_position()
		if not reach_to(unit_pos, to_pos):
			set_alert(PATHING)
			path_to(thought, unit_pos, to_pos)

func set_alert(level):
	if level == IDLE:
		search_pos = null
		target = null
	elif level == CHASING:
		search_pos = null
	elif level < PATHING:
		target = null
	alertness = level

func reach_to(unit_pos, target_pos):
	var collision = G.space.intersect_ray(unit_pos, target_pos, [], 0b00000000000000100101)
	if not collision:
		var dir = unit_pos.direction_to(target_pos)
		dir.y = 0
		alertness = CHASING
		set_task(["move", 9999, target_pos, 0])
		return true

func path_to(repath, from, to):
	var path
	if repath:
		pathing.result = []
		pathing.next_reset = 0
		pathing.height = unit.get_position().y+.1
	path = pathing.update(from, to)
	if path:
		set_task(["idle", 0])
		for p in path:
			add_task(["move", 9999, Vector3(p.x,from.y,p.z), .1])
		next_task()

func unstuck(target_pos):
	if G.rng.randi_range(0, 3) == 0:
		set_task(["attack", 9999, target_pos])
	else:
		var unit_pos = unit.get_interact_position()
		var strafe = unit_pos.cross(target_pos) * (40 * G.rng.randi_range(0, 1) - 20)
		set_task(["move", G.rng.randi_range(20, 40), unit_pos + strafe, 0])

func perceive():
	for obj in G.world.units.get_children():
		if obj != unit:
			var objpos = obj.get_view_position()
			var unitpos = unit.get_view_position()
			var dist = unitpos.distance_to(objpos)
			if dist < sight_range and obj.controller.faction != faction and\
				unitpos.direction_to(objpos).dot(unit.transform.basis.z) > 0:
					if !obj.status.has_state("ghost"):
						var collision = G.space.intersect_ray(unitpos, objpos, [unit, obj], 32)
						if not collision:
							return obj

func hear(vec):
	if alertness == IDLE:
		var unitpos = unit.get_interact_position()
		search_pos = Vector3(vec.x, unitpos.y, vec.z)

func on_hit(_pos, hitter, _damage):
	if hitter != null:
		target = hitter
		alertness = CHASING
		set_task(["move", 9999, target.get_interact_position(), 0])
	elif alertness == IDLE:
		set_task(["move", 9999, unit.get_position() + unit.transform.basis.z * -2, 0])

func die():
	set_alert(IDLE)
	queue_free()

func on_process(delta):
	.on_process(delta)
	if target and (!is_instance_valid(target) or target.state == "death"):
		target = null
		set_alert(IDLE)
		return
	perform(alertness)

func perform(current_state):
	if G.time.second:
		var unit_pos = unit.get_position()
		if target and G.time.seconds % 4 == 0:
			if task[0] == "move":
				if (last_pos - unit_pos).length_squared() < .3:
					var pos = target.get_interact_position()
					unstuck(pos)
					set_alert(UNSTUCKING)
					G.message("UNSTUCKING")
					last_pos = unit_pos + Vector3(9,9,9)
					return
			last_pos = unit_pos + Vector3(9,9,9)
		else:
			last_pos = unit_pos
		var t = perceive()
		if t:
			target = t
			update_target(target.get_interact_position(), true)
			return
	if current_state == IDLE:
		if G.time.second:
			if search_pos:
				update_target(search_pos, true)
				set_alert(SEARCHING)
				unit.talk(npc_search)
			elif follow:
				target = follow
				update_target(target.get_interact_position(), true)
	elif current_state == SEARCHING:
		if G.time.quarter_second:
			update_target(search_pos, false)
			set_alert(SEARCHING)
			if (unit.get_interact_position() - search_pos).length() < 1.5:
				set_alert(IDLE)
				set_task()
	elif current_state == PATHING:
		if G.time.quarter_second:
			update_target(target.get_interact_position(), tasks.empty())
	elif current_state == CHASING:
		var target_pos = target.get_position()
		var unit_pos = unit.get_position()
		var dist = (target_pos - unit_pos).length()
		if dist < unit.get_reach()+(unit.move_speed.y - target.move_speed.y):
			if target != follow:
				last_pos = unit_pos + Vector3(9,9,9)
				set_task(["attack", 9999, target_pos])
		else:
			update_target(target_pos, true)
	elif current_state == UNSTUCKING:
		if G.time.second and G.time.seconds % 5 == 0:
			last_pos = unit.get_position() + Vector3(9,9,9)
			if target:
				update_target(target.get_interact_position(), true)
			else:
				alertness = IDLE

func announce(_msg):
	pass
