extends Resource
class_name DataStock


func load(data:Dictionary) -> bool:
	var required = required_properties()
	var data_keys = data.keys()
	for property in required:
		if not data_keys.has(property):
			return false
	
	for k in data_keys: set(k, data[k])
	return true


func has_property(property:String) -> bool:
	return get_properties().has(property)


func get_properties() -> PoolStringArray:
	return PoolStringArray(inst2dict(self).keys())


static func required_properties() -> PoolStringArray:
	return PoolStringArray()


static func typeof_named(obj) -> String:
	var type = typeof(obj)
	
	var builtin_type_names = [
		"null", "bool", "int",
		"float", "String", "Vector2",
		"Rect2", "Vector3", "Transform2D",
		"Plane", "Quat", "AABB",
		"Basis", "Transform", "Color",
		"NodePath", "RID", "Object",
		"Dictionary", "Array", "PoolByteArray",
		"PoolIntArray", "PoolRealArray", "PoolStringArray",
		"PoolVector2Array", "PoolVector3Array", "PoolColorArray"
	]
	
	var type_name:String = "unknown"
	
	if type >= 0 & type < builtin_type_names.size():
		var name = builtin_type_names[type]
		if name != null:
			if name == "nil": name = "unknown"
			type_name = name
	
	return type_name


static func maybe_changable(oval, nval) -> String:
	var otype = typeof_named(oval)
	var ntype = typeof_named(nval)
	
	if otype != "null" and (otype != "unknown" and ntype != "unknown"):
		if otype == "Object" and otype == ntype:
			var oCls = oval.get_class()
			var nCls = nval.get_class()
			if oCls != nCls:
				var err:String = "InvalidType: Expected %s class instance but got a % instance" % [oCls, nCls]
				return err
		elif (ntype != "null" and otype != "Object") or (ntype != "Object" and otype != "null"):
			if ntype != otype:
				var err:String = "InvalidType: Expected %s type but got %s" % [otype, ntype]
				return err
	
	return ""

