extends "res://objects/units/Pilot.gd"

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
		if abs(unit_pos.y - target_pos.y) < 2:
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
		pathing.height = unit.get_position().y+.2
	path = pathing.update(from, to)
	if path:
		set_task(["idle", 0])
		for p in path:
			add_task(["move", 9999, Vector3(p.x,from.y,p.z), .1])
		next_task()

func unstuck():
	alertness = -1
	var target_pos = target.get_interact_position()
	if G.rng.randi_range(0,1) == 0:
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
			if dist < sight_range and !obj.controller.faction.is_ally(faction) and\
				unitpos.direction_to(objpos).dot(unit.transform.basis.z) > 0:
				var collision = G.space.intersect_ray(unitpos, objpos, [unit, obj], 32)
				if not collision:
					return obj

func hear(vec):
	if alertness == IDLE:
		search_pos = Vector3(vec.x, unit.get_interact_position().y, vec.z)
		G.make_particle("repair", search_pos, 3)

func on_hit(_pos, hitter, _damage):
	target = hitter
	update_target(target.get_interact_position(), true)

func die():
	set_alert(0)
	unit.status.die()
	unit.queue_free()
	queue_free()

func on_process(delta):
	.on_process(delta)
	if target and !is_instance_valid(target):
		target = null
		set_alert(0)
		return
	perform(alertness)

func perform(current_state):
	if G.time.second:
		var t = perceive()
		if t:
			target = t
			update_target(target.get_interact_position(), true)
			return
	if current_state == IDLE:
		if search_pos:
			if G.time.second:
				update_target(search_pos, true)
				set_alert(SEARCHING)
				unit.talk(npc_search)
	elif current_state == SEARCHING:
		if G.time.quarter_second:
			update_target(search_pos, false)
			set_alert(SEARCHING)
			if (unit.get_interact_position() - search_pos).length() < 1.5:
				G.message("search end")
				set_alert(0)
	elif current_state == PATHING:
		if G.time.quarter_second:
			update_target(target.get_interact_position(), false)
	elif current_state == CHASING:
		var target_pos = target.get_interact_position()
		if task[0] == "move":
			var dist = (target_pos - unit.get_interact_position()).length()
			if dist < unit.get_reach()+1:
				set_task(["attack", 9999, target_pos])
			else:
				task[2] = target_pos
		elif task[0] == "attack":
			task[2] = target_pos
