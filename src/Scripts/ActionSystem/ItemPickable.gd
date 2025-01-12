extends InteractableRigidBody
## Pickable item script
## Created by Yni, licensed under CC0 License
class_name ItemPickable

@export var item: Item

func interact(player: Node3D):
	if player != null:
		if player.get_node("Inventory").add_item(item):
			queue_free()
## Basic item use, called from InventoryUI
func use(player: Node3D, target_player: Node3D) -> void:
	pass
