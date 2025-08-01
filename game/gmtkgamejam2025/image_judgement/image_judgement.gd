extends Node

const NO_TRAIT_COLOR: Color = Color(1, 1, 1, 0)

enum Trait {
	NONE = -999,
	PERSON_1 = -5,
	PERSON_2 = -4,
	PERSON_3 = -3,
	PERSON_4 = -2,
	PERSON_5 = -1,
	BALD = 0,
	HAIR = 1,
	FISH = 2,
	EX_PARTNER = 3,
	CELEB = 4,
	COOL = 5,
	RAINY = 6,
	SUNNY = 7,
	SAD = 8,
	HAPPY = 9,
	FRIENDS = 10,
}

@export var trait_colors: Dictionary[Trait, Color]

func compare_file_to_desired(file: File, desired_judgement: DesiredJudgement) -> void:
	pass

# Returns a dictionary of various info about the file
# Keys: 
# - "traits": another dictionary, where the keys are Traits, and the values are simple integers (a count of the number of pixels that have that trait)
# - "modified_count": an integer, counting the number of pixels that have changed
func get_file_info(file: File) -> Dictionary:
	var info_dict: Dictionary = {}
	
	var traits: Dictionary[Trait, int]
	var trait_texture: Texture = file.trait_texture
	var trait_image: Image = trait_texture.get_image()
	for x in trait_image.get_size().x:
		for y in trait_image.get_size().y:
			var trait_color: Color = trait_image.get_pixel(x, y)
			
			var trait_type: Trait = get_trait_from_color(trait_color)
			if traits.has(trait_type):
				traits[trait_type] += 1
			else:
				traits[trait_type] = 1
	
	info_dict["traits"] = traits
	info_dict["modified_count"] = file.modified_count
	
	return info_dict

func get_trait_from_color(color: Color) -> Trait:
	for key in trait_colors.keys():
		if color.is_equal_approx(trait_colors[key]):
			return key
	
	return Trait.NONE
