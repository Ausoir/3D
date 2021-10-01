var faction = 1
var units = []
var buildings = []
var allies = []
var resource = {"mana": 50, "food": 10}
var frame = 0


func _init(pfaction):
	faction = pfaction
	allies.append(faction)


func is_ally(target):
	return target in allies


func add(unit):
	unit.set_faction(faction)
	if unit.item_type == "unit":
		units.append(unit)
	elif unit.item_type == "building":
		buildings.append(unit)


func remove(unit):
	if unit.item_type == "unit":
		units.erase(unit)
	elif unit.item_type == "building":
		buildings.erase(unit)


func add_resource(mana, food, message=true):
	resource["mana"] += mana
	resource["food"] += food
	G.ui.update_resources()
	if message:
		G.ui.display_gather(mana, food)


func require_resource(spend, mana, food, message=true):
	if resource["mana"] - mana >= 0:
		if resource["food"] - food >= 0:
			if spend:
				add_resource(-mana, -food, message)
			return true
		if spend and message:
			G.message("Not enough food!")
		return false
	if spend and message:
		G.message("Not enough mana!")
	return false


func has_building(name):
	for building in buildings:
		if building.item_name == name:
			return true
	return false


func on_hour(hour):
	for building in buildings:
		building.on_hour(hour)
