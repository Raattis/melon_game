extends Node2D
class_name Dropper

onready var cursor : Node2D = $fruit_cursor
onready var score : Score = $"/root/ui/score"
var cursor_y : float
var future_fruit : MeshInstance2D
var target_x := 0.0
var drop_queued := false

var level := 1
var future_level := 1
const prefab : PackedScene = preload("res://fruit.tscn")
const original_size := Vector2(10,10)
var cooldown := 0.0
const border_const := 199.9

var is_game_over : bool = false
var ending_over : bool = false
var ending_cooldown : float = 0.0

var fruit_rng := RandomNumberGenerator.new()

func _ready():
	fruit_rng.set_seed(7) # Chosen with a fair dice roll (also the sequence starts with two small fruits)
	score.level_start()
	future_fruit = cursor.duplicate()
	add_child(future_fruit)
	move_child(future_fruit, 0)
	future_fruit.name = "FUTURE"
	future_fruit.global_position = Vector2(-208, -280)
	#print_debug(future_fruit)
	cursor_y = cursor.position.y
	cursor.global_position = future_fruit.global_position

func maybe_restart():
	if is_game_over and ending_over:
		get_tree().reload_current_scene()

func make_fruit():
	if is_game_over:
		return
	
	score.end_combo()
	var fruit = prefab.instance()
	fruit.level = level
	$"..".add_child(fruit)
	fruit.global_position.y = cursor.global_position.y
	var border_dist := border_const - Fruit.get_target_scale(level) * original_size.x
	fruit.global_position.x = clamp(target_x, -border_dist, border_dist)
	fruit.linear_velocity.y = 400.0
	fruit.linear_velocity.x = 0
	fruit.angular_velocity = fruit_rng.randf() * 0.2 - 0.1
	level = future_level
	future_level = int(clamp(abs(fruit_rng.randfn(0.5, 2.3)) + 1, 1, 5))
	cooldown = 0.1 + min(0.2, level * 0.1)
	
	cursor.global_position = future_fruit.global_position
	cursor.scale = original_size * Fruit.get_target_scale(level)
	cursor.modulate = Fruit.get_color(level)

func _physics_process(delta: float):
	if is_game_over:
		do_ending(delta)

	cooldown -= delta
	var t : float = 1.0 - pow(0.0001, delta)
	cursor.modulate = lerp(cursor.modulate, Fruit.get_color(level), t)
	var target_scale := original_size * Fruit.get_target_scale(level)
	cursor.scale = lerp(cursor.scale, target_scale, t)
	var border_dist := border_const - cursor.scale.x

	if not drop_queued:
		target_x = clamp(get_local_mouse_position().x, -border_dist, border_dist)

	if not is_game_over:
		var pos_t : float = 1.0 - pow(0.0000001, delta)
		var target_pos := Vector2(target_x, cursor_y)
		cursor.position = lerp(cursor.position, target_pos, pos_t)

	future_fruit.scale = lerp(future_fruit.scale, original_size * Fruit.get_target_scale(future_level), t)
	future_fruit.modulate = lerp(future_fruit.modulate, Fruit.get_color(future_level), t)
	#print_debug(str(level) + "<-" + str(future_level) )

	if Input.is_key_pressed(KEY_I) and cooldown < 0.13:
		drop_queued = true
		maybe_restart()
		
	if drop_queued and abs(target_x - cursor.position.x) < 10:
		make_fruit()
		drop_queued = false

func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed():
			if cooldown <= 0:
				drop_queued = true
		maybe_restart()
	elif event is InputEventKey:
		if event.physical_scancode == KEY_ESCAPE and OS.has_feature("editor"):
			get_tree().quit()

func game_over():
	if is_game_over:
		return
	is_game_over = true
	ending_over = false
	ending_cooldown = 1.0
	score.game_over()

	var parent : Node2D = $".."
	for c in parent.get_children():
		if c is Fruit:
			c.game_over = true

var cooldown_progress := 1.0

func do_ending(delta: float):
	ending_cooldown -= delta
	if ending_cooldown > 0.0 or ending_over:
		return
	ending_cooldown += fruit_rng.randf() * 0.25 * max(0.1, cooldown_progress) + 0.01 * max(0.1, cooldown_progress)
	ending_cooldown = max(ending_cooldown, delta * 0.75)
	cooldown_progress *= 0.97
	var parent : Node2D = $".."
	for c in parent.get_children():
		if c is Fruit and not c.popped:
			c.pop()
			return
	ending_over = true
