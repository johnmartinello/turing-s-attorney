extends Node

## Troca o local sob um nó hospedeiro para o HUD continuar na tela.

signal location_changed(scene_path: String)

var current_scene_path := ""

var _host: Node
var _queued_scene := ""
var _swap_pending := false


func register_host(host: Node) -> void:
	_host = host


func go_to(scene_path: String) -> void:
	if scene_path.is_empty():
		return
	_queued_scene = scene_path
	if _swap_pending:
		return
	_swap_pending = true
	_swap.call_deferred()


func _swap() -> void:
	_swap_pending = false
	var scene_path := _queued_scene
	if _host == null:
		push_error("SceneRouter: no location host registered")
		return
	if not ResourceLoader.exists(scene_path):
		push_error("SceneRouter: missing scene %s" % scene_path)
		return
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("SceneRouter: failed to load %s" % scene_path)
		return
	for child in _host.get_children():
		_host.remove_child(child)
		child.free()
	var location := packed.instantiate()
	_host.add_child(location)
	current_scene_path = scene_path
	location_changed.emit(scene_path)
