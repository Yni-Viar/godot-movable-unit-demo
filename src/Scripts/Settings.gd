extends Node
## Settings autoload
## Created by Yni, licensed under MIT License

enum Stages {release, testing, dev}
enum ItemType {item, map_object, npc}

signal settings_saved

## Migrated from Globals.
## Game's data compatibility for modding.
const DATA_COMPATIBILITY: String = "0.1.0"
## Migrated from Globals.
## Game's data compatibility for modding.
const CURRENT_STAGE: Stages = Stages.release
## Available languages
var available_languages: Array[String] = ["en", "ru"]
## Necessary for overriding Godot bug.
## Checks when settings would be loaded.
var first_start: bool = true
## Settings resource
var setting_res: SettingsResource
## Default windows sizes.
var window_size: Array[Vector2i] = [Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1366, 768),
						Vector2i(1280, 720), Vector2i(1024, 768), Vector2i(800, 600)]
## Is the device touchscreen
var touchscreen: bool = false

#var _check_dir: String = ""

func _init():
	load_resource()
	# Add custom windows sizes.
	for v in setting_res.window_size:
		window_size.append(v)

## Sometimes ago it was a great function. Now it is just a stub, that calls ResourceStorage and loads settings
func load_resource():
	var settings_from_file = ResourceStorage.load_resource("user://Settings.bin", "SettingsResource")
	if settings_from_file != null:
		setting_res = settings_from_file
	else:
		if OS.get_name() == "Android":
			var res = load("res://Scripts/SettingsResource/Presets/OpenGL/Mobile.tres")
			save_resource(res)
			setting_res = res
		elif RenderingServer.get_rendering_device() != null:
			var res = load("res://Scripts/SettingsResource/Presets/RD/Medium.tres")
			save_resource(res)
			setting_res = res
		else:
			var res = load("res://Scripts/SettingsResource/Presets/OpenGL/Low.tres")
			save_resource(res)
			setting_res = res
## Sometimes ago it was a great function. Now it is just a stub, that calls ResourceStorage and saves settings
func save_resource(res):
	ResourceStorage.save_resource("user://Settings.bin", res)
	emit_signal("settings_saved")
#-= LEGACY PACK LOADER BELOW: =-
# Get directories for searching packs
#func get_current_dir() -> void:
	#var current_dir: String = ""
	#if OS.get_name() == "Android":
		#if OS.is_debug_build():
			#current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/.SCP_AssetPack/"
			#var dir: DirAccess = DirAccess.open(current_dir[0])
			#if !dir.dir_exists(current_dir[0]):
				#dir.make_dir(current_dir[0])
		#else:
		#_check_dir = OS.get_user_data_dir()
	#elif !OS.has_feature("editor") && OS.get_name() != "Web":
		#_check_dir = OS.get_executable_path().get_base_dir()
# Loads resource pack from the source
# Use this, and not ProjectSettings.load_resource_pack because of security reasons.
#func load_resource_pack(resource_name: String) -> bool:
	#if ProjectSettings.load_resource_pack(_check_dir + "/" + resource_name, false):
		#return true
	#else:
		#return false
#
# Checks available resource packs
# You must call this function before load_resource_pack, because of dependence
#func check_resource_packs() -> Array[String]:
	#var packs: Array[String] = []
	#if OS.has_feature("editor") || OS.get_name() == "Web":
		# Search the local folders for platforms, not supporting separate packs
		#var dir = DirAccess.open("res://ResourcePacks/")
		#if dir:
			#dir.list_dir_begin()
			#var file_name = dir.get_next()
			#while file_name != "":
				#if !dir.current_is_dir():
					#continue
				#packs.append(file_name)
				#file_name = dir.get_next()
			#dir.list_dir_end()
		#else:
			#print("An error occurred when trying to access the path.")
	#else:
		## Search all available folders 
		#var dir = DirAccess.open(_check_dir)
		#if dir:
			#dir.list_dir_begin()
			#var file_name = dir.get_next()
			#while file_name != "":
				#if dir.current_is_dir():
					#file_name = dir.get_next()
					#continue
				#elif file_name.ends_with(".pck") && file_name != "SCPContainingProcedures.pck":
					#packs.append(file_name.rstrip(".pck"))
				#file_name = dir.get_next()
			#dir.list_dir_end()
		#else:
			#print("An error occurred when trying to access the path.")
	#return packs
#
