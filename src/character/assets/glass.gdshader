shader_type canvas_item;

uniform sampler2D glass_texture;

void fragment() {
	float glass_scale = 0.3;
	vec4 glass = texture(glass_texture, SCREEN_UV * vec2(16.0, -9.0) * glass_scale);
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= 1.0 - glass.r * 0.25;
}
