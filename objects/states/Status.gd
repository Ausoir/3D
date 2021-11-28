const State = preload("res://objects/states/State.gd")

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


func remove_state(statename):
	for state in states:
		if state.name == statename:
			state.lifetime = 0
			state.die()
			states.erase(state)
			return


func update(_delta):
	if !states.empty():
		for i in range(len(states)-1, -1, -1):
			if states[i].update():
				states[i].die()
				states.remove(i)


func die():
	for state in states:
		state.die()
