extends Spatial

var you
var younit
var world
onready var item = preload("res://object/Spawn.gd").new()

var resource = {"gold": 9, "material": 9, "food": 9}


func rid(arg, remove=true):
	if arg.get_parent() == world.objects:
		world.objects.remove_child(arg)
		if remove:
			arg.queue_free()


func drop(arg, exc):
	var r = get_world().direct_space_state.intersect_ray(arg.transform.origin + Vector3(0, 1, 0), arg.transform.origin + Vector3(0, -40, 0), exc)
	world.objects.add_child(arg)
	if r and r.position:
		arg.transform.origin = r.position


func make_and_add(arg, pos):
	var newitem = item.make(arg)
	newitem.transform.origin = pos
	drop(newitem, [newitem])


func spawn_and_add(arg, pos):
	var newitem = item.make_unit(arg)
	newitem.transform.origin = pos
	drop(newitem, [newitem])


func add_resource(gold, mat, food):
	resource["gold"] += gold
	resource["material"] += mat
	resource["food"] += food
	you.get_node("Interface").display_gather(mat, gold, food)


func require_resource(gold, mat, food):
	var ngold = resource["gold"] - gold
	var nmat = resource["material"] - mat
	var nfood = resource["food"] - food
	if nmat >= 0:
		if ngold >= 0:
			if nfood >= 0:
				resource["material"] = nmat
				resource["gold"] = ngold
				resource["food"] = nfood
				return null
			return "food"
		return "gold"
	return "material"


func message(msg):
	you.get_node("Interface").message(msg)
