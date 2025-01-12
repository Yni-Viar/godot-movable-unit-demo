// NOTE: Shader automatically converted from Godot Engine 4.3.1.rc's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix;

uniform sampler2D albedo_a: source_color;
uniform sampler2D albedo_b: source_color;

uniform float roughness : hint_range(0.0, 1.0);

uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;

void fragment() {
	vec4 tex_a = texture(albedo_a, UV);
	vec4 tex_b = texture(albedo_b, UV);
	ALBEDO = tex_a.rgb + tex_b.rgb;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, UV).rgb;
}
