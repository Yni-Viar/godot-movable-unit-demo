extends DoorBase


func door_controller(keycard: int):
	super.door_controller(keycard)
	if is_opened:
		door_close()
		$NavigationLink3D.enabled = false
	else:
		door_open()
		$NavigationLink3D.enabled = true
