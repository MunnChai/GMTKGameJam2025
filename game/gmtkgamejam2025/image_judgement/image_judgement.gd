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
	DOG = 12,
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
	if file.file_type != "image":
		var results := {
			"rating": 0,
			"comments": "This is just a text file...",
		}
		return results
	
	var results := {}
	var file_info: Dictionary = get_file_info(file)
	var traits: Dictionary = file_info["traits"]
	var modified_count: int = file_info["modified_count"]
	
	var rating: int = 0
	var comments: String = ""
	
	if modified_count < desired_judgement.desired_modification.x: # Not modified enough
		comments += desired_judgement.modification_comments[0]
		return {
			"rating": rating,
			"comments": comments,
			"amount_paid": 0,
		}
	elif modified_count < desired_judgement.desired_modification.y: # Good modification
		comments += desired_judgement.modification_comments[1]
		rating += 2
	elif modified_count >= desired_judgement.desired_modification.y:
		comments += desired_judgement.modification_comments[2]
	
	if not comments.ends_with(" ") and comments != "":
		comments += " "
	
	var desired_traits: Dictionary = desired_judgement.desired_traits
	var feedback_comments: Dictionary = desired_judgement.feedback_comments
	var trait_weights: Dictionary = desired_judgement.trait_weights
	
	var completed_trait_weight: float = 0
	var total_trait_weight: float = 0
	for trait_type: Trait in desired_traits.keys():
		var desired_range: Vector2 = desired_traits[trait_type]
		var submission_trait_value: int = traits.get_or_add(trait_type, 0)
		
		var new_comment: String = ""
		total_trait_weight += trait_weights[trait_type]
		if submission_trait_value < desired_range.x: # Not enough trait
			new_comment = feedback_comments[trait_type][0]
		elif submission_trait_value < desired_range.y: # Good amount
			completed_trait_weight += trait_weights[trait_type]
			new_comment = feedback_comments[trait_type][1]
		elif submission_trait_value >= desired_range.y: # Too much trait
			new_comment = feedback_comments[trait_type][2]
		
		#print("Trait: ", trait_type)
		#print("Amount: ", submission_trait_value)
		#print("Range: ", desired_range)
		
		if not new_comment.ends_with(" ") and new_comment != "":
			new_comment += " "
		
		comments += new_comment
	
	rating += int(completed_trait_weight * 8 / total_trait_weight)
	
	results["rating"] = rating
	results["comments"] = comments
	results["amount_paid"] = desired_judgement.min_money + (desired_judgement.max_money - desired_judgement.min_money) * (max(rating - 3, 0) / 7.0)
	
	print("Rating: ", rating)
	print("Comments: ", comments)
	print("Amount Paid: ", results["amount_paid"])
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
