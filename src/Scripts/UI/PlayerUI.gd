extends Control
## Player UI
## Created by Yni, licensed under MIT License

var special_screen: bool = false
var interact_busy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if special_screen:
		$Cursor.hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		$Cursor.show()
		if !Settings.touchscreen:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("console"):
		input_values("console")
	if !interact_busy:
		if Input.is_action_pressed("ui_cancel"):
			input_values("exitgame")
		if Input.is_action_pressed("map_open"):
			input_values("map")
		if Input.is_action_pressed("inventory_open"):
			input_values("inventory")
	if Input.is_action_just_released("map_open") || Input.is_action_just_released("ui_cancel") || Input.is_action_just_released("inventory_open"):
		interact_busy = false

func input_values(state: String):
	interact_busy = true
	match state:
		"console":
			if !special_screen && !get_tree().root.get_node("Game/InGameConsole").visible:
				get_tree().root.get_node("Game/InGameConsole").visible = true
				special_screen = true
			else:
				get_tree().root.get_node("Game/InGameConsole").visible = false
				special_screen = false
		"exitgame":
			if !special_screen && !$PauseMenu.visible:
				$PauseMenu.show()
				special_screen = true
			else:
				$PauseMenu.hide()
				special_screen = false
		"map":
			if !special_screen && !$Map.visible:
				$Map.show()
				special_screen = true
			else:
				$Map.hide()
				special_screen = false
		"inventory":
			if !special_screen && get_tree().root.get_node_or_null("Game/Spectator").selected_pawn != null && !$InventoryUI.visible:
				$InventoryUI/ItemList.update_inventory(get_tree().root.get_node("Game/Spectator").selected_pawn.get_node("Inventory"))
				$InventoryUI.show()
				special_screen = true
			else:
				$InventoryUI.hide()
				special_screen = false

# For exiting through pause menu
func _on_exit_button_pressed():
	get_tree().root.get_node("Game").quit()

func _on_continue_button_pressed() -> void:
	$PauseMenu.hide()
