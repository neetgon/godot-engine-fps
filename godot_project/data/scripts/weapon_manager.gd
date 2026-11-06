extends Node
class_name WeaponManager;

var arsenal : Array[Weapon];

var current_weapon : Weapon;
@export var weapon_socket : Node3D;
@export var arms_animation_player : AnimationPlayer;

func _ready() -> void:
	if not arsenal.is_empty():
		set_current_weapon(arsenal[0]);
	
	Global.change_weapon.connect(change_weapon_from_inventory);
	
	update_weapons();

func update_weapons() -> void:
	arsenal.clear()
	
	for child in weapon_socket.get_children():
		if child is Weapon:
			child.visible = false;
			child.arms_animation_player = arms_animation_player;
			arsenal.append(child);
	
	set_current_weapon(arsenal[0]);

func _process(_delta: float) -> void:
	if Global.player_inventory.visible:
		return;
	
	change_weapon();
	
	if Input.is_action_pressed("MB_LEFT"):
		if is_instance_valid(current_weapon):
			current_weapon.fire_weapon();
	
	if Input.is_action_pressed("KEY_R"):
		if is_instance_valid(current_weapon):
			current_weapon.reload_weapon();
	
	if Input.is_action_just_pressed("KEY_F"):
		if is_instance_valid(current_weapon):
			current_weapon.inspect();

var can_change_weapon : bool = true;

func change_weapon() -> void:
	for i in range(1, 10):
		var key := KEY_0 + i;
		if Input.is_key_pressed(key):
			var index : int = (i - 1);
			
			if index < arsenal.size():
				set_current_weapon(arsenal[index]);

func change_weapon_from_inventory(weapon_name : String) -> void:
	for weapon in arsenal:
		if weapon.weapon_id == weapon_name:
			set_current_weapon(weapon);
			break;

func set_current_weapon(weapon : Weapon) -> void:
	if not can_change_weapon: return;
	if not is_instance_valid(weapon): return;
	
	if weapon == current_weapon: return;
	
	var last_weapon : Weapon = current_weapon;
	
	if is_instance_valid(last_weapon):
		can_change_weapon = false;
		await last_weapon.holster();
	
	current_weapon = weapon;
	
	await current_weapon.draw_weapon();
	
	can_change_weapon = true;
