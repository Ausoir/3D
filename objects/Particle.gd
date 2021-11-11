extends Spatial

var duration = 3
var target
var initPos

func _ready():
	if has_node("Sound"):
		var sound = $Sound
		sound.play()
		var dist = max(12, sound.get_max_distance())
		G.cmds([["alert", sound.global_transform.origin, dist]], null)

func follow(p):
	target = p
	initPos = target.transform.origin

func _process(delta):
	if duration < 9999:
		duration -= delta
		if duration <= 0:
			queue_free()
		elif target != null:
			var newPos = target.transform.origin
			translate(newPos - initPos)
			initPos = newPos
