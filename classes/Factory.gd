const WORK_DELAY = 5
const Item_Script = preload("res://objects/Item.gd")
const Blueprint = preload("res://assets/materials/mat_blueprint.tres")
const Despawn = preload("res://assets/materials/mat_despawn.tres")
const Progress = preload("res://interface/progress_bar.tscn")
const Status = preload("res://objects/Status.gd")
const Ai = preload("res://objects/units/Ai.tscn")
const Bag = preload("res://assets/models/bag.obj")
const Type_Object = preload("res://objects/Object.tscn")
const Type_Item = preload("res://objects/Item.tscn")

const unit_data = {
	"worker": ["unit", Ai, {}, ["pickaxe"]],
	"warrior": ["unit", Ai, {}, ["spear", "leather armor", "leather gloves", "leather boots"]],
	"soldier": ["unit", Ai, {}, ["longsword", "iron armor", "iron gauntlets", "iron boots", "full helmet"]],
}

const data = {
	"lantern": ["item", preload("res://objects/Lamp.tscn"), {},{}],

	"branch": ["item", preload("res://assets/models/branch.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["menu","branch"]]]]},{}],
	"stone": ["item", preload("res://assets/models/stone.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["menu","stone"]]]]},{}],
	"axe": ["item", preload("res://assets/models/axe.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=.8, tags=["cut"]}],
	"cleaver": ["item", preload("res://assets/models/cleaver.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d10", tags=["cut"]}],
	"shovel": ["item", preload("res://assets/models/shovel.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d4"}],
	"pickaxe": ["item", preload("res://assets/models/pickaxe.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=.3, tags=["demolish", "penetrate", "mine"]}],
	"knife": ["item", preload("res://assets/models/knife.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d4", speed=2, tags=["cut"]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{onswing=[["wait", 9, "work"],["cmd", 0, [["menu","hammer"]]]]},{}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6"}],
	"shortsword": ["item", preload("res://assets/models/shortsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d4", speed=1.2}],
	"saber": ["item", preload("res://assets/models/saber.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1.2, tags=["cut"]}],
	"longsword": ["item", preload("res://assets/models/longsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d8"}],
	"greatsword": ["item", preload("res://assets/models/greatsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d16", speed=.6}],
	"rapier": ["item", preload("res://assets/models/rapier.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=1.2, tags=["penetrate"]}],
	"katana": ["item", preload("res://assets/models/katana.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d16", speed=1.2, tags=["cut"]}],
	"mace": ["item", preload("res://assets/models/mace.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d4", speed=.8, tags=["penetrate"]}],
	"greatmace": ["item", preload("res://assets/models/greatmace.obj"),
		{onswing=[["swing", 9999]]}, {damage="3d4", speed=.6, tags=["demolish", "penetrate"]}],
	"greathammer": ["item", preload("res://assets/models/greathammer.obj"),
		{onswing=[["swing", 9999]]}, {damage="3d6", speed=.6, tags=["demolish", "penetrate"]}],
	"feather blade": ["item", preload("res://assets/models/shortsword_unique.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1.5, tags=["cut"]}],
	"real blade": ["item", preload("res://assets/models/longsword_unique.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d10", speed=1.1}],

	"cloth armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{part="armor",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"gloves": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{part="arms",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"shoes": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{part="legs",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d6", part="armor",skin=preload("res://assets/materials/mat_dirt.tres")}],
	"iron armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d12", part="armor",skin=preload("res://assets/materials/mat_metal.tres")}],
	"leather gloves": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d6", part="arms",skin=preload("res://assets/materials/mat_dirt.tres")}],
	"iron gauntlets": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d12", part="arms",skin=preload("res://assets/materials/mat_metal.tres")}],
	"leather boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d6", part="legs",skin=preload("res://assets/materials/mat_dirt.tres")}],
	"iron boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d12", part="legs",skin=preload("res://assets/materials/mat_metal.tres")}],
	"headband": ["item", preload("res://assets/models/headband.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{health=20, part="head"}],
	"helmet": ["item", preload("res://assets/models/helmet.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d4", part="head"}],
	"full helmet": ["item", preload("res://assets/models/fullhelm.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense="1d6", part="head"}],

	"chest": ["object", preload("res://assets/models/chest.obj"),
		{onuse=[["wait",12,"work"],["cmd",0,[["die"],["v","tgt"],["v","pos"],["r","cmd",[[["make","leather armor"]],[["make","helmet"]],[["make","shortsword"]]]]]]]},
		 {health=4, defense="1d6"}],
	"site": ["building", preload("res://assets/buildings/Site.tscn"),
		{onmake=[["v", "host"], ["state", "work", 9999], ["setwork", 2, "Constructing..."]],
		 onwork=[["v","transform"], ["make","building"], ["v","host"], ["die"]]},{}],
	"room": ["building", preload("res://assets/buildings/Room.tscn"), {},{}],
	"stairs": ["building", preload("res://assets/buildings/Stairs.tscn"), {},{}],
	"post": ["building", preload("res://assets/buildings/Post.tscn"), {},{}],
	"kitchen": ["building", preload("res://assets/buildings/Table.tscn"), {},{}],
	"workshop": ["building", preload("res://assets/buildings/Workshop.tscn"),
		{onuse=[["cmd", 0, [["menu","workshop"]]]]},{}],
	"farm": ["building", preload("res://assets/buildings/Farm.tscn"),
		{onmake=[["v","pos"],["tile",900],["v", "host"], ["state", "work", 9999], ["setwork", 5, "Growing..."]],
		 onwork=[["v","transform"], ["make", "crops"],["claim"], ["v","host"], ["die"]]},{}],
	"crops": ["building", preload("res://assets/buildings/FarmGrown.tscn"),
		{onuse=[["work", WORK_DELAY]],
		 onwork=[["cost",0,-3,true], ["v","transform"], ["make", "farm"],["claim"], ["v","host"], ["die"]]},{}],
	"bed": ["building", preload("res://assets/buildings/Bed.tscn"),
		{onuse=[["cmd", 0, [["menu","hire"]]]]},{}],
	"crystal": ["building", preload("res://assets/buildings/Crystal.tscn"),
		{onmake=[["v","spawnpoint",0],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",1],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",2],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",3],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",4],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",5],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",6],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",7],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",8],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",9],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",10],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
		]},{health=400}],
	"camp": ["building", preload("res://assets/buildings/Camp.tscn"),
		{onmake=[["v","spawnpoint",0],["r","cmd",[[["spawn","warrior"]],[["spawn","soldier"]]]], ["claim",2],
				 ["v","spawnpoint",1],["spawn","warrior"], ["claim",2],
				 ["v","spawnpoint",2],["make","chest"], ["drop"]]},{defense="9999"}],
	"house": ["building", preload("res://assets/buildings/House.tscn"),
		{onmake=[["v","spawnpoint",0],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",1],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]]]},{defense="9999"}],
	"graveyard": ["building", preload("res://assets/buildings/Graveyard.tscn"),
		{onmake=[["v","spawnpoint",0],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",1],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",2],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",3],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]]]},{defense="9999"}],
	"tower": ["building", preload("res://assets/buildings/Tower.tscn"),
		{onmake=[["v","spawnpoint",0],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]],
				 ["v","spawnpoint",0],["r","cmd",[[],[["spawn","warrior"]],[["spawn","soldier"]]]]]},{health=80}],
}

const decor_interactions = {
	"rocks": [["wait", 3, "work"], ["cmd", 0, [["v","pos"],["make","stone"],["equip"]]]],
	"palm": [["wait", 8, "work"], ["cmd", 0, [["cost",0,-1]]]],
}

var descriptions = {
	"Build Bedroom": "Hire units",
	"Build Room": "Build an empty room",
	"Build Farm": "Grow food",
	"Build Workshop": "Craft tools",
	"Build Lab": "Research items",
	"cut": "Cut plants",
	"penetrate": "Ignore armor",
	"demolish": "Destroy buildings",
}

onready var craftables = {
	"hand": [
		["Deconstruct", [0,0,[]], [["v","parent"],["task",[["wait", 3, "work"], ["cmd",0,
			[["v","usepos"],["v","snap"],["getobj","building"],["!if",null],["run",
				[["v","host"],["state","work",9999],["setwork",3,"Deconstructing..."],["oncall","onwork",[["v","host"],["die"]]]]
			]]
		]]]]],
		["Build Bedroom", [1,0], [["v","usepos"],["v","snap"], ["prepare","bed",2],["!if",null],["claim"],["cost",1,0]]],
		["Build Room", [1,0,["bed"]], [["v","usepos"],["v","snap"], ["prepare","room",2,1],["!if",null],["claim"],["cost",1,0]]],
		#["Build Farm", [1,0,["bed"]], [["v","usepos"],["v","snap"],["v","add",Vector3(0,-6,0)],["iftile",G.world.get_node("GridTerrain").dirt],["v","usepos"],["v","snap"],["prepare","farm",2,1],["!if",null],["claim"],["cost",1,0]]],
		["Build Camp", [1,0,["farm"]], [["v","usepos"],["v","snap"], ["prepare","camp",2,0]]],
		["Build Kitchen", [1,0,["farm"]], [["v","usepos"],["v","snap"], ["prepare","kitchen",2,0]]],
		["Build Workshop", [1,0,["bed"]], [["v","usepos"],["v","snap"], ["prepare","workshop",2,0]]],
		["Wield Axe", [1,0], [["v","pos",1], ["make","axe"],["wield"],["cost",1,0]]],
		["Wield Pickaxe", [1,0], [["v","pos",1], ["make","pickaxe"],["wield"],["cost",1,0]]],
		["Wield Rapier", [1,0], [["v","pos",1], ["make","rapier"],["wield"],["cost",1,0]]],
		["Wield Greatsword", [1,0], [["v","pos",1], ["make","greatsword"],["wield"],["cost",1,0]]],
		["Wield Lamp", [1,0], [["v","pos",1], ["make","lantern"],["wield"],["cost",1,0]]],
		["Equip Iron Suit", [1,0], [["v","pos",1], ["make","iron armor"],["equip"], ["make","iron gauntlets"],["equip"], ["make","iron boots"],["equip"]]],
		["Equip Head", [1,0], [["v","pos",1], ["make","headband"],["equip"],["cost",1,0]]],
		["Spawn Friend", [1,0], [["v","pos"], ["spawn","warrior"], ["claim"]]],
		["Spawn Enemy", [1,0], [["v","pos"], ["spawn","soldier"], ["claim",2]]],
		["Spawn Chest", [1,0], [["v","pos"], ["make","chest"], ["drop"]]],
	],
	"hammer": [
		["Build Post", [1,0,["room"]], [["v","pos"],["v","snap"], ["prepare","post",3,1],["!if",null],["claim"],["cost",1,0]]],
		["Build Stairs", [1,0,["room"]], [["v","pos"],["v","snap"], ["prepare","stairs",2,1],["!if",null],["claim"],["cost",1,0]]],
		["Build Lab", [1,0,["workshop","farm"]], [["v","pos"],["v","snap"], ["prepare","lab",2,0]]],
	],
	"workshop": [
		["Craft Lantern", [1,0], [["v","pos",1], ["blueprint","lantern",2],["cost",1,0]]],
		["Craft Axe", [1,0], [["v","pos",1], ["blueprint","axe",2],["cost",1,0]]],
		["Craft Spear", [1,0], [["v","pos",1], ["blueprint","spear",5],["cost",1,0]]],
		["Craft Hammer", [1,0], [["v","pos",1], ["blueprint","hammer",5],["cost",1,0]]],
		["Craft Pickaxe", [1,0], [["v","pos",1], ["blueprint","pickaxe",5],["cost",1,0]]],
	],
	"lab": [
		["Research Armory", [1,1], [["cost",1,1],
			["v","lab"],["set","unlock","armory"],
			["v","lab"],["run",[["v","host"],["state", "work", 9999],["setwork", 2, "Researching..."]]]]],
	],
	"armory": [
		["Craft Headband", [1,1], [["v","frontpos",1], ["blueprint","lantern",2]]],
	],
	"hire": [
		["Summon Miner", [0,0], [["v","host"], ["state","work",9999], ["setwork",3,"Summoning..."],
			["oncall", "onwork", [["req",0,1], ["v","host"], ["trigger","worker"],["v","host"],["unstate","work"], ["cost",0,1]]]]],
		["Summon Warrior", [0,0,"workshop"], [["v","host"], ["state","work",9999], ["setwork",3,"Summoning..."],
			["oncall", "onwork", [["req",0,1], ["v","host"], ["trigger","warrior"],["v","host"],["unstate","work"], ["cost",0,1]]]]],
	],
}

var uncraftables = {
	"armory": ["Construct Armory", [1,1], [["v","usepos"],["v","snap"], ["prepare","bed",2,1]]],
	"tower": ["Build Tower", [1,1], [["v","usepos"],["v","snap"], ["prepare","tower",5,1], ["if",true], ["v","weapon"], ["die"], ["cost",1,1]]],
}


func get_description(name):
	if name in descriptions:
		return descriptions[name]
	return ""


func make_unit(arg):
	var item = unit_data[arg]
	var itemdata = item[2]
	var r = item[1].instance()
	var unit = r.get_node("Pilot/Unit")
	unit.item_name = arg
	if itemdata.has("health"):
		unit.health = Vector2(itemdata.health, itemdata.health)
	G.world.units.add_child(r)
	for i in item[3]:
		G.cmds([["v","pos"],["make", i],["equip"]], unit)
	unit.rotate_y(G.rng.randf() * PI)
	return r


func make_blueprint(arg, worktime):
	var item = data[arg]
	var r
	if item[1] is Mesh:
		r = Type_Object.instance()
		r.mesh = item[1]
		r.set_material_override(Blueprint)
	else:
		r = item[1].instance()
		for child in r.get_children():
			if child is MeshInstance:
				child.set_material_override(Blueprint)
			elif child is StaticBody:
				child.set_collision_layer(0b00000000000000000100)
				child.set_collision_mask(0)
	r.set_progress_bar()
	r.item_type = "object"
	r.item_name = arg
	r.set_work(worktime)
	r.health = Vector2(1, 1)
	r.onuse = [["work", WORK_DELAY]]
	r.onwork = [["v","transform"], ["make", arg],["claim"], ["v","host"], ["die"]]
	return r


func make(arg):
	var item = data[arg]
	var r
	if item[1] is PackedScene:
		r = item[1].instance()
	elif item[0] == "item":
		r = Type_Item.instance()
	else:
		r = Type_Object.instance()
	if item[0] == "object":
		r.mesh = item[1]
		r.create_trimesh_collision()
		r.get_child(0).set_collision_layer(0b00000000000000000110)
	elif item[0] == "item":
		r.mesh = item[1]
		r.onuse = [["wait", 6, "grab"],["cmd", 0, [["wield"]]]]
	r.item_name = arg
	r.item_type = item[0]
	var itemdata = item[2]
	if itemdata.has("health"):
		r.health = Vector2(itemdata.health, itemdata.health)
	if itemdata.has("req"):
		r.req = itemdata.req
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
	if itemdata.has("ondie"):
		r.ondie = []
		for i in itemdata.ondie:
			r.ondie.append(get_duplicate(r, i))
	for i in item[3].keys():
		r.properties[i] = item[3][i]
	return r


func get_duplicate(this, arr):
	var r = []
	for i in arr:
		if i == null:
			r.append(this)
		else:
			r.append(i)
	return r


func convert_gltf(item):
	var child = item.get_child(0)
	item.remove_child(child)
	item.free()
	child.set_script(Item_Script)
	child.create_trimesh_collision()
	child.get_child(0).set_collision_layer(0b00000000000000000110)
	return child
