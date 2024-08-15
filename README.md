## A simple programming game

You should be able to use loops, variables and
if statements to plant and harvest four crops
from the 2x2 grid. The syntax is very similar to
gdscript, so check https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html for info 
on how to program in the game. You
also need to declare variables before using them (for now).

### Running the game:
There should be a Windows, Linux, and MacOS executable file
in the export folder.

Alternatively, you can load project.godot file into Godot and press
the play button.

### Building from source:

You need Godot for this step. Download Godot at
https://godotengine.org/download/. Make sure you get v4.2.2.

Follow this tutorial to export the source code into an executable:

https://docs.godotengine.org/en/4.2/tutorials/export/exporting_projects.html

You might need to download an export config.

### Viewing the source code:

We recommend using Godot to view the source code. 

Open the Godot executable you downloaded, and click the import button in the 
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
