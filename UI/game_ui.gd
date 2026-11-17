extends Control

var current_level := 1

@onready var level_menu := $TopBar/TopBarContainer/LevelMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_level_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func populate_level_menu():
	level_menu.clear()
	
	#change to array of existing levels at some point
	for i in range(1,11):
		level_menu.add_item("Level %02d" % i, i-1)
