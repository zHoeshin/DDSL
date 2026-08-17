@tool
extends VBoxContainer

@export var digits: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
@export var digit = 0:
	set(value):
		digit = value % len(digits)
		$digit.text = digits[digit]

@export var arrowUp: Texture2D = preload("res://addons/ddsl/styledbox/defaultUp.png"):
	set(value):
		arrowUp = value
		$up.texture = arrowUp
@export var arrowDown: Texture2D = preload("res://addons/ddsl/styledbox/defaultDown.png"):
	set(value):
		arrowDown = value
		$down.texture = arrowDown
@export var arrowUpActive: Texture2D = preload("res://addons/ddsl/styledbox/defaultUpActive.png")
@export var arrowDownActive: Texture2D = preload("res://addons/ddsl/styledbox/defaultDownActive.png")

@export var colorUnselected: Color = Color.WHITE:
	set(value):
		colorUnselected = value
		$digit.modulate = value
@export var colorSelected: Color = Color.YELLOW

var selected: bool = false

func setDigit(d):
	digit = d % len(digits)

func addDigit(d):
	digit = (digit + d) % len(digits)

func getDigit() -> String:
	return digits[digit]

func setFontSize(fontSize: int):
	$digit.add_theme_font_size_override("normal_font_size", fontSize)
	$digit.add_theme_font_size_override("bold_font_size", fontSize)
	$digit.add_theme_font_size_override("italics_font_size", fontSize)
	$digit.add_theme_font_size_override("bold_italics_font_size", fontSize)
	$digit.add_theme_font_size_override("mono_font_size", fontSize)

func select():
	selected = true
	$digit.modulate = colorSelected
	$up.texture = arrowUpActive
	$down.texture = arrowDownActive
func deselect():
	selected = false
	$digit.modulate = colorUnselected
	$up.texture = arrowUp
	$down.texture = arrowDown

func setTextures(up: Texture2D, down: Texture2D, upactive: Texture2D, downactive: Texture2D):
	arrowUp = up
	arrowDown = down
	arrowUpActive = upactive
	arrowDownActive = downactive
	if selected:
		$up.texture = arrowUpActive
		$down.texture = arrowDownActive
	else:
		$up.texture = arrowUp
		$down.texture = arrowDown
