class_name Location
extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	DialogueDirector.dialogue_started.connect(_refresh_input)
	DialogueDirector.dialogue_finished.connect(_refresh_input)
	_refresh_input()


func _refresh_input() -> void:
	for node in find_children("*", "BaseButton", true, false):
		if node.has_method("refresh_state"):
			node.refresh_state()
		else:
			node.disabled = DialogueDirector.is_running
