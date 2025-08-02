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
	AVENGING_GUYS = 11,
}

@export var trait_colors: Dictionary[Trait, Color]
var color_hash_to_trait: Dictionary[int, Trait]

func _ready() -> void:
	generate_color_hash_dict()

func generate_color_hash_dict() -> void:
	for key in trait_colors:
		var color = trait_colors[key]
		color_hash_to_trait[color.to_rgba32()] = key

#func compare_file_to_desired(file: File, desired_judgement: DesiredJudgement) -> void:
	#pass

func compare_file_to_desired(file: File, desired_judgement: DesiredJudgement) -> Dictionary:
	var results := {}
	var file_info: Dictionary = get_file_info(file)
	var traits: Dictionary = file_info["traits"]
	var modified_count: int = file_info["modified_count"]
	
	if modified_count < desired_judgement.desired_modification.x: # Not modified enough
		pass 
	elif modified_count < desired_judgement.desired_modification.y: # Good modification
		pass
	else: # Too much modification
		pass
	
	var comments: String = ""
	
	for trait_type: Trait in desired_judgement.desired_traits:
		var desired_range: Vector2 = desired_judgement.desired_traits[trait_type]
		var submission_trait: int = traits.get_or_add(trait_type, 0)
		
		var new_comment: String = ""
		
		if modified_count < desired_judgement.desired_modification.x: # Not enough trait
			new_comment = desired_judgement.feedback_comments[trait_type][0]
		elif modified_count < desired_judgement.desired_modification.y: # Good amount
			pass
		else: # Too much trait
			new_comment = desired_judgement.feedback_comments[trait_type][1]
		
		comments += new_comment
	
	results["rating"] = randi_range(0, 10)
	results["comments"] = comments
	return results

# Returns a dictionary of various info about the file
# Keys: 
# - "traits": another dictionary, where the keys are Traits, and the values are simple integers (a count of the number of pixels that have that trait)
# - "modified_count": an integer, counting the number of pixels that have changed
func get_file_info(file: File) -> Dictionary:
	var info_dict: Dictionary = {}
	
	var traits: Dictionary[Trait, int]
	var trait_image: Image = file.trait_texture.get_image()
	for x in trait_image.get_size().x:
		for y in trait_image.get_size().y:
			var trait_color: Color = trait_image.get_pixel(x, y)
			
			var trait_type: Trait = get_trait_from_color(trait_color)
			traits[trait_type] = traits.get_or_add(trait_type, 0) + 1
	
	info_dict["traits"] = traits
	info_dict["modified_count"] = file.modified_count
	
	return info_dict

func get_trait_from_color(color: Color) -> Trait:
	var color_hash: int = color.to_rgba32()
	if color_hash_to_trait.has(color_hash):
		return color_hash_to_trait.get(color_hash)
	return Trait.NONE
