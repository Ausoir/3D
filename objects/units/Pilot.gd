extends Node

var unit
var build_queue = []
var tgt #for use in cmd
var tasks
var task
var task_timer
var faction
var ability


func assign(arg):
	faction = G.factions[0]
	unit = arg
	unit.controller = self
	set_task()

func set_faction(p):
	faction = G.factions[p]

func set_ability(p):
	ability = p
	G.skills.on_set(p, unit)

func set_task(newtask=["wait", 0]):
	tasks = []
	on_task_set(newtask)
	task_timer = task[1]

func set_tasks(newtasks):
	tasks = []
	for i in newtasks:
		add_task(i)
	next_task()

func insert_tasks(newtasks):
	tasks.append(task)
	for i in newtasks:
		tasks.append(i)
	next_task()

func add_task(newtask):
	tasks.insert(0, newtask)

func change_task(newtask):
	tasks.append(newtask)
	next_task()

func next_task():
	var newtask = tasks.pop_back()
	if newtask == null:
		newtask = ["wait", 9999]
	on_task_set(newtask)

func on_process(delta):
	if task_timer <= 0:
		if on_task_finish():
			next_task()
		return
	elif task_timer < 9999:
		task_timer -= delta * 10
	on_task_update()

func on_task_set(newtask):
	task = newtask
	task_timer = newtask[1]
	on_task_update()

func on_task_update():
	if task[0] == "wait":
		if len(task) > 2:
			unit.set_state(task[2])
		else:
			unit.set_state()
	elif task[0] == "work":
		unit.set_state("work")
	elif task[0] == "interact":
		unit.set_state("grab")
	elif task[0] == "move":
		unit.set_state("move")
		var dist = face(task[2])
		var proximity = 1
		if len(task) > 3:
			proximity = task[3]
		if dist.length() <= proximity:
			task_timer = 0
		else:
			unit.motion_target = Vector2(0, 1)
	elif task[0] == "attack":
		unit.set_state("swing")
		face(task[2])
		unit.motion_target = Vector2(0, 1)
	elif task[0] == "moveto":
		unit.motion_target = Vector2(task[2], task[3])
		unit.set_state("move")
	elif task[0] == "swing":
		unit.set_state("swing")
	elif task[0] == "special":
		unit.set_state("special")

func on_task_finish():
	if task[0] == "damage":
		task[2].damage(task[3])
	elif task[0] == "cmd":
		if len(task) > 3:
			tgt = task[3]
		G.cmds([["t",tgt]]+task[2], unit)
	elif task[0] == "special":
		G.skills.perform(ability, unit)
	elif task[0] == "interact":
		var item = get_interactable()
		if item:
			interact(item)
		return false
	elif task[0] == "work":
		if is_instance_valid(tgt): #Check if node was freed
			if tgt.work > 0:
				task_timer = G.factory.WORK_DELAY
				tgt.work -= 1
				tgt.check_workdone()
				return false
	unit.set_state()
	return true

func face(to):
	var diff = unit.get_interact_position() - to
	var dir = diff.normalized()
	dir.y = 0
	unit.view_z = dir
	return diff


func get_interactable():
	var items = G.world.get_items_at(unit.get_interact_position())
	var r
	if items:
		for item in items:
			if item.get("item_name") and item.onuse:
				if item.item_type == "item":
					return item
				elif item.item_type == "object":
					r = item
				elif item.item_type == "building":
					r = item
	return r


func interact(object):
	if object != null:
		if object is String:
			if object in G.factory.decor_interactions:
				tgt = object
				set_tasks(G.factory.decor_interactions[object])
		elif object.onuse:
			tgt = object
			set_tasks(object.onuse)
		return true


func swing(object):
	if object != null and object.onswing:
		tgt = object
		set_tasks(object.onswing)
		return true
