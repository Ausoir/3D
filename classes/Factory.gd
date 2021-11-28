const WORK_DELAY = 5
const Item_Script = preload("res://objects/Item.gd")
const Despawn = preload("res://assets/materials/mat_despawn.tres")
const Progress = preload("res://interface/progress_bar.tscn")
const Status = preload("res://objects/states/Status.gd")
const Man = preload("res://objects/units/Man.tscn")
const Ai = preload("res://objects/units/Ai.gd")
const Bag = preload("res://assets/models/bag.obj")
const Type_Object = preload("res://objects/Object.tscn")
const Type_Item = preload("res://objects/Item.tscn")
const Transparent = preload("res://assets/materials/mat_transparent.tres")

const misc_data = {
	"missile": preload("res://objects/items/Missile.tscn"),
	"charge": preload("res://objects/items/Charge.tscn"),
	"lightning": preload("res://objects/items/Lightning.tscn"),
	"beam": preload("res://objects/items/Beam.tscn"),
}

const unit_data = {
	"dummy": [Man, 0, {hp=Vector2(10,10)}, ["torch","cloth armor","jade staff"]],
	"phantom": [Man, 1, {hp=Vector2(1,1)}, []],
	"miner": [Man, 1, {hp=Vector2(10,10)}, ["cloth armor", "boots", "pickaxe"]],
	"digger": [Man, 1, {hp=Vector2(10,10)}, ["cloth armor", "boots", "shovel"]],
	"guard": [Man, 1, {hp=Vector2(10,10)}, ["shortsword", "leather armor", "boots", "torch"]],
	"spearman": [Man, 1, {hp=Vector2(10,10)}, ["spear", "leather armor", "leather boots"]],
	"warrior": [Man, 1, {hp=Vector2(10,10)}, ["katana", "chainmail", "leather gloves", "leather boots"]],
	"soldier": [Man, 1, {hp=Vector2(10,10)}, ["longsword", "iron armor", "iron gauntlets", "iron boots", "full helmet"]],
	"inquisitor": [Man, 1, {hp=Vector2(5,5),reach=8}, ["jade staff", "cloth armor", "gloves", "boots"]],
}

const CMD_SWING = [["wait", 9999, "swing"]]
const CMD_EQUIP = [["wait",6,"work"],["cmd",0,[["equip"]]]]
const data = {
	"branch": ["item", preload("res://assets/models/branch.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["menu","branch"]]]]},{}],
	"stone": ["item", preload("res://assets/models/stone.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["menu","stone"]]]]},{}],
	"pickaxe": ["item", preload("res://assets/models/pickaxe.obj"),
		{skill="axes",onswing=CMD_SWING, damage="1d6", haste=-3, tags=["demolish", "true", "mine"]}],
	"knife": ["item", preload("res://assets/models/knife.obj"),
		{skill="daggers",onswing=CMD_SWING, damage="1d6", haste=1, tags=["true","light"]}],
	"shiv": ["item", preload("res://assets/models/shiv.obj"),
		{skill="daggers",onswing=CMD_SWING, damage="1d4", haste=2, tags=["true","light"]}],
	"hammer": ["item", preload("res://assets/models/hammer.obj"),
		{skill="maces",onswing=CMD_SWING, damage="1d6",weight=1, tags=["bash"]}],
	"axe": ["item", preload("res://assets/models/axe.obj"),
		{skill="axes",onswing=CMD_SWING, damage="1d8",weight=1, tags=[]}],
	"cleaver": ["item", preload("res://assets/models/cleaver.obj"),
		{skill="axes",onswing=CMD_SWING, damage="1d12",weight=2, tags=[]}],
	"shovel": ["item", preload("res://assets/models/shovel.obj"),
		{skill="axes",onswing=CMD_SWING, damage="1d6",weight=1}],
	"spear": ["item", preload("res://assets/models/spear.obj"),
		{skill="spears",onswing=CMD_SWING, damage="1d6"}],
	"trident": ["item", preload("res://assets/models/trident.obj"),
		{skill="spears",onswing=CMD_SWING, damage="1d12",weight=1}],
	"halberd": ["item", preload("res://assets/models/halberd.obj"),
		{skill="spears",onswing=CMD_SWING, damage="1d16", haste=-1,weight=2}],
	"glaive": ["item", preload("res://assets/models/glaive.obj"),
		{skill="spears",onswing=CMD_SWING, damage="2d10", haste=-2,weight=2}],
	"shortsword": ["item", preload("res://assets/models/shortsword.obj"),
		{skill="daggers",onswing=CMD_SWING, damage="2d4", haste=1}],
	"scimitar": ["item", preload("res://assets/models/scimitar.obj"),
		{skill="swords",onswing=CMD_SWING, damage="2d6", haste=1,weight=1, tags=["cut"]}],
	"saber": ["item", preload("res://assets/models/saber.obj"),
		{skill="swords",onswing=CMD_SWING, damage="2d6", haste=1,weight=1, tags=["cut"]}],
	"longsword": ["item", preload("res://assets/models/longsword.obj"),
		{skill="longswords",onswing=CMD_SWING, damage="2d8", weight=2}],
	"greatsword": ["item", preload("res://assets/models/greatsword.obj"),
		{skill="longswords",onswing=CMD_SWING, damage="2d16", haste=1,weight=3, tags=["cut"]}],
	"rapier": ["item", preload("res://assets/models/rapier.obj"),
		{skill="longswords",onswing=[["wait", 9999, "flurry"]], damage="1d6", tags=["penetrate"]}],
	"katana": ["item", preload("res://assets/models/katana.obj"),
		{skill="swords",onswing=[["wait", 9999, "flurry"]], damage="1d16", haste=1, tags=["cut"]}],
	"wakizashi": ["item", preload("res://assets/models/shortkatana.obj"),
		{skill="swords",onswing=[["wait", 9999, "flurry"]], damage="1d16", haste=2, tags=["cut","light"]}],
	"club": ["item", preload("res://assets/models/club.obj"),
		{skill="maces",onswing=CMD_SWING, damage="2d4", haste=-1, tags=["bash"]}],
	"mace": ["item", preload("res://assets/models/mace.obj"),
		{skill="maces",onswing=CMD_SWING, damage="2d8", haste=-1,weight=2, tags=["bash"]}],
	"greatmace": ["item", preload("res://assets/models/greatmace.obj"),
		{skill="maces",onswing=CMD_SWING,onattack=[["rnd",.4],["act","$t","knockdown",true]], damage="1d16", haste=-1,weight=3, tags=["bash"]}],
	"warhammer": ["item", preload("res://assets/models/warhammer.obj"),
		{skill="maces",onswing=CMD_SWING,onattack=[["rnd",.5],["act","$t","knockdown",true]], damage="2d8", haste=-1,weight=4, tags=["bash"]}],
	"conesword": ["item", preload("res://assets/models/shortsword_cone.obj"),
		{skill="daggers",onswing=CMD_SWING,onattack=[["hit","$t",null,4,["magic"]]], damage="1d6", haste=1, tags=["cut","light"]}],
	"feather blade": ["item", preload("res://assets/models/shortsword_unique.obj"),
		{skill="swords",onswing=CMD_SWING, damage="2d6", haste=4, tags=["cut","light"]}],
	"real blade": ["item", preload("res://assets/models/longsword_unique.obj"),
		{skill="longswords",onswing=CMD_SWING, damage="2d10", haste=1}],
	"jade staff": ["item", preload("res://assets/models/staff_common.obj"),
		{skill="maces",onswing=[["wait", 30, "special"]], ability="stars"}],
	"crystal staff": ["item", preload("res://assets/models/staff_uncommon.obj"),
		{skill="maces",onswing=[["wait", 30, "special"]], ability="lightning", haste=1}],
	"ruby staff": ["item", preload("res://assets/models/staff_rare.obj"),
		{skill="maces",onswing=[["wait", 30, "special"]], ability="rune", haste=2}],

	"torch": ["item", preload("res://objects/items/Torch.tscn"),
		{onswing=CMD_EQUIP, part="offhand"}],
	"cloth armor": ["item", Bag,
		{onswing=CMD_EQUIP, defense=6,part="armor",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather armor": ["item", Bag, 
		{onswing=CMD_EQUIP, defense=6,health=5,weight=1, part="armor",skin=preload("res://assets/materials/mat_leather.tres")}],
	"chainmail": ["item", Bag,
		{onswing=CMD_EQUIP, defense=9,health=8,weight=2, part="armor",skin=preload("res://assets/materials/mat_chain.tres")}],
	"cuirass": ["item", Bag,
		{onswing=CMD_EQUIP, defense=12,health=10,weight=4, part="armor",skin=preload("res://assets/materials/mat_metal.tres")}],
	"gloves": ["item", Bag,
		{onswing=CMD_EQUIP, focus=1,part="arms",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather gloves": ["item", Bag,
		{onswing=CMD_EQUIP, defense=2,part="arms",skin=preload("res://assets/materials/mat_leather.tres")}],
	"chain leggings": ["item", Bag,
		{onswing=CMD_EQUIP, defense=4,weight=1,part="arms",skin=preload("res://assets/materials/mat_chain.tres")}],
	"iron gauntlets": ["item", Bag,
		{onswing=CMD_EQUIP, defense=6,weight=2,part="arms",skin=preload("res://assets/materials/mat_metal.tres")}],
	"boots": ["item", Bag,
		{onswing=CMD_EQUIP, speed=1,part="legs",skin=preload("res://assets/materials/mat_cloth.tres")}],
	"leather boots": ["item", Bag,
		{onswing=CMD_EQUIP, speed=1,defense=1,part="legs",skin=preload("res://assets/materials/mat_leather.tres")}],
	"chain boots": ["item", Bag,
		{onswing=CMD_EQUIP, defense=3,part="legs",skin=preload("res://assets/materials/mat_chain.tres")}],
	"iron boots": ["item", Bag,
		{onswing=CMD_EQUIP, defense=5,weight=1,part="legs",skin=preload("res://assets/materials/mat_metal.tres")}],
	"headband": ["item", preload("res://assets/models/headband.obj"),
		{onswing=CMD_EQUIP, health=5,part="head"}],
	"helmet": ["item", preload("res://assets/models/helmet.obj"),
		{onswing=CMD_EQUIP, defense=4,weight=1, part="head"}],
	"full helmet": ["item", preload("res://assets/models/fullhelm.obj"),
		{onswing=CMD_EQUIP, defense=8,weight=2, part="head"}],
	"amulet of protection": ["item", Bag,
		{onswing=CMD_EQUIP, defense=6, part="accessory"}],
	"amulet of focus": ["item", Bag,
		{onswing=CMD_EQUIP, focus=2, part="accessory"}],
	"amulet of strength": ["item", Bag,
		{onswing=CMD_EQUIP, strength=1, part="accessory"}],
	"amulet of health": ["item", Bag,
		{onswing=CMD_EQUIP, health=5, part="accessory"}],

	"2 gold": ["item", preload("res://assets/models/coinsSmall.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",0,-2,true]]]]}],
	"4 gold": ["item", preload("res://assets/models/coinsMedium.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",0,-4,true]]]]}],
	"8 gold": ["item", preload("res://assets/models/coinsLarge.obj"),
		{onuse=[["wait", 12, "work"],["cmd", 0, [["die"],["cost",0,-8,true]]]]}],
	"health potion": ["item", preload("res://assets/models/potionSmall_blue.obj"),
		{onswing=[["wait", 12, "work"],["cmd", 0, [["die"],["v","host"],["state","regen",120]]]]}],
	"spellbook": ["item", preload("res://objects/items/Spellbook.tscn"),
		{onswing=[["wait", 36, "work"],["cmd", 0, [["trigger"]]]], loot="spells"}],



	"waste": ["building", preload("res://objects/buildings/Waste.tscn"), {
		onmake=[["v","spawnpoint","$h",0],["r","cmd",[[],[["make","shovel"]]]],
				["v","spawnpoint","$h",1],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint","$h",2],["r","cmd",[[],[["make","pot"]]]]]
	}],
	"pots": ["building", preload("res://objects/buildings/Pots.tscn"), {
		mat="ceramic",hp=Vector2(1,1),
		onmake=[["v","spawnpoint","$h",0],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint","$h",1],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint","$h",2],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint","$h",3],["r","cmd",[[],[["make","pot"]]]],
				["v","spawnpoint","$h",4],["r","cmd",[[],[["make","pot"]]]]]
	}],
	"pot": ["building", preload("res://objects/buildings/Pot.tscn"), {mat="ceramic",hp=Vector2(1,1)}],
	"table": ["building", preload("res://objects/buildings/Table.tscn"), {mat="wood",hp=Vector2(4,4)}],
	"large table": ["building", preload("res://objects/buildings/TableLarge.tscn"), {mat="wood",hp=Vector2(8,8)}],
	"bed cluster": ["building", preload("res://objects/buildings/Bed.tscn"), {hp=Vector2(12,12),loot="beds"}],
	"beds": ["building", preload("res://objects/buildings/Bed2.tscn"), {hp=Vector2(4,4),loot="beds"}],
	"campfire": ["building", preload("res://objects/buildings/Campfire.tscn"),{mat="wood",hp=Vector2(4,4)}],
	"walltorch": ["building", preload("res://objects/buildings/Torch.tscn"),{hp=Vector2(1,1)}],
	"crates": ["building", preload("res://objects/buildings/Crates.tscn"),{mat="wood",hp=Vector2(2,2)}],
	"barrels": ["building", preload("res://objects/buildings/Barrels.tscn"),{mat="wood",hp=Vector2(2,2)}],
	"derelict floor": ["building", preload("res://objects/buildings/DerelictFloor.tscn"),{}],
	"derelict floor2": ["building", preload("res://objects/buildings/DerelictFloor2.tscn"),{}],
	"scaffold": ["building", preload("res://assets/models/buildings/scaffold_small_high.obj"),{}],
	"planks": ["building", preload("res://objects/buildings/Planks.tscn"),{}],
	"carpet": ["building", preload("res://objects/buildings/Carpet.tscn"),{}],
	"kegs": ["building", preload("res://objects/buildings/Kegs.tscn"),{mat="wood",hp=Vector2(12,12)}],
	"desk": ["building", preload("res://objects/buildings/Desk.tscn"),{mat="wood",hp=Vector2(4,4)}],
	"bench": ["building", preload("res://objects/buildings/Bench.tscn"),{mat="wood",hp=Vector2(2,2)}],
	"bubblelight": ["building", preload("res://objects/buildings/Magelight.tscn"),{}],
	"mageaura": ["building", preload("res://objects/buildings/Mageaura.tscn"),
		{onuse=[["wait",16,"work",true],["cmd",0,[["state","regenerate",45],["v","host"],["trigger"]]]]}],
	"cauldron": ["building", preload("res://objects/buildings/Cauldron.tscn"),{}],
	"altar": ["building", preload("res://objects/buildings/Altar.tscn"),{}],
	"benchs": ["building", preload("res://objects/buildings/Benchs.tscn"),{}],
	"dissection": ["building", preload("res://objects/buildings/Dissection.tscn"),{hp=Vector2(12,12)}],
	"occluder": ["building", preload("res://objects/buildings/Occluder.tscn"),{}],
	"portal": ["building", preload("res://objects/buildings/Portal.tscn"),{
		onmake=[["v","host"],["state","work",9999],["setwork",24,"Destabilizing..."]],
		onwork=[["setwork"],["v","host"],["trigger",""]],
		#onuse=[["wait",8,"work",true],["cmd",0,[["v","host"],["v","controller"],["menu","Shop"]]]]
	}],
	"door": ["building", preload("res://objects/buildings/Door.tscn"),{
		mat="wood",ontouch=[["cmd",0,[["trigger"]]]],hp=Vector2(4,4),jail_defense=6
	}],
	"trapdoor": ["building", preload("res://objects/buildings/Trapdoor.tscn"),{
		onuse=[["wait",24,"work",true],["cmd",0,[["trigger"]]]]
	}],
	"chest": ["building", preload("res://objects/buildings/Chest.tscn"),
		{hp=Vector2(4,4),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="doodads", rarity=1}],
	"loot": ["building", preload("res://objects/buildings/Chest.tscn"),
		{hp=Vector2(12,12),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="treasure", rarity=2}],
	"treasure": ["building", preload("res://objects/buildings/Chest.tscn"),
		{hp=Vector2(12,12),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="treasure", rarity=3}],
	"bookcase": ["building", preload("res://objects/buildings/Bookcase.tscn"),
		{mat="wood",hp=Vector2(6,6),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="books"}],
	"wand rack": ["building", preload("res://objects/buildings/RackWands.tscn"),
		{mat="wood",hp=Vector2(6,6),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="wands"}],
	"weapon rack": ["building", preload("res://objects/buildings/RackWeapons.tscn"),
		{mat="wood",hp=Vector2(6,6),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="weapons"}],
	"armor rack": ["building", preload("res://objects/buildings/RackArmors.tscn"),
		{mat="wood",hp=Vector2(6,6),onuse=[["wait",12,"work",true],["cmd",0,[["trigger"]]]], loot="armors"}],
}

var descriptions = {
	"true": "Ignores armor.",
	"demolish": "Can destroy walls.",
	"health": "This is how much damage you can take.",
	"defense": "Defense represents how much damage you have chance of negating.",
	"strength": "Reduces item weight impact on your move/attack/casting speed",
	"focus": "Reduces spellcasting cooldown",
	"Revitalize": "Regenerate health",
	"Forget Spells": "Forget all your memorized spells",
	"Enchant Health": "Permanently increases health by 5 points",
	"Enchant Strength": "Permanently increases strength by 1 point",
	"Enchant Focus": "Permanently increases focus by 1 point",
	"Swords": "Your swords proficiency",
	"Spears": "Your spears proficiency",
	"Dodging": "You gain extra defense equal to your dodging proficiency",
	"Memorize Light": "Enchant yourself with bright light for a while",
	"Memorize Cat's Eye": "Gain night vision",
	"Memorize Haste": "Gain a burst of speed for a while",
	"Memorize Passwall": "Cast against a wall to pass through it",
	"Memorize Missile": "Shoot some magical projectiles to damage the enemy",
	"Memorize Rune Trap": "Set a trap that explodes when anything passes by",
	"Memorize Lightning": "Shoot a lightning to decimate a single enemy",
	"Memorize Possess Weapon": "Imbue your wielded weapon with its own will to attack your enemies",
	"Memorize Charm": "Charm target for a while",
	"Memorize Invisibility": "Become invisible for a while",
	"Memorize Light Beam": "Shoot a beam of light to decimate anything in its way",
}

var spells = [
	[
		["Transmute Gold to Mana", [0,5], [["cost",0,5],["cost",-2,0]]],
		["Revitalize", [1,0], [["v","host"],["state","regenerate",45],["cost",1,0]]],
		["Forget Spells", [1,0], [["v","controller","$h"],["spell","forget"]]],
		["Enchant Health", [5,0], [["dat","g","hp",null],["v","add","$t",Vector2(1,1)],["dat","a","hp","$"],["cost",10,0]]],
		["Enchant Strength", [10,0], [["dat","g","strength",0],["v","add","$t",1],["dat","a","strength","$"],["cost",10,0]]],
		["Enchant Focus", [5,0], [["dat","g","focus",0],["v","add","$t",1],["dat","a","focus","$"],["cost",10,0]]],
	],
	[
		["Summon Torch", [1,0], [["make","torch"],["wield"],["cost",1,0]]],
		["Summon Pickaxe", [2,0], [["make","pickaxe"],["wield"],["cost",2,0]]],
		["Summon Shortsword", [2,0], [["make","shortsword"],["wield"],["cost",2,0]]],
		["Summon Saber", [5,0], [["make","saber"],["wield"],["cost",5,0]]],
		["Summon Halberd", [5,0], [["make","halberd"],["wield"],["cost",5,0]]],
		["Summon Mace", [3,0], [["make","mace"],["wield"],["cost",3,0]]],
		["Summon Cleaver", [3,0], [["make","cleaver"],["wield"],["cost",3,0]]],

		["Summon Full Iron Suit", [15,0], [["make","iron armor"],["equip"], ["make","iron gauntlets"],["equip"], ["make","iron boots"],["equip"],["cost",15,0]]],
		["Summon Iron Helmet", [2,0], [["make","helmet"],["equip"],["cost",2,0]]],
		["Summon Full Helmet", [3,0], [["make","full helmet"],["equip"],["cost",3,0]]],
		["Summon Iron Boots", [2,0], [["make","iron boots"],["equip"],["cost",2,0]]],
		["Summon Gauntlets", [2,0], [["make","iron gauntlets"],["equip"],["cost",2,0]]],
		["Summon Cuirass", [3,0], [["make","cuirass"],["equip"],["cost",3,0]]],
		["Summon Amulet of Protection", [4,0], [["make","amulet of protection"],["equip"],["cost",4,0]]],
		["Summon Amulet of Focus", [4,0], [["make","amulet of focus"],["equip"],["cost",4,0]]],
		["Summon Amulet of Strength", [4,0], [["make","amulet of strength"],["equip"],["cost",4,0]]],
		["Summon Amulet of Health", [4,0], [["make","amulet of health"],["equip"],["cost",4,0]]],

		["Summon Warrior", [2,5], [["v","$h","pos"], ["make","warrior"],["v","controller","$h"],["faction",1]]],
		["Summon Soldier", [2,10], [["v","$h","pos"], ["make","soldier"],["v","controller","$h"],["faction",1]]],
	],
	[
		["Memorize Flurry", [5,0], [["v","controller","$h"],["spell","memorize","flurry",true],["if",true],["cost",5,0]]],
		["Memorize Light", [1,0], [["v","controller","$h"],["spell","memorize","light",true],["if",true],["cost",1,0]]],
		["Memorize Cat's Eye", [5,0], [["v","controller","$h"],["spell","memorize","cateye",true],["if",true],["cost",5,0]]],
		["Memorize Haste", [5,0], [["v","controller","$h"],["spell","memorize","haste",true],["if",true],["cost",5,0]]],
		["Memorize Passwall", [5,0], [["v","controller","$h"],["spell","memorize","passwall",true],["if",true],["cost",5,0]]],
		["Memorize Missile", [5,0], [["v","controller","$h"],["spell","memorize","missile",true],["if",true],["cost",5,0]]],
		["Memorize Rune Trap", [5,0], [["v","controller","$h"],["spell","memorize","rune",true],["if",true],["cost",5,0]]],
		["Memorize Lightning", [5,0], [["v","controller","$h"],["spell","memorize","lightning",true],["if",true],["cost",5,0]]],
		["Memorize Clairvoyance", [5,0], [["v","controller","$h"],["spell","memorize","clairvoyance",true],["if",true],["cost",3,0]]],
		["Memorize Possess Weapon", [5,0], [["v","controller","$h"],["spell","memorize","phantom",true],["if",true],["cost",3,0]]],
		["Memorize Charm", [5,0], [["v","controller","$h"],["spell","memorize","charm",true],["if",true],["cost",3,0]]],
		["Memorize Invisibility", [5,0], [["v","controller","$h"],["spell","memorize","invisibility",true],["if",true],["cost",3,0]]],
		["Memorize Light Beam", [5,0], [["v","controller","$h"],["spell","memorize","stars",true],["if",true],["cost",5,0]]],
	]
]


func get_description(name):
	if name in descriptions:
		return descriptions[name]
	return ""


func make_unit(arg):
	if arg in unit_data:
		var item = unit_data[arg]
		var r = item[0].instance()
		if item[1] == 1:
			var ai = Ai.new(r)
			G.controllers.append(ai)
		r.item_name = arg
		r.dat = G.Properties.new(item[2])
		G.world.units.add_child(r)
		if item[0] == Man:
			for i in item[3]:
				G.cmds([["v","pos",r],["make", i],["equip"]], r)
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
		r.item_name = arg
		r.item_type = item[0]
		r.dat = G.Properties.new(item[2])
		if item[0] == "object":
			r.create_trimesh_collision()
			r.get_child(0).set_collision_layer(0b00000000000000000110)
		elif item[0] == "item":
			r.dat.a("onuse", [["wait", 6, "grab"],["cmd", 0, [["wield"]]]])
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

func get_known_spells():
	var r = []
	for spell_type in spells:
		var new_types = []
		for spell in spell_type:
			if G.rng.randi_range(0, 3) == 0:
				new_types.append(spell)
		r.append(new_types)
	return r
