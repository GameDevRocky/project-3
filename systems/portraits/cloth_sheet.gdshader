shader_type spatial;
render_mode cull_disabled, diffuse_burley;

float hash21(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	float fold = sin(UV.x * 38.0 + sin(UV.y * 13.0) * 2.2) * 0.055;
	float grain = hash21(floor(UV * vec2(190.0, 150.0))) * 0.08;
	float stain = smoothstep(0.64, 0.92, hash21(floor(UV * 19.0))) * 0.16;
	ALBEDO = vec3(0.56, 0.53, 0.44) + fold + grain - stain;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
