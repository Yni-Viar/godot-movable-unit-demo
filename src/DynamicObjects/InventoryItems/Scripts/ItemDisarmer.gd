extends ItemPickable
## Disarmer item script
## Created by Yni, licensed under MIT License

var prev_position: Vector3

func _ready() -> void:
	prev_position = global_position

func use(player: Node3D, target_player: Node3D) -> void:
	if target_player == player:
		get_tree().root.get_node("Game").alert("""Can't disarm yourself.
		Perhaps you clicked the Use Item button from the inventory.
		You should click R key, or touch "Item" button to disarm someone""")
	elif target_player is NpcPlayerScript && player is NpcPlayerScript:
		var inv: Inventory = target_player.get_node("Inventory")
		for i in range(inv.inventory_storage.size()):
			inv.remove_item(i, false)
		var head_mesh: HumanPuppetScript = player.get_node("Puppet")
		var human_mesh: BasePuppetScript = target_player.get_node("Puppet")
		if human_mesh is HumanPuppetScript:
			if human_mesh.secondary_state == human_mesh.SecondaryState.CUFFED:
				human_mesh.secondary_state = human_mesh.SecondaryState.NONE
				head_mesh.cuffed_players.erase(target_player)
			elif player.puppet_class.team != target_player.puppet_class.team && head_mesh.cuffed_players.size() < 4 && player.global_position.distance_to(target_player.global_position) < 8.0:
				human_mesh.secondary_state = human_mesh.SecondaryState.CUFFED
				head_mesh.cuffed_players.append(target_player)
			else:
				get_tree().root.get_node("Game").alert("""Can't disarm this player.
				Perhaps you reached the limit of 4 cuffed players, or the player,
				that you want to cuff, is far away.""")
