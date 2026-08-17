@tool

extends DialogBox
class_name StylableDialogBox

@onready var bgNode: NinePatchRect = $bg
@onready var container: HBoxContainer = $container

@export_enum("Text", "Options", "Digits", "Number", "More to come") var preview: String = "Text":
	set(value):
		if not is_node_ready():
			return
		if not Engine.is_editor_hint():
			$container/io/examples.hide()
			return
		match preview:
			"Options":
				$container/io/examples/options.hide()
			"Digits":
				$container/io/examples/digits.hide()
			"Number":
				$container/io/examples/number.hide()
			"String":
				pass
		match value:
			"Options":
				$container/io/examples/options.show()
			"Digits":
				$container/io/examples/digits.show()
			"Number":
				$container/io/examples/number.show()
			"String":
				pass
		preview = value

@export_group("sprites")
@export_subgroup("background", "bg_")
@export var bg_Texture: Texture2D = preload("res://addons/ddsl/styledbox/defaultBox.png"):
	set(value):
		bg_Texture = value
		$bg.texture = value
@export var bg_Left: float = 12.0:
	set(value):
		bg_Left = value
		$bg.patch_margin_left = value
		$container.offset_left = value
@export var bg_Top: float = 12.0:
	set(value):
		bg_Top = value
		$bg.patch_margin_top = value
		$container.offset_top = value
@export var bg_Right: float = 12.0:
	set(value):
		bg_Right = value
		$bg.patch_margin_right = value
		$container.offset_right = -value
@export var bg_Bottom: float = 12.0:
	set(value):
		bg_Bottom = value
		$bg.patch_margin_bottom = value
		$container.offset_bottom = -value

func _updateExampleArrows():
	if is_node_ready() or Engine.is_editor_hint():
		$container/io/examples/digits/Digit1.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)
		$container/io/examples/digits/Digit2.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)
		$container/io/examples/digits/Digit3.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)
		$container/io/examples/number/Digit1.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)
		$container/io/examples/number/Digit2.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)
		$container/io/examples/number/Digit3.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)

@export_subgroup("arrows", "arrow_")
@export var arrow_up: Texture2D = preload("res://addons/ddsl/styledbox/defaultUp.png"):
	set(value):
		arrow_up = value
		_updateExampleArrows()
@export var arrow_down: Texture2D = preload("res://addons/ddsl/styledbox/defaultDown.png"):
	set(value):
		arrow_down = value
		_updateExampleArrows()
@export var arrow_up_active: Texture2D = preload("res://addons/ddsl/styledbox/defaultUpActive.png"):
	set(value):
		arrow_up_active = value
		_updateExampleArrows()
@export var arrow_down_active: Texture2D = preload("res://addons/ddsl/styledbox/defaultDownActive.png"):
	set(value):
		arrow_down_active = value
		_updateExampleArrows()

@export_subgroup("Text decorators", "td_")
@export var td_SelectedOption_Left: String = "[color=yellow]":
	set(value):
		td_SelectedOption_Left = value
		if Engine.is_editor_hint():
			$"container/io/examples/options/wrapper/1".text = td_SelectedOption_Left + "Yes" + td_SelectedOption_Right
@export var td_SelectedOption_Right: String = "[/color]":
	set(value):
		td_SelectedOption_Right = value
		if Engine.is_editor_hint():
			$"container/io/examples/options/wrapper/1".text = td_SelectedOption_Left + "Yes" + td_SelectedOption_Right
@export var td_UnselectedOption_Left: String = "":
	set(value):
		td_UnselectedOption_Left = value
		if Engine.is_editor_hint():
			$"container/io/examples/options/wrapper/2".text = td_UnselectedOption_Left + "No" + td_UnselectedOption_Right
@export var td_UnselectedOption_Right: String = "":
	set(value):
		td_UnselectedOption_Right = value
		if Engine.is_editor_hint():
			$"container/io/examples/options/wrapper/2".text = td_UnselectedOption_Left + "No" + td_UnselectedOption_Right

@export_subgroup("Colors", "color_")
@export var color_selectedDigit: Color = Color.YELLOW:
	set(value):
		color_selectedDigit = value
		

#@export var td_SelectedDigit_Left: String = "[color=yellow]":
	#set(value):
		#td_SelectedDigit_Left = value
		#if Engine.is_editor_hint():
			#$"container/io/examples/options/wrapper/1".text = td_SelectedDigit_Left + "Yes" + td_SelectedDigit_Right
#@export var td_SelectedDigit_Right: String = "[/color]":
	#set(value):
		#td_SelectedDigit_Right = value
		#if Engine.is_editor_hint():
			#$"container/io/examples/options/wrapper/1".text = td_SelectedOption_Left + "Yes" + td_SelectedDigit_Right
#@export var td_UnselectedDigit_Left: String = "":
	#set(value):
		#td_UnselectedDigit_Left = value
		#if Engine.is_editor_hint():
			#$"container/io/examples/options/wrapper/2".text = td_UnselectedDigit_Left + "No" + td_UnselectedDigit_Right
#@export var td_UnselectedDigit_Right: String = "":
	#set(value):
		#td_UnselectedDigit_Right = value
		#if Engine.is_editor_hint():
			#$"container/io/examples/options/wrapper/2".text = td_UnselectedOption_Left + "No" + td_UnselectedDigit_Right

@export var fontSize: int = 32:
	set(value):
		if not is_node_ready():
			return
		fontSize = value
		_setFontSize($container/io/split/output, value)
		_setFontSize($container/io/examples/output, value)
		_setFontSize($container/io/examples/digits/Digit1.get_node("digit"), value)
		_setFontSize($container/io/examples/digits/Digit2.get_node("digit"), value)
		_setFontSize($container/io/examples/digits/Digit3.get_node("digit"), value)
		_setFontSize($container/io/examples/number/Digit1.get_node("digit"), value)
		_setFontSize($container/io/examples/number/Digit2.get_node("digit"), value)
		_setFontSize($container/io/examples/number/Digit3.get_node("digit"), value)
		$container/io/examples/number/Sign.add_theme_font_size_override("font_size", value)
		$container/io/split/number/sign.add_theme_font_size_override("font_size", value)
		$container/io/split/number/sign2.add_theme_font_size_override("font_size", value)
		_setFontSize($"container/io/examples/options/wrapper/1", value)
		_setFontSize($"container/io/examples/options/wrapper/2", value)

func _setFontSize(node, size):
	node.add_theme_font_size_override("normal_font_size", fontSize)
	node.add_theme_font_size_override("bold_font_size", fontSize)
	node.add_theme_font_size_override("italics_font_size", fontSize)
	node.add_theme_font_size_override("bold_italics_font_size", fontSize)
	node.add_theme_font_size_override("mono_font_size", fontSize)



enum _State {
	Idle,
	Output,
	OutputComplete,
	InputOption,
	InputDigits,
	InputNumber,
	InputString,
}
var currentState: _State = _State.Idle

var totalChars: int = -1

@onready var inputDigitsNode: HBoxContainer = $container/io/split/digits
const digitScene = preload("res://addons/ddsl/styledbox/digit.tscn")

var currentDigits: Array = []
var currentDigit: int = 0
var digitFunction: Callable = Callable()

@onready var inputNumberNode: HBoxContainer = $container/io/split/number/wrapper
@onready var inputNumberSign: Label = $container/io/split/number/sign
@onready var inputNumberSignMirror: Label = $container/io/split/number/sign2
@onready var inputNumberWrapper: HBoxContainer = $container/io/split/number
var currentMin: int
var currentMax: int
var currentNumber: int
var currentPower: int
var currentNumberLength: int
var currentNumberDigits: Array

@onready var inputOptionsNode: VBoxContainer = $"container/io/split/options/wrapper"
@onready var inputOptionsWrapper: Control = $container/io/split/options
var currentOptions: Array = []
var currentOption: int = 0
var currentOptionNodes: Array = []

func input(type: Dialog.InputOption, branches: Array, options: Dictionary = {}):
	if currentState != _State.Idle:
		push_error("Cannot take input during another action")
		return
	if type is Dialog.OptionsInput:
		currentState = _State.InputOption
		currentOptions = []
		currentOption = 0
		currentOptionNodes = []
		for branch in branches:
			var node = RichTextLabel.new()
			node.fit_content = true
			node.bbcode_enabled = true
			node.add_theme_font_size_override("normal_font_size", fontSize)
			node.add_theme_font_size_override("bold_font_size", fontSize)
			node.add_theme_font_size_override("italics_font_size", fontSize)
			node.add_theme_font_size_override("bold_italics_font_size", fontSize)
			node.add_theme_font_size_override("mono_font_size", fontSize)
			node.text = td_UnselectedOption_Left + str(branch) + td_UnselectedOption_Right
			inputOptionsNode.add_child(node)
			currentOptionNodes.append(node)
			currentOptions.append(branch)
		currentOptionNodes[0].text = td_SelectedOption_Left + str(branches[0]) + td_SelectedOption_Right
		inputOptionsWrapper.show()
		show()
	elif type is Dialog.DigitsInput:
		currentState = _State.InputDigits
		for i in type.length:
			var digit = digitScene.instantiate()
			digit.digits = type.digits
			digit.setFontSize(fontSize)
			digit.setDigit(0)
			digit.setTextures(arrow_up, arrow_down, arrow_up_active, arrow_down_active)
			inputDigitsNode.add_child(digit)
			currentDigits.append(digit)
		currentDigits[currentDigit].select()
		digitFunction = type.type
		inputDigitsNode.show()
		show()
	elif type is Dialog.NumberInput:
		currentState = _State.InputNumber
		currentMin = type.min
		currentMax = type.max
		var mins = str(abs(int(currentMin)))
		var maxs = str(abs(int(currentMax)))
		currentNumberLength = max(len(mins), len(maxs))
		currentNumber = 0
		currentPower = 0
		currentNumberDigits = []
		for i in currentNumberLength:
			var digit = digitScene.instantiate()
			digit.colorSelected = Color.WHITE
			digit.setFontSize(fontSize)
			currentNumberDigits.append(digit)
			inputNumberNode.add_child(digit)
		currentNumberDigits.reverse()
		currentNumberDigits[currentPower].select()
		inputNumberWrapper.show()
		show()
	else:
		push_error("Unknown input type " + str(type))
		return

@onready var outputNode: RichTextLabel = $container/io/split/output
@onready var spriteNode: TextureRect = $container/sprite
@onready var skipTimer: Timer = $timers/skip

var o_skipTime: float = 0.02
var o_autoconfirm: bool = false
var o_wait: float = 0.05

func output(sprite, text: String, options: Dictionary = {}):
	if currentState != _State.Idle:
		push_error("Cannot output during another action")
		return
	outputNode.text = text
	totalChars = outputNode.get_total_character_count()
	outputNode.visible_characters = 0.0
	currentState = _State.Output
	if sprite is Texture2D:
		spriteNode.texture = sprite
		spriteNode.show()
	else:
		spriteNode.hide()
	currentState = _State.Output
	timer = 0.0
	
	o_skipTime = options.get("wait", 0.1)
	if options.get("full", false):
		outputNode.visible_characters = 1
	o_autoconfirm = options.get("next", false) || options.get("autoconfirm", false)
	if options.has("speed"):
		o_wait = 1.0 / options.get("speed")

func endOutput():
	skipTimer.stop()
	if not currentState in [_State.Output, _State.OutputComplete, _State.Idle]:
		return
	outputNode.visible_characters = totalChars
	currentState = _State.Idle
	hide()
	outputComplete.emit()

func _ready():
	#if Engine.is_editor_hint():
		#$container/io/examples.hide()
		#$container/io/split.show()
	#else:
		#$container/io/examples.show()
		#$container/io/split.hide()
	
	$container/io/examples.hide()
	$container/io/split.show()

func _exit_tree():
	$container/io/examples.show()
	$container/io/split.hide()

var timer: float = 0.0
func _process(delta):
	match currentState:
		_State.Idle:
			return
		_State.Output:
			if Input.is_action_pressed("dialog_skip"):
				outputNode.visible_characters = totalChars
				currentState = _State.OutputComplete
				skipTimer.start()
			if outputNode.visible_characters >= totalChars:
					currentState = _State.OutputComplete
			else:
				timer += delta
				while timer >= o_wait:
					timer -= o_wait
					outputNode.visible_characters += 1
				if Input.is_action_just_pressed("dialog_cancel"):
					outputNode.visible_characters = totalChars
					currentState = _State.OutputComplete
		_State.OutputComplete:
			if Input.is_action_just_pressed("dialog_skip"):
				skipTimer.start()
			if o_autoconfirm || Input.is_action_just_pressed("dialog_confirm"):
				endOutput()
		_State.InputOption:
			if Input.is_action_just_pressed("dialog_confirm"):
				currentState = _State.Idle
				var branch = currentOptions[currentOption]
				currentOptions = []
				currentOption = 0
				for node in currentOptionNodes:
					node.queue_free()
				if branch is Dialog.Alias:
					inputComplete.emit(branch.value)
				else:
					inputComplete.emit(branch)
				inputOptionsWrapper.hide()
				hide()
				return
			var h = int(Input.is_action_just_pressed("dialog_right")) - int(Input.is_action_just_pressed("dialog_left"))
			var d = int(Input.is_action_just_pressed("dialog_up")) - int(Input.is_action_just_pressed("dialog_down"))
			var dir = h - d
			if dir == 0:
				return
			currentOption += dir
			currentOption = clamp(currentOption, 0, len(currentOptions) - 1)
			var i = 0
			while i < len(currentOptionNodes):
				var option = currentOptionNodes[i]
				if i == currentOption:
					option.text = td_SelectedOption_Left + str(currentOptions[i]) + td_SelectedOption_Right
				else:
					option.text = td_UnselectedOption_Left + str(currentOptions[i]) + td_UnselectedOption_Right
				i += 1
		_State.InputDigits:
			if Input.is_action_just_pressed("dialog_confirm"):
				var digits: String = ""
				for d in currentDigits:
					digits += d.getDigit()
				inputDigitsNode.hide()
				hide()
				for d in currentDigits:
					d.queue_free()
				currentDigits = []
				currentDigit = 0
				currentState = _State.Idle
				if digitFunction.is_valid():
					inputComplete.emit(digitFunction.call(digits))
				else:
					inputComplete.emit(digits)
				return
			var h = int(Input.is_action_just_pressed("dialog_right")) - int(Input.is_action_just_pressed("dialog_left"))
			if h != 0:
				currentDigit = clamp(currentDigit + h, 0, len(currentDigits) - 1)
				for digit in currentDigits:
					digit.deselect()
				currentDigits[currentDigit].select()
			var d = int(Input.is_action_just_pressed("dialog_up")) - int(Input.is_action_just_pressed("dialog_down"))
			if Input.is_action_pressed("dialog_cancel"):
				d *= 5
			if d == 0:
				return
			currentDigits[currentDigit].addDigit(d)
		_State.InputNumber:
			if Input.is_action_just_pressed("dialog_confirm"):
				for d in currentNumberDigits:
					d.queue_free()
				currentNumberDigits = []
				currentPower = 0
				currentState = _State.Idle
				inputNumberSign.text = ""
				inputNumberSignMirror.text = ""
				inputComplete.emit(currentNumber)
				currentNumber = 0
				inputNumberWrapper.hide()
				hide()
			var h = -int(Input.is_action_just_pressed("dialog_right")) + int(Input.is_action_just_pressed("dialog_left"))
			if h != 0:
				currentPower = clamp(currentPower + h, 0, currentNumberLength - 1)
				for digit in currentNumberDigits:
					digit.deselect()
				currentNumberDigits[currentPower].select()
			var d = int(Input.is_action_just_pressed("dialog_up")) - int(Input.is_action_just_pressed("dialog_down"))
			if Input.is_action_pressed("dialog_cancel"):
				d *= 5
			if d == 0:
				return
			currentNumber += int(d * 10 ** currentPower)
			currentNumber = clamp(currentNumber, currentMin, currentMax)
			var nstr = str(abs(currentNumber))
			nstr = "0".repeat(currentNumberLength - len(nstr)) + nstr
			if currentNumber < 0:
				inputNumberSignMirror.text = "-"
				inputNumberSign.text = "-"
			else:
				inputNumberSignMirror.text = ""
				inputNumberSign.text = ""
			var i = 0
			while i < len(nstr):
				currentNumberDigits[currentNumberLength - i - 1].setDigit(int(nstr[i]))
				i += 1

func setTexture(texture: Texture2D):
	$bg.texture = texture

func setMargins(a = -1, b = -1, c = -1, d = -1):
	var m = _margins(a, b, c, d, 0)
	$bg.offset_top = m.x
	$bg.offset_right = m.y
	$bg.offset_bottom = m.z
	$bg.offset_left = m.w
	$container.offset_top = m.x + $bg.patch_margin_top
	$container.offset_right = m.y - $bg.patch_margin_right
	$container.offset_bottom = m.z - $bg.patch_margin_bottom
	$container.offset_left = m.w - $bg.patch_margin_left

func setNinePatchRect(a = -1, b = -1, c = -1, d = -1):
	var m = _margins(a, b, c, d, a)
	$bg.patch_margin_top = m.x
	$bg.patch_margin_right = m.y
	$bg.patch_margin_bottom = m.z
	$bg.patch_margin_left = m.w
	$container.offset_top = $bg.offset_top + m.x
	$container.offset_right = -$bg.offset_right - m.y
	$container.offset_bottom = -$bg.offset_bottom - m.z
	$container.offset_left = $bg.offset_left + m.w

func _margins(a = -1, b = -1, c = -1, d = -1, defBottom = 0):
	if d != -1:
		return Vector4(a, -b, -c, d)
	elif a == -1:
		return Vector4(0, 0, 0, 0)
	elif b == -1:
		return Vector4(a, -a, -a, a)
	elif c == -1:
		return Vector4(a, -b, -a, b)
	elif d == -1:
		return Vector4(a, -b, -defBottom, c)
