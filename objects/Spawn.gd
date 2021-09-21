const WORK_DELAY = 5
const blueprint = preload("res://assets/mat_blueprint.tres")
const despawn = preload("res://assets/mat_despawn.tres")
const progress = preload("res://interface/progress_bar.tscn")
const Status = preload("res://objects/Status.gd")
const types = {
	"object": preload("res://objects/Object.tscn"),
	"item": preload("res://objects/Item.tscn"),
	"lamp": preload("res://objects/Lamp.tscn"),
}

const unit_data = {
	"worker": ["object", preload("res://objects/units/Npc.tscn"),
		{req=[1, 3, 0]}],
}

const data = {
	"lantern": ["lamp", preload("res://assets/models/lantern.obj"),
		{req=[0, 1, 0]}],

	"branch": ["item", preload("res://assets/models/branch.obj"),
		{onswing=[["wait", 3, "work"],["cmd", 0, [["menu","branch"]]]]}],
	"stone": ["item", preload("res://assets/models/stone.obj"),
		{onswing=[["wait", 3, "work"],["cmd", 0, [["menu","stone"]]]]}],
	"axe": ["item", preload("res://assets/models/axe.obj"),
		{onswing=[["swing", 999999]], attack="slash", req=[0, 2, 0]}],
	"shovel": ["item", preload("res://assets/models/shovel.obj"),
		{onswing=[["swing", 999999]], attack="bash", req=[1, 1, 0]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{onswing=[["swing", 999999]], attack="bash", req=[1, 1, 0]}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{onswing=[["swing", 999999]], attack="pierce", req=[2, 1, 0]}],
	"pickaxe": ["item", preload("res://assets/models/pickaxe.obj"),
		{onswing=[["swing", 999999]], attack="hack", req=[2, 1, 0]}],
	
	"site": ["building", preload("res://objects/buildings/Site.tscn"),
		{onmake=[["v", "host"], ["state", "work", 999999], ["v", "host"], ["setwork", 1]],
		 onwork=[["v","transform"], ["make","building"], ["v","host"], ["damage",1]]}],
	"farm": ["building", preload("res://objects/buildings/Farm.tscn"), {}],
	"building": ["building", preload("res://objects/buildings/Building.tscn"), {}],
	"stairs": ["building", preload("res://objects/buildings/Stairs.tscn"), {}],
	"tower": ["building", preload("res://objects/buildings/Tower.tscn"), {}],
	"table": ["furniture", preload("res://objects/buildings/Table.tscn"), {}],
	"bed": ["furniture", preload("res://objects/buildings/Bed.tscn"),
		{onmake=[["v","host"], ["state","work",999999], ["v", "host"], ["setwork",3]],
		 onwork=[["req",0,1], ["v","pos"], ["spawn","worker"], ["cost",0,1]]}],
}

const decor_interactions = {
	"flower": [["wait", 3, "work"], ["spawn", 0, "person"]],
	"rocks": [["wait", 3, "work"], ["find", 0, "stone"]],
	"tree": [["wait", 0, "work"], ["find", 0, "branch"]],
	"palm": [["wait", 8, "work"], ["gather", 0, [7,7]]],
}

const craftables = {
	"hand": [
		["Build", [1,1], [["v","usepos"],["v","snap"], ["build","site",2,1]]],
		["Build Tower", [1,1], [["v","usepos"],["v","snap"], ["build","tower",3,1]]],
		["Build Stairs", [1,1], [["v","usepos"],["v","snap"], ["build","stairs",1,1]]],
		["Summon", [0,0], [["v","frontpos",1], ["spawn","worker"]]],
		["Craft Axe", [1,1], [["v","frontpos",1], ["blueprint","axe",2]]],
		["Craft Hammer", [1,1], [["v","frontpos",1], ["blueprint","hammer",2]]],
		["Craft Lantern", [1,1], [["v","frontpos",1], ["blueprint","lantern",2]]],
	],
	"branch": [
		["Build", [1,1], [["v","usepos"],["v","snap"], ["build","site",5,1], ["if",null], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Build Tower", [1,1], [["v","usepos"],["v","snap"], ["build","tower",5,1], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Build Farm", [1,1], [["v","usepos"],["v","snap"], ["build","farm",5,1], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Construct Table", [1,1], [["v","usepos"],["v","snap"], ["furnish","table",5,1], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Construct Bed", [1,1], [["v","usepos"],["v","snap"], ["furnish","bed",5,1], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
	],
	"stone": [
		["Craft Spear", [1,1], [["v","frontpos",1], ["blueprint","spear",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Craft Hammer", [1,1], [["v","frontpos",1], ["blueprint","hammer",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Craft Pickaxe", [1,1], [["v","frontpos",1], ["blueprint","pickaxe",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
	],
}


func make_unit(arg):
	var item = unit_data[arg]
	var itemdata = item[2]
	var r = item[1].instance()
	if itemdata.has("health"):
		r.health = itemdata.health
	return r


func make_blueprint(arg, worktime, faction):
	var item = data[arg]
	var r
	if item[1] is Mesh:
		r = types["object"].instance()
		r.mesh = item[1]
		r.set_material_override(blueprint)
	else:
		r = item[1].instance()
		for child in r.get_children():
			if child is MeshInstance:
				child.set_material_override(blueprint)
			elif child is StaticBody:
				child.set_collision_layer(0b00000000000000000100)
				child.set_collision_mask(0)
	r.set_progress_bar()
	r.item_type = "object"
	r.set_work(worktime)
	r.health = 1
	r.faction = faction
	r.onuse = [["work", WORK_DELAY, r]]
	r.onwork = [["v","transform"], ["make", arg, faction], ["v","host"], ["damage", 1]]
	return r


func make(arg):
	var item = data[arg]
	var r
	if item[1] is PackedScene:
		r = item[1].instance()
	else:
		if item[0] in types:
			r = types[item[0]].instance()
		else:
			r = types["object"].instance()
	r.item_name = arg
	r.item_type = item[0]
	if r.item_type == "object":
		r.mesh = item[1]
		r.create_trimesh_collision()
	elif r.item_type == "item":
		r.mesh = item[1]
	elif r.item_type == "lamp":
		r.mesh = item[1]
		r.item_type = "item"
	var itemdata = item[2]
	if itemdata.has("health"):
		r.health = itemdata.health
	if itemdata.has("reach"):
		r.reach = itemdata.reach
	if itemdata.has("req"):
		r.req = itemdata.req
	if itemdata.has("attack"):
		r.attack = itemdata.attack
	if itemdata.has("onmake"):
		r.onmake = []
		for i in itemdata.onmake:
			r.onmake.append(get_duplicate(r, i))
	if itemdata.has("onuse"):
		r.onuse = []
		for i in itemdata.onuse:
			r.onuse.append(get_duplicate(r, i))
	if itemdata.has("onswing"):
		r.onswing = []
		for i in itemdata.onswing:
			r.onswing.append(get_duplicate(r, i))
	if itemdata.has("onwork"):
		r.onwork = []
		for i in itemdata.onwork:
			r.onwork.append(get_duplicate(r, i))
	return r


func get_duplicate(this, arr):
	var r = []
	for i in arr:
		if i == null:
			r.append(this)
		else:
			r.append(i)
	return r
