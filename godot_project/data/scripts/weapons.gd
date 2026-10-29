extends Node3D
class_name WeaponsController;

@export_group("Weapons Nodes")

@export var glock_17 : Glock17;
@export var mauser_c96 : Glock17;

enum WEAPONS {
	GLOCK17,
	MAUSER_C96
}

@export var current_weapon : WEAPONS = WEAPONS.GLOCK17;

@onready var weapons_nodes : Dictionary = {
	WEAPONS.GLOCK17: glock_17,
	WEAPONS.MAUSER_C96: mauser_c96
}

func _ready() -> void:
	await get_tree().process_frame;
	change_weapon(WEAPONS.GLOCK17);
	
	print(weapons_nodes[current_weapon]);

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_1):
		change_weapon(WEAPONS.GLOCK17);
	
	if Input.is_key_pressed(KEY_2):
		change_weapon(WEAPONS.MAUSER_C96);

func change_weapon(_weapon : WEAPONS) -> void:
	current_weapon = _weapon;
	
	for w in weapons_nodes:
		var we = weapons_nodes[w]
		
		if w == current_weapon:
			we.change_state("IDLE");
		else:
			we.change_state("OUT");
