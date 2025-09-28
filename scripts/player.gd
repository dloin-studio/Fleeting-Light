extends CharacterBody2D


signal game_over_by_darkness
signal torch_core_updated(new_value: float)

var torch_core: float = 100.0
var is_torch_active: bool = false
const CORE_DRAIN_RATE: float = 15.0
const MIN_CORE: float = 0.0


@onready var ray: RayCast2D = $RayCast2D
@onready var torch_light: PointLight2D = $TorchLight 

var inputs: Dictionary = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

const TILE_SIZE: int = 16


func _ready() -> void:
	# CRASH FIX: Check if the light node was found before trying to enable/disable it.
	if is_instance_valid(torch_light):
		torch_light.enabled = false
	else:
		push_error("ERROR: TorchLight node is missing! Please add a PointLight2D child named 'TorchLight' to the Player.")
		
	emit_signal("torch_core_updated", torch_core)


func _process(delta: float) -> void:
	var light_is_valid = is_instance_valid(torch_light)
	
	if is_torch_active and not get_tree().paused:
		var old_core = torch_core
		torch_core = max(MIN_CORE, torch_core - CORE_DRAIN_RATE * delta)
		
		if old_core != torch_core:
			emit_signal("torch_core_updated", torch_core)
		
		if torch_core <= MIN_CORE:
			is_torch_active = false
			if light_is_valid:
				torch_light.enabled = false
			emit_signal("game_over_by_darkness")
	
	if light_is_valid:
		torch_light.enabled = is_torch_active and torch_core > MIN_CORE
	pass


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)
			
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("toggle_torch"): 
		toggle_torch()
	pass


func toggle_torch() -> void:
	var light_is_valid = is_instance_valid(torch_light)
	
	if torch_core > MIN_CORE:
		is_torch_active = not is_torch_active
		if light_is_valid:
			torch_light.enabled = is_torch_active
	else:
		is_torch_active = false
		if light_is_valid:
			torch_light.enabled = false


func move(dir: StringName) -> void:
	var vector_pos: Vector2 = inputs[dir] * TILE_SIZE
	var can_move_player: bool = false # Flag to determine if the player can move this frame
	

	ray.target_position = vector_pos
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		can_move_player = true
	else:
		var collider: Node2D = ray.get_collider()
		
		if is_instance_valid(collider) and collider.is_in_group("box"):
			if collider.move(dir):
				can_move_player = true

	if can_move_player:
		position += vector_pos
