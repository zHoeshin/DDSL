extends DialogBox

var isOutputting: bool = false
var isFinishedOutputting: bool = false
var isSkipping: bool = false
var outputString: String = ""
var outputSplit: PackedStringArray = []
var outputCount: int = 0
var DEFAULT_TIMER_THRESHOLD = 0.05
var outputTimer: float = 0
var threshold = 0.05


var isInputting: bool = false
var isOptions: bool = false
var optionsCount: int = 0
var selectedOption: int = 0
var optionValues = []
var canInputOption = false
var autoconfirm: bool = false

@onready var container = $container/text
@onready var outputText = $container/text/text
@onready var outputSprite = $container/sprite
@onready var outputSkipTimer = $skipTimer

@onready var options = [
	[],
	[
		$container/text/output1/label1
	], [
		$container/text/output2/label1,
		$container/text/output2/label2,
	], [
		$container/text/output3/label1,
		$container/text/output3/label2,
		$container/text/output3/label3,
	], [
		$container/text/output4/row1/label1,
		$container/text/output4/row1/label2,
		$container/text/output4/row2/label3,
		$container/text/output4/row2/label4
	]
]

@onready var optionContainers = [
	null,
	$container/text/output1,
	$container/text/output2,
	$container/text/output3,
	$container/text/output4
]

func _ready():
	outputSprite.set_deferred("size", Vector2(
		outputSprite.size.y, outputSprite.size.y
	))

func input(type, branches: Array, _options: Dictionary = {}):
	if type is Dialog.OptionsInput:
		canInputOption = false
		optionsCount = min(len(branches), 4)
		if optionsCount == null:
			return
		isInputting = true
		isOptions = true
		selectedOption = 0
		optionContainers[optionsCount].show()
		for i in optionsCount:
			options[optionsCount][i].text = str(branches[i])
			options[optionsCount][i].modulate = Color.WHITE
		options[optionsCount][selectedOption].modulate = Color.YELLOW
		optionValues = branches
		show()
		return

func output(sprite, text: String, _options: Dictionary = {}):
	if isOutputting:
		push_error("Trying to output while already outputting")
		return
	outputText.text = ""
	if sprite != null:
		outputSprite.texture = sprite
		outputSprite.show()
	else:
		outputSprite.hide()
	threshold = DEFAULT_TIMER_THRESHOLD
	isOutputting = true
	outputString = text
	outputSplit = text.split("")
	
	## makes input options appear with the previous text for prompting
	if _options.get("full", false):
		isFinishedOutputting = true
		outputText.text = outputString
	autoconfirm = _options.get("autoconfirm", false)
	show()

func _process(delta):
	if isOutputting:
		if isSkipping:
			return
		if Input.is_action_pressed("dialog_skip"):
			isSkipping = true
			outputSkipTimer.start()
			isFinishedOutputting = true
			outputText.text = outputString
			return
		if isFinishedOutputting:
			outputText.text = outputString
			if autoconfirm or Input.is_action_just_pressed("dialog_confirm"):
				cleanupOutput()
		else:
			outputTimer += delta
			outputText.text = "".join(outputSplit.slice(0, outputCount + 1))
			while outputTimer > threshold:
				outputTimer -= threshold
				outputCount += 1
				if outputCount >= len(outputSplit):
					isFinishedOutputting = true
			if Input.is_action_just_pressed("dialog_cancel"):
				isFinishedOutputting = true
				outputText.text = outputString
	if isInputting:
		if isOptions:
			var dir = Vector2(
				int(Input.is_action_just_pressed("dialog_right"))
				-
				int(Input.is_action_just_pressed("dialog_left"))
				,
				int(Input.is_action_just_pressed("dialog_down"))
				-
				int(Input.is_action_just_pressed("dialog_up"))
			)
			processOptionDirection(dir)
			
			## HACK: ensure option input cannot be accidentally skipped
			if canInputOption and Input.is_action_just_pressed("dialog_confirm"):
				cleanupOptions()
			canInputOption = true

func processOptionDirection(dir: Vector2):
	match optionsCount:
		1:
			return
		2:
			var d = dir.x + dir.y
			if d == 0: return
			selectedOption = clamp(selectedOption + d, 0, 1)
			options[2][0].modulate = Color.WHITE
			options[2][1].modulate = Color.WHITE
			options[2][selectedOption].modulate = Color.YELLOW
		3:
			var d = dir.x + dir.y
			if d == 0: return
			selectedOption = clamp(selectedOption + d, 0, 2)
			options[3][0].modulate = Color.WHITE
			options[3][1].modulate = Color.WHITE
			options[3][2].modulate = Color.WHITE
			options[3][selectedOption].modulate = Color.YELLOW
		4:
			if dir.x == 1:
				selectedOption |= 0b10
			if dir.x == -1:
				selectedOption &= 0b01
			if dir.y == 1:
				selectedOption |= 0b01
			if dir.y == -1:
				selectedOption &= 0b10
			options[4][0].modulate = Color.WHITE
			options[4][1].modulate = Color.WHITE
			options[4][2].modulate = Color.WHITE
			options[4][3].modulate = Color.WHITE
			options[4][selectedOption].modulate = Color.YELLOW
			

func cleanupOptions():
	optionContainers[optionsCount].hide()
	isInputting = false
	isOptions = false
	optionsCount = 0
	var s = optionValues[selectedOption]
	optionValues = []
	hide()
	inputComplete.emit(s)

func cleanupOutput():
	autoconfirm = false
	isOutputting = false
	isFinishedOutputting = false
	isSkipping = false
	outputString = ""
	outputSplit = []
	outputCount = 0
	outputTimer = 0
	hide()
	outputComplete.emit()
