# Code Gi, The Tech Farmer

# Hosted at https://gitlab.cs.uct.ac.za/code-game-group/test-project

## Table of Contents 

- [Overview](#overview)
- [Technologies Used](#technologies-used)
- [How to run the game](#how-to-run-the-game)
- [How to build and export the game](#how-to-build-and-export-the-game)
- [Source Code Guide](#viewing-the-source-code)

## Overview 
Code Gi is a farming game for players who want to learn programming. In the game, you program a farmer using a simple beginner friendly language to fully automate various farming tasks.

## Technologies Used

### Development 
- Godot
- Docker
- Gitlab

### Testing 
- GODOT (Godot Unit Tesing)

## How to run the game
You need Godot for this step. Download Godot at
https://godotengine.org/download/. Make sure you get v4.2.2.

Follow the steps below in order to run the game
1. Load the project.godot file for this project. This can simply be done by clicking on the file
2. Press the play button as shown in the picture below
   ![Play Button](docs/play_button.png)
3. Play the game an feel the satisfaction of simply pressing "GO"

## How to build and export the game

### For MACOS

#### Requirements 
- Download the Godot export templates. Use the Godot menu: `Editor` > `Manage Export Templates` as shown in the picture below. Ensure you are downloading from `Best available mirror`.

#### Steps to build and export

- Navigate to `Project` > `Export` as shows in the picture below
  ![Play Button](docs/export_nav.png)

- Set the bundle identifier to `com.codegi` as shown in the picture below
  ![Play Button](docs/macos_bundle_id.png)
- Click Export

### For WINDOWS

#### Steps to build and export

- Navigate to `Project` > `Export` as shown in picture the below
  ![Play Button](docs/export_nav_windows.png)
  
- Click Export

## Viewing the source code:

We recommend using Godot to view the source code. 

Open the Godot engine executable you downloaded, and click the import button in the 
projects window. Navigate to the `project.godot` file in our project root
and double click.

This should import our project into the editor. Opening the project in 
the editor will present you with three main views: `2D`, `3D`, and `Script`.
`3D` is irrelevant for this project. 

`2D` is used to view and edit the `.tscn`
files. This allows you to move Nodes around and change node properties without editing
config files directly.

`Script` is used to edit and view our code. You can double click on any `.gd` file
in the filesystem tab (bottom left) to view specific files. Control clicking on most
things takes you to their definitions.

If you don't want to use the engine, all the code is in `scripts` and `autoload`.

The `.tcsn` and `.tres` files are generated by the engine, but they
are all just text files, so you can view those as well if you want.

### Some notes about Godot architecture

gdscript, Godot's scripting language, does not have traditional
inheritance (much like Python). Here are some patterns we used 
to represent different OOP concepts.

#### Private variables

`var _my_private_variable = "shhh"`

`var my_public_variable = "hi"`

If you have to access a var with an underscore externally, you're doing
something wrong.

#### Virtual functions

```
class_name ParentClass
func my_virtual_function():
	pass
```
```
class_name ChildClass
extends ParentClass
func my_virtual_function():
	do_something()
```

#### Signals

Signals are like events that get passed between engine nodes. Sometimes
it's hard to track down where a signal is coming from. Usually you'll have
something like this at the top of a class:

```
signal my_signal(data)
```

Either this signal is connected to another function using the engine
UI, or it's connected programmatically:

```
func receiver_function(data):
	do_something()

func _ready():
	my_signal.connect(receiver_function)
```

#### Builtin engine types

`RefCounted` is the same as a Java or Python object.

`Node2D` extends `RefCounted`. It represents an object that is in the game.
e.g. a sprite showing the farmer.

`Resource` also extends `RefCounted`. It represents a stored data type. e.g a player's save file

`Control` nodes extend `Node` and are meant for UI. Most of their properties are set in the UI.
