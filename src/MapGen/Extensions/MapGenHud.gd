extends Panel

@onready var mapgen: FacilityGenerator = get_tree().root.get_node("Game/FacilityGenerator")


func _on_facility_generator_generated() -> void:
	var counter: int = 0
	for i in range(mapgen.size_x):
		for j in range(mapgen.size_y):
			$ScrollContainer/GridContainer.columns = mapgen.size_x
			var slot: MapGenSlot = MapGenSlot.new()
			slot.display_data(mapgen.mapgen[i][j].resource, mapgen.mapgen[i][j].angle, mapgen.mapgen[i][j].room_name)
			$ScrollContainer/GridContainer.add_child(slot)
			counter += 1


func _on_close_button_button_down() -> void:
	get_parent().input_values("map")
