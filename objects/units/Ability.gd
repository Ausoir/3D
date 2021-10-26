extends Node

const data = {
	"debug": ["debug_flight", 1],
	"charge": ["charge", 2],
	"flurry": ["flurry", 0],
}

func on_set(ability, unit):
	unit.set_special(data[ability][1])

func perform(ability, unit):
	if unit.state == "special" and unit.cast > 0:
		call(data[ability][0], unit)

func debug_flight(unit):
	if unit.cast == 2:
		unit.transform.origin.y -= 12
	elif unit.cast == 1:
		G.cmds([["v","host"],["state","night vision",24]], unit)
		G.cmds([["v","host"],["state","light",24],["v","host"],["state","haste",24],["v","host"],["state","slowfall",3]], unit)

func charge(unit):
	unit.set_state("charge", true)

func flurry(unit):
	unit.set_state("flurry", true)
