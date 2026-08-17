@tool
extends EditorSyntaxHighlighter
class_name DDSLSyntaxHighlight

func _get_name() -> String:
	return "DDSL"

func _get_supported_languages() -> PackedStringArray:
	return ["TextFile"]


var colors = {
	"comment": Color(0.382, 0.382, 0.382),
	"ident": Color(0.804, 0.808, 0.824),
	"numdec": Color(0.627, 1.0, 0.878),
	"numint": Color(0.627, 1.0, 0.878),
	"string": Color(1.0, 0.929, 0.627),
	"trstring": Color(1.0, 0.776, 0.627, 1.0),
	"varid": Color(0.804, 0.808, 0.824),
	#"vartemp": Color(0.487, 0.658, 0.961),
	"varfile": Color(0.927, 0.754, 0.616),
	"varglobal": Color(0.78, 1.0, 0.929),
	"varpath": Color(0.357, 0.686, 0.325),
	"varpathstr": Color(0.349, 0.663, 0.322),
	"varnode": Color.DARK_GREEN,
	"varuniquenode": Color.FOREST_GREEN,
	"op": Color(0.671, 0.788, 1.0),
	"bracket": Color(0.655, 0.773, 0.976),
	"newline": Color(0.569, 0.569, 0.569),
	"ws": Color(0.22, 0.22, 0.22),
	"control": Color(0.953, 0.525, 0.757)
}

func _init():
	colors["comment"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/comment_color")
	colors["numdec"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/number_color")
	colors["numint"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/number_color")
	colors["string"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/string_color")
	colors["trstring"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/string_placeholder_color")
	colors["varid"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/text_color")
	#colors["vartemp"] = EditorInterface.get_editor_settings().get_setting("")
	colors["varfile"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/gdscript/annotation_color")
	colors["varglobal"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/user_type_color")
	colors["varpath"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/gdscript/node_path_color")
	colors["varpathstr"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/gdscript/node_path_color")
	colors["varnode"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/gdscript/node_reference_color")
	colors["varuniquenode"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/gdscript/node_reference_color")
	colors["op"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/symbol_color")
	colors["bracket"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/symbol_color")
	colors["control"] = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/control_flow_keyword_color")

const open = "[{("
const closed = ")}]"
const pair = {
	"]": "[", "}": "{", ")": "("
}
var tokenize = preload("res://addons/ddsl/utils/tokenizer.gd").tokenize

func _get_line_syntax_highlighting(line):
	var colormap = {0: {"color": Color(0.32, 0.0, 0.0)}}
	var tokens = tokenize.callv([get_text_edit().get_line(line), [false] as Array[bool]])
	#print(tokens)
	#return colormap

	#var b = []
	
	#var hadop = false
	var i: int = 0
	var hadany = false
	while i < len(tokens):
		var t = tokens[i]
		i += 1
		var c = colors.get(t.type, Color(1.0, 0.0, 0.0))
		if (t.type == "op") and (t.value in [":", "<-", "?", "?!", ".", "-", "--", "if", "elif", "else", "match", "case", "while", "for", "break", "continue", "exit"]): # and (not hadop):
			if t.value == "." and hadany:
				c = colors["op"]
			else:
				c = colors["control"]
		hadany = true
		#if (len(b) == 0) and (t.type == "op") and (t.value in [">", "<", "?", "?!", ".", "-", "--"]):
			#hadop = true
		#elif t.type == op: hadop = true
		#elif t.type not in ["ws", "newline", "ident"]:
		#	hadop = true
		if t.type in ["newline", "ident"]:
			hadany = false
		
		#if t.type == "bracket":
			#if t.value in open:
				#b.append(t.value)
			#if t.value in closed:
				#b.pop_back()
		
		colormap[t.x] = {"color": c}
	
	#print(colormap)
	return colormap
