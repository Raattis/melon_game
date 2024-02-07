GDPC                                                                                          P   res://.godot/exported/133200997/export-20a18325f7c6eab45b6b222a29d4ddff-wall.scn�G      M      e��_4�g�һɯU    P   res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn`       �      �M�8����"Ln���    P   res://.godot/exported/133200997/export-5d2f649bfda0e984c5f95c948cc9f360-ui.scn  �@            B���>iY�&�}\͟    T   res://.godot/exported/133200997/export-96d9542281595709dde67debd2e51295-fruit.scn   `      �      6�3��0�7����    X   res://.godot/exported/133200997/export-f1b7f1c7213c60bd017baa66b76fd09c-kill_plane.scn  �      �      I]���ӷ.�|Ս�    ,   res://.godot/global_script_class_cache.cfg  0N      �       �s��b0��K�
�Kv    L   res://.godot/imported/white.png-d8533361663a5f8fe5200e5b5262a62d.etc2.ctex  �      <       ���ȝji2ÏC�:U�    L   res://.godot/imported/white.png-d8533361663a5f8fe5200e5b5262a62d.s3tc.ctex  P      <       .L��P��a�V�A�b�U       res://.godot/uid_cache.bin  �R      �       �_��1# ��q�u8       res://dropper.gd        �      ��";$��	��-�<1       res://fruit.gd         W      �`��id����2����       res://fruit.tscn.remap  L      b       �Kq�V#�x��]��       res://icon.svg   O      �      C��=U���^Qu��U3       res://kill_plane.gd 0      y      :|�U�l�!����        res://kill_plane.tscn.remap �L      g       ��l�B�g��ϒ�.�       res://main.tscn.remap   �L      a       �J�Sw� ������       res://project.binary�S            [��r�ӰB�("&m�t       res://score.gd  @?      Z      �t�s�$d�G7���       res://ui.tscn.remap `M      _       �B��H��p����MW       res://wall.tscn.remap   �M      a       o�����Θ�Cl��       res://white.png.import  �      R      .�Z�6��87B�}L�    extends Node2D

@onready var cursor : Node2D = $fruit_cursor
@onready var score : Score = $"/root/ui/score"

var level := 1
const prefab := preload("res://fruit.tscn")
var original_size : Vector2
var cooldown := 0.0
const border_const := 203

func _ready():
	original_size = cursor.scale
	score.level_start()

func make_fruit():
	score.end_combo()
	var fruit := prefab.instantiate()
	$"..".add_child(fruit)
	fruit.global_position = cursor.global_position
	var border_dist := border_const - Fruit.get_target_scale(level) * 0.5 * original_size.x
	fruit.global_position.x = clamp(fruit.global_position.x, -border_dist, border_dist)
	fruit.level = level
	fruit.linear_velocity.y = 400.0
	fruit.angular_velocity = randf_range(-1, 1)
	level = randi_range(1, 5)
	cooldown = 0.1 + min(0.2, fruit.level * 0.1)

func _process(delta):
	cooldown -= delta
	
	var t : float = 1.0 - pow(0.0001, delta)
	var target_scale := original_size * Fruit.get_target_scale(level)
	cursor.scale = lerp(cursor.scale, target_scale, t)
	var border_dist := border_const - cursor.scale.x * 0.5
	cursor.position.x = clamp(get_local_mouse_position().x, -border_dist, border_dist)
	
	cursor.modulate = lerp(cursor.modulate, Fruit.get_color(level), t)
	
	if Input.is_key_pressed(KEY_I) and cooldown < 0.13:
		make_fruit()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			if cooldown <= 0:
				make_fruit()
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and OS.has_feature("editor"):
			get_tree().quit()
               extends RigidBody2D
class_name Fruit

@export var level := 1
var current_scale := Vector2(1,1)
var current_mass := 1.0
var cooldown := 0.1
@onready var mesh := $MeshInstance2D
@onready var collider := $CollisionShape2D
var absorber : Fruit
var in_game := false

@export var colors : Array[Color]
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
	if false and colors != baked_colors:
		print("[")
		for c in colors: 
			print("\t\tColor", c, ",")
		print("\t]")
	contact_monitor = true
	max_contacts_reported = 50

func get_absorbed(other: Fruit):
	collider.queue_free()
	absorber = other
	mesh.reparent($"..")
	mesh.global_position = global_position

func _process(delta: float):
	var t := 1.0 - pow(0.0001, delta)
	mesh.modulate = lerp(mesh.modulate, Fruit.get_color(level), t)
	current_mass = Fruit.get_target_mass(level)

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
	if cooldown > delta:
		cooldown -= delta
		return
	else:
		cooldown = 0

	for node in get_colliding_bodies():
		in_game = true
		if not node is Fruit or node.level != level or node.is_queued_for_deletion():
			continue
		if node.absorber:
			continue
		if node.cooldown > 0:
			continue
		if node.get_instance_id() < get_instance_id():
			continue
		apply_impulse(-(node.global_position - global_position) * mass * 2)
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
	mass = lerp(mass, current_mass, t)
	var target_scale := Vector2(1,1) * Fruit.get_target_scale(level)
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
         RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   friction    rough    bounce 
   absorbent    script    custom_solver_bias    radius    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    height    radial_segments    rings    is_hemisphere 	   _bundled       Script    res://fruit.gd ��������      local://PhysicsMaterial_ifn83 i         local://CircleShape2D_w0g38 �         local://SphereMesh_t5nl4 �         local://PackedScene_8vg11 �         PhysicsMaterial          ���=      ��>         CircleShape2D             SphereMesh             PackedScene          	         names "         fruit    physics_material_override 
   can_sleep    continuous_cd    max_contacts_reported    contact_monitor    linear_damp    script    level    colors    RigidBody2D    CollisionShape2D    shape    MeshInstance2D    scale    mesh    	   variants                                               �?                      ��x?    	�|>  �?   ��u?���>���>  �?   ��?���>��z?  �?   ��z?��2?���<  �?   ��x?��?���=  �?   ��p?���>���>  �?   ��x?��m?���>  �?   �y?��F?��;?  �?   ��r?��O?��@<  �?   ��?��X?��p=  �?   ���=��?�� =  �?         
     �A  �A               node_count             nodes     -   ��������
       ����	                                                    	                        ����      	                     ����      
                   conn_count              conns               node_paths              editable_instances              version             RSRC        GST2            ����                           ��UUUU    GST2            ����                         ���        [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bplfva0fam11n"
path.s3tc="res://.godot/imported/white.png-d8533361663a5f8fe5200e5b5262a62d.s3tc.ctex"
path.etc2="res://.godot/imported/white.png-d8533361663a5f8fe5200e5b5262a62d.etc2.ctex"
metadata={
"imported_formats": ["s3tc_bptc", "etc2_astc"],
"vram_texture": true
}
               extends Area2D

var restart_queued := false

func _process(_delta):
	if restart_queued:
		get_tree().reload_current_scene()
		return

	for body in get_overlapping_bodies():
		if body is Fruit and not body.freeze and body.in_game:
			get_tree().reload_current_scene()

func _on_body_entered(body):
	if body is Fruit and not body.freeze and body.in_game:
		restart_queued = true
       RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       Script    res://kill_plane.gd ��������      local://RectangleShape2D_d3i48 V         local://PackedScene_g0kkx w         RectangleShape2D             PackedScene          	         names "   	      kill_plane 	   position    scale    script    Area2D    CollisionShape2D    shape    _on_body_entered    body_entered    	   variants       
     �� ���
   ʣ�B9�C                          node_count             nodes        ��������       ����                                        ����                   conn_count             conns                                       node_paths              editable_instances              version             RSRC RSRC                    PackedScene            ��������                                            �      resource_local_to_scene    resource_name    custom_solver_bias    size    script    render_priority 
   next_pass    transparency    blend_mode 
   cull_mode    depth_draw_mode    no_depth_test    shading_mode    diffuse_mode    specular_mode    disable_ambient_light    disable_fog    vertex_color_use_as_albedo    vertex_color_is_srgb    albedo_color    albedo_texture    albedo_texture_force_srgb    albedo_texture_msdf 	   metallic    metallic_specular    metallic_texture    metallic_texture_channel 
   roughness    roughness_texture    roughness_texture_channel    emission_enabled 	   emission    emission_energy_multiplier    emission_operator    emission_on_uv2    emission_texture    normal_enabled    normal_scale    normal_texture    rim_enabled    rim 	   rim_tint    rim_texture    clearcoat_enabled 
   clearcoat    clearcoat_roughness    clearcoat_texture    anisotropy_enabled    anisotropy    anisotropy_flowmap    ao_enabled    ao_light_affect    ao_texture 
   ao_on_uv2    ao_texture_channel    heightmap_enabled    heightmap_scale    heightmap_deep_parallax    heightmap_flip_tangent    heightmap_flip_binormal    heightmap_texture    heightmap_flip_texture    subsurf_scatter_enabled    subsurf_scatter_strength    subsurf_scatter_skin_mode    subsurf_scatter_texture &   subsurf_scatter_transmittance_enabled $   subsurf_scatter_transmittance_color &   subsurf_scatter_transmittance_texture $   subsurf_scatter_transmittance_depth $   subsurf_scatter_transmittance_boost    backlight_enabled 
   backlight    backlight_texture    refraction_enabled    refraction_scale    refraction_texture    refraction_texture_channel    detail_enabled    detail_mask    detail_blend_mode    detail_uv_layer    detail_albedo    detail_normal 
   uv1_scale    uv1_offset    uv1_triplanar    uv1_triplanar_sharpness    uv1_world_triplanar 
   uv2_scale    uv2_offset    uv2_triplanar    uv2_triplanar_sharpness    uv2_world_triplanar    texture_filter    texture_repeat    disable_receive_shadows    shadow_to_opacity    billboard_mode    billboard_keep_scale    grow    grow_amount    fixed_size    use_point_size    point_size    use_particle_trails    proximity_fade_enabled    proximity_fade_distance    msdf_pixel_range    msdf_outline_size    distance_fade_mode    distance_fade_min_distance    distance_fade_max_distance    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    subdivide_width    subdivide_height    subdivide_depth    radius    height    radial_segments    rings    is_hemisphere 	   friction    rough    bounce 
   absorbent 	   _bundled       PackedScene    res://wall.tscn k��р�!
   PackedScene    res://kill_plane.tscn �����   Script    res://dropper.gd ��������   Script    res://fruit.gd ��������	      local://RectangleShape2D_efixp %      !   local://StandardMaterial3D_hi5v3 F         local://BoxMesh_c7hof �         local://RectangleShape2D_sjotd �         local://BoxMesh_wp6md �         local://SphereMesh_t3y8x �         local://PhysicsMaterial_ifn83 �         local://SphereMesh_t5nl4 5         local://PackedScene_gfs6w P         RectangleShape2D             StandardMaterial3D          ��w?��,?���>  �?         BoxMesh    r                     RectangleShape2D             BoxMesh             SphereMesh             PhysicsMaterial          ���=�      ��>         SphereMesh             PackedScene    �      	         names "   -      Node2D 	   Camera2D    walls    Node 
   wall_left 	   position    scale    wall_left_ext    StaticBody2D    CollisionShape2D    shape    MeshInstance2D    visible    mesh    wall_right_ext    wall_right    floor 	   modulate    kill_plane3    kill_plane4    kill_plane5    dropper    script    fruit_cursor    deco    fruit    physics_material_override 
   can_sleep    freeze    continuous_cd    max_contacts_reported    contact_monitor    colors    RigidBody2D    fruit2    level    fruit3    fruit4    fruit5    fruit6    fruit7    fruit8    fruit9    fruit10    fruit11    	   variants    8             
     \�  �A
   V�?  �A
     ��  &C
      A=
B
   ���>                     
     �A  �A         
    ��C  &C
     \C  �A
         �C
   �̾A   @
         �B
     �?   A            ��G?��	?���>  �?                  
         �D
    @F   B
     ��
��
      A   A
     �C
��
         ��                  
    @�  ��                                             ��h?�� <�� =  �?   ��u?���>���>  �?   ��?���>��z?  �?   ��z?��2?���<  �?   ��x?��?���=  �?   ��n?���=���=  �?   ��x?��m?���>  �?   �y?��F?��;?  �?   ��r?��O?��@<  �?   ��?��X?��p=  �?   ���=��?�� =  �?         
     ��  ��      
    ���  ��      
     �� ���      
     ��  T�      
    ���  T�      
    ���  ��      
     ��  �A      
    ���  UC   	   
    ��C  ��   
   
     �C  3C            node_count    *         nodes     r  ��������        ����                      ����                      ����               ���                                       ����                          	   	   ����         
                       ����                  	                    ����      
                    	   	   ����   
                       ����                  	              ���                                       ����                          	   	   ����               
                       ����                                ���                                ���                                ���                                        ����                                ����                                  ����               !      ����	                                                 !       "                    ����            #              !   "   ����
      $                        %                   !   #   %       "                    ����            #              !   $   ����
      &                        %                   !   #   '       "                    ����            #              !   %   ����
      (                        %                   !   #   )       "                    ����            #              !   &   ����
      *                        %                   !   #   +       "                    ����            #              !   '   ����
      ,                        %                   !   #   -       "                    ����            #              !   (   ����
      .                        %                   !   #   /       "                     ����            #              !   )   ����
      0                        %                   !   #   1       "       "             ����            #              !   *   ����
      2                        %                   !   #   3       "       $             ����            #              !   +   ����
      4                        %                   !   #   5       "       &             ����            #              !   ,   ����
      6                        %                   !   #   7       "       (             ����            #             conn_count              conns               node_paths              editable_instances              version             RSRC   extends Label
class_name Score

var combo_counter := 1
var score := 0

func _ready():
	text = ""

func level_start():
	$"../prev_score".text = text
	text = ""

func end_combo():
	combo_counter = 1

func add(val:  int):
	combo_counter += 1
	score += int(val * combo_counter)
	write_score(score)
	
func write_score(val: int):
	text = str(int(val))
      RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 
   fallbacks    font_names    font_italic    font_weight    font_stretch    antialiasing    generate_mipmaps    allow_system_fallback    force_autohinter    hinting    subpixel_positioning #   multichannel_signed_distance_field    msdf_pixel_range 
   msdf_size    oversampling    script    line_spacing    font 
   font_size    font_color    outline_size    outline_color    shadow_size    shadow_color    shadow_offset 	   _bundled       Script    res://score.gd ��������      local://SystemFont_ufdem          local://LabelSettings_pf3cd 6         local://PackedScene_odevg �         SystemFont                                 LabelSettings                                               �?         PackedScene          	         names "         ui    follow_viewport_enabled    CanvasLayer    score    offset_left    offset_top    offset_right    offset_bottom    text    label_settings    horizontal_alignment    vertical_alignment    justification_flags    script    Label    prev_score    	   variants                  lB    ��C     hC     �C      score: 1000                                            g�     h�      node_count             nodes     =   ��������       ����                            ����
                                 	      
               	      
                     ����	                                 	               	      
             conn_count              conns               node_paths              editable_instances              version             RSRC              RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    subdivide_width    subdivide_height    subdivide_depth 	   _bundled           local://RectangleShape2D_efixp �         local://BoxMesh_c7hof 
         local://PackedScene_l15ar "         RectangleShape2D             BoxMesh             PackedScene          	         names "         wall    StaticBody2D    CollisionShape2D    shape    MeshInstance2D 	   modulate    scale    mesh    	   variants                    ��G?��	?���>  �?
     �A  �A               node_count             nodes        ��������       ����                      ����                            ����                               conn_count              conns               node_paths              editable_instances              version             RSRC   [remap]

path="res://.godot/exported/133200997/export-96d9542281595709dde67debd2e51295-fruit.scn"
              [remap]

path="res://.godot/exported/133200997/export-f1b7f1c7213c60bd017baa66b76fd09c-kill_plane.scn"
         [remap]

path="res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn"
               [remap]

path="res://.godot/exported/133200997/export-5d2f649bfda0e984c5f95c948cc9f360-ui.scn"
 [remap]

path="res://.godot/exported/133200997/export-20a18325f7c6eab45b6b222a29d4ddff-wall.scn"
               list=Array[Dictionary]([{
"base": &"RigidBody2D",
"class": &"Fruit",
"icon": "",
"language": &"GDScript",
"path": "res://fruit.gd"
}, {
"base": &"Label",
"class": &"Score",
"icon": "",
"language": &"GDScript",
"path": "res://score.gd"
}])
 <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             |�Og��3   res://fruit.tscn��'6�S]   res://icon.svg�����   res://kill_plane.tscnsjw���8   res://main.tscn�S��ⅈ{   res://ui.tscnk��р�!
   res://wall.tscn)/�P�0   res://white.png           ECFG      application/config/name         MelooniPeli    application/run/main_scene         res://main.tscn    application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg  !   application/config/build_datetime         2024-02-04T17:29:37    autoload/buildtime_printer<      4   *res://addons/buildtime_printer/buildtime_printer.gd   autoload/ui         *res://ui.tscn  "   display/window/size/viewport_width      �     display/window/stretch/mode         canvas_items   display/window/stretch/aspect         expand  #   display/window/handheld/orientation            editor_plugins/enabled   "       9   rendering/textures/canvas_textures/default_texture_filter          #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility4   rendering/textures/vram_compression/import_etc2_astc         2   rendering/shader_compiler/shader_cache/strip_debug         >   rendering/textures/default_filters/anisotropic_filtering_level          >   rendering/anti_aliasing/screen_space_roughness_limiter/enabled          2   rendering/environment/defaults/default_clear_color      ���>���>���>  �?              