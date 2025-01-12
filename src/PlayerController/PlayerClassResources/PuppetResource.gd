extends Resource
## Puppet resource
## Created by Yni, licensed under MIT License
class_name PuppetClass

@export var puppet_class_name: String
@export var speed: float = 3
@export var prefab: PackedScene
## Group, where the game find spawnpoints
@export var spawn_point_group: String
@export var initial_amount: int
## Is this NPC controlled by the player
@export var automatic: bool
@export var footstep_sounds: Dictionary
## 0 is human, 1 is hostile SCP, 2 is vision SCP (like 650 and 173)
@export var fraction: int
@export var apply_height_bugfix: bool = true
## Will the puppet stay on this point, or it will wander
@export var enable_wander: bool = true
@export var inventory_item_size: int = 0
@export var health: Array[float] = [100]
## Only for humans currently.
## 0 is none team, 1 is Foundation personnel, 2 is Class-D personnel,
## 3 is Chaos Insurgency
@export var team: int = 0
@export var initial_items: Array[Item] = []
