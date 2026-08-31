<img src="icon.svg" alt="icon" width="120">

DialogueDSL is a dialogue manager plugin for [Godot 4.6+](https://godotengine.org/), using scripts with integration with the GDScript system

## Installation
- Copy the folder `addons/ddsl` from this repository into your Godot project's `addons/` folder
- Go to `Project > Project Settings` tab `Plugins` in the Godot editor
- Enable the DDSL plugin
- The `Dialog` singleton should be now accessible in the code and `dialog_*` input map actions should be added
- If this is not the case, reload the project
- Add appropriate controls to the `dialog_*` actions in `Project > Project settings` under the `Input map` tab

## Documentation
https://dialoguedsl.readthedocs.io/

## Basic usage
Dialogue scripts can be created anywhere within the game's project folder. For this, create a text file, and end it with `.ddsl`, then fill it with the dialog, for example
```ddsl
edwin = ^"res://sprites/portraits/edwin.png"
edwin: "Hello, little rover. Are you lost?" { autoconfirm = true }
<- option
- "Yes"
    edwin: "Oh, well, we can't have that here. Come, follow me"
    Cutscenes.trigger("edwinTavernWalk")
- "No"
    edwin: "Are you sure? Well, then... Hope this helps you in your journey"
    Inventory.add("potion/health2")
    edwin: "If you need me, you can find me in my tavern"
- "Kill all humans" ? Inventory.has("weapon/knife") # this branch is not created unless the player has a knife
    edwin: "Why, why, so aggressive! And here I thought you were a friendly little roomba!"
    edwin: "I say, you shouldn't have this"
    Inventory.remove("weapon/knife")
    edwin: "Are you even old enough to have a knife? When were you born?"
    age <- number(1980, 10000)
    ? Time.get_time_dict_from_system()["year"] < age
        edwin: "A time traveller too? I find it hard to believe."
    edwin: "I think you should come with me"
    Cutscenes.trigger("edwinTavernWalk")
```

Note that the language focuses on programmer-styled dialogue description rather than a writer-style one. It is also not intended for creating monolithic dialogues carrying the entire story(i.e. it is not made for visual novels)

Once a dialogue file is created, it can be executed in-game in two primary ways
```gdscript
# Note that there is no default dialogue box provided so Dialog will error during execution if one is not explicitly set
Dialog.setBox(someDialogBoxScene)

# The main way the dialogues can interact with GDScript is via explicit object bindings
# Global bindings are permanent between all dialogue calls
Dialog.bindGlobal(InventoryManager, "Inventory")

# This will start the dialogue without blocking current execution, executing _dialog_callback after the dialogue finishes
Dialog.start("res://path/to/dialog.ddsl", null, {}, _dialog_callback)

# Current execution will be paused for the duration of the dialogue
# `value` will be assigned to a dictionary containing all variables created during script execution
var vars = await Dialog.start("res://path/to/dialog.ddsl")
```

## Features
- built-in syntax highlighting for `.ddsl` dialogue scripts
- translation support
- no dependencies
- integration with GDScript
- built-in UI with simple customization
- simple interface for creating dialogue UI
- custom input types creation
- structured branching over jumping
