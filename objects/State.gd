var host
var type = "none"
var lifetime = 1
var particle


func _init(phost, ptype, plifetime):
	host = phost
	type = ptype
	if type == "work":
		particle = G.make_particle("repair", host.global_transform.origin, 9999)
	lifetime = plifetime


func die():
	if particle:
		particle.queue_free()


func update():
	if particle:
		particle.transform.origin = host.global_transform.origin
	if type == "work":
		host.work -= 1
	if lifetime < 999999:
		lifetime -= 1
		if lifetime < 0:
			if particle:
				particle.queue_free()
			return true
