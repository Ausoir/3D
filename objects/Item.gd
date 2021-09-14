extends Spatial

var item_name
var item_type
var health = 1
var faction = 1
var holder
var req = [0, 0, 0, 0]
var onuse
var onswing
var onwork
var work = 1
var work_max = 0
var attack
var progress_bar
var states = []
var frame = 0


func on_make():
	pass


func on_hit(pos, _hitter):
	G.make_particle("splinter", pos, 1)
	damage(1)


func damage(dmg):
	health -= dmg
	if health <= 0:
		if holder:
			holder.set_weapon(null)
		die()


func die():
	for state in states:
		state.die()
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
	frame += delta
	if frame > 2:
		frame -= 2
		check_workdone()
		for state in states:
			if state.update():
				states.remove(state)
				state.queue_free()
