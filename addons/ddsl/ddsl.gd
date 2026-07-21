@tool
extends EditorPlugin

var _initialized = false
var highlighter: DDSLSyntaxHighlight = null

func _enter_tree():
	if _initialized:
		return
	_initialized = true
	
	add_autoload_singleton("Dialog", "dialog.gd")
	
	highlighter = DDSLSyntaxHighlight.new()
	EditorInterface.get_script_editor().register_syntax_highlighter(highlighter)
	
	var settings = EditorInterface.get_editor_settings()
	var current = settings.get_setting("docks/filesystem/textfile_extensions")
	
	_setup_action("dialog_confirm")
	_setup_action("dialog_cancel")
	_setup_action("dialog_skip")
	_setup_action("dialog_up")
	_setup_action("dialog_down")
	_setup_action("dialog_left")
	_setup_action("dialog_right")
	ProjectSettings.save()

func _exit_tree() -> void:
	if is_instance_valid(highlighter):
		EditorInterface.get_script_editor().unregister_syntax_highlighter(highlighter)
		highlighter = null
	remove_autoload_singleton("Dialog")

func _setup_action(action: String):
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		#ProjectSettings.set_setting("input/" + action, {"deadzone": 0.5,"events": []})

#func _handles(object):
	#return is_instance_of(object, DialogFile)
