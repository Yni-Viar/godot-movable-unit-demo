extends Node3D
## Main game scene script.
## Created by Yni, licensed under MIT License
class_name GameCore

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var game_data: GameData
@export var seed: String = ""
@export var world_name: String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	$BackgroundMusic.stream = load(game_data.ambient_path)
	$BackgroundMusic.play()
	load_settings()
	if !(seed.is_empty() || seed == null):
		$FacilityGenerator.rng_seed = hash(seed)
	$FacilityGenerator.prepare_generation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("credits_show"):
		alert('''Credits:
Code:
Debug console (License - The Unlicense)
- Made by USBashka
Touchscreen controls (License - MIT)
- Made by Marco Fazio
Button system
Assets:
Heater model by GameDev Nick (https://sketchfab.com/GameDevNick)
Sounds and music:
- Robot vacuum cleaner.ogg by Eelke -- https://freesound.org/s/383372/ -- License: Attribution 4.0
- Elevator.ogg - Kevin MacLeod - License CC-BY 3.0
- Used some Kenney.nl sounds, which are CC0
- DoorOpen and footsteps are made by SCP: Godot project (MIT License) ''')

## Quits from the game
func quit():
	Settings.first_start = true
	get_tree().quit()

func load_settings():
	$WorldEnvironment.environment.ssao_enabled = Settings.setting_res.ssao
	$WorldEnvironment.environment.ssil_enabled = Settings.setting_res.ssil
	$WorldEnvironment.environment.ssr_enabled = Settings.setting_res.ssr
	$WorldEnvironment.environment.glow_enabled = Settings.setting_res.glow
	if !Settings.setting_res.enable_lighting:
		$WorldEnvironment.environment.tonemap_exposure = 8.0
	if !Settings.setting_res.reflection_probes:
		for node in get_tree().get_nodes_in_group("ReflectionProbes"):
			if node is ReflectionProbe:
				node.hide()
	if !Settings.setting_res.dynamic_gi:
		for node in get_tree().get_nodes_in_group("VoxelGI"):
			if node is VoxelGI:
				node.hide()


func _on_facility_generator_generated() -> void:
	var player_spawns: Array[Node] = get_tree().get_nodes_in_group("PlayerSpawn")
	if player_spawns.size() > 0:
		var player_spawnpoint = player_spawns[rng.randi_range(0, player_spawns.size() - 1)]
		if player_spawnpoint is Marker3D:
			$Spectator.global_position = player_spawnpoint.global_position
	startup_spawn()


func startup_spawn():
	for puppet_res in game_data.puppet_classes:
		var spawn_point_group = get_tree().get_nodes_in_group(puppet_res.spawn_point_group)
		var used_spawns: Array[int] = []
		if get_tree().get_nodes_in_group(puppet_res.spawn_point_group).size() == 0:
			continue
		for i in range(puppet_res.initial_amount):
			if i > spawn_point_group.size() - 1:
				break
			var random_number: int = rng.randi_range(0, spawn_point_group.size() - 1)
			if used_spawns.has(random_number):
				continue
			$NPCs.object_spawner(puppet_res, spawn_point_group[random_number].global_position)
			used_spawns.append(random_number)

func alert(message: String):
	var window: AcceptDialog = load("res://Assets/HUD/CustomAcceptDialog.tscn").instantiate()
	window.dialog_text = message + "\n[ESC - Hide]"
	add_child(window)

func get_root_viewport() -> Viewport:
	return get_viewport()
