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
	"lantern": ["item", preload("res://assets/models/torch.tscn"),
		{health=1,onswing=[["swing", 9999]]}, {damage="1d6", speed=.8, tags=["cut"]}],

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
	"shiv": ["item", preload("res://assets/models/shiv.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=2, tags=["cut"]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{onswing=[["wait", 9, "work"],["cmd", 0, [["menu","hammer"]]]]},{}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d9"}],
	"trident": ["item", preload("res://assets/models/trident.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d12"}],
	"halberd": ["item", preload("res://assets/models/halberd.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d16"}],
	"glaive": ["item", preload("res://assets/models/glaive.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d10", speed=.9}],
	"shortsword": ["item", preload("res://assets/models/shortsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d4", speed=1.2}],
	"scimitar": ["item", preload("res://assets/models/scimitar.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1.2, tags=["cut"]}],
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
	"wakizashi": ["item", preload("res://assets/models/shortkatana.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d16", speed=1.2, tags=["cut"]}],
	"club": ["item", preload("res://assets/models/club.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d4", speed=.8, tags=["blunt"]}],
	"mace": ["item", preload("res://assets/models/mace.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d8", speed=.8, tags=["blunt"]}],
	"greatmace": ["item", preload("res://assets/models/greatmace.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d12", speed=.6, tags=["blunt"]}],
	"warhammer": ["item", preload("res://assets/models/warhammer.obj"),
		{onswing=[["swing", 9999]]}, {damage="3d6", speed=.6, tags=["blunt"]}],
	"conesword": ["item", preload("res://assets/models/shortsword_cone.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1.5, tags=["cut"]}],
	"feather blade": ["item", preload("res://assets/models/shortsword_unique.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1.5, tags=["cut"]}],
	"real blade": ["item", preload("res://assets/models/longsword_unique.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d10", speed=1.1}],

	"casual wear": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{part="armor",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=3,weight=1, part="armor",skin=preload("res://assets/materials/mat_dirt.tres")}],
	"iron armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=5,weight=3, part="armor",skin=preload("res://assets/materials/mat_metal.tres")}],
	"leather gloves": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=1, part="arms",skin=preload("res://assets/materials/mat_dirt.tres")}],
	"iron gauntlets": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2,weight=1, part="arms",skin=preload("res://assets/materials/mat_metal.tres")}],
	"shoes": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{part="legs",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=1, part="legs",skin=preload("res://assets/materials/mat_dirt.tres")}],
	"iron boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2,weight=1, part="legs",skin=preload("res://assets/materials/mat_metal.tres")}],
	"headband": ["item", preload("res://assets/models/headband.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{health=20, part="head"}],
	"helmet": ["item", preload("res://assets/models/helmet.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=1,weight=1, part="head"}],
	"full helmet": ["item", preload("res://assets/models/fullhelm.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2,weight=2, part="head"}],
	"amulet of protection": ["item", {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2, part="accessory"}],

	"few gold": ["item", preload("res://assets/models/coinsSmall.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",-1,0,true]]]]},{}],
	"many gold": ["item", preload("res://assets/models/coinsMedium.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",-2,0,true]]]]},{}],
	"lots of gold": ["item", preload("res://assets/models/coinsLarge.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",-4,0,true]]]]},{}],
	"chest": ["building", preload("res://world/buildings/Chest.tscn"),
		{health=4,onuse=[["wait",12,"work"],["cmd",0,[["trigger",""]]]]},
		 {defense="1d6", loot=["shortsword","helmet","leather armor","lots of gold","many gold"]}],
	"table": ["building", preload("res://world/buildings/Table.tscn"), {health=4},{}],
	"large table": ["building", preload("res://world/buildings/TableLarge.tscn"), {health=8},{}],
	"pots": ["building", preload("res://world/buildings/Pots.tscn"), {health=1},{}],
	"bed cluster": ["building", preload("res://world/buildings/Bed.tscn"), {health=12, onmake=[
		["v","spawnpoint",0],["r","cmd",[[],[["make","few gold"]],[["make","many gold"]],[["spawn","warrior"]],[["spawn","soldier"],["make","lots of gold"]]]],
		["v","spawnpoint",1],["r","cmd",[[],[["make","few gold"]],[["make","many gold"]],[["spawn","warrior"]],[["spawn","soldier"],["make","many gold"]]]],
	]},{}],
	"beds": ["building", preload("res://world/buildings/Bed2.tscn"), {health=4, onmake=[
		["v","spawnpoint",0],["r","cmd",[[],[["make","few gold"]],[["spawn","warrior"]]]],
		["v","spawnpoint",1],["r","cmd",[[],[],[["spawn","warrior"]]]],
	]},{}],
	"campfire": ["building", preload("res://world/buildings/Campfire.tscn"),{health=4},{}],
	"torch": ["building", preload("res://world/buildings/Torch.tscn"),{health=2},{}],
	"crates": ["building", preload("res://world/buildings/Crates.tscn"),{health=4},{}],
	"barrels": ["building", preload("res://world/buildings/Barrels.tscn"),{health=8},{}],
	"derelict floor": ["building", preload("res://world/buildings/DerelictFloor.tscn"),{},{}],
	"derelict floor2": ["building", preload("res://world/buildings/DerelictFloor2.tscn"),{},{}],
	"bookcase": ["building", preload("res://world/buildings/Bookcase.tscn"),{},{}],
	"scaffold": ["building", preload("res://assets/models/buildings/scaffold_small_high.obj"),{},{}],
}

var descriptions = {
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
		["Build Camp", [1,0,["farm"]], [["v","usepos"],["v","snap"], ["prepare","camp",2,0]]],
		["Build Kitchen", [1,0,["farm"]], [["v","usepos"],["v","snap"], ["prepare","kitchen",2,0]]],
		["Build Workshop", [1,0,["bed"]], [["v","usepos"],["v","snap"], ["prepare","workshop",2,0]]],
		["Wield Katana", [1,0], [["make","katana"],["wield"],["cost",1,0]]],
		["Wield Wakizashi", [1,0], [["make","wakizashi"],["wield"],["cost",1,0]]],
		["Wield Saber", [1,0], [["make","saber"],["wield"],["cost",1,0]]],
		["Wield scimitar", [1,0], [["make","scimitar"],["wield"],["cost",1,0]]],
		["Wield Warhammer", [1,0], [["make","warhammer"],["wield"],["cost",1,0]]],
		["Wield Shovel", [1,0], [["make","shovel"],["wield"],["cost",1,0]]],
		["Wield Pickaxe", [1,0], [["make","pickaxe"],["wield"],["cost",1,0]]],
		["Wield Trident", [1,0], [["make","trident"],["wield"],["cost",1,0]]],
		["Wield Halberd", [1,0], [["make","halberd"],["wield"],["cost",1,0]]],
		["Wield Glaive", [1,0], [["make","glaive"],["wield"],["cost",1,0]]],
		["Wield Lamp", [1,0], [["make","lantern"],["wield"],["cost",1,0]]],
		["Equip Iron Suit", [1,0], [["make","iron armor"],["equip"], ["make","iron gauntlets"],["equip"], ["make","iron boots"],["equip"]]],
		["Equip Head", [1,0], [["make","full helmet"],["equip"],["cost",1,0]]],
		["Equip Head2", [1,0], [["make","helmet"],["equip"],["cost",1,0]]],
		["Spawn Friend", [1,0], [["v","pos"], ["spawn","warrior"], ["claim"]]],
		["Spawn Enemy", [1,0], [["v","pos"], ["spawn","soldier"], ["claim",2]]],
		["Spawn Chest", [1,0], [["v","pos"], ["make","chest"], ["drop"]]],
		["Ability Flurry", [1,0], [["v","host"],["v","parent"],["ability","flurry"]]],
		["Ability Charge", [1,0], [["v","host"],["v","parent"],["ability","charge"]]],
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
	var rot = G.rng.randf() * PI
	unit.rotate_y(rot)
	unit.view_z = unit.view_z.rotated(Vector3.UP, rot)
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
		if r.get_script() == null:
			r.set_script(Item_Script)
	elif item[0] == "item":
		r = Type_Item.instance()
		r.mesh = item[1]
	else:
		r = Type_Object.instance()
		r.mesh = item[1]
	if item[0] == "object":
		r.create_trimesh_collision()
		r.get_child(0).set_collision_layer(0b00000000000000000110)
	elif item[0] == "item":
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
