extends Node

const data = {
	"debug": ["debug_flight", 1, 2, 0],
	"charge": ["charge", 2, .1, 999],
	"flurry": ["flurry", 0, 1, .2],
}

func on_set(ability, unit):
	unit.set_special(data[ability][1], data[ability][2])

func perform(ability, unit):
	if unit.state == "special" and unit.state_time > data[ability][3]:
		call(data[ability][0], unit)

func debug_flight(unit):
	if unit.state_time > 1.5:
		unit.transform.origin.y -= 12
	elif unit.state_time > .7:
		unit.set_state("jump")
		unit.velocity.y = 20
	elif unit.state_time > .3:
		G.cmds([["v","host"],["state","night vision",24]], unit)
	else:
		G.cmds([["v","host"],["state","light",24],["v","host"],["state","haste",24],["v","host"],["state","slowfall",3]], unit)

func charge(unit):
	unit.set_state("charge", true)

func flurry(unit):
	unit.set_state("flurry", true)
