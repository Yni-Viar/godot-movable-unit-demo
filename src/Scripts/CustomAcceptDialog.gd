extends AcceptDialog
## Accept button, that will be closed, and not hidden on every action
## Created by Yni, licensed under MIT License


func _on_canceled() -> void:
	queue_free()


func _on_confirmed() -> void:
	queue_free()
