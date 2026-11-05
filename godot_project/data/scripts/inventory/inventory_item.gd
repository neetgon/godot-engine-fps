class_name InventoryItem;

var name : String;
var columms : int;
var rows : int;
var id : int;

func _init(_name : String, _columms : int, _rows : int, _id : int) -> void:
		self.name = _name;
		self.columms = _columms;
		self.rows = _rows;
		self.id = _id;
