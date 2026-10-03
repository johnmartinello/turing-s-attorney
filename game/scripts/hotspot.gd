class_name Hotspot
extends Interaction

## Timeline reproduzida quando [member flag] não está definida.
@export_file("*.dtl") var timeline: String = ""
## Timeline reproduzida quando [member flag] já está definida. Deixe vazio para usar sempre [member timeline].
@export_file("*.dtl") var timeline_if_flag: String = ""
## Flag do GameState que troca para [member timeline_if_flag].
@export var flag: String = ""
## Esconde este ponto de interação até o GameState ter esta flag.
@export var required_flag: String = ""
## Desativa depois da primeira conversa bem-sucedida.
@export var one_shot: bool = false

var _used := false


func _ready() -> void:
	super()
	pressed.connect(_on_pressed)
	GameState.flag_changed.connect(_on_flag_changed)
	refresh_state()


func refresh_state() -> void:
	var locked := not required_flag.is_empty() and not GameState.has_flag(required_flag)
	visible = not locked
	disabled = locked or (_used and one_shot) or DialogueDirector.is_running
	_update_cursor()


func _on_flag_changed(_flag: String, _value: bool) -> void:
	refresh_state()


func _on_pressed() -> void:
	if DialogueDirector.is_running:
		return
	var next := timeline
	if not timeline_if_flag.is_empty() and not flag.is_empty() and GameState.has_flag(flag):
		next = timeline_if_flag
	if not DialogueDirector.start(next):
		return
	if one_shot:
		_used = true
		refresh_state()
