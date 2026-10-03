extends Node

## Flags da história que não são itens do inventário.

signal flag_changed(flag: String, value: bool)

var _flags: Dictionary = {}


func set_flag(flag: String, value: bool = true) -> void:
	if flag.is_empty():
		return
	_flags[flag] = value
	flag_changed.emit(flag, value)


func has_flag(flag: String) -> bool:
	return bool(_flags.get(flag, false))


func clear_flag(flag: String) -> void:
	set_flag(flag, false)
