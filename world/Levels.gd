const dungeons = [
	[Vector2(12,12), [3,0], ["storage"]],
	[Vector2(14,14), [4,2], ["living", "storage"]],
	[Vector2(16,16), [4,2], ["living", "lab", "storage"]],
	[Vector2(18,18), [4,3], ["living", "lab", "storage"]],
	[Vector2(20,20), [4,3], ["living", "lab", "storage"]],
	[Vector2(24,24), [5,3], ["living", "lab", "storage"]],
	[Vector2(28,28), [4,2], ["living", "lab", "storage"]],
]
const finds = {
	mobs = [
		["digger", "miner"],
		["guard", "spearman", "warrior"],
		["inquisitor", "spearman"],
	],
	undead = [
		["digger"],
	],
	items = [
		["2 gold","4 gold"],
		["4 gold","8 gold"],
	],
	armors = [
		["cloth armor","boots"],
		["helmet","leather armor","leather gloves","leather boots"],
	],
	weapons = [
		["shortsword", "torch", "knife", "shiv", "shovel", "spear", "axe", "club"],
		["cleaver", "hammer", "trident", "scimitar", "mace"],
	],
	wands = [
		["jade staff", "crystal staff", "ruby staff"],
	],
	trinkets = [
		["amulet of protection","2 gold","4 gold","8 gold"],
	],
	beds = [
		["2 gold", "miner", "digger"]
	],
	books = [
		["spellbook"]
	]
}
var level


func _init(arg):
	level = arg

func get_dungeon():
	return dungeons[level]

func get_variance(arr, mod):
	var loot_level = floor(abs(G.rng.randfn(level, 1)))+mod
	loot_level = clamp(loot_level, 0, len(arr) - 1)
	return arr[loot_level]

func get_loot(loot_type, biome=-1):
	var mod = 0
	if loot_type == "doodads":
		if G.rng.randf() < .3:
			return null
		loot_type = G.rng.rand_arr(["weapons", "armors"])
		mod = -3
	elif loot_type == "treasures":
		loot_type = G.rng.rand_arr(["weapons", "armors", "items", "trinkets"])
		mod = 1
	if loot_type in finds:
		var loot_table = finds[loot_type]
		var loot_list = get_variance(loot_table, mod)
		if biome == -1:
			return G.rng.rand_arr(loot_list)
		else:
			var biome_threshold = 1.0 / len(loot_list)
			var biome_index = floor(biome / biome_threshold)
			return loot_list[biome_index]
