extends Node

var tick_events = []
var frame = 0
var frames = 0
var second
var half_second
var quarter_second


func on_process(delta):
	frame += delta
	second = false
	half_second = false
	quarter_second = false
	if frame >= .25:
		if len(tick_events) > 0:
			var event = tick_events.pop_back()
			if event.is_valid():
				event.call_func()
		frame = frame - .25
		frames = frames + 1
		quarter_second = true
		if frames == 2:
			half_second = true
		elif frames == 4:
			second = true
			frames = 0
