extends Node

const Default := preload("detail/default_implementation.gd")
const Iterator := preload("detail/iterator.gd")


# note: Type definitions.
# -----------------------

# unary_prdicate
# A function that takes a single element of a container and returns a value testable as bool.
# Additionally, it takes an Array argument that can be 
# used to supply it with data required for the evaluation.
# 
# Example:
# func is_valid_file(filepath: String, args: Array) -> bool:
#     var valid_extension := args[0] as String
#     return filepaht.endswith(valid_extension)

# binary_predicate
# A function that takes two elements of a container and returns a value testable as bool.
# Additionally, it takes an Array argument that can be
# used to supply it with data required for the evaluation.
#
# Example:
# func matching_enemy_type(left: Enemy, right: Enemy, _args: Array) -> bool:
#     return left.type == right.type

# unary_function
# A function that gets applied to a single element of a container.
# Additionally, it takes an Array argument that can be
# used to supply it with data required for the function.
#
# Example:
# func print_username(user: User, _args: Array) -> void:
#     print(user.username)

# unary_operation
# A function that gets applied to a single element of a container and returns a value.
# Additionally, it takes an Array argument that can be
# used to supply it with data required for the function.
#
# Example:
# func string_to_clamped_float(string: String, args: Array) -> float:
#    var minimum := args[0] as float
#    var maximum := args[1] as float
#    return clamp(float(string), minimum, maximum)

# binary_operation
# A function that takes to values and returns a value.
# Additionally, it takes an Array argument that can be
# used to supply it with data required for the function.
#
# Example:
# func accumulate_attack_power(current: int, equipment: Equipment) -> int:
#     return current + equipment.attack_power

# comparator
# A function that takes two elements of a container and returns a value testable as bool.
# Additionally, it takes an Array argument that can be
# used to supply it with data required for the evaluation.
#
# Example:
# func greater_string(left: String, right: String, _args: Array) -> bool:
#     return left.casecmp_to(right) > -1

enum OutputHint {
	NONE = 0,
	PUSH_FRONT = 1,
	PUSH_BACK = 2,
}





# note: Non-modifying sequence operations.
# ----------------------------------------

func all_of(container, unary_predicate: FuncRef, args: Array = []) -> bool:
	"""Checks if unary_predicate returns true for all elements in container."""
	for element in Iterator.input(container):
		if not unary_predicate.call_func(element, args):
			return false
	return true


func any_of(container, unary_predicate: FuncRef, args: Array = []) -> bool:
	"""Checks if unary_predicate returns true for at least one elements in container."""
	for element in Iterator.input(container):
		if unary_predicate.call_func(element, args):
			return true
	return false


func none_of(container, unary_predicate: FuncRef, args: Array = []) -> bool:
	"""Checks if unary_predicate returns true for no elements in container."""
	for element in Iterator.input(container):
		if unary_predicate.call_func(element, args):
			return false
	return true


func for_each(container, unary_function: FuncRef, args: Array = []) -> void:
	"""Applies the given function to every element in container."""
	for element in Iterator.input(container):
		unary_function.call_func(element, args)


func count(container, value) -> int:
	"""Returns the number of elements in container that are equal to value."""
	var result := 0
	for element in Iterator.input(container):
		if element == value:
			result += 1
	return result


func count_if(container, unary_predicate: FuncRef, args: Array = []) -> int:
	"""Returns the number of elements in container for which unary_predicate returns true."""
	var result := 0
	for element in Iterator.input(container):
		if unary_predicate.call_func(element, args):
			result += 1
	return result


func find(container, value):
	"""Returns the first element in container equal to value or null if no equal is found."""
	for element in Iterator.input(container):
		if element == value:
			return element
	return null


func find_if(container, unary_predicate: FuncRef, args: Array = []):
	"""Returns the first element in container for which unary_predicate retruns true
	or null if no element satisfies the criteria."""
	for element in Iterator.input(container):
		if unary_predicate.call_func(element, args):
			return element
	return null


func find_if_not(container, unary_predicate: FuncRef, args: Array = []):
	"""Returns the first element in container for which unary_predicate returns false
	or null if all elements satisfy the criteria."""
	for element in Iterator.input(container):
		if not unary_predicate.call_func(element, args):
			return element
	return null





# note: Modifying sequence operations.
# ------------------------------------

func copy(input, output, hint: int = OutputHint.NONE) -> void:
	"""Copies all elements in input to output."""
	var output_iter: Iterator.OutputIntf = Iterator.output(output, hint)
	for element in Iterator.input(input):
		output_iter.write(element)


func copy_if(input, output, unary_predicate: FuncRef, args: Array = [],
		hint: int = OutputHint.NONE) -> void:
	"""Copies elements in input to output for which unary_predicate returns true."""
	var output_iter: Iterator.OutputIntf = Iterator.output(output, hint)
	for element in Iterator.input(input):
		if unary_predicate.call_func(element, args):
			output_iter.write(element)


func transform(input, output, unary_operation: FuncRef, args: Array = [],
		hint: int = OutputHint.NONE) -> void:
	"""Applies transform to each element in input and stores the result in output."""
	var output_iter: Iterator.OutputIntf = Iterator.output(output, hint)
	for element in Iterator.input(input):
		output_iter.write(unary_operation.call_func(element, args))


func remove(container, value) -> void:
	"""Removes all elements in container that are equal to value."""
	var iter: Iterator.InputRemoveIntf = Iterator.input_remove(container)
	for element in iter:
		if element == value:
			iter.flag()
	iter.remove_flagged()


func remove_if(container, unary_predicate: FuncRef, args: Array = []) -> void:
	"""Removes all elements in container for which unary_predicate returns true."""
	var iter: Iterator.InputRemoveIntf = Iterator.input_remove(container)
	for element in iter:
		if unary_predicate.call_func(element, args):
			iter.flag()
	iter.remove_flagged()


func remove_copy(input, output, value, hint: int = OutputHint.NONE) -> void:
	"""Copies elements from input to output, omitting elements that equal value."""
	var input_iter: Iterator.InputRemoveIntf = Iterator.input_remove(input)
	var output_iter: Iterator.OutputIntf = Iterator.output(output, hint)
	for element in input_iter:
		if element != value:
			input_iter.flag()
			output_iter.write(element)
	input_iter.remove_flagged()


func remove_copy_if(input, output, unary_predicate: FuncRef, args: Array = [],
		hint: int = OutputHint.NONE) -> void:
	"""Copies elements from input to output, omitting elements for which unary_predicate retruns true."""
	var input_iter: Iterator.InputRemoveIntf = Iterator.input_remove(input)
	var output_iter: Iterator.OutputIntf = Iterator.output(output, hint)
	for element in input_iter:
		if not unary_predicate.call_func(element, args):
			input_iter.flag()
			output_iter.write(element)
	input_iter.remove_flagged()


func unique(container, binary_predicate: FuncRef = funcref(Default, "equals"), args: Array = []) -> void:
	"""Eliminates all except the first of equivalent elements in contianer for which binary_predicate returns true.
	Each element is compared to all elements previously identified as unique.
	By default uses left == right to compare elements.
	Note: This function behaves differently in the C++ standard library.
	See: https://en.cppreference.com/w/cpp/algorithm/unique"""
	var iter: Iterator.InputRemoveIntf = Iterator.input_remove(container)
	var unique_elements := []
	for element in iter:
		var is_unique := true
		for unique_element in unique_elements:
			if binary_predicate.call_func(element, unique_element, args):
				is_unique = false
				break
		if is_unique:
			unique_elements.push_back(element)
		else:
			iter.flag()
	iter.remove_flagged()


func unique_copy(input, output, binary_predicate: FuncRef = funcref(Default, "equals"), args: Array = [],
		hint: int = OutputHint.NONE) -> void:
	"""Copies elements from input to output in such a way that there are no equal elements in output as compared by binary_predicate.
	By default uses left == right to compare elements."""
	var input_iter: Iterator.InputIntf = Iterator.input(input)
	var output_iter: Iterator.OutputIntf = Iterator.output(output, hint)
	var unique_elements := []
	for element in input_iter:
		var is_unique := true
		for unique_element in unique_elements:
			if binary_predicate.call_func(element, unique_element, args):
				is_unique = false
				break
		if is_unique:
			output_iter.write(element)
			unique_elements.push_back(element)





# note: Minimum/maximum operations.
# ---------------------------------

func max_element(container, comparator: FuncRef = funcref(Default, "greater_than"), args: Array = []):
	"""Finds the greates element in container.
	By default uses left > right to compare elements."""
	var iter: Iterator.InputIntf = Iterator.input(container)
	var largest = null
	for element in iter:
		largest = element
		break
	for element in iter:
		if comparator.call_func(element, largest, args):
			largest = element
	return largest


func min_element(container, comparator: FuncRef = funcref(Default, "lesser_than"), args: Array = []):
	"""Finds the smallest element in container.
	By default used left < right to compare elements."""
	var iter: Iterator.InputIntf = Iterator.input(container)
	var smallest = null
	for element in iter:
		smallest = element
		break
	for element in iter:
		if comparator.call_func(element, smallest, args):
			smallest = element
	return smallest





#note: Numeric operations.
# ------------------------

func accumulate(container, init, binary_operation: FuncRef = funcref(Default, "add"), args: Array = []):
	"""Computes the sum of the given value init and the elements in container.
	binary_operation is used to add the currently accumulated value with the current element.
	By default uses left + right to add elements.
	Note: binary_operation's first passed parameter is the accumulated value, second is the element."""
	var result = init
	for element in Iterator.input(container):
		result = binary_operation.call_func(result, element, args)
	return convert(result, typeof(init))
