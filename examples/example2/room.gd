extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var options = Dialog.Options.new()
	options.canAccessNodesByPath = true
	Dialog.start("res://examples/example2/example.ddsl", options)
