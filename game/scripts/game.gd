extends Control

const START_SCENE := "res://game/scenes/locations/office.tscn"

@onready var _record_button: Button = %RecordButton
@onready var _inventory_panel: InventoryPanel = %InventoryPanel


func _ready() -> void:
	_record_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	SceneRouter.register_host(%LocationHost)
	SceneRouter.go_to(START_SCENE)
	_record_button.pressed.connect(_inventory_panel.toggle)
	DialogueDirector.dialogue_started.connect(_on_dialogue_started)
	DialogueDirector.dialogue_finished.connect(_on_dialogue_finished)


func _on_dialogue_started() -> void:
	_inventory_panel.hide()
	_record_button.disabled = true


func _on_dialogue_finished() -> void:
	_record_button.disabled = false
