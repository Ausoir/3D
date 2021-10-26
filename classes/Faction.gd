var faction = 1
var allies = []
var units = []
var frame = 0


func _init(pfaction):
	faction = pfaction
	allies.append(faction)


func is_ally(target):
	return target.faction in allies


func add(unit):
	unit.set_faction(faction)
	units.append(unit)


func remove(unit):
	units.erase(unit)
