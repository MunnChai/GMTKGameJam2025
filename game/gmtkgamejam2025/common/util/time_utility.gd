class_name TimeUtil

## ---
## TIME UTILITY
## Implements various useful time-based components
## for use in other scripts.
## ---
## Last edited: July 30th, 2025
## ---

## Produces unscaled delta time by dividing out the Engine time_scale modification
## NOTE: Does not work when Engine.time_scale is approximately zero
static func unscaled_delta(delta: float) -> float:
	if is_zero_approx(Engine.time_scale):
		return delta
	return delta / Engine.time_scale
