class_name ExitArrow
extends Interaction

enum Direction { LEFT, RIGHT, UP, DOWN }

const DIRECTION_ICONS: Dictionary[Direction, Texture2D] = {
	Direction.LEFT: preload("res://assets/kenney_cursor-pack/PNG/Outline/Double/arrow_w.png"),
	Direction.RIGHT: preload("res://assets/kenney_cursor-pack/PNG/Outline/Double/arrow_e.png"),
	Direction.UP: preload("res://assets/kenney_cursor-pack/PNG/Outline/Double/arrow_n.png"),
	Direction.DOWN: preload("res://assets/kenney_cursor-pack/PNG/Outline/Double/arrow_s.png"),
}

## Cena do local a abrir.
@export_file("*.tscn") var target_scene: String = ""
## Esconde esta saída até o GameState ter esta flag.
@export var required_flag: String = ""
## Para que lado a seta aponta.
@export var direction: Direction = Direction.RIGHT:
	set(value):
		direction = value
		_update_direction_icon()


func _ready() -> void:
	super()
	flat = true
	text = ""
	focus_mode = Control.FOCUS_NONE
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_update_direction_icon()
	var empty := StyleBoxEmpty.new()
	for style_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(style_name, empty)
	pressed.connect(_on_pressed)
	GameState.flag_changed.connect(_on_flag_changed)
	refresh_state()


func _update_cursor() -> void:
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	_update_direction_icon()


func _update_direction_icon() -> void:
	icon = DIRECTION_ICONS[direction] if _hovered and not disabled else null


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
