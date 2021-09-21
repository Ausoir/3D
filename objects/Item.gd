extends Spatial

onready var status = G.item.Status.new()
var item_name
var item_type
var health = 1
var faction = 0
var direction = 0
var holder
var req = [0, 0, 0, 0]
var onmake
var onuse
var onswing
var onwork
var work = 1
var work_max = 0
var attack
var progress_bar
var frame = 0


func on_make():
	if onmake:
		G.cmds(onmake, self)


func on_hit(pos, _hitter, damage=1):
	G.make_particle("splinter", pos, 1)
	damage(damage)


func damage(dmg):
	health -= dmg
	if health <= 0:
		if holder:
			holder.set_weapon(null)
		die()


func die():
	status.die()
	queue_free()


func set_work(amount):
	work = amount
	work_max = amount


func set_progress_bar():
	progress_bar = G.item.progress.instance()
	add_child(progress_bar)


func check_workdone():
	if progress_bar:
		progress_bar.progress(float(work_max - work) / work_max)
	if work <= 0 and onwork:
		work = work_max
		G.cmds(onwork, self)


func _process(delta):
	status.update(delta)
	frame += delta
	if frame > 1:
		frame -= 1
		check_workdone()
