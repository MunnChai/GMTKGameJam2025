shader_type canvas_item;

// TODO: Make it not look bad, smoothing down to a rounded end...

// End sine value has to equal start sine value?

// Parameters for the sine wave
uniform float frequency = 1.5;
uniform float amplitude = 1000.0;
uniform float speed = 10.0;
uniform float direction: hint_range(-1.0, 1.0) = 1.0;

// Uniforms for colors
uniform vec4 color1: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color2: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float opacity: hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = FRAGCOORD.xy;
    float sine_wave = sin(UV.x * frequency + TIME * speed * direction) * amplitude;

	float sine_2 = 0.5 + (sin(UV.x * frequency + TIME * speed * direction) * 0.5);

	float width = UV.y; // 0 to 1
	float width_2 = 1.0 - (width * 2.0); // -1 to 1
	float width_3 = abs(width_2 * 1.0); // 0 to 1, with 0 at the center and 1 at edges

	float height = sine_2 * 0.5; // 0 to 1, based on strength

	// Basically
	// - when the height is stronger, clip off

	float clip = step(height, width_3);
	float new = clip;

	// When strength is 0... 0 width
	// When strength is 1... 1 width

    uv.y += sine_wave;
    float t = sin(UV.x * frequency + TIME * speed * direction) * (1.0 - new);
    vec4 final_color = t > 0.0 ? color1 : color2;
    final_color *= vec4(1.0, 1.0, 1.0, opacity);
    COLOR = final_color;

	COLOR = vec4(new, new, new, 1.0);
}