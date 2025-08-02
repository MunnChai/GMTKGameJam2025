class_name DesiredJudgement
extends Resource

# A dictionary of desired traits, and the vector2 represents a range of values for the trait (x = lower bound, y = upper bound)
# If a trait is not present in this dictionary, the judgement will not take any pixels of that trait into account
@export var desired_traits: Dictionary[ImageJudgement.Trait, Vector2]

# A dictionary of traits to string arrays, where the trait is which trait the commissioner is commenting on,
# and the PackedStringArray should have 3 elements. The first element should be the comment if the trait is
# too low, and the second element should be the comment if the trait within the correct range, 
# and the third element should be the comment if the trait is too high
@export var feedback_comments: Dictionary[ImageJudgement.Trait, PackedStringArray]


# A range of the desired modification count (how many pixels of the original image were modified) (x = lower bound, y = upper bound)
@export var desired_modification: Vector2

@export var modification_comments: PackedStringArray

@export var min_money: float
@export var max_money: float
