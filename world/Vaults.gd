
const walls = ['W', '#', 'S']
const data = [
	["WWWWWWWWW",
	 "W.?..!..W",
	 "W..W....W",
	 "WW.WWWW#W",
	 "W.!.....W",
	 "WWW.WWWWW"],
	["WWWWW##",
	 "W.?W?.#",
	 "W.WWWDW",
	 "W..W..W",
	 "W.!.!.W",
	 "WWW.WWW"],
	["WSSSSSW",
	 "W?....W",
	 "W.WDW.W",
	 "W!#.#!W",
	 "WWW.WWW"],
	["WWW.WWW",
	 "W?!...W",
	 "W!..f.D",
	 "W?!...W",
	 "WWWWWWW"],
	["WWWWW",
	 "D!.!D",
	 "D.?.D",
	 "D!.!D",
	 "WWWWW"],
	["#DWWWWW",
	 "#..D.!W",
	 "#..W!?W",
	 "WWWWWWW"],
	["#D##",
	 "#.^#",
	 "#^.#",
	 "##D#"],
	["WWW.WWW",
	 "W.D!D.W",
	 "W.###.W"],
	["W###WW",
	 ".D?..D",
	 "W###WW"],
	["WWW.W",
	 "W.W.W",
	 "W.WWW"],
	["#####",
	 "D.^.D",
	 "#####"],
	["##D#",
	 "#..#",
	 "####"],
	["###",
	 "#f#",
	 "###"],
	["###",
	 "...",
	 "###"],
	[".!.",
	 ".!."],
	[".^",
	 "^."],
	["W###W"],
	["W##W"],
	["W#W"],
	["###"],
]
const data2 = [ #debug only
	["ffffff",
	 "f^!!^f",
	 "ffffff"],
]

func make_vault(rng, base, from, to):
	var size = to - from
	var candidates = []
	for vault in data:
		var diffX = size.x - len(vault[0]) + 1
		var diffY = size.y - len(vault) + 1
		var diffX2 = size.x - len(vault) + 1
		var diffY2 = size.y - len(vault[0]) + 1
		if diffX == 0 and diffY == 0:
			candidates.append([vault, from.x, from.y, rng.randi_range(0, 3), false])
		elif diffX2 == 0 and diffY2 == 0:
			candidates.append([vault, from.x, from.y, rng.randi_range(0, 3), true])
		elif diffX >= 4 and diffY >= 4:
			var startX = from.x + rng.randi_range(2, diffX-2)
			var startY = from.y + rng.randi_range(2, diffY-2)
			candidates.append([vault, startX, startY, rng.randi_range(0, 3), false])
		elif diffX2 >= 4 and diffY2 >= 4:
			var startX = from.x + rng.randi_range(2, diffX2-2)
			var startY = from.y + rng.randi_range(2, diffY2-2)
			candidates.append([vault, startX, startY, rng.randi_range(0, 3), true])
	print(size, " ", len(candidates), " ", from, " ", to)
	for candidate in candidates:
		if rng.randi_range(0, 3) > 0:
			return place_vault(rng, base, from, candidate[0], candidate[1], candidate[2], candidate[3], candidate[4])

func place_vault(rng, base, from, vault, startX, startY, flip, rot):
	if !check_vault_validity(vault):
		print("Invalid vault: " + str(vault))
	else:
		var doors = []
		for y in range(len(vault)):
			for x in range(len(vault[0])):
				var sX = startX + x
				var sY = startY + y
				if flip == 1 or flip == 3:
					sX = startX + (len(vault[0])-1 - x)
				if flip == 2 or flip == 3:
					sY = startY + (len(vault)-1 - y)
				if rot:
					place_tile(base, startX + y, startY + x, vault[y][x], doors)
				else:
					place_tile(base, startX + x, startY + y, vault[y][x], doors)
		for door in doors:
			for i in range(-1, 2):
				if base[door[1]][i + door[0]] in walls:
					base[door[1]][i + door[0]] = '.'
				if base[i + door[1]][door[0]] in walls:
					base[i + door[1]][door[0]] = '.'

func place_tile(base, x, y, val, doors):
	if base[y][x] != 'D' or !(val in walls):
		base[y][x] = val

func check_vault_validity(vault):
	var sizeX = len(vault[0])
	for y in vault:
		if len(y) != sizeX:
			return false
	return true
