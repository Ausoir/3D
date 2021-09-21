const State = preload("res://objects/State.gd")

var states = []
var frame = 0


func has_state(arg):
	for state in states:
		if state.name == arg:
			return true
	return false


func add_state(host, statename, time):
	for state in states:
		if state.name == statename:
			state.lifetime = time
			return
	states.append(State.new(host, statename, time))


func update(delta):
	var second = false
	frame += delta
	if frame > 1:
		frame -= 1
		second = true
	for i in range(len(states)-1, -1, -1):
		if states[i].update(delta, second):
			states[i].die()
			states.remove(i)


func die():
	for state in states:
		state.die()
