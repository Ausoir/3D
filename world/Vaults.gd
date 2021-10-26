
const walls = ['W', '#', '=']
const data = {
	"default" : [
		["WWWWWWWWW",
		 "W.?,!,..W",
		 "W.,W,...W",
		 "WW,WWW=WW",
		 "W.!,,,..W",
		 "WWW.WWWWW"],
		["WWWWWWWW",
		 "W..W.?.W",
		 "W,.W.!.W",
		 "WDWWWDWW",
		 "W,..!,.W",
		 "WW.WWWWW"],
		["WWWWWWW",
		 "W..W..W",
		 "W.WWWDW",
		 "W..W..W",
		 "W.!.!.W",
		 "WWW.WWW"],
		["WWWWWWW",
		 "W?,,,,W",
		 "W,WDW,W",
		 "W!=.=!W",
		 "WWW.WWW"],
		["WWW,WWW",
		 "W..,..W",
		 ",,!f!,,",
		 "W..,..W",
		 "WWW,WWW"],
		["WWWWWW",
		 "W^D!.=",
		 "D.D?fW",
		 "W^D!.=",
		 "WWWWWW"],
		["WWWWW",
		 "D!.!D",
		 "D.?.D",
		 "D!.!D",
		 "WWWWW"],
		["WWWWWWWWW",
		 "W,.W,D,,=",
		 "=.,D!Wf.W",
		 "WWWWWWWWW"],
		["#DWWWWW",
		 "#..D.!W",
		 "#..=!?W",
		 "WWWWWWW"],
		["W###W",
		 "#...#",
		 "#...#",
		 "W###W"],
		["W=#W",
		 "#..=",
		 "=..#",
		 "W#=W"],
		["#D##",
		 "#.^#",
		 "#^.#",
		 "##D#"],
		["WW=WWWDWWW#WW",
		 "D...........D",
		 "WWW#WWDWW=WWW"],
		["WW=WW==WW=WW",
		 "W..........W",
		 "WWW=WWWW=WWW"],
		["###########",
		 "#...D^D...#",
		 "###########"],
		["###,,,,###",
		 "#..!^^!..#",
		 "###,,,,###"],
		["WWWWW=WWW",
		 "W.D.D.D.W",
		 "WWW=WWWWW"],
		["WWW.WWW",
		 "W.DfD.W",
		 "W.###.W"],
		["W###WW",
		 ".D?,,#",
		 "W###WW"],
		["WWW.W",
		 "=.D.=",
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
		["W=W",
		 "...",
		 "W=W"],
		["#W#",
		 "=?=",
		 "###"],
		["W...W",
		 ",,W,,"],
		["W=W",
		 "W.W"],
		[",,W",
		 "W,,"],
		[",!,",
		 ",!,"],
		[",^",
		 "^,"],
		["WW=WW"],
		["W##W"],
		["W#W"],
		["###"],
	],
	"chapel" : [
		["WWWWWWW",
		 "=,,0,,=",
		 "W?222!W",
		 "=,222,=",
		 "WDWWWDW"],
		["WWDWW",
		 "=,,,=",
		 "W,0,W",
		 "=,,,=",
		 "WWWWW"],
		["WWWWW",
		 "W101W",
		 ",WWW,"],
		[",",
		 "0",
		 "W"]
	],
	"lab" : [ #Inner only
		["WWWWWWW",
		 "W03430W",
		 "W03430W",
		 "WWWWWWW"],
		["WWWWWW",
		 "W155?W",
		 "W2662W",
		 "WWDWWW"],
		["WDWWW",
		 "W.#1W",
		 "W.D5W",
		 "WWWWW"],
		["W=#W",
		 "#00=",
		 "=00#",
		 "W#=W"],
		["######",
		 "#?!50#",
		 "##D###"],
		["W###W",
		 "22222",
		 ".W3W."],
		["W111W",
		 "W101W",
		 "2W=W2"],
		["WWWW",
		 "2112",
		 "W22W"],
		["W2W2W",
		 "6W6W6"],
		["WWWWW",
		 "W222W"],
		["WW=WW",
		 "W212W"],
		["##",
		 "##"],
		["44",
		 "44"],
		["66W66"],
		["66666"],
		["11111"],
	],
	"entrance" : [
		["WWDWW",
		 "=,,,=",
		 "W,0,W",
		 "=,,,=",
		 "WWWWW"],
		["WWWWW",
		 "W101W",
		 ",WWW,"],
		["#","#","#",
		 "#","P","#",
		 "#","D","#"],
		["#","#","#",
		 "#","#","#"],
		[",","0",","],
		["#","#",
		 "#","#"],
		["1","0",
		 "2","2"]
	],
}

func make_vault(rng, base, from, to, type="default", container_only=false):
	var size = to - from
	var candidates = []
	for vault in data[type]:
		var diffX = size.x - len(vault[0]) + 1
		var diffY = size.y - len(vault) + 1
		var diffX2 = size.x - len(vault) + 1
		var diffY2 = size.y - len(vault[0]) + 1
		if diffX == 0 and diffY == 0 and !container_only:
			candidates.append([vault, from.x, from.y, rng.randi_range(0, 3), false])
		elif diffX2 == 0 and diffY2 == 0 and !container_only:
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
		if rng.randi_range(0, 2) > 0:
			place_vault(base, candidate[0], candidate[1], candidate[2], candidate[3], candidate[4])
			if candidate[4]:
				if candidate[3] == 1 or candidate[3] == 3:
					return 22
				else:
					return 16
			else:
				if candidate[3] == 2 or candidate[3] == 3:
					return 10
				else:
					return 0
	return -1

func place_vault(base, vault, startX, startY, flip, rot):
	if !check_vault_validity(vault):
		print("Invalid vault: " + str(vault))
	else:
		for y in range(len(vault)):
			for x in range(len(vault[0])):
				var sX = x
				var sY = y
				if flip == 1 or flip == 3:
					sX = (len(vault[0])-1 - x)
				if flip == 2 or flip == 3:
					sY = (len(vault)-1 - y)
				if rot:
					place_tile(base, startX+sY, startY+sX, vault[y][x])
				else:
					place_tile(base, startX+sX, startY+sY, vault[y][x])

func place_tile(base, x, y, val):
	if base[y][x] != 'D' or !(val in walls):
		base[y][x] = val

func check_vault_validity(vault):
	var sizeX = len(vault[0])
	for y in vault:
		if len(y) != sizeX:
			return false
	return true
