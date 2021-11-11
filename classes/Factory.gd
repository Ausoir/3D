const WORK_DELAY = 5
const Item_Script = preload("res://objects/Item.gd")
const Despawn = preload("res://assets/materials/mat_despawn.tres")
const Progress = preload("res://interface/progress_bar.tscn")
const Status = preload("res://objects/Status.gd")
const Man = preload("res://objects/units/Man.tscn")
const Ai = preload("res://objects/units/Ai.gd")
const Bag = preload("res://assets/models/bag.obj")
const Type_Object = preload("res://objects/Object.tscn")
const Type_Item = preload("res://objects/Item.tscn")

const unit_data = {
	"dummy": [Man, 0, {}, ["torch","cloth armor","boots"]],
	"miner": [Man, 1, {}, ["cloth armor", "boots", "pickaxe"]],
	"digger": [Man, 1, {}, ["cloth armor", "boots", "shovel"]],
	"guard": [Man, 1, {}, ["shortsword", "leather armor", "boots", "torch"]],
	"warrior": [Man, 1, {}, ["spear", "leather armor", "leather gloves", "leather boots"]],
	"soldier": [Man, 1, {}, ["longsword", "iron armor", "iron gauntlets", "iron boots", "full helmet"]],
}

const data = {
	"branch": ["item", preload("res://assets/models/branch.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["menu","branch"]]]]},{}],
	"stone": ["item", preload("res://assets/models/stone.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["menu","stone"]]]]},{}],
	"pickaxe": ["item", preload("res://assets/models/pickaxe.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=-3, tags=["demolish", "penetrate", "mine"]}],
	"knife": ["item", preload("res://assets/models/knife.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d4", speed=2, tags=["cut"]}],
	"shiv": ["item", preload("res://assets/models/shiv.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=2, tags=["cut"]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6",weight=1, tags=["blunt"]}],
	"axe": ["item", preload("res://assets/models/axe.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d8",weight=1, tags=["cut"]}],
	"cleaver": ["item", preload("res://assets/models/cleaver.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d12",weight=2, tags=["cut"]}],
	"shovel": ["item", preload("res://assets/models/shovel.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6",weight=1}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6"}],
	"trident": ["item", preload("res://assets/models/trident.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d12",weight=1}],
	"halberd": ["item", preload("res://assets/models/halberd.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d16", speed=-1,weight=2}],
	"glaive": ["item", preload("res://assets/models/glaive.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d10", speed=-2,weight=2}],
	"shortsword": ["item", preload("res://assets/models/shortsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d4", speed=1}],
	"scimitar": ["item", preload("res://assets/models/scimitar.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1,weight=1, tags=["cut"]}],
	"saber": ["item", preload("res://assets/models/saber.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1,weight=1, tags=["cut"]}],
	"longsword": ["item", preload("res://assets/models/longsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d8", weight=2}],
	"greatsword": ["item", preload("res://assets/models/greatsword.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d16", speed=1,weight=3}],
	"rapier": ["item", preload("res://assets/models/rapier.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", tags=["penetrate"]}],
	"katana": ["item", preload("res://assets/models/katana.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d16", speed=1, tags=["cut"]}],
	"wakizashi": ["item", preload("res://assets/models/shortkatana.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d16", speed=2, tags=["cut"]}],
	"club": ["item", preload("res://assets/models/club.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d4", speed=-1, tags=["blunt"]}],
	"mace": ["item", preload("res://assets/models/mace.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d8", speed=-1,weight=2, tags=["blunt"]}],
	"greatmace": ["item", preload("res://assets/models/greatmace.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d12", speed=-1,weight=3, tags=["blunt"]}],
	"warhammer": ["item", preload("res://assets/models/warhammer.obj"),
		{onswing=[["swing", 9999]]}, {damage="3d8", speed=-1,weight=4, tags=["blunt"]}],
	"conesword": ["item", preload("res://assets/models/shortsword_cone.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=1, tags=["cut"]}],
	"feather blade": ["item", preload("res://assets/models/shortsword_unique.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d6", speed=4, tags=["cut"]}],
	"real blade": ["item", preload("res://assets/models/longsword_unique.obj"),
		{onswing=[["swing", 9999]]}, {damage="2d10", speed=1}],
	"jade staff": ["item", preload("res://assets/models/staff_common.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=1}],
	"crystal staff": ["item", preload("res://assets/models/staff_uncommon.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=1}],
	"ruby staff": ["item", preload("res://assets/models/staff_rare.obj"),
		{onswing=[["swing", 9999]]}, {damage="1d6", speed=1}],

	"torch": ["item", preload("res://assets/models/torch.tscn"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{part="offhand"}],
	"cloth armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{health=3,part="armor",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather armor": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=3,weight=1, part="armor",skin=preload("res://assets/materials/mat_leather.tres")}],
	"cuirass": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=5,weight=3, part="armor",skin=preload("res://assets/materials/mat_metal.tres")}],
	"leather gloves": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=1, part="arms",skin=preload("res://assets/materials/mat_leather.tres")}],
	"iron gauntlets": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2,weight=1, part="arms",skin=preload("res://assets/materials/mat_metal.tres")}],
	"boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{health=2,part="legs",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=1, part="legs",skin=preload("res://assets/materials/mat_leather.tres")}],
	"iron boots": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2,weight=1, part="legs",skin=preload("res://assets/materials/mat_metal.tres")}],
	"headband": ["item", preload("res://assets/models/headband.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{health=20, part="head"}],
	"helmet": ["item", preload("res://assets/models/helmet.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=1,weight=1, part="head"}],
	"full helmet": ["item", preload("res://assets/models/fullhelm.obj"), {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2,weight=2, part="head"}],
	"amulet of protection": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{defense=2, part="accessory"}],
	"amulet of focus": ["item", Bag, {onswing=[["wait",6,"work"],["cmd",0,[["equip"]]]]},
		{focus=2, part="accessory"}],

	"2 gold": ["item", preload("res://assets/models/coinsSmall.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",0,-2,true]]]]},{}],
	"4 gold": ["item", preload("res://assets/models/coinsMedium.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",0,-4,true]]]]},{}],
	"8 gold": ["item", preload("res://assets/models/coinsLarge.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",0,-8,true]]]]},{}],
	"health potion": ["item", preload("res://assets/models/potionSmall_blue.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["v","host"],["state","regen",120]]]]},{}],



	"waste": ["building", preload("res://world/buildings/Waste.tscn"), {
		onmake=[["v","spawnpoint",0],["r","cmd",[[],[["make","shovel"]]]],
				["v","spawnpoint",1],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint",2],["r","cmd",[[],[["make","pot"]]]]]
	},{}],
	"pots": ["building", preload("res://world/buildings/Pots.tscn"), {
		onmake=[["v","spawnpoint",0],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint",1],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint",2],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint",3],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint",4],["r","cmd",[[],[["make","pot"]]]]]
	},{}],
	"pot": ["building", preload("res://world/buildings/Pot.tscn"), {health=1},{}],
	"table": ["building", preload("res://world/buildings/Table.tscn"), {health=4},{}],
	"large table": ["building", preload("res://world/buildings/TableLarge.tscn"), {health=8},{}],
	"bed cluster": ["building", preload("res://world/buildings/Bed.tscn"), {health=12},{loot="beds"}],
	"beds": ["building", preload("res://world/buildings/Bed2.tscn"), {health=4},{loot="beds"}],
	"campfire": ["building", preload("res://world/buildings/Campfire.tscn"),{health=4},{}],
	"walltorch": ["building", preload("res://world/buildings/Torch.tscn"),{health=2},{}],
	"crates": ["building", preload("res://world/buildings/Crates.tscn"),{health=2},{}],
	"barrels": ["building", preload("res://world/buildings/Barrels.tscn"),{health=4},{}],
	"derelict floor": ["building", preload("res://world/buildings/DerelictFloor.tscn"),{},{}],
	"derelict floor2": ["building", preload("res://world/buildings/DerelictFloor2.tscn"),{},{}],
	"bookcase": ["building", preload("res://world/buildings/Bookcase.tscn"),{},{}],
	"scaffold": ["building", preload("res://assets/models/buildings/scaffold_small_high.obj"),{},{}],
	"planks": ["building", preload("res://world/buildings/Planks.tscn"),{},{}],
	"carpet": ["building", preload("res://world/buildings/Carpet.tscn"),{},{}],
	"kegs": ["building", preload("res://world/buildings/Kegs.tscn"),{health=12},{}],
	"desk": ["building", preload("res://world/buildings/Desk.tscn"),{health=4},{}],
	"bench": ["building", preload("res://world/buildings/Bench.tscn"),{health=2},{}],
	"bubblelight": ["building", preload("res://world/buildings/Magelight.tscn"),{},{}],
	"mageaura": ["building", preload("res://world/buildings/Mageaura.tscn"),{},{}],
	"cauldron": ["building", preload("res://world/buildings/Cauldron.tscn"),{},{}],
	"altar": ["building", preload("res://world/buildings/Altar.tscn"),{},{}],
	"benchs": ["building", preload("res://world/buildings/Benchs.tscn"),{},{}],
	"dissection": ["building", preload("res://world/buildings/Dissection.tscn"),{health=12},{}],
	"occluder": ["building", preload("res://world/buildings/Occluder.tscn"),{},{}],
	"portal": ["building", preload("res://world/buildings/Portal.tscn"),{
		onmake=[["v","host"],["state","work",9999],["setwork",24,"Destabilizing..."]],
		onwork=[["setwork"],["v","host"],["trigger",""]],
		onuse=[["wait",8,"work",true],["cmd",0,[["v","host"],["v","controller"],["menu","shop"]]]]
	},{}],
	"door": ["building", preload("res://world/buildings/Door.tscn"),{
		ontouch=[["cmd",0,[["trigger"]]]]
	},{}],
	"trapdoor": ["building", preload("res://world/buildings/Trapdoor.tscn"),{
		onuse=[["wait",24,"work",true],["cmd",0,[["trigger",""]]]]
	},{}],
	"chest": ["building", preload("res://world/buildings/Chest.tscn"),
		{health=4,onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]]},
		{loot="doodads"}],
	"treasure": ["building", preload("res://world/buildings/Treasure.tscn"),
		{health=12,onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]]},
		 {loot="treasure"}],
	"wand rack": ["building", preload("res://world/buildings/RackWands.tscn"),
		{health=6,onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]]},
		 {loot="wands"}],
	"weapon rack": ["building", preload("res://world/buildings/RackWeapons.tscn"),
		{health=6,onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]]},
		 {loot="weapons"}],
	"armor rack": ["building", preload("res://world/buildings/RackArmors.tscn"),
		{health=6,onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]]},
		 {loot="armors"}],
}

var descriptions = {
	"cut": "Cut plants",
	"penetrate": "Ignore armor",
	"demolish": "Destroy buildings",
}

onready var menu = {
	"shop": [
		[
			["Transmute Gold to Mana", [0,5], [["cost",0,5],["cost",-2,0]]],
			["Summon Health Potion", [1,0], [["make","health potion"],["wield"],["cost",1,0]]],
			["Call a Warrior", [2,5], [["v","pos"], ["make","warrior"], ["claim",1]]],
			["Call a Soldier", [2,10], [["v","pos"], ["make","soldier"], ["claim",1]]],
			["Brighten Dungeon", [1,0], [["v","pos"], ["make","soldier"], ["claim",1]]],
		],
		[
			["Summon Torch", [1,0], [["make","torch"],["wield"],["cost",1,0]]],
			["Summon Pickaxe", [2,0], [["make","pickaxe"],["wield"],["cost",2,0]]],
			["Summon Shortsword", [2,0], [["make","shortsword"],["wield"],["cost",2,0]]],
			["Summon Saber", [5,0], [["make","saber"],["wield"],["cost",5,0]]],
			["Summon Halberd", [5,0], [["make","halberd"],["wield"],["cost",5,0]]],
			["Summon Mace", [3,0], [["make","mace"],["wield"],["cost",3,0]]],
			["Summon Cleaver", [3,0], [["make","cleaver"],["wield"],["cost",3,0]]],
		],
		[
			["Summon Full Iron Suit", [15,0], [["make","iron armor"],["equip"], ["make","iron gauntlets"],["equip"], ["make","iron boots"],["equip"],["cost",15,0]]],
			["Summon Iron Helmet", [2,0], [["make","helmet"],["equip"],["cost",2,0]]],
			["Summon Full Helmet", [3,0], [["make","full helmet"],["equip"],["cost",3,0]]],
			["Summon Iron Boots", [2,0], [["make","iron boots"],["equip"],["cost",2,0]]],
			["Summon Gauntlets", [2,0], [["make","iron gauntlets"],["equip"],["cost",2,0]]],
			["Summon Cuirass", [3,0], [["make","cuirass"],["equip"],["cost",3,0]]],
			["Summon Amulet of Protection", [4,0], [["make","amulet of protection"],["equip"],["cost",4,0]]],
			["Summon Amulet of Focus", [4,0], [["make","amulet of focus"],["equip"],["cost",4,0]]],
		],
		[
			["Memorize Flurry", [5,0], [["v","host"],["v","controller"],["ability","flurry"],["cost",3,0]]],
			["Memorize Light", [5,0], [["v","host"],["v","controller"],["ability","light"],["cost",3,0]]],
			["Memorize Cat's Eye", [8,0], [["v","host"],["v","controller"],["ability","cateye"],["cost",3,0]]],
			["Memorize Haste", [5,0], [["v","host"],["v","controller"],["ability","haste"],["cost",3,0]]],
			["Memorize Passwall", [5,0], [["v","host"],["v","controller"],["ability","passwall"],["cost",3,0]]],
		]
	],
}


func get_description(name):
	if name in descriptions:
		return descriptions[name]
	return ""


func make_unit(arg):
	if arg in unit_data:
		var item = unit_data[arg]
		var itemdata = item[2]
		var r = item[0].instance()
		if item[1] == 1:
			var ai = Ai.new(r)
			G.controllers.append(ai)
		r.item_name = arg
		if itemdata.has("health"):
			r.health = Vector2(itemdata.health, itemdata.health)
		G.world.units.add_child(r)
		if item[0] == Man:
			for i in item[3]:
				G.cmds([["v","pos"],["make", i],["equip"]], r)
		r.orientation.basis = Transform().looking_at(Vector3(G.rng.randf_range(-1,1),0,G.rng.randf_range(-1,1)), Vector3.UP).basis.orthonormalized()
		r.set_seed(-1)
		return r


func make(arg):
	if arg in data:
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
		if itemdata.has("ontouch"):
			r.ontouch = []
			for i in itemdata.ontouch:
				r.ontouch.append(get_duplicate(r, i))
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
		G.world.objects.add_child(r)
		return r


func get_duplicate(this, arr):
	var r = []
	for i in arr:
		if i == null:
			r.append(this)
		else:
			r.append(i)
	return r
