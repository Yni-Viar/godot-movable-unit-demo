extends InteractableNode
## Toggles heater
## Made by Yni. Licensed under MIT License.
class_name InteractableHeater

@export var enabled: bool = false:
	set(val):
		enabled = val
		$Heater.visible = enabled

# Called when the node enters the scene tree for the first time.
func interact(player: Node3D):
	enabled = !enabled
