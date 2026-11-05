
class_name Inventory;

var columns: int = 10;
var rows: int = 6;

enum SlotState {
	FREE,
	OCCUPIED
}

var slots : Dictionary[Vector2i, SlotState];

signal slot_state_changed;

func _init(_colums : int, _rows : int) -> void:
	self.columns = _colums;
	self.rows = _rows;
	
	setup();

func setup() -> void:
	for x in range(columns):
		for y in range(rows):
			slots[Vector2i(x, y)] = SlotState.FREE;

func change_slot_state(slot_psotion : Vector2i, state : SlotState) -> void:
	if slot_psotion in slots:
		slots[slot_psotion] = state;
		
		slot_state_changed.emit();

func clear() -> void:
	for slot in slots:
		slots[slot] = SlotState.FREE;
	
	slot_state_changed.emit();

func is_occupied(slot_id: Vector2i) -> bool:
	if has_slot(slot_id):
		if slots[slot_id] == SlotState.FREE:
			return false;
		
		if slots[slot_id] == SlotState.OCCUPIED:
			return true;
	
	return false;

func has_slot(slot_id : Vector2i) -> bool:
	if slot_id in slots:
		return true;
	else:
		return false;
