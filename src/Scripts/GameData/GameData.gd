extends Resource
## Game DB.
## Made by Yni, licensed under MIT license.
class_name GameData

## Available classes
@export var puppet_classes: Array[PuppetClass] = []
## Available inventory items
@export var items: Array[Item]
@export var ambient_path: String
