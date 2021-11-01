extends KinematicBody

const GRAVITY = -.98
const JUMP_SPEED = 20
const HEIGHT = Vector3(0, 16, 0)
onready var sfx_land = $Sound/Land
onready var sfx_step = $Sound/Step
onready var sfx_voice = $Sound/Voice
onready var anim_tree = $AnimationTree
onready var anim_player = $AnimationPlayer
onready var skeleton = $CharacterArmature/Skeleton
onready var body_mesh = $CharacterArmature/Skeleton/Body
onready var health_bar = $Health
onready var damage_label = $Damage
var dissolve = preload("res://assets/materials/mat_dissolve.tres").duplicate()
var item_name = "unit"
var controller
var unit_size = Vector3.ONE
var move_speed = Vector2(4,4)
var motion_target = Vector2()
var motion = Vector2()
var view_x = Vector3()
var view_z = Vector3()
var orientation = Transform()
var velocity = Vector3()
var prev_post_velocity = 0
var state = "move"
var state_time = 0
var state_lock = false
var status
var airborne_time = -2
var frame = 0
var head
var hit_glance = true #hit bounces off object. Disabled for AI's
var hitbox
var hitshape
var level = 1
var health = Vector2(5, 5)

func _ready():
	status = G.factory.Status.new()
	orientation = global_transform
	orientation.origin = Vector3()
	head = skeleton.find_bone("Head")

func on_make():
	pass

func set_state(arg="move", force=false):
	if state != arg:
		if !state_lock or force:
			if state != "death":
				state = arg
				state_time = 0

func get_defense():
	return 0

func on_hit(pos, hitter, damage, tags):
	if !("true" in tags):
		var ac = 0
		get_defense()
		damage -= G.roll("1d"+str(ac))
	if hitter:
		controller.on_hit(pos, hitter, damage)
	if damage <= 0:
		G.make_particle("spark", pos, 1)
	else:
		damage_label.display(damage)
		G.make_particle("blood", pos, 1)
		set_state("hit", true)
		damage(damage)
		health_bar.display(health.x, health.y, item_name, level)

func _physics_process(delta):
	controller.on_process(delta)
	on_process(delta)

func on_process(delta):
	move_speed.x = move_speed.y
	status.update(delta)
	if is_on_floor():
		if airborne_time > .3:
			airborne_time = 0
			on_hit(get_position(), null, 1, ["true"])
			set_state("drop", true)
			sfx_land.play()
		else:
			airborne_time = 0
			if !state_lock:
				if state == "move":
					if motion_target == Vector2.ZERO and velocity == Vector3.ZERO:
						return
					else:
						anim_tree["parameters/lunge/blend_amount"] *= .8
						motion_target *= .8
				else:
					motion_target *= 0
			elif state == "drop":
				motion_target *= 0
			elif state == "hit":
				motion_target *= 0
			elif state == "death":
				return dying(delta)
			else: #state in attack_map
				anim_tree["parameters/lunge/blend_amount"] += (1-anim_tree["parameters/lunge/blend_amount"])*.1
				if state == "swing":
					var atkspd = 1/anim_tree["parameters/attack speed/scale"]
					motion_target *= .8
					if state_time > (.3 * atkspd) and state_time < (.7 * atkspd):
						move_speed.x = move_speed.y * 1.5
					elif state_time > (.7 * atkspd):
						motion_target *= .3
				elif state == "charge" and state_time > .5:
					move_speed.x = move_speed.y * 1.2
				else:
					motion_target *= .2
			state_time += delta
	elif velocity.y < GRAVITY * .15:
		airborne_time += delta
		if airborne_time > .1:
			set_state("fall")
			if get_position().y < 1:
				if state != "death":
					on_hit(get_position(), null, 4, ["true"])
				else:
					return dying(delta)
	else:
		motion_target *= 0
	motion = motion.linear_interpolate(motion_target, 8 * delta)
	var speed = max(abs(motion.x), abs(motion.y))
	if speed > 0.1:
		var target = motion.x * view_x + motion.y * view_z
		var q_from = orientation.basis.get_rotation_quat()
		var q_to = Transform().looking_at(target, Vector3.UP).basis.get_rotation_quat()
		orientation.basis = Basis(q_from.slerp(q_to, delta * 10))
	var rotdiff = orientation.basis.x.dot(view_z)
	anim_tree["parameters/head_h/add_amount"] = rotdiff * -2
	var h_velocity = Vector2(0, move_speed.x*speed).rotated(-orientation.basis.get_euler().y)
	velocity.x = h_velocity.x
	velocity.z = h_velocity.y
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector3.UP)
	var post_velocity = Vector2(velocity.x, velocity.z).length() / move_speed.y
	post_velocity = prev_post_velocity + (post_velocity - prev_post_velocity) * .1
	anim_tree["parameters/movement/blend_position"] = post_velocity
	prev_post_velocity = post_velocity
	push_objects(h_velocity)

	orientation = orientation.orthonormalized() # Orthonormalize orientation.
	global_transform.basis = orientation.basis.scaled(unit_size)

func push_objects(vel):
	var slides = get_slide_count()
	for i in range(slides):
		var col = get_slide_collision(i)
		if col.collider is KinematicBody:
			col.collider.move_and_slide(Vector3(vel.x*unit_size.x*.5,0,vel.y*unit_size.z*.5), Vector3.UP)
			return

func on_anim_finish():
	pass

func on_step():
	if abs(motion.x) > .5 or abs(motion.y) > .5:
		sfx_step.seek(0)
		sfx_step.play()
		G.cmds([["alert", get_position(), 3]], self)

func talk(stream):
	sfx_voice.set_stream(stream)
	sfx_voice.seek(0)
	sfx_voice.play()

func glance(hitpos, weapon_tags):
	if hit_glance and !("blunt" in weapon_tags):
		G.make_particle("spark", hitpos, 1)
		set_state("hit", true)

func get_view_position():
	return (global_transform * skeleton.get_bone_global_pose(head)).origin

func get_position():
	return global_transform.origin

func get_interact_position():
	return global_transform.origin + Vector3.UP

func get_adjacent(x, y):
	var h = Vector2(x, y).rotated(-transform.basis.get_euler().y)
	var pos = get_position()
	var target_pos = Vector3(pos.x + h.x, pos.y, pos.z + h.y)
	return target_pos

func damage(dmg):
	if health.x > 0:
		health.x -= dmg
		if health.x <= 0:
			controller.set_task()
			set_state("death", true)

func dying(delta):
	if state_time > 3:
		var mat_override = body_mesh.get_material_override()
		if mat_override == null:
			body_mesh.set_material_override(dissolve)
		elif state_time < 6:
			dissolve.set_shader_param("dissolve_amount", ease((state_time-3)/3.0, 0.4))
		else:
			die()
	state_time += delta

func die():
	status.die()
	controller.die()
	queue_free()

func set_faction(p):
	controller.set_faction(p)
