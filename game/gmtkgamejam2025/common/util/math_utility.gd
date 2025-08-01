class_name MathUtil

## ---
## MATH UTILITY
## Implements various more "advanced" mathematical
## components for use in other scripts.
## ---
## Last edited: July 30th, 2025
## ---
## TODO
## - Determine performance impact of using exp every frame
## ---

## "Exponential decay" of value from start a to end b value,
## With decay constant, optimal range (1, 25)
## 1 is slow decay, 25 is fast decay
## NOTE: Use this for a framerate independent lerp, see video link for more info
## Credit and ref: https://www.youtube.com/watch?v=LSNQuFEDOyQ at 49:48
static func decay(a, b, decay_constant : float, delta : float):
	return b + (a - b) * exp(-decay_constant * delta)
