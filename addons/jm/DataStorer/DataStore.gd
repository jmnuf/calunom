extends Resource
class_name DataStore

signal error(message)

signal deleted_dataset(name, dtset)
signal created_dataset(name, dtset)

signal item_created(set_name, id, item)
signal item_updated(set_name, id, stock, changed)
signal item_overwrote(set_name, id, stock)
signal item_deleted(set_name, id, stock)

var push_errors:bool
var _datasets:Dictionary = {}


func _init(_push_errors:bool=true) -> void:
	push_errors = _push_errors


func dataset_exists(set_name:String) -> bool:
	return _datasets.has(set_name)


func dataset(set_name:String) -> DataSet:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't retrieve inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	return _datasets.get(set_name) as DataSet


func create_dataset(set_name:String, Model:GDScript, _push_errors:bool=push_errors) -> DataSet:
	if dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't create already existing DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	var dtset := DataSet.new(_push_errors)
	
	_datasets[set_name] = dtset
	
	dtset.connect("created", self, "_bubble_up_signal", [ [ "item_created", set_name ] ])
	dtset.connect("updated", self, "_bubble_up_signal", [ [ "item_updated", set_name ] ])
	dtset.connect("overwrote", self, "_bubble_up_signal", [ [ "item_overwrote", set_name ] ])
	dtset.connect("deleted", self, "_bubble_up_signal", [ [ "item_deleted", set_name ] ])
	dtset.connect("error", self, "_bubble_up_signal", [ [ "error", set_name ] ])
	
	emit_signal("created_dataset", set_name, dtset)
	
	return dtset


func delete_dataset(set_name:String) -> bool:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't delete inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	var dtset := dataset(set_name)
	
	_datasets.erase(set_name)
	
	emit_signal("deleted_dataset", set_name, dtset)
	
	return true


func clear_dataset(set_name:String) -> void:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't clear inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return
	
	dataset(set_name).clear()


func item_exists(set_name:String, id:String) -> bool:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't check for item existence in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	return dataset(set_name).exists(id)


func retrieve(set_name:String, id:String) -> DataStock:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't retrieve item in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	return dataset(set_name).retrieve(id)


func retrieve_property(set_name:String, id:String, property:String):
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't retrieve item property in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	return dataset(set_name).retrieve_property(id, property)


func create_item(set_name:String, id:String, data) -> DataStock:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't create item in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	return dataset(set_name).create(id, data)


func delete_item(set_name:String, id:String) -> bool:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't delete item in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	return dataset(set_name).delete(id)


func update_item(set_name:String, id:String, changes:Dictionary) -> bool:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't update item in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	return dataset(set_name).update(id, changes)


func update_item_property(set_name:String, id:String, property:String, value) -> bool:
	if not dataset_exists(set_name):
		var err:String = "InvalidSetName: Can't update item property in inexistent DataSet(%s)" % set_name
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	return dataset(set_name).update_property(id, property, value)


func override_item(set_name:String, id:String, data) -> bool:
	if not dataset_exists(set_name):
		return false
	
	return dataset(set_name).override(id, data)



func _bubble_up_signal(a, b=null, c=null, d=null) -> void:
	var params:Array
	if d != null:
		params = [ d[0], d[1], c, b, a ]
	elif c != null:
		params = [ c[0], c[1], b, a ]
	else:
		if b[0] == "error":
			var err:String = a
			if err.find("\n") != -1: err = "%s\nWithin DataSet(%s)" % [a, b[1]]
			else: err = "%s within DataSet(%s)" % [a, b[1]]
			params = [ b[0], err ]
		else:
			params = [ b[0], b[1], a ]
	
	callv("emit_signal", params)

