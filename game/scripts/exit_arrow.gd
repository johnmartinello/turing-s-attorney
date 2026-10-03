class_name ExitArrow
extends Interaction

enum Direction { LEFT, RIGHT, UP, DOWN }

## Cena do local a abrir.
@export_file("*.tscn") var target_scene: String = ""
## Esconde esta saída até o GameState ter esta flag.
@export var required_flag: String = ""
## Para que lado a seta aponta.
@export var direction: Direction = Direction.RIGHT


func _ready() -> void:
	super()
	flat = true
	text = ""
	focus_mode = Control.FOCUS_NONE
	var empty := StyleBoxEmpty.new()
	for style_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(style_name, empty)
	pressed.connect(_on_pressed)
	GameState.flag_changed.connect(_on_flag_changed)
	refresh_state()


func refresh_state() -> void:
	var locked := not required_flag.is_empty() and not GameState.has_flag(required_flag)
	visible = not locked
	disabled = locked or DialogueDirector.is_running
	_update_cursor()


func _on_flag_changed(_flag: String, _value: bool) -> void:
	refresh_state()


func _on_pressed() -> void:
	if DialogueDirector.is_running:
		return
	SceneRouter.go_to(target_scene)
