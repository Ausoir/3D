extends Spatial

onready var status = G.factory.Status.new()
var item_name
var item_type
var health = Vector2(1, 1)
var faction = 0
var direction = 0
var holder
var req = [0, 0, 0, 0]
var onmake
var onuse
var onswing
var onwork
var properties = {}
var work = 1
var work_max = 0
var progress_bar
var frame = 0


func set_faction(pfaction):
	faction = pfaction


func get_team():
	return G.factions[faction]


func on_hour(_hour):
	pass


func on_make():
	if onmake:
		G.cmds(onmake, self)


func on_hit(pos, _hitter, damage=1):
	G.make_particle("splinter", pos, 1)
	damage(damage)


func trigger(_arg):
	pass


func damage(dmg):
	health.x -= dmg
	if health.x <= 0:
		if holder:
			holder.set_weapon(null)
		die()


func die():
	G.factions[faction].remove(self)
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
	if onwork:
		work = work_max
		G.cmds(onwork, self)
		return true


func _process(delta):
	status.update(delta)
	frame += delta
	if frame > 1:
		frame -= 1
		check_workdone()
