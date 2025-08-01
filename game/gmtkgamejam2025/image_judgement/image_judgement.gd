extends Node

enum Trait {
	PERSON_1 = -5,
	PERSON_2 = -4,
	PERSON_3 = -3,
	PERSON_4 = -2,
	PERSON_5 = -1,
	BALD = 0,
	HAIR,
	FISH,
	EX_PARTNER,
	CELEB,
	COOL,
	RAINY,
	SUNNY,
	SAD,
	HAPPY,
	FRIENDS,
}

@export var trait_colors: Dictionary[Trait, Color]
