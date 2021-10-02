extends Node

var duration = 3


func _ready():
	if has_node("Sound"):
		$Sound.play()


func _process(delta):
	if duration < 9999:
		duration -= delta
		if duration <= 0:
			queue_free()

