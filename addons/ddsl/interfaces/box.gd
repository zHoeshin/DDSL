@icon("../icon.svg")
class_name DialogBox
extends Control

## Must be emitted after the current input is completed
signal inputComplete(value: Variant)

## Must be emitted [i]after[/i] the current message has been confirmed by user
signal outputComplete()

## Called to create a message to display to the player[br][br]
## [code]sprite[/code]: texture to display as character portrait, may be null[br]
## [code]text[/code]: message to display to player[br]
## [code]options[/code]: additional options added by programmer using option syntax[br]
func output(sprite, text, options: Dictionary = {}): pass

## Called to show an input prompt to the player[br][br]
## [code]type[/code]: a Dialog.InputOption describing input[br]
## [code]branches[/code]: list of branches stated in the dialog(excluding default branch)[br]
## [code]options[/code]: additional options added by programmer using option syntax[br]
func input(type, branches: Array, options: Dictionary = {}): pass
