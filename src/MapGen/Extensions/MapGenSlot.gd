extends CenterContainer
class_name MapGenSlot

var hover: bool = false
var slot_panel: TextureRect = TextureRect.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hover && Input.is_action_pressed("map_click") && get_child_count() > 0:
		var path_name: String = get_child(0).name
		get_tree().root.get_node("Game/Spectator").global_position = get_tree().root.get_node("Game/FacilityGenerator/" + path_name + "/playerspawn").global_position
		get_tree().root.get_node("Game/PlayerUI").input_values("map")

func display_data(slot: MapGenRoom, angle: float, node_name: String):
	if slot != null:
		match angle:
			0.0:
				slot_panel.texture = slot.icon_0_degrees
			90.0:
				slot_panel.texture = slot.icon_90_degrees
			180.0:
				slot_panel.texture = slot.icon_180_degrees
			270.0:
				slot_panel.texture = slot.icon_270_degrees
		slot_panel.name = node_name
		add_child(slot_panel)

func on_mouse_entered():
	hover = true

func on_mouse_exited():
	hover = false
