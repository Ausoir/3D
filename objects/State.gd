var host
var name = "none"
var lifetime = 1
var particle


func _init(phost, ptype, plifetime):
	host = phost
	name = ptype
	if name == "work":
		particle = G.make_particle("repair", host.global_transform.origin, 9999)
	elif name == "haste":
		particle = G.make_particle("repair", host.global_transform.origin, 9999)
	lifetime = plifetime


func die():
	if particle:
		particle.queue_free()


func update(delta, second):
	if name == "haste":
		host.motion_target *= 100*delta
	elif name == "slowfall":
		if host.velocity.y < 0:
			host.velocity.y *= .5

	if second:
		if particle:
			particle.transform.origin = host.global_transform.origin
		if name == "work":
			host.work -= 1
		if lifetime < 999999:
			lifetime -= 1
			if lifetime <= 0:
				if particle:
					particle.queue_free()
				return true
