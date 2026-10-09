shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_tint : source_color = vec4(0.82, 0.75, 0.60, 1.0);
uniform bool family_style = false;
uniform float ghost_amount : hint_range(0.0, 1.0) = 0.0;
uniform float active_amount : hint_range(0.0, 1.0) = 1.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float soft_ellipse(vec2 p, vec2 center, vec2 radius) {
	float d = length((p - center) / radius);
	return 1.0 - smoothstep(0.82, 1.12, d);
}

void fragment() {
	vec2 uv = UV;
	float warp = sin(uv.y * 42.0 + TIME * 3.2) * 0.018 * ghost_amount;
	uv.x += warp;
	float grain = hash21(floor(uv * vec2(300.0, 240.0)));
	float scratches = step(0.994, hash21(floor(uv * vec2(27.0, 43.0)))) * 0.25;
	float vignette = smoothstep(0.05, 0.75, uv.x) * smoothstep(0.05, 0.75, 1.0 - uv.x) * smoothstep(0.04, 0.8, uv.y) * smoothstep(0.04, 0.8, 1.0 - uv.y);
	vec3 pigment = vec3(0.40, 0.39, 0.31);
	if (family_style) {
		pigment = mix(vec3(0.26, 0.29, 0.25), vec3(0.53, 0.38, 0.28), uv.y);
		float bodies = soft_ellipse(uv, vec2(0.34, 0.43), vec2(0.105, 0.28)) + soft_ellipse(uv, vec2(0.51, 0.43), vec2(0.12, 0.31)) + soft_ellipse(uv, vec2(0.69, 0.42), vec2(0.10, 0.26));
		float heads = soft_ellipse(uv, vec2(0.34, 0.70), vec2(0.075, 0.105)) + soft_ellipse(uv, vec2(0.51, 0.73), vec2(0.08, 0.11)) + soft_ellipse(uv, vec2(0.69, 0.68), vec2(0.07, 0.095));
		pigment = mix(pigment, vec3(0.66, 0.57, 0.43), clamp(bodies * 0.72 + heads * 0.9, 0.0, 1.0));
		pigment = mix(pigment, vec3(0.17, 0.17, 0.15), smoothstep(0.12, 0.0, abs(uv.y - 0.20)));
	} else {
		pigment = mix(vec3(0.23, 0.33, 0.34), vec3(0.71, 0.59, 0.40), uv.y * 0.78);
		float hill = smoothstep(0.30 + sin(uv.x * 9.0) * 0.04, 0.37 + sin(uv.x * 9.0) * 0.04, uv.y);
		float distant = smoothstep(0.45 + sin(uv.x * 16.0) * 0.035, 0.52 + sin(uv.x * 16.0) * 0.035, uv.y);
		pigment = mix(pigment, vec3(0.38, 0.39, 0.29), hill);
		pigment = mix(pigment, vec3(0.29, 0.32, 0.31), distant * 0.8);
	}
	float face = soft_ellipse(uv, vec2(0.52, 0.57), vec2(0.18, 0.31));
	float skull = soft_ellipse(uv, vec2(0.52, 0.67), vec2(0.13, 0.16));
	float shoulders = soft_ellipse(uv, vec2(0.52, 0.31), vec2(0.27, 0.20));
	float figure = max(skull, shoulders * 0.85) * smoothstep(0.03, 0.2, ghost_amount);
	float eye_l = soft_ellipse(uv, vec2(0.475, 0.685), vec2(0.027, 0.017));
	float eye_r = soft_ellipse(uv, vec2(0.565, 0.685), vec2(0.027, 0.017));
	float mouth = soft_ellipse(uv, vec2(0.52, 0.615), vec2(0.035, 0.055));
	float dragged = step(0.82, fract((uv.x + warp) * 13.0 + sin(uv.y * 19.0) * 0.13)) * ghost_amount * 0.12;
	pigment = mix(pigment, vec3(0.035, 0.027, 0.03), figure * 0.91);
	pigment = mix(pigment, vec3(0.82, 0.73, 0.57), max(eye_l, eye_r) * ghost_amount * 0.9);
	pigment = mix(pigment, vec3(0.008, 0.006, 0.01), mouth * ghost_amount * 0.8);
	pigment += vec3(dragged * (0.22 + sin(TIME * 2.0) * 0.06));
	float wear = scratches + (1.0 - vignette) * 0.1 + (grain - 0.5) * 0.08;
	pigment = (pigment - wear) * base_tint.rgb;
	pigment = mix(vec3(0.18, 0.16, 0.14), pigment, active_amount);
	ALBEDO = pigment;
	ROUGHNESS = 0.94;
	METALLIC = 0.0;
	NORMAL = normalize(vec3(warp * 1.8, sin(uv.x * 31.0 + TIME * 1.7) * 0.025 * ghost_amount, 1.0));
	EMISSION = vec3(0.12, 0.08, 0.035) * ghost_amount * (0.3 + 0.25 * sin(TIME * 2.3));
}
