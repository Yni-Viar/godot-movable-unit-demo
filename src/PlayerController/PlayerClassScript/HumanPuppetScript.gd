extends BasePuppetScript
## Example implementation of human system.
## Made by Yni, licensed under MIT license.
class_name HumanPuppetScript

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

enum SecondaryState {NONE, ITEM, CUFFED}

@export var secondary_state: SecondaryState = SecondaryState.NONE

var cuffed_players: Array[NpcPlayerScript] = []
var raycast: RayCast3D
var vision_entity: Array = []
var has_animtree: bool = false
var update_timer = 1.0

# Called when the node enters the scene tree for the first time.
func on_start():
	raycast = get_parent().get_node("RayCast3D")
	if get_node_or_null("AnimationTree") != null:
		get_node("AnimationTree").active = true
		has_animtree = true
	#get_parent().get_node("NpcSelection").set_collision_mask_value(3, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Change animation state
	if has_animtree && get_parent().visible_on_screen:
		match state:
			States.IDLE:
				if !get_node("AnimationTree").get("parameters/state_machine/blend_amount") - 0.00001 < -1:
					call("set_state", "state_machine", "blend_amount", lerp(get_node("AnimationTree").get("parameters/state_machine/blend_amount"), -1.0, get_parent().character_speed * delta))
			States.WALKING:
				if !get_node("AnimationTree").get("parameters/state_machine/blend_amount") + 0.00001 > 0:
					call("set_state", "state_machine", "blend_amount", lerp(get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 0.0, get_parent().character_speed * delta))
			States.RUNNING:
				if !get_node("AnimationTree").get("parameters/state_machine/blend_amount") + 0.00001 > 1:
					call("set_state", "state_machine", "blend_amount", lerp(get_node("AnimationTree").get("parameters/state_machine/blend_amount"), 1.0, get_parent().character_speed * delta))
		match secondary_state:
			SecondaryState.NONE:
				if !get_node("AnimationTree").get("parameters/items_blend/blend_amount") - 0.00001 < 0:
					call("set_state", "items_blend", "blend_amount", lerp(get_node("AnimationTree").get("parameters/items_blend/blend_amount"), 0.0, get_parent().character_speed * delta))
			SecondaryState.ITEM:
				call("set_state", "secondary_state", "transition_request", "item")
			SecondaryState.CUFFED:
				call("set_state", "secondary_state", "transition_request", "cuffed")
		if secondary_state != SecondaryState.NONE:
			if !get_node("AnimationTree").get("parameters/items_blend/blend_amount") + 0.00001 > 1:
				call("set_state", "items_blend", "blend_amount", lerp(get_node("AnimationTree").get("parameters/items_blend/blend_amount"), 1.0, get_parent().character_speed * delta))
	
	# Look at enemy
	if active_puppets.size() > 0 && state == States.IDLE:
		var prev_entity_distance: float = 16777216
		var index = 0
		# Fixing scientist not looking at 650 - now people will look at the nearest object
		for i in range(active_puppets.size()):
			var entity_distance: float = active_puppets[i].global_position.distance_to(get_parent().global_position)
			if entity_distance < prev_entity_distance || i == active_puppets.size() - 1:
				prev_entity_distance = entity_distance
				index = i
		var looking_object: Vector3 = active_puppets[index].global_position
		looking_object.y = 0
		get_parent().look_at(looking_object)
	
	# My bad. How good is Git. I just thought, that it is unnecessary code.
	# I was wrong. It handles watching at 173 and 650...
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is NpcSelection:
			var selected_pawn = collider.get_pawn()
			if selected_pawn != null:
				var puppet_class = selected_pawn.puppet_class
				if puppet_class.fraction == 2:
					vision_entity.append(selected_pawn.get_node("Puppet"))
					if !selected_pawn.get_node("Puppet").watching_puppets.has(get_parent()):
						selected_pawn.get_node("Puppet").watching_puppets.append(get_parent())
				elif vision_entity.size() > 0:
					for entity in vision_entity:
						entity.watching_puppets.clear()
					vision_entity.clear()
		elif vision_entity.size() > 0:
			for entity in vision_entity:
				entity.watching_puppets.clear()
			vision_entity.clear()
	# Cuffed players mechanic
	if cuffed_players.size() > 0:
		target_follow(delta)
	on_update_human(delta)

func on_update_human(delta):
	pass

## Set animation to an entity via Animation Tree.
func set_state(animation_name: String, action_name: String, amount):
	get_node("AnimationTree").set("parameters/" + animation_name + "/" + action_name, amount)

#func set_anim_state(animation_name: String):
	#$AnimationPlayer.play(animation_name)

## Playing footsteps
func footstep(key: String):
	get_parent().get_node("WalkSounds").stream = load(get_parent().puppet_class.footstep_sounds[key][rng.randi_range(0, get_parent().puppet_class.footstep_sounds[key].size() - 1)])
	get_parent().get_node("WalkSounds").play()

## Follow the players, if cuffed
func target_follow(delta: float):
	if update_timer > 0:
		update_timer -= delta
	else:
		for player in cuffed_players:
			player.set_movement_target(get_parent().global_position, true, false)
		update_timer = 1.0
