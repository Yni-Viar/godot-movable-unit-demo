extends CharacterBody3D
## Flying player script
## Made by Yni, licensed by CC0
class_name FlyPlayerScript

const SPEED = 7.5
#const JUMP_VELOCITY = 4.5

var prev_x_coordinate: float = 0

@onready var raycast = $RayCast3D
var selected_pawn: NpcPlayerScript
## Workaround for touch screen
var interact_busy: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * Settings.setting_res.mouse_sensitivity * 0.05
		rotation.x -= event.relative.y * Settings.setting_res.mouse_sensitivity * 0.05
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	# A play of "3 (three)" and "input"
	var trinput_dir: Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	if !trinput_dir.is_zero_approx():
		if !is_equal_approx(rotation_degrees.x / 180, prev_x_coordinate):
			trinput_dir.y = rotation_degrees.x / 180
			prev_x_coordinate = trinput_dir.y
		var direction := transform.basis * trinput_dir.normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
			velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity = Vector3.ZERO
	move_and_slide()
	
	if !interact_busy:
		if Input.is_action_pressed("interact") && raycast.is_colliding():
			interact("Point")
		if Input.is_action_pressed("interact_alt") && raycast.is_colliding():
			interact("Item")
	if Input.is_action_just_released("interact") || Input.is_action_just_released("interact_alt"):
		interact_busy = false

func interact(value: String) -> void:
	interact_busy = true
	match value:
		"Point":
			var collider = raycast.get_collider()
			if collider is NpcSelection:
				selected_pawn = collider.get_pawn()
			elif collider is InteractableNode:
				collider.call("interact", self)
			elif selected_pawn != null:
				if selected_pawn is NpcPlayerScript:
					if !selected_pawn.automatic:
						selected_pawn.set_movement_target(raycast.get_collision_point(), true, false)
						if collider is ItemPickable:
							collider.call("interact", selected_pawn)
		"Item":
			var puppet: BasePuppetScript = selected_pawn.get_node("Puppet")
			var item: ItemPickable
			if puppet.get_node_or_null(puppet.armature_name + "/Skeleton3D/ItemAttachment/Marker3D") != null:
				var puppet_hand: Marker3D = puppet.get_node(puppet.armature_name + "/Skeleton3D/ItemAttachment/Marker3D")
				if puppet_hand.get_children().size() > 0:
					item = puppet_hand.get_child(0)
					var collider = raycast.get_collider()
					if collider is NpcSelection:
						item.call("use", selected_pawn, collider.get_parent())
