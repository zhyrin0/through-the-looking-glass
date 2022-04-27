shader_type canvas_item;

const vec4 RED = vec4(1.0, 0.0, 0.0, 1.0);
const vec4 GREEN = vec4(0.0, 1.0, 0.0, 1.0);
const vec4 BLUE = vec4(0.0, 0.0, 1.0, 1.0);
const vec4 YELLOW = vec4(1.0, 1.0, 0.0, 1.0);
const vec4 CYAN = vec4(0.0, 1.0, 1.0, 1.0);
const vec4 MAGENTA = vec4(1.0, 0.0, 1.0, 1.0);

uniform sampler2D kaleidoscope_texture;
uniform float time_scale : hint_range(0.0, 1.0);
uniform vec4 color_1 : hint_color;
uniform vec4 color_2 : hint_color;
uniform vec4 color_3 : hint_color;
uniform vec4 color_4 : hint_color;
uniform vec4 color_5 : hint_color;
uniform vec4 color_6 : hint_color;

void fragment() {
	vec2 kaleidoscope_uv = SCREEN_UV * vec2(16.0, -9.0) * 0.125 + vec2(-0.5, 0.05);
	vec4 kaleidoscope_color = texture(kaleidoscope_texture, kaleidoscope_uv);
	float delta = sin(TIME * time_scale);
	COLOR = kaleidoscope_color;
	if (COLOR == RED) {
		COLOR += mix(color_1, color_3, delta) * 0.75;
	}
	if (COLOR == GREEN) {
		COLOR += mix(color_2, color_4, delta) * 0.75;
	}
	if (COLOR == BLUE) {
		COLOR += mix(color_3, color_5, delta) * 0.75;
	}
	if (COLOR == YELLOW) {
		COLOR += mix(color_4, color_6, delta) * 0.75;
	}
	if (COLOR == CYAN) {
		COLOR += mix(color_5, color_1, delta) * 0.75;
	}
	if (COLOR == MAGENTA) {
		COLOR += mix(color_6, color_2, delta) * 0.75;
	}
}
