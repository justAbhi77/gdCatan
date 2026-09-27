
class_name gdCatanHelper
extends Node

# Mutates Array in place
static func seeded_shuffle(array: Array, in_seed: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = in_seed

	for i in range(array.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)

		var temp = array[i]
		array[i] = array[j]
		array[j] = temp

	return array

