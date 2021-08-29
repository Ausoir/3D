extends Node

var type
var holder
var health = 1
var req = [0, 0, 0, 0]
var interact = []
var use = []
var work = 0
var reach = 1


func damage(dmg):
	health -= dmg
	if health <= 0:
		if holder:
			holder.set_weapon(null)
		queue_free()
