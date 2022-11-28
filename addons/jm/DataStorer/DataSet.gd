extends DataStock
class_name DataSet

signal error(message)

signal created(id, stock)
signal updated(id, stock, changed)
signal overwrote(id, stock)
signal deleted(id, stock)

var _incremental_id:int = 0
var push_errors:bool
var _data:Dictionary = {}
var Model:GDScript = DataStock as GDScript

func _init(_push_errors:bool=true) -> void:
	push_errors = _push_errors


func exists(id:String) -> bool:
	return _data.has(id)


func retrieve(id:String) -> DataStock:
	if not exists(id):
		var err:String = "InvalidID(%s): ID doesn't exist in Set" % id
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	return _data[id]


func retrieve_property(id:String, property:String):
	var stock := retrieve(id)
	if not stock:
		return null
	
	if not stock.has_property(property):
		var err:String = "InvalidKey: Attempting to get inexistent property(%s)" % property
		if push_errors: push_error(err)
		emit_signal("error", err)
	
	return stock.get(property)


func create(id:String, data) -> DataStock:
	if exists(id):
		var err:String = "InvalidID: Can't create data, ID(%s) already exists in Set" % id
		if push_errors: push_error(err)
		emit_signal("error", err)
		return null
	
	var stock:DataStock
	
	if typeof(data) != TYPE_DICTIONARY:
		if data is Model:
			stock = data
		else:
			var err:String = "InvalidType: Expected a Dictionary or Model instance but got a %s" % DataStock.typeof_named(data)
			if push_errors: push_error(err)
			emit_signal("error", err)
			return null
	else:
		stock = Model.new()
		if not stock.load(data):
			var err:String = "ParseError: Failed to create stock from data: %s" % JSON.print(data)
			if push_errors: push_error(err)
			emit_signal("error", err)
			return null
	
	_data[id] = stock
	
	emit_signal("created", id, stock)
	
	return stock


func update(id:String, changes:Dictionary) -> bool:
	if not exists(id):
		var err:String = "InvalidID: Can't update inexistent Set ID(%s)" % id
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	var stock := retrieve(id)
	var stock_keys := stock.get_properties()
	var errors := PoolStringArray()
	
	var changed_keys := PoolStringArray()
	
	for k in changes.keys():
		if not stock_keys.has(k):
			var err:String = "InvalidKey: Attempting to set inexistent property(%s)" % k
			errors.append(err)
			continue
		
		var oval = stock.get(k)
		var nval = changes.get(k)
		
		var err:String = DataStock.maybe_changable(oval, nval)
		if not err.empty():
			errors.append(err)
			continue
		
		stock.set(k, nval)
		changed_keys.append(k)
	
	if errors.size() > 0:
		var err = errors.join("\n")
		if push_errors: push_error(err)
		emit_signal("error", err)
		# If all changes failed we return false
		if errors.size() == changes.keys().size():
			return false
	
	emit_signal("updated", id, stock, changed_keys)
	
	# Return true if at least one thing changed
	return true


func update_property(id:String, property:String, value) -> bool:
	if not exists(id):
		var err:String = "InvalidID: Can't update inexistent Set ID(%s)" % id
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	var stock := retrieve(id)
	var base_prop = property.substr(0, property.find(":")) if property.find(":") != -1 else property
	if not stock.has_property(base_prop):
		var err:String = "InvalidKey: Can't update inexistent property %s of Stock(%s)" % [base_prop, id]
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	var err:String = DataStock.maybe_changable(stock.get_indexed(property), value)
	if not err.empty():
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	stock.set_indexed(property, value)
	
	emit_signal("updated", id, stock, PoolStringArray([base_prop]))
	
	return true


func override(id:String, data) -> bool:
	if not exists(id):
		var err:String = "InvalidID: Can't override inexistent Set ID(%s)" % id
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	var stock:DataStock
	
	if typeof(data) != TYPE_DICTIONARY:
		if data is Model:
			stock = data
		else:
			var err:String = "InvalidType: Expected a Dictionary or Model instance but got a %s" % DataStock.typeof_named(data)
			if push_errors: push_error(err)
			emit_signal("error", err)
			return false
	else:
		stock = Model.new()
		if not stock.load(data):
			var err:String = "ParseError: Failed to create stock from data: %s" % JSON.print(data)
			if push_errors: push_error(err)
			emit_signal("error", err)
			return false
	
	_data[id] = stock
	
	emit_signal("overwrote", id, stock)
	emit_signal("updated", id, stock.get_properties())
	
	return true


func delete(id:String) -> bool:
	if not exists(id):
		var err:String = "InvalidID: Can't delete inexistent Set ID(%s)" % id
		if push_errors: push_error(err)
		emit_signal("error", err)
		return false
	
	var stock = retrieve(id)
	_data.erase(id)
	
	emit_signal("deleted", id, stock)
	
	return true


func clear() -> void:
	_data.clear()

