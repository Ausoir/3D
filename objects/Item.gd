extends Spatial

onready var status = G.factory.Status.new()
var item_name
var item_type
var direction = 0
var holder
var req = [0, 0, 0, 0]
var dat
var work = 1
var work_max = 0
var progress_bar


func on_hour(_hour):
	pass

func on_make():
	if dat.g("onmake"):
		G.cmds(dat.v.onmake, self)

func on_hit(pos, _hitter, damage=1, _tags=[]):
	if !pos:
		pos = transform.origin
	if dat.g("defense"):
		damage -= G.roll(dat.v.defense)
	if damage > 0:
		G.make_particle("splinter", pos, 1)
		damage(damage)
	else:
		G.make_particle("spark", pos, 1)

func trigger(_arg):
	pass

func damage(dmg):
	dat.add("hp", Vector2(-dmg, 0))
	if dat.is_dead():
		die()

func die():
	G.make_particle("dust", transform.origin, 2)
	if dat.g("ondie"):
		G.cmds(dat.v.ondie, self)
	if holder:
		holder.set_weapon(null)
	status.die()
	queue_free()

func set_work(amount):
	work = amount
	work_max = amount

func set_progress_bar(label=null):
	progress_bar = G.factory.Progress.instance()
	if label:
		progress_bar.label(label)
	add_child(progress_bar)

func check_workdone():
	if progress_bar:
		progress_bar.progress(float(work_max - work) / work_max)
	if work <= 0:
		on_work()

func on_work():
	if dat.g("onwork"):
		work = work_max
		G.cmds(dat.v.onwork, self)
		return true

func _process(delta):
	status.update(delta)
	if G.time.quarter_second:
		check_workdone()
