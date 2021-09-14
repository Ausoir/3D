const WORK_DELAY = 5
const blueprint = preload("res://assets/mat_blueprint.tres")
const progress = preload("res://interface/progress_bar.tscn")
const types = {
	"object": preload("res://objects/Object.tscn"),
	"item": preload("res://objects/Item.tscn"),
	"lamp": preload("res://objects/Lamp.tscn"),
	"npc": preload("res://objects/units/Npc.tscn"),
}

const data = {
	"stump": ["object", preload("res://assets/models/stump.obj"),
		{onuse=[["wait", 20, "work"],["menu", 0, "stonecraft"]], req=[1, 3, 0]}],

	"lantern": ["lamp", preload("res://assets/models/lantern.obj"),
		{onswing=[["drop", 50]], req=[0, 1, 0]}],

	"branch": ["item", preload("res://assets/models/branch.obj"),
		{onswing=[["wait", 3, "work"],["menu", 0, "branch"]]}],
	"stone": ["item", preload("res://assets/models/stone.obj"),
		{onswing=[["wait", 3, "work"],["menu", 0, "stone"]]}],
	"axe": ["item", preload("res://assets/models/axe.obj"),
		{onswing=[["swing", 999999]], attack="axe", req=[0, 2, 0]}],
	"shovel": ["item", preload("res://assets/models/shovel.obj"),
		{onswing=[["swing", 999999]], req=[1, 1, 0]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{onswing=[["wait", 3, "work"],["menu", 0, "hammer"]], req=[1, 1, 0]}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{onswing=[["swing", 999999]], attack="weapon", req=[2, 1, 0]}],
	"pickaxe": ["item", preload("res://assets/models/pickaxe.obj"),
		{onswing=[["swing", 999999]], attack="pickaxe", req=[2, 1, 0]}],
	
	"site": ["building", preload("res://objects/buildings/Site.tscn"),
		{onuse=[["wait", 3, "work"]], req=[3,1,1]}],
	"farm": ["building", preload("res://objects/buildings/Farm.tscn"), {req=[2,1,1]}],
	"building": ["building", preload("res://objects/buildings/Building.tscn"), {req=[2,1,1]}],
	"tower": ["building", preload("res://objects/buildings/Tower.tscn"), {req=[2,1,1]}],
	"table": ["furniture", preload("res://objects/buildings/Table.tscn"), {req=[2,1,1]}],
	"bed": ["furniture", preload("res://objects/buildings/Bed.tscn"), {req=[2,1,1]}],
}

const interactions = {
	"flower": [["wait", 3, "work"], ["spawn", 0, "person"]],
	"rock": [["wait", 3, "work"], ["find", 0, "stone"]],
	"rocks": [["wait", 3, "work"], ["find", 0, "stone"]],
	"tree": [["wait", 0, "work"], ["find", 0, "branch"]],
	"palm": [["wait", 8, "work"], ["gather", 0, [7,7]]],
}

const craftables = {
	"branch": [
		["Build", [1,1], [["v","usepos"], ["build","site",5], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Build Tower", [1,1], [["v","usepos"], ["build","tower",5], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Build Farm", [1,1], [["v","usepos"], ["build","farm",5], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Construct Table", [1,1], [["v","usepos"], ["furnish","table",5], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Construct Bed", [1,1], [["v","usepos"], ["furnish","bed",5], ["if",true], ["v","weapon"], ["damage",1], ["cost",1,1]]],
	],
	"stone": [
		["Craft Spear", [1,1], [["v","frontpos",1], ["blueprint","spear",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Craft Hammer", [1,1], [["v","frontpos",1], ["blueprint","hammer",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Craft Axe", [1,1], [["v","frontpos",1], ["blueprint","axe",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
		["Craft Pickaxe", [1,1], [["v","frontpos",1], ["blueprint","pickaxe",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
	],
	"hammer": [
		["Craft Lantern", [1,1], [["v","frontpos",1], ["blueprint","spear",5], ["v","weapon"], ["damage",1], ["cost",1,1]]],
	],
}


func make_unit(_arg):
	var r = types["npc"].instance()
	var mat = load("res://assets/mat_grass.tres")
	r.get_node("Pilot/Unit").set_skin(3, mat)
	return r


func make_blueprint(arg, work_amount):
	var item = data[arg]
	var r
	if item[1] is Mesh:
		r = types["object"].instance()
		r.mesh = item[1]
		for i in range(r.get_surface_material_count()):
			r.set_surface_material(i, blueprint)
	else:
		r = item[1].instance()
		for child in r.get_children():
			if child is MeshInstance:
				for i in range(child.get_surface_material_count()):
					child.set_surface_material(i, blueprint)
			elif child is StaticBody:
				child.set_collision_layer(0b00000000000000000100)
				child.set_collision_mask(0)
	r.set_progress_bar()
	r.item_type = "building"
	r.set_work(work_amount)
	r.health = 1
	r.onuse = [["work", WORK_DELAY, r]]
	r.onwork = [["v","transform"], ["make", arg], ["v","host"], ["damage", 1]]
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
