const new_object = preload("res://object/Object.tscn")
const new_item = preload("res://object/Item.tscn")
const new_lamp = preload("res://object/Lamp.tscn")
const new_unit = preload("res://object/Unit.tscn")

const data = {
	"site": ["object", preload("res://assets/models/site.obj"),
			{health=1, interact=[]}],
	"bed": ["object", preload("res://assets/models/bed.obj"),
		{interact=[["spawn", 0, "person"]], req=[3, 1, 0, 0]}],
	"stump": ["object", preload("res://assets/models/stump.obj"),
		{interact=[["wait", 20, "work"],["menu", 0, "stonecraft"]], req=[1, 3, 0, 0]}],

	"lantern": ["lamp", preload("res://assets/models/lantern.obj"),
		{use=[["drop", 50]], req=[0, 1, 0, 0]}],

	"branch": ["item", preload("res://assets/models/branch.obj"),
		{use=[["wait", 20, "work"],["damage", 0, null, 1],["menu", 0, "branch"]]}],
	"axe": ["item", preload("res://assets/models/axe.obj"),
		{use=[["attack", 50]], req=[0, 0, 2, 0]}],
	"shovel": ["item", preload("res://assets/models/shovel.obj"),
		{use=[["attack", 50]], req=[1, 1, 1, 0]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{use=[["wait", 20, "work"],["menu", 0, "hammer"]], req=[1, 1, 2, 0]}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{use=[["attack", 100]], req=[1, 1, 2, 0]}],
}

const interactions = {
	"rocks": [["work", 50, {work=5}], ["gather", 0, [0,1,0]]],
	"tree": [["work", 50, {work=1}], ["find", 0, "branch"]],
}

const craftables = {
	"branch": ["hammer", "axe", "spear", "shovel", "bed"],
	"hammer": ["stump", "lantern"],
	"stonecraft": ["shovel", "spear", "axe"],
}


func make_unit(arg):
	var r = new_unit.instance()
	var mat = load("res://assets/mat_grass.tres")
	r.set_skin(2, mat)
	return r


func make(arg):
	var item = data[arg]
	var r
	if item[0] == "object":
		r = new_object.instance()
		r.mesh = item[1]
		r.create_trimesh_collision()
	elif item[0] == "item":
		r = new_item.instance()
		r.mesh = item[1]
	elif item[0] == "lamp":
		r = new_lamp.instance()
		r.mesh = item[1]
	r.type = item[0]
	var itemdata = item[2]
	if itemdata.has("health"):
		r.health = itemdata.health
	if itemdata.has("reach"):
		r.reach = itemdata.reach
	if itemdata.has("req"):
		r.req = itemdata.req
	if itemdata.has("use"):
		for i in itemdata.use:
			r.use.append(get_duplicate(r, i))
	if itemdata.has("interact"):
		for i in itemdata.interact:
			r.interact.append(get_duplicate(r, i))
	return r


func get_duplicate(this, arr):
	var r = []
	for i in arr:
		if i == null:
			r.append(this)
		else:
			r.append(i)
	return r
