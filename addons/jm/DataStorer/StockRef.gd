extends DataStock

var _store:DataStore
var _dataset:String
var _id:String

func _init(store:DataStore, dataset:String, id:String) -> void:
	_store = store
	_dataset = dataset
	_id = id


func switch_ref(id:String, dataset:String=_dataset, store:DataStore=_store) -> void:
	_id = id
	_dataset = dataset
	_store = store


func valid_ref() -> bool:
	if not _store: return false
	if not _store.dataset_exists(_dataset): return false
	return _store.item_exists(_dataset, _id)


func retrieve() -> DataStock:
	return _store.retrieve(_dataset, _id)


func _get(property: String):
	return _store.retrieve_property(_dataset, _id, property)

func _set(property: String, value) -> bool:
	_store.update_item_property(_dataset, _id, property, value)
	return true
