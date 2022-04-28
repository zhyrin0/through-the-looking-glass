shader_type canvas_item;

const vec4 RED = vec4(1.0, 0.0, 0.0, 1.0);
const vec4 GREEN = vec4(0.0, 1.0, 0.0, 1.0);
const vec4 BLUE = vec4(0.0, 0.0, 1.0, 1.0);
const vec4 YELLOW = vec4(1.0, 1.0, 0.0, 1.0);
const vec4 CYAN = vec4(0.0, 1.0, 1.0, 1.0);
const vec4 MAGENTA = vec4(1.0, 0.0, 1.0, 1.0);

uniform int to_state = 1;
uniform sampler2D alt_texture;
uniform sampler2D kaleidoscope_texture;
uniform float kaleidoscope_width : hint_range(0.0, 0.1);
uniform float kaleidoscope_time_scale : hint_range(0.0, 5.0);
uniform float kaleidoscope_intensity : hint_range(0.0, 1.0);
uniform vec4 color_1 : hint_color;
uniform vec4 color_2 : hint_color;
uniform vec4 color_3 : hint_color;
uniform vec4 color_4 : hint_color;
uniform vec4 color_5 : hint_color;
uniform vec4 color_6 : hint_color;
uniform vec4 modulate : hint_color;
uniform vec4 modulate_alt : hint_color;
uniform vec2 orb_screen_uv;
uniform float transition : hint_range(0.0, 1.0);


vec4 calculate_kaleidoscope(vec2 screen_uv, float time) {
	vec2 kaleidoscope_uv = screen_uv * vec2(16.0, -9.0) * 0.125 + vec2(-0.5, 0.05);
	vec4 kaleidoscope_color = texture(kaleidoscope_texture, kaleidoscope_uv);
	float delta = sin(time * kaleidoscope_time_scale);
	
	if (kaleidoscope_color == RED) {
		kaleidoscope_color = mix(color_1, color_3, delta) * 0.75;
	}
	if (kaleidoscope_color == GREEN) {
		kaleidoscope_color = mix(color_2, color_4, delta) * 0.75;
	}
	if (kaleidoscope_color == BLUE) {
		kaleidoscope_color = mix(color_3, color_5, delta) * 0.75;
	}
	if (kaleidoscope_color == YELLOW) {
		kaleidoscope_color = mix(color_4, color_6, delta) * 0.75;
	}
	if (kaleidoscope_color == CYAN) {
		kaleidoscope_color = mix(color_5, color_1, delta) * 0.75;
	}
	if (kaleidoscope_color == MAGENTA) {
		kaleidoscope_color = mix(color_6, color_2, delta) * 0.75;
	}
	
	return kaleidoscope_color;
}

float range_remap(float value, float in_a, float in_b, float out_a, float out_b) {
	return (value - in_a) / (in_b - in_a) * (out_b - out_a) + out_a;
}


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 alt_color = texture(alt_texture, UV);
	vec4 kaleidoscope_color = calculate_kaleidoscope(SCREEN_UV, TIME);
	
	vec4 current_color = to_state == 1 ? color : alt_color;
	vec4 to_color = to_state == 1 ? alt_color : color;
	vec4 current_modulate = to_state == 1 ? modulate : modulate_alt;
	vec4 to_modulate = to_state == 1 ? modulate_alt : modulate;
	
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 screen_position = SCREEN_UV * resolution;
	vec2 orb_position = vec2(orb_screen_uv.x, 1.0 - orb_screen_uv.y) * resolution;
	float dist = distance(screen_position, orb_position);
	float radius = transition * length(resolution);
	
	float screen_phase = range_remap(dist, 0.0, length(resolution), 0.0, 1.0);
	COLOR = current_color * current_modulate;
	if (screen_phase < transition) {
		COLOR = to_color * to_modulate;
	}
	float kaleidoscope_cutoff = range_remap(transition, 0.0, 1.0, 0.0, kaleidoscope_width);
	if (transition > kaleidoscope_cutoff && screen_phase > transition && screen_phase - kaleidoscope_cutoff < transition) {
		COLOR.rgb += kaleidoscope_color.rgb * kaleidoscope_intensity;
	}
}
