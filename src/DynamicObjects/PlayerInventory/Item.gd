extends Resource
## Made by Yni, licensed under CC0.
class_name Item

enum Usage {NORMAL, ONE_TIME, ONE_TIME_DROP}

@export var id: int = 0
@export var name: String = ""
@export var texture: Texture2D = null
@export var pickable_path: String = ""
@export var pickup_sound_path: String = ""
@export var usage: Usage = Usage.NORMAL
@export var upgrade_rough: Array[int] = []
@export var upgrade_coarse: Array[int] = []
@export var upgrade_one_to_one: Array[int] = []
@export var upgrade_fine: Array[int] = []
@export var upgrade_very_fine: Array[int] = []
