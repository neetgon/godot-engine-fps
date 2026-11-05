extends Control
class_name InventoryItemGui;

@export var item_dummy : Node3D;

@export var item_name : String = "Unkwnow";
@export_range(1, 9, 1) var columns : int = 1;
@export_range(1, 9, 1) var rows : int = 1;
@export var item_id : int;

var inventory_item : InventoryItem;

@export var background : ColorRect;
@export var item_texture : TextureRect;

@export var selected : ColorRect;

enum STATES {
	DRAG=1,
	RELEASED=2,
}

var current_state : STATES = STATES.RELEASED;

var mouse_hover : bool = false;

var colors : Dictionary[Inventory.SlotState, Color] = {
	Inventory.SlotState.OCCUPIED: Color.DARK_RED,
	Inventory.SlotState.FREE: Color.SEA_GREEN,
}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT);
	
	inventory_item = InventoryItem.new(
		item_name,
		columns,
		rows,
		item_id
	)
	
	custom_minimum_size = Vector2i(
		columns * Global.player_inventory.INVENTORY_SLOT_SIZE,
		rows * Global.player_inventory.INVENTORY_SLOT_SIZE
	);
	
	size = Vector2i(
		columns * Global.player_inventory.INVENTORY_SLOT_SIZE,
		rows * Global.player_inventory.INVENTORY_SLOT_SIZE
	);
	
	z_index = 100;

func set_item_model(scene : PackedScene, pos : Vector3 = Vector3.ZERO, rot : Vector3 = Vector3.ZERO) -> void:
	for c in item_dummy.get_children():
		c.queue_free();
	
	var item : Node3D = scene.instantiate();
	item.position = pos;
	item.rotation_degrees = rot;
	
	item_dummy.add_child(item);

func _process(_delta: float) -> void:
	var target_rotation : Vector3 = Vector3.ZERO;
	var target_position : Vector3 = Vector3(0, 0, -0.3);
	
	background.color = background.color.lerp(
		Color("ffffff1e"),
		_delta * 5.0
	)
	selected.visible = false;
	
	match current_state:
		STATES.RELEASED:
			if mouse_hover:
				if Input.is_action_just_pressed("MB_RIGHT"):
					Global.change_weapon.emit(
						item_name
					);
				
				selected.visible = true;
				
				var mouse_local_pos := get_local_mouse_position()
				var rotation_sense := 0.3
				
				var center := item_texture.position + item_texture.size / 2.0
				
				target_rotation.y = -(center.x - mouse_local_pos.x) * rotation_sense
				target_rotation.x = -(center.y - mouse_local_pos.y) * rotation_sense
				
				background.color = background.color.lerp(
					Color("5d3024c8"),
					_delta * 8.0
				)
				
				target_position.z = -0.25;
	
	var weight := 1.0 - exp(-5.0 * _delta)
	
	item_dummy.position = item_dummy.position.move_toward(
		target_position,
		0.5 * _delta
	);
	
	item_dummy.rotation_degrees.x = lerpf(
		item_dummy.rotation_degrees.x,
		target_rotation.x,
		weight
	)
	
	item_dummy.rotation_degrees.y = lerpf(
		item_dummy.rotation_degrees.y,
		target_rotation.y,
		weight
	)
	
	item_dummy.rotation_degrees.y = clampf(
		item_dummy.rotation_degrees.y,
		-15, 15
	);

func change_background_color(_color : Color) -> void:
	background.color = _color;

var animation_tween : Tween;

func _on_mouse_entered() -> void:
	mouse_hover = true;

func _on_mouse_exited() -> void:
	mouse_hover = false;
