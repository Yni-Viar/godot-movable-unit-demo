extends Node3D
## Used from Godot docs tutorial
## Created by Godot Engine contributors, licensed under MIT License
class_name NpcPlayerScript

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var puppet_class: PuppetClass
@export var character_speed := 10.0
@export var automatic: bool = false
## See PuppetResource description
@export var fraction: int
@export var health: Array[float] = []
@export var current_health: Array[float] = []

## The main wandering switch
@export var wandering: bool = false
## How many npc will rotate
var wandering_rotator: int
## Walking/rotating toggle
var wander_action: bool = false
## On which degree npc will wander
var wandering_destination: int
## Only when idle NPC will wander
var idle: bool = true

var puppet_mesh: BasePuppetScript

## Just for optimization purposes
## E.g. wandering will be disabled, if npc is not visible
var visible_on_screen: bool = false

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
var movement_delta: float

func _ready() -> void:
	$RayCast3D.add_exception($NpcSelection)
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	puppet_mesh = puppet_class.prefab.instantiate()
	automatic = puppet_class.automatic
	fraction = puppet_class.fraction
	health = puppet_class.health
	wandering = puppet_class.enable_wander && Settings.setting_res.enable_wandering
	if wandering:
		while wandering_rotator == 0:
			wandering_rotator = rng.randi_range(-15, 15)
	current_health = health
	add_child(puppet_mesh)

func set_movement_target(movement_target: Vector3, hold: bool, run: bool):
	navigation_agent.set_target_position(movement_target)
	if run:
		puppet_mesh.state = puppet_mesh.States.RUNNING
	else:
		puppet_mesh.state = puppet_mesh.States.WALKING
	if puppet_class.apply_height_bugfix:
		puppet_mesh.position.y = -0.4
	idle = false
	if hold:
		hold_still()

func _physics_process(delta):
	if !idle:
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
			puppet_mesh.state = puppet_mesh.States.IDLE
			idle = true
			return
		if navigation_agent.is_navigation_finished() || (!navigation_agent.is_target_reachable() && wandering):
			puppet_mesh.state = puppet_mesh.States.IDLE
			idle = true
			if !navigation_agent.is_target_reachable() && wandering:
				wander_reached_the_end()
			return
		
		movement_delta = character_speed * delta
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_delta
		var offset: Vector3 = next_path_position - global_position
		offset.y = 0
		look_at(global_position + offset, Vector3.UP)
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)
	else:
		if wandering && visible_on_screen:
			wander(delta)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

## Health management (health type: 0 is generic health, 1 is water)
func health_manage(health_to_add: float, health_type: int = 0):
	if health_type >= current_health.size() || health_type >= health.size():
		print("Invalid parameter - wrong health type")
	if current_health[health_type] + health_to_add <= health[health_type]:
		current_health[health_type] += health_to_add
	else:
		current_health[health_type] = health[health_type]
	
	if current_health[health_type] <= 0:
		get_tree().root.get_node("Game/NPCs").object_remover(name)

## Wander implementation
func wander(delta: float):
	# If wander_action, the npc will walk as much as possible, also generate new rotation
	if wander_action:
		wandering_rotator = rng.randi_range(-15, 15)
		set_movement_target(global_position - global_transform.basis.z * 2, false, false)
		# set the destination with a new rotation degrees
		wandering_destination = roundi(rotation_degrees.y + wandering_rotator)
	else:
		# If the destination is reached - wander
		if roundi(rotation_degrees.y) == wandering_destination:
			wander_action = true
		var rot: float
		# If a dead end reached, rotate faster
		if wandering_rotator > 120 || wandering_rotator < -120:
			rotate_y(deg_to_rad(20 * delta))
		else:
			rotate_y(deg_to_rad(wandering_rotator * delta))
		
## This function is called, when npc will reach dead end
func wander_reached_the_end():
	# disable wandering, enable rotation
	wander_action = false
	wandering_rotator = rng.randi_range(150, 179)
	wandering_destination = roundi(rotation_degrees.y + wandering_rotator)
	# to fix degree problems
	if wandering_destination > 180:
		wandering_rotator = wandering_rotator - 360
		wandering_destination = roundi(rotation_degrees.y + wandering_rotator)

func hold_still():
	wandering = false
	await get_tree().create_timer(15.0).timeout
	wandering = puppet_class.enable_wander


func _on_optimizator_screen_entered() -> void:
	visible_on_screen = true


func _on_optimizator_screen_exited() -> void:
	visible_on_screen = false
