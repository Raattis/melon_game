extends RigidBody2D
class_name Fruit

export var level := 1
var current_scale := Vector2(1,1)
var cooldown := 0.1
onready var mesh := $MeshInstance2D
onready var collider := $CollisionShape2D
var absorber
var popped := false
var game_over := false

const baked_colors := [
		Color(0.9725, 0, 0.2471, 1),
		Color(0.9608, 0.4157, 0.2824, 1),
		Color(0.6039, 0.3922, 0.9804, 1),
		Color(0.9804, 0.698, 0.0157, 1),
		Color(0.9725, 0.5176, 0.0706, 1),
		Color(0.9412, 0.3765, 0.302, 1),
		Color(0.9725, 0.9294, 0.4588, 1),
		Color(0.9765, 0.7765, 0.7333, 1),
		Color(0.949, 0.8118, 0.0118, 1),
		Color(0.6, 0.8471, 0.0588, 1),
		Color(0.0784, 0.5686, 0.0314, 1),
	]
#export var colors := baked_colors


static func get_target_scale(level_: int) -> float:
	return [
		1, # red
		1.5, # pink
		2, # purple
		3, # yellow
		4, # orange
		5, # red
		6, # pale yellow
		9, # pink
		11, # yellow
		13, # pale green
		15 # green
		][level_ - 1]

static func get_color(level_: int) -> Color:
	return baked_colors[level_ - 1]

static func get_target_mass(level_: int) -> float:
	return pow(2.0, level_ - 1)

func _ready():
	#if false and colors != baked_colors:
	#	print("[")
	#	for c in colors: 
	#		print("\t\tColor", c, ",")
	#	print("\t]")
	contact_monitor = true
	set_max_contacts_reported(50)
	
	mesh.modulate = get_color(level)
	mass = get_target_mass(level)
	var target_scale := Vector2(1,1) * get_target_scale(level)
	var prev_scale = current_scale
	current_scale = target_scale
	_scale_2d(target_scale)

func get_absorbed(other):
	collider.queue_free()
	absorber = other
	mesh.owner = $".."
	mesh.global_position = global_position
	var audio : Audio = $"../audio"
	var sample := audio.combine5
	var pitch := 1.0
	var volume := 0.0
	match level:
		0,1,2,3:
			sample = audio.combine7
			pitch += (3 - level) * 0.1
			volume += randf() * -1
		4,5,6: 
			sample = audio.combine4
			pitch += (6 - level) * 0.1
			volume += 5 - (6 - level)
		7,8,9:
			sample = audio.combine2
			pitch += (9 - level) * 0.1
			volume += 5 - (9 - level)
		10,11,12: 
			sample = audio.combine6
			pitch += (12 - level) * 0.1
			volume += 8 - (12 - level)
	audio.play_audio(sample, pitch + randf() * 0.1, volume)

func _process(delta: float):
	var t := 1.0 - pow(0.0001, delta)
	mesh.modulate = lerp(mesh.modulate, get_color(level), t)

	if absorber:
		if is_instance_valid(absorber) and absorber.cooldown > 0:
			var dist : Vector2 = absorber.global_position - mesh.global_position
			var speed := 1000.0 * delta
			if dist.length() <= speed:
				pass
			else:
				mesh.global_position += dist.normalized() * speed
				return
		mesh.queue_free()
		queue_free()

func do_combining(delta: float):
	if game_over:
		return

	if cooldown > delta:
		cooldown -= delta
		return
	else:
		cooldown = 0

	for node in get_colliding_bodies():
		if not node.has_method("get_absorbed") or node.level != level or node.is_queued_for_deletion():
			continue
		if node.absorber:
			continue
		if node.cooldown > 0:
			continue
		if node.get_instance_id() < get_instance_id():
			continue
		apply_central_impulse(-(node.global_position - global_position) * mass * 2)
		cooldown = 0.1
		level += 1
		var score : Score = $"/root/ui/score"
		score.add(level)
		if level >= 12:
			level = 11
			cooldown = 1000
			queue_free()
			node.queue_free()
		else:
			node.get_absorbed(self)
		return

func _physics_process(delta: float):
	if is_queued_for_deletion():
		return
	do_combining(delta)

	var t := 1.0 - pow(0.0001, delta)
	mass = lerp(mass, get_target_mass(level), t)
	var target_scale := Vector2(1,1) * (get_target_scale(level) if not popped else 0.0)
	var prev_scale = current_scale
	current_scale = lerp(current_scale, target_scale, t)
	_scale_2d(current_scale / prev_scale)

func _scale_2d(target_scale: Vector2):
	if target_scale.x == 1:
		return
	for child in get_children():
		if child is Node2D:
			child.scale *= target_scale
			child.transform.origin *= target_scale

func pop():
	popped = true
	var audio : Audio = $"../audio"
	var sample := audio.pop
	var pitch := 1.0
	var volume := 0.0
	match level:
		0,1,2,3:
			sample = audio.pop_small3
			pitch += (3 - level) * 0.2 - 0.3
			volume += (3 - level) * 1.0 - 10
		4,5,6:
			sample = audio.pop_med
			pitch += (6 - level) * 0.1
			volume += (-2 - (6 - level)) * 1.0
		7,8,9:
			sample = audio.pop_big
			pitch += (9 - level) * 0.1
			volume += (0 - (9 - level))
		10,11,12: 
			sample = audio.pop_big2
			pitch += (12 - level) * 0.1
			volume += (3 - (12 - level))
	audio.play_audio(sample, pitch - randf() * 0.3, volume - randf() * 2)
