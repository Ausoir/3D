const dungeons = [
	[Vector2(13,13), [3,0], ["storage"]],
	[Vector2(15,15), [4,2], ["living", "storage"]],
	[Vector2(17,17), [4,2], ["living", "lab", "storage"]],
	[Vector2(19,19), [4,3], ["living", "lab", "storage"]],
	[Vector2(21,21), [4,3], ["living", "lab", "storage"]],
	[Vector2(25,25), [5,3], ["living", "lab", "storage"]],
	[Vector2(25,25), [5,3], ["living", "lab", "storage"]],
]
const finds = {
	mobs = [
		["guard"],
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
		["helmet","leather armor"],
		["shortsword"],
		["amulet of protection","2 gold","4 gold","8 gold"],
	],
	trinkets = [
		["amulet of protection","2 gold","4 gold","8 gold"],
	],
	beds = [
		["2 gold", "miner", "digger"]
	],
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

func get_loot(loot_type):
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
		return G.rng.rand_arr(loot_list)
