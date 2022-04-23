extends Object

const Pair := preload("../pair.gd")


class InputIntf:
	extends Reference
	
	func _iter_init(_arg) -> bool:
		# note: Initialize iteration.
		return _iter_should_continue()
	
	func _iter_should_continue() -> bool:
		return false
	
	func _iter_next(_arg) -> bool:
		# note: Step iteration.
		return _iter_should_continue()
	
	func _iter_get(_arg):
		return null


class InputArray:
	extends InputIntf
	
	var _array: Array
	var _current_index: int
	
	func _init(array: Array) -> void:
		_array = array
	
	func _iter_init(_arg) -> bool:
		_current_index = 0
		return _iter_should_continue()
	
	func _iter_should_continue() -> bool:
		return _current_index < _array.size()
	
	func _iter_next(_arg) -> bool:
		_current_index += 1
		return _iter_should_continue()
	
	func _iter_get(_arg):
		return _array[_current_index]


class InputDictionary:
	extends InputArray
	
	func _init(dictionary: Dictionary).(_dictionary_to_array(dictionary)) -> void:
		pass
	
	func _dictionary_to_array(dictionary: Dictionary) -> Array:
		var result := []
		for key in dictionary:
			result.push_back(Pair.new(key, dictionary[key]))
		return result


class InputRemoveIntf:
	extends Reference
	
	func _iter_init(_arg) -> bool:
		# note: Initialize iteration.
		return _iter_should_continue()
	
	func _iter_should_continue() -> bool:
		return false
	
	func _iter_next(_arg) -> bool:
		# note: Step iteration.
		return _iter_should_continue()
	
	func _iter_get(_arg):
		return null
	
	func flag() -> void:
		pass
	
	func remove_flagged() -> void:
		pass


class InputRemoveArray:
	extends InputRemoveIntf
	
	var _array: Array
	var _current_index: int
	var _flagged_indices: PoolIntArray
	
	func _init(array: Array) -> void:
		_array = array

	func _iter_init(_arg) -> bool:
		_current_index = 0
		_flagged_indices = PoolIntArray()
		return _iter_should_continue()
	
	func _iter_should_continue() -> bool:
		return _current_index < _array.size()
	
	func _iter_next(_arg) -> bool:
		_current_index += 1
		return _iter_should_continue()
	
	func _iter_get(_arg):
		return _array[_current_index]
	
	func flag() -> void:
		_flagged_indices.push_back(_current_index)
	
	func remove_flagged() -> void:
		for i in range(_flagged_indices.size() - 1, -1, -1):
			_array.remove(_flagged_indices[i])


class InputRemoveDictionary:
	extends InputRemoveIntf
	
	var _dictionary: Dictionary
	var _keys: Array
	var _current_index: int
	var _flagged_keys: Array
	
	func _init(dictionary: Dictionary) -> void:
		_dictionary = dictionary
	
	func _iter_init(_arg) -> bool:
		_current_index = 0
		_keys = _dictionary.keys()
		_flagged_keys = []
		return _iter_should_continue()
	
	func _iter_should_continue() -> bool:
		return _current_index < _keys.size()
	
	func _iter_next(_arg) -> bool:
		_current_index += 1
		return _iter_should_continue()
	
	func _iter_get(_arg):
		return Pair.new(_keys[_current_index], _dictionary[_keys[_current_index]])
	
	func flag() -> void:
		_flagged_keys.push_back(_keys[_current_index])
	
	func remove_flagged() -> void:
		for flagged_key in _flagged_keys:
			_dictionary.erase(flagged_key)


class OutputIntf:
	extends Reference
	
	func write(_value) -> void:
		pass


class OutputArray:
	extends OutputIntf
	
	enum Hint {
		NONE = 0,
		PUSH_FRONT = 1,
		PUSH_BACK = 2,
	}
	
	var _array: Array
	var _function: FuncRef
	
	func _init(array: Array, hint: int = Hint.NONE) -> void:
		_array = array
		match hint:
			Hint.PUSH_FRONT:
				_function = funcref(self, "_push_front")
			_:
				_function = funcref(self, "_push_back")
	
	func write(value) -> void:
		_function.call_func(value)
	
	func _push_front(value) -> void:
		_array.push_front(value)
	
	func _push_back(value) -> void:
		_array.push_back(value)


class OutputDictionary:
	extends OutputIntf
	
	const Pair := preload("../pair.gd")
	
	var _dictionary: Dictionary
	
	func _init(dictionary: Dictionary) -> void:
		_dictionary = dictionary
	
	func write(pair: Pair) -> void:
		_dictionary[pair.key] = pair.value


static func input(container) -> InputIntf:
	match typeof(container):
		TYPE_ARRAY:
			return InputArray.new(container)
		TYPE_DICTIONARY:
			return InputDictionary.new(container)
	return InputIntf.new()


static func input_remove(container) -> InputRemoveIntf:
	match typeof(container):
		TYPE_ARRAY:
			return InputRemoveArray.new(container)
		TYPE_DICTIONARY:
			return InputRemoveDictionary.new(container)
	return InputRemoveIntf.new()


static func output(container, hint: int) -> OutputIntf:
	match typeof(container):
		TYPE_ARRAY:
			return OutputArray.new(container, hint)
		TYPE_DICTIONARY:
			return OutputDictionary.new(container)
	return OutputIntf.new()
