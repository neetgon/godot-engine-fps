extends Control
class_name PlayerInventory;

var max_slots : int = 8;
var inventory : Inventory = Inventory.new(6, 4);
const INVENTORY_SLOT_SIZE : int = 64;

var slots : Dictionary[Vector2i, ColorRect];

@export var inventory_item_gui : InventoryItemGui;

func _init() -> void:
	Global.player_inventory = self;

func _ready() -> void:
	setup();
	create_inventory_background();
	
	visible = false;
	
	inventory.slot_state_changed.connect(slot_state_changed);

func _process(_delta: float) -> void:
	toggle();
	change_slot_debug();
	movement();
	
	Debug.draw_string("Inventory Slot", get_inventory_slot());

func setup() -> void:
	# Verifica se o inventário existe
	if not is_instance_valid(inventory):
		return;
	
	# Cria os slots do inventário
	for x in range(inventory.columns):
		for y in range(inventory.rows):
			pass

func toggle() -> void:
	if Input.is_action_just_pressed("inventory"):
		visible = !visible;
		
		Global.inventory_is_visible = visible;
		
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func movement() -> void:
	var pos : Vector2i = get_mouse_position_in_inventory() * INVENTORY_SLOT_SIZE;
	inventory_item_gui.position = pos;
	
	if is_free(get_mouse_position_in_inventory(), inventory_item_gui.inventory_item):
		inventory_item_gui.change_background_color(
			inventory_item_gui.colors[Inventory.SlotState.FREE]
		)
	else:
		inventory_item_gui.change_background_color(
			inventory_item_gui.colors[Inventory.SlotState.OCCUPIED]
		)

func create_inventory_background() -> void:
	var color_rect : ColorRect = ColorRect.new();
	
	color_rect.name = "InventoryBackground";
	
	color_rect.size = Vector2(
		inventory.columns * INVENTORY_SLOT_SIZE,
		inventory.rows * INVENTORY_SLOT_SIZE
	)
	
	color_rect.modulate.a = 1.1;
	
	add_child(color_rect);
	
	# Slots
	for x in range(inventory.columns):
		for y in range(inventory.rows):
			var slot_id : Vector2i = Vector2i(x, y);
			
			var pos : Vector2i = Vector2i(
				x * INVENTORY_SLOT_SIZE, 
				y * INVENTORY_SLOT_SIZE
			);
			
			var slots_rect : ColorRect = ColorRect.new();
			slots_rect.name = "Slot" + str(slot_id);
			
			slots_rect.position = pos + Vector2i(1, 1);
			
			slots_rect.size = Vector2(
				INVENTORY_SLOT_SIZE-2,
				INVENTORY_SLOT_SIZE-2
			)
			
			slots_rect.color = Color.BLACK;
			
			slots[slot_id] = slots_rect;
			
			add_child(slots_rect);

func is_free(_pos : Vector2i, _item : InventoryItem) -> bool:
	for x in range(_item.columms):
		for y in range(_item.rows):
			var slot_id = _pos + Vector2i(x, y);
			
			if not inventory.has_slot(slot_id):
				return false;
			
			if inventory.is_occupied(slot_id):
				return false;
	
	return true;

func get_inventory_slot() -> Vector2i:
	var mouse_pos: Vector2 = get_local_mouse_position();
	
	var slot_id : Vector2i = Vector2i(
		floori(mouse_pos.x / INVENTORY_SLOT_SIZE),
		floori(mouse_pos.y / INVENTORY_SLOT_SIZE)
	)
	
	if slot_id.x < 0 or slot_id.x >= inventory.columns:
		return Vector2i(-1, -1);
	
	if slot_id.y < 0 or slot_id.y >= inventory.rows:
		return Vector2i(-1, -1);
	
	return slot_id;

func get_mouse_position_in_inventory() -> Vector2i:
	var mouse_pos: Vector2 = get_local_mouse_position();
	
	mouse_pos = Vector2i(
		floori(mouse_pos.x / INVENTORY_SLOT_SIZE),
		floori(mouse_pos.y / INVENTORY_SLOT_SIZE)
	)
	
	return mouse_pos;

func change_slot_debug() -> void:
	if not visible:
		return;
	
	if Input.is_action_just_pressed("MB_LEFT"):
		var slot_id : Vector2i = get_inventory_slot();
		
		if slot_id == Vector2i(-1, -1):
			return;
		
		if inventory.is_occupied(slot_id):
			print("SLOT OCUPADO");
		else:
			inventory.change_slot_state(slot_id, Inventory.SlotState.OCCUPIED);
	
	if Input.is_action_just_pressed("MB_RIGHT"):
		var slot_id : Vector2i = get_inventory_slot();
		
		if slot_id == Vector2i(-1, -1):
			return;
		
		if inventory.is_occupied(slot_id):
			inventory.change_slot_state(slot_id, Inventory.SlotState.FREE);
			print("SLOT VOLTOU A FICAR LIVRE");

func slot_state_changed() -> void:
	for x in range(inventory.columns):
		for y in range(inventory.rows):
			var slot_id : Vector2i = Vector2i(x, y);
			
			if inventory.is_occupied(slot_id):
				recolor(slot_id, Color.SEA_GREEN);
			else:
				recolor(slot_id, Color.BLACK);

func recolor(slot_id : Vector2i, color : Color) -> void:
	if slot_id in slots:
		slots[slot_id].color = color;
