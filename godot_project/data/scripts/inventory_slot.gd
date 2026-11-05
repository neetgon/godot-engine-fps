extends Control
class_name InventoryItemGui;

@export var item_dummy : Node3D;

@export var item_name : String = "Unkwnow";
@export_range(1, 9, 1) var columns : int = 1;
@export_range(1, 9, 1) var rows : int = 1;
@export var item_id : int;

var inventory_item : InventoryItem;

@export var background : ColorRect;

var colors : Dictionary[Inventory.SlotState, Color] = {
	Inventory.SlotState.OCCUPIED: Color.DARK_RED,
	Inventory.SlotState.FREE: Color.SEA_GREEN,
}

func _ready() -> void:
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

func _process(_delta: float) -> void:
	item_dummy.rotation.y = 0;

func change_background_color(_color : Color) -> void:
	background.color = _color;
