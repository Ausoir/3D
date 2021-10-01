extends Node

var duration = 3


func _process(delta):
	if duration < 9999:
		duration -= delta
		if duration <= 0:
			queue_free()

