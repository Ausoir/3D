extends Node

var unit
var build_queue = []
var tgt #for use in cmd
var tasks
var task = ["", 0]
var task_timer
var faction = 0


func assign(arg):
	unit = arg
	unit.controller = self
	set_task()

func set_task(newtask=["wait", 0]):
	tasks = []
	if newtask[0] != task[0]:
		on_task_finish()
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
		newtask = ["wait", 0]
	on_task_set(newtask)

func on_process(delta):
	if task_timer <= 0:
		if on_task_finish():
			next_task()
		return
	elif task_timer < 9999:
		task_timer -= delta * 10
	on_task_update(delta)

func on_task_set(newtask):
	task = newtask
	task_timer = newtask[1]
	on_task_update(0)

func on_task_update(delta):
	if task[0] == "wait":
		if len(task) > 2:
			unit.set_state(task[2])
			if len(task) > 3 and is_instance_valid(tgt):
				face(tgt.transform.origin)
				unit.face(delta, Vector2(0,.1))
		else:
			unit.set_state()
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
		face(task[2])
		unit.motion_target = Vector2(0, 1)
		swing(unit.weapon)
	elif task[0] == "moveto":
		unit.motion_target = Vector2(task[2], task[3])
		unit.set_state("move")
	elif task[0] == "special":
		if unit.cast == 0:
			unit.set_state("special")

func on_task_finish():
	if task[0] == "damage":
		task[2].damage(task[3])
	elif task[0] == "cmd":
		if len(task) > 3:
			tgt = task[3]
		G.cmds([["t",tgt]]+task[2], unit)
	elif task[0] == "interact":
		var item = get_interactable()
		if item:
			face(item.global_transform.origin)
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
			if item.get("item_type") and item.dat.g("onuse"):
				if item.item_type == "item":
					return item
				elif item.item_type == "object":
					r = item
				elif item.item_type == "building":
					r = item
	return r


func interact(object):
	if object != null:
		var onuse = object.dat.g("onuse")
		if onuse:
			tgt = object
			set_tasks(onuse)
		return true


func swing(object):
	if object != null:
		var onswing = object.dat.g("onswing")
		tgt = object
		set_tasks(onswing)
		return true
