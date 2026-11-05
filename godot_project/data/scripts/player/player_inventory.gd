extends Control
class_name PlayerInventory;

var max_slots : int = 8;
var inventory : Inventory = Inventory.new(9, 6);
const INVENTORY_SLOT_SIZE : int = 64;

var slots : Dictionary[Vector2i, ColorRect];

@export var pre_inventory_item_gui : PackedScene;

var item_selected : InventoryItemGui;

# Item drag
signal on_item_drag;
var last_drag_position : Vector2i;
var current_drag_position : Vector2i;
var drag_offset : Vector2i;

var inventory_scale : Vector2 = Vector2(1.0, 1.0);

var save_item_position : Vector2i;
var tween_anim : Tween;


func _init() -> void:
	Global.player_inventory = self;


func _ready() -> void:
	setup()
	create_inventory_background()

	visible = false
	set_hide()

	inventory.slot_state_changed.connect(slot_state_changed)

	var mauser_c96 : InventoryItemGui = create_item(
		"mauser_c96",
		2,
		1,
		3
	)

	mauser_c96.set_item_model(
		load("res://data/models/weapons/mauser_c96/mauser_c96.glb"),
		Vector3(-0.15, -0.06, 0.0),
		Vector3(0, -90, 0)
	)

	for x in 5:
		var glock : InventoryItemGui = create_item(
			"glock_17",
			2,
			1,
			3
		)

		glock.set_item_model(
			load("res://data/models/weapons/glock_17/glock_17.glb"),
			Vector3(-0.07, -0.025, 0.0),
			Vector3(0, -90, 0)
		)


func set_hide() -> void:
	if is_instance_valid(tween_anim):
		tween_anim.kill()

	tween_anim = create_tween()

	set_anchors_preset(Control.PRESET_CENTER)

	pivot_offset_ratio = Vector2(0.5, 0.5)

	tween_anim.tween_property(
		self,
		"inventory_scale:x",
		0.0,
		0.3
	).set_trans(Tween.TRANS_ELASTIC)

	tween_anim.parallel().tween_property(
		self,
		"inventory_scale:y",
		0.0,
		0.5
	).set_trans(Tween.TRANS_ELASTIC)

	tween_anim.tween_callback(func(): visible = false)


func set_unhide() -> void:
	visible = true

	set_anchors_preset(Control.PRESET_CENTER_LEFT)

	pivot_offset_ratio = Vector2(0.5, 0.5)

	if is_instance_valid(tween_anim):
		tween_anim.kill()

	tween_anim = create_tween()

	tween_anim.tween_property(
		self,
		"inventory_scale:x",
		1.0,
		0.3
	).set_trans(Tween.TRANS_ELASTIC)

	tween_anim.parallel().tween_property(
		self,
		"inventory_scale:y",
		1.0,
		0.3
	).set_trans(Tween.TRANS_ELASTIC)


func drag_item() -> void:
	if Input.is_action_pressed("MB_LEFT"):
		if item_selected == null:
			for item in get_children():
				if item is InventoryItemGui and item.mouse_hover:
					if item.current_state == item.STATES.DRAG:
						continue

					last_drag_position = get_inventory_slot()
					current_drag_position = last_drag_position
					drag_offset = get_local_mouse_position() - item.position

					item.current_state = item.STATES.DRAG

					clear_item(item)

					save_item_position = Vector2i(item.position)
					item_selected = item

					break

	else:
		if Input.is_action_just_released("MB_LEFT"):
			if item_selected != null:
				var dragged_item : InventoryItemGui = item_selected
				var original_position := Vector2(save_item_position)
				var target_position := get_position_in_grid(dragged_item.position)

				item_selected = null

				if not is_free(target_position, dragged_item.inventory_item):
					occupy_item_raw(
						save_item_position / INVENTORY_SLOT_SIZE,
						dragged_item.columns,
						dragged_item.rows
					)

					var start_position := dragged_item.position

					var tween := create_tween()

					tween.tween_method(
						func(value: float) -> void:
							if is_instance_valid(dragged_item):
								dragged_item.position = start_position + Vector2(
									[-3, 3].pick_random() * value,
									[-3, 3].pick_random() * value
								),
						1.0,
						0.0,
						0.3
					)

					tween.tween_property(
						dragged_item,
						"position",
						original_position,
						0.2
					).set_trans(Tween.TRANS_CUBIC)

					tween.tween_callback(
						func() -> void:
							if is_instance_valid(dragged_item):
								dragged_item.position = original_position
								dragged_item.current_state = dragged_item.STATES.RELEASED
					)

				else:
					occupy_item_raw(
						target_position,
						dragged_item.columns,
						dragged_item.rows
					)

					dragged_item.current_state = dragged_item.STATES.RELEASED

	if item_selected != null:
		if is_free(
			get_position_in_grid(item_selected.position),
			item_selected.inventory_item
		):
			item_selected.change_background_color(
				item_selected.colors[inventory.SlotState.FREE]
			)
		else:
			item_selected.change_background_color(
				item_selected.colors[inventory.SlotState.OCCUPIED]
			)

		var pos : Vector2 = get_local_mouse_position() - Vector2(drag_offset)

		pos.x = round(pos.x / INVENTORY_SLOT_SIZE) * INVENTORY_SLOT_SIZE
		pos.y = round(pos.y / INVENTORY_SLOT_SIZE) * INVENTORY_SLOT_SIZE

		item_selected.position = pos
		current_drag_position = get_position_in_grid(pos)

	if current_drag_position != last_drag_position:
		AudioPlayer.play(
			load("res://data/sounds/inventory/drag.ogg"),
			Vector3.ZERO,
			0.8,
			true,
			true
		)

		last_drag_position = current_drag_position

		on_item_drag.emit()


func get_position_in_grid(_pos: Vector2) -> Vector2i:
	return Vector2i(
		roundi(_pos.x / INVENTORY_SLOT_SIZE),
		roundi(_pos.y / INVENTORY_SLOT_SIZE)
	)


func _process(_delta: float) -> void:
	drag_item()
	toggle()

	Debug.draw_string("Inventory Slot", get_inventory_slot())

	update_inventory_scale()


func update_inventory_scale() -> void:
	var viewport_size := get_viewport_rect().size
	var uniform_scale := viewport_size.y / 800.0

	scale = Vector2.ONE * uniform_scale * inventory_scale

	set_anchors_preset(Control.PRESET_CENTER_LEFT)

	custom_minimum_size = Vector2i(
		inventory.columns * INVENTORY_SLOT_SIZE,
		inventory.rows * INVENTORY_SLOT_SIZE
	)


func create_item(_name : String, _columns : int, _rows : int, _id : int) -> InventoryItemGui:
	var _item : InventoryItemGui = pre_inventory_item_gui.instantiate()

	_item.item_name = _name
	_item.columns = _columns
	_item.rows = _rows
	_item.item_id = _id

	add_child(_item)

	place_item(_item)

	return _item


func occupy_item(_item : InventoryItemGui) -> void:
	if not is_instance_valid(_item):
		return

	occupy_item_raw(
		get_position_in_grid(_item.position),
		_item.inventory_item.columms,
		_item.inventory_item.rows
	)


func occupy_item_raw(_position : Vector2i, _columns : int, _rows : int) -> void:
	for x in _columns:
		for y in _rows:
			var slot_position := _position + Vector2i(x, y)

			inventory.change_slot_state(
				slot_position,
				inventory.SlotState.OCCUPIED
			)


func place_item(_item : InventoryItemGui, _position : Vector2i = Vector2i.ZERO) -> void:
	var target_position := _position

	if not is_free(target_position, _item.inventory_item):
		target_position = Vector2i(-1, -1)

		for y in inventory.rows:
			for x in inventory.columns:
				var pos := Vector2i(x, y)

				if is_free(pos, _item.inventory_item):
					target_position = pos
					break

			if target_position != Vector2i(-1, -1):
				break

	if target_position == Vector2i(-1, -1):
		_item.queue_free()
		return

	_item.position = Vector2(target_position * INVENTORY_SLOT_SIZE)

	occupy_item_raw(
		target_position,
		_item.inventory_item.columms,
		_item.inventory_item.rows
	)


func clear_item(_item : InventoryItemGui) -> void:
	var pos := get_position_in_grid(_item.position)

	for x in _item.inventory_item.columms:
		for y in _item.inventory_item.rows:
			inventory.change_slot_state(
				pos + Vector2i(x, y),
				inventory.SlotState.FREE
			)


func setup() -> void:
	if not is_instance_valid(inventory):
		return

	for x in range(inventory.columns):
		for y in range(inventory.rows):
			pass


func toggle() -> void:
	if Input.is_action_just_pressed("inventory"):
		Global.inventory_is_visible = visible

		if not visible:
			set_unhide()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			set_hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func create_inventory_background() -> void:
	var padding : int = 1
	var background_padding : int = 2

	var color_rect : ColorRect = ColorRect.new()

	color_rect.name = "InventoryBackgroundLine"

	color_rect.size = Vector2(
		inventory.columns * INVENTORY_SLOT_SIZE + background_padding * 2,
		inventory.rows * INVENTORY_SLOT_SIZE + background_padding * 2
	)

	color_rect.rotation_degrees = -5
	color_rect.pivot_offset_ratio = Vector2(0.5, 0.5)

	color_rect.color = Color("453939ff")
	color_rect.position -= Vector2(background_padding, background_padding)

	add_child(color_rect)

	color_rect = ColorRect.new()

	color_rect.name = "InventoryBackground"

	color_rect.size = Vector2(
		inventory.columns * INVENTORY_SLOT_SIZE,
		inventory.rows * INVENTORY_SLOT_SIZE
	)

	color_rect.color = Color("#1B1B1B")

	add_child(color_rect)

	# Slots
	for x in range(inventory.columns):
		for y in range(inventory.rows):
			var slot_id : Vector2i = Vector2i(x, y)

			var pos : Vector2i = Vector2i(
				x * INVENTORY_SLOT_SIZE,
				y * INVENTORY_SLOT_SIZE
			)

			var slots_rect : ColorRect = ColorRect.new()

			slots_rect.name = "Slot" + str(slot_id)

			slots_rect.position = pos + Vector2i(padding, padding)

			slots_rect.size = Vector2(
				INVENTORY_SLOT_SIZE - padding * 2,
				INVENTORY_SLOT_SIZE - padding * 2
			)

			slots_rect.color = Color("111111ff")

			slots[slot_id] = slots_rect

			add_child(slots_rect)


func is_free(_pos : Vector2i, _item : InventoryItem) -> bool:
	for x in range(_item.columms):
		for y in range(_item.rows):
			var slot_id := _pos + Vector2i(x, y)

			if not inventory.has_slot(slot_id):
				return false

			if inventory.is_occupied(slot_id):
				return false

	return true


func get_inventory_slot() -> Vector2i:
	var mouse_pos : Vector2 = get_local_mouse_position()

	var slot_id : Vector2i = Vector2i(
		floori(mouse_pos.x / INVENTORY_SLOT_SIZE),
		floori(mouse_pos.y / INVENTORY_SLOT_SIZE)
	)

	if slot_id.x < 0 or slot_id.x >= inventory.columns:
		return Vector2i(-1, -1)

	if slot_id.y < 0 or slot_id.y >= inventory.rows:
		return Vector2i(-1, -1)

	return slot_id


func get_mouse_position_in_inventory() -> Vector2i:
	var mouse_pos : Vector2 = get_local_mouse_position()

	mouse_pos = Vector2i(
		floori(mouse_pos.x / INVENTORY_SLOT_SIZE),
		floori(mouse_pos.y / INVENTORY_SLOT_SIZE)
	)

	return mouse_pos


func slot_state_changed() -> void:
	for x in range(inventory.columns):
		for y in range(inventory.rows):
			var slot_id : Vector2i = Vector2i(x, y)

			if inventory.is_occupied(slot_id):
				pass
			else:
				pass


func recolor(slot_id : Vector2i, color : Color) -> void:
	if slot_id in slots:
		slots[slot_id].color = color
