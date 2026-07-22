extends CanvasLayer

static var _tokenize = null
static var _parser = null

static var _Interpreter = null

## Emitted before starting dialog
signal dialogStarted

## Emitted after ending dialog
signal dialogEnded


static var _globals: Dictionary = {
	"options": OptionsInput.new(),
	"option": OptionsInput.new(),
	"string": StringInput.new
}

var currentBox: DialogBox = null

func bindGlobal(thing: Variant, name: String):
	_globals[name] = thing
func removeGlobal(name: String):
	_globals.erase(name)
func getGlobal(name: String, default: Variant = null):
	return _globals.get(name, default)

## Start a dialog from file[br][br]
## [code]dialog[/code]: path to the dialog resource in DDSL syntax[br]
## [code]callback[/code]: callable executed when dialog finishes[br][br]
## [code]return[/code]: returns Dictionary[String, Variant] of internal interpreter variables[br]
func start(dialog: String, callback: Callable = Callable()) -> Dictionary:
	var text = FileAccess.get_file_as_string(dialog)
	var err = FileAccess.get_open_error()
	if err != OK:
		return {}
	var parsed = _parse(text)
	#print("!!! ", parsed)
	dialogStarted.emit()
	var interpreter = _Interpreter.new()
	await interpreter.start(parsed)
	if callback.is_valid():
		callback.call(interpreter.variables)
	dialogEnded.emit()
	return interpreter.variables


## Start a dialog from file[br][br]
## [code]dialog[/code]: raw dialog script in DDSL syntax[br]
## [code]callback[/code]: callable executed when dialog finishes[br][br]
## [code]return[/code]: returns Dictionary[String, Variant] of internal interpreter variables[br]
func startFromSource(source: String, callback: Callable = Callable()) -> Dictionary:
	var parsed = _parse(source)
	dialogStarted.emit()
	var interpreter = _Interpreter.new()
	await interpreter.start(parsed)
	dialogEnded.emit()
	return interpreter.variables

## Sets the current dialog box style[br][br]
## [code]box[/code]: The dialog box style. Must be an instantiated scene[br]
func setBox(box: DialogBox):
	for child in get_children():
		child.queue_free()
	add_child(box)
	box.hide()
	currentBox = box

func _enter_tree():
	_tokenize = preload("res://addons/ddsl/utils/tokenizer.gd").tokenize
	_parser = preload("res://addons/ddsl/utils/parser.gd").parse
	_Interpreter = preload("res://addons/ddsl/interpreter.gd").Interpreter
	
	#anchor_left = 0
	#anchor_top = 0
	#anchor_right = 1
	#anchor_bottom = 1
	
	

func _parse(raw: String):
	return _parser.call(_tokenize.call(raw) as Array[ASTNode])


## General class for input options(used in the <- input syntax)
class InputOption:
	func _init(): pass

class OptionsInput extends InputOption:
	func _init(): pass

class StringInput extends InputOption:
	var maxLen: int
	func _init(l: int):
		maxLen = l



class ASTNode:
	var type
	var value
	var x: int
	var y: int
	var offset: int
	var subtype = null
	var op = null
	var operands = null
	
	func _init(type, value, x = -1, y = -1, offset = -1):
		self.type = type
		self.value = value
		self.x = x; self.y = y; self.offset = offset
	
	func _to_string():
		return str(self.value) + "(" + self.type + ")"
	
	func dump():
		var d = {"type": self.type}
		if self.subtype != null: d["subtype"] = self.subtype
		if self.op != null: d["subtype"] = self.op
		if self.operands != null: d["subtype"] = self.operands
		if self.value is Array:
			var v = []
			for value in self.value:
				if value is Object and value.has_method("dump"):
					v.append(value.dump())
				else:
					v.append(str(value))
			d["value"] = v
		elif self.value is Dictionary:
			var kv = {}
			for k in self.value:
				var v = self.value[k]
				var rk
				if k is Object and k.has_method("dump"):
					rk = k.dump()
				else:
					rk = str(k)
				
				if v is Object and v.has_method("dump"):
					kv[rk] = v.dump()
				else:
					kv[rk] = str(v)
			d["value"] = kv
		elif self.value is Object and self.value.has_method("dump"):
			d["value"] = self.value.dump()
		else:
			d["value"] = str(self.value)
		return d
		
	static func fromDict(thing: Dictionary):
		var node: ASTNode = ASTNode.new(
			thing.get("type", ""),
			thing.get("value", ""),
			thing.get("x", -1),
			thing.get("y", -1),
			thing.get("offset", -1)
		)
		if thing.has("subtype"):
			node.subtype = thing["subtype"]
		if thing.has("op"):
			node.op = thing["op"]
		if thing.has("operands"):
			node.operands = thing["operands"]
		return node
