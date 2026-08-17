@tool
extends EditorPlugin

var _initialized = false
var highlighter: DDSLSyntaxHighlight = null

var _http: HTTPRequest

func _enter_tree():
	if _initialized:
		return
	_initialized = true
	
	add_autoload_singleton("Dialog", "dialog.gd")
	Dialog.__plugin = self
	
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
	
	var http = HTTPRequest.new()
	add_child(http)
	_http = http
	http.request_completed.connect(_verify_plugin)
	http.request("https://godotengine.org/asset-library/api/asset/5385")

func _exit_tree() -> void:
	if is_instance_valid(highlighter):
		EditorInterface.get_script_editor().unregister_syntax_highlighter(highlighter)
		highlighter = null
	remove_autoload_singleton("Dialog")

func _setup_action(action: String):
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		#ProjectSettings.set_setting("input/" + action, {"deadzone": 0.5,"events": []})

func _verify_plugin(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
	if code != 200:
		return
	var response = body.get_string_from_utf8()
	_http.queue_free()
	var json = JSON.parse_string(response)
	if not json:
		return
	if json is not Dictionary:
		return
	if not (json as Dictionary).has("version_string"):
		return
	var vlatest = (json as Dictionary).get("version_string", "0.0.0").split(".")
	var config = ConfigFile.new()
	if config.load("res://addons/ddsl/plugin.cfg") != OK:
		return
	var vcurrstr = config.get_value("plugin", "version", "0.0.0")
	var vcurr = vcurrstr.split(".")
	var versionLatest = Vector3i(
		int(vlatest[0]),
		int(vlatest[1]),
		int(vlatest[2]),
	)
	var versionCurrent = Vector3i(
		int(vcurr[0]),
		int(vcurr[1]),
		int(vcurr[2]),
	)
	if versionLatest > versionCurrent:
		push_warning("Using potentially outdated version of DialogueDSL " + vcurrstr + ", latest is " + json["version_string"])
	
	var latestTime = Time.get_unix_time_from_datetime_string(json["modify_date"].replace(" ", "T"))
	var currentTime = Time.get_unix_time_from_system()
	
	if currentTime - latestTime < 3 * 24 * 60 * 60:
		if versionLatest == versionCurrent:
			push_warning("Using a new version of DialogueDSL " + vcurrstr)
			print_rich("[color=" + EditorInterface.get_editor_theme().get_color("warning_color", "Editor").to_html(false) + "]Report any regressions or issues with new features at [url=https://github.com/zHoeshin/DDSL/issues/]the plugin's Github[/url][/color]")

#func _handles(object):
	#return is_instance_of(object, DialogFile)
