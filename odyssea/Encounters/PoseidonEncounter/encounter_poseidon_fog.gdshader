shader_type canvas_item;

uniform vec2 resolution = vec2(1920, 1080);
uniform int octave_count: hint_range(1, 20) = 5;
uniform float opacity: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float amp_start: hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float amp_coeff: hint_range(0.0, 1.0, 0.01) = 0.6;
uniform float freq_coeff: hint_range(0.0, 10.0, 0.01) = 2.0;
uniform float zoom: hint_range(0.1, 10.0, 0.01) = 3.0;
uniform float speed: hint_range(0.0, 1.0, 0.01) = 0.03;
uniform vec4 base_color: source_color = vec4(0, 0, 0, 1.0); //vec4(0.0);
uniform vec4 p_color: source_color = vec4(0.12, 0.09, 0.6, 1.0);
uniform vec4 q_color: source_color = vec4(0.8, 0.25, 1, 1.0);
uniform vec4 f_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float brightness: hint_range(0.0, 4.0, 0.1) = 0.8;
uniform float contrast: hint_range(0.0, 1.0, 0.01) = 0.25;
uniform sampler2D maskImage;

vec2 hash22(vec2 uv) {
	uv = vec2(dot(uv, vec2(127.1, 311.7)),
				dot(uv, vec2(269.5, 183.3)));
	return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
	vec2 iuv = floor(uv);
	vec2 fuv = fract(uv);
	vec2 blur = smoothstep(0.0, 1.0, fuv);
	return mix(mix(dot(hash22(iuv + vec2(0.0, 0.0)), fuv - vec2(0.0, 0.0)),
					dot(hash22(iuv + vec2(1.0, 0.0)), fuv - vec2(1.0, 0.0)), blur.x),
				mix(dot(hash22(iuv + vec2(0.0, 1.0)), fuv - vec2(0.0, 1.0)),
					dot(hash22(iuv + vec2(1.0, 1.0)), fuv - vec2(1.0, 1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv) {
	float value = 0.0;
	float amplitude = amp_start;
	for (int i= 0; i < octave_count; i++) {
		value += amplitude * noise(uv);
		uv *= freq_coeff;
		amplitude *= amp_coeff;
	}
	return value;
}

void fragment() {
	vec4 maskImageColor = texture(maskImage, UV);
    // Caluclate the brightness of the pixel in the mask image
    float maskImageBrightness = (maskImageColor.r + maskImageColor.g + maskImageColor.b) / 3.0;
    // Show only the white area on the target texture
    COLOR.a = maskImageBrightness;
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	uv *= zoom;
	float time = TIME * speed;
	uv.y -= time;
	vec2 p = vec2(fbm(uv));
	vec2 q = vec2(fbm(uv + p + time * 2.0), fbm(uv + p - time * 2.0));
	float f = fbm(uv + q);
	vec4 color = base_color;
	color = mix(color, p_color, length(p));
	color = mix(color, q_color, length(q));
	color = mix(color, f_color, pow(f, 4.0) * 4.0);
	vec4 dust_color_with_alpha = vec4(color * brightness);

	float alpha = 1.0; // Start with full dust

	//// If outside the inner exclusion rectangle
	//if (UV.x > exclusion_min.x && UV.x < exclusion_max.x &&
		//UV.y > exclusion_min.y && UV.y < exclusion_max.y) {
		//alpha = 0.0;
		//// Apply feathering near the edges
		//if (dist_to_left > 0.0 && dist_to_left < feather) {
			//alpha += (feather - dist_to_left) / feather;
		//}
		//if (dist_to_right > 0.0 && dist_to_right < feather) {
			//alpha += (feather - dist_to_right) / feather;
		//}
		//if (dist_to_bottom > 0.0 && dist_to_bottom < feather) {
			//alpha += (feather - dist_to_bottom) / feather;
		//}
		//if (dist_to_top > 0.0 && dist_to_top < feather) {
			//alpha += (feather - dist_to_top) / feather;
		//}
	//}
	
	// Option 2: Feather from the outside in
	// Calculate the signed distance to the *outer* edges of the feathered exclusion zone
	//float dist_to_left = exclusion_min.x - UV.x;
	//float dist_to_right = UV.x - exclusion_max.x;
	//float dist_to_top = exclusion_min.y - UV.y;
	//float dist_to_bottom = UV.y - exclusion_max.y;
//
	//float alpha = 1.0; // Start with full dust
	//
	//// If outside the inner exclusion rectangle
	//if (UV.x < exclusion_min.x && !(UV.y < exclusion_min.y || UV.y > exclusion_max.y)) {
		//// Apply feathering near the edges
		//if (dist_to_left > 0.0 && dist_to_left < feather) {
			//alpha -= (feather - dist_to_left) / feather;
		//}
	//}
	//if (UV.x > exclusion_max.x && !(UV.y < exclusion_min.y || UV.y > exclusion_max.y)) {
		//// Apply feathering near the edges
		//if (dist_to_right > 0.0 && dist_to_right < feather) {
			//alpha -= (feather - dist_to_right) / feather;
		//}
	//}
	//if (UV.y < exclusion_min.y && !(UV.x < exclusion_min.x || UV.x > exclusion_max.x)) {
		//// Apply feathering near the edges
		//if (dist_to_top > 0.0 && dist_to_top < feather) {
			//alpha -= (feather - dist_to_top) / feather;
		//}
	//}
	//if (UV.y > exclusion_max.y && !(UV.x < exclusion_min.x || UV.x > exclusion_max.x)) {
		//alpha = 1.0;
		//// Apply feathering near the edges
		//if (dist_to_bottom > 0.0 && dist_to_bottom < feather) {
			//alpha -= (feather - dist_to_bottom) / feather;
		//}
	//}
	//if (UV.x > exclusion_min.x && UV.x < exclusion_max.x &&
		//UV.y > exclusion_min.y && UV.y < exclusion_max.y) {
		//alpha = 0.0;
	//}
	
	//if (UV.x < exclusion_min.x || UV.x > exclusion_max.x ||
		//UV.y < exclusion_min.y || UV.y > exclusion_max.y) {
		//alpha = 1.0;
		//// Apply feathering near the edges
		//if (dist_to_left > 0.0 && dist_to_left < feather) {
			//alpha -= (feather - dist_to_left) / feather;
		//}
		//if (dist_to_right > 0.0 && dist_to_right < feather) {
			//alpha -= (feather - dist_to_right) / feather;
		//}
		//if (dist_to_bottom > 0.0 && dist_to_bottom < feather) {
			//alpha -= (feather - dist_to_bottom) / feather;
		//}
		//if (dist_to_top > 0.0 && dist_to_top < feather) {
			//alpha -= (feather - dist_to_top) / feather;
		//}
	//}

	// Apply the dust with the calculated alpha
	COLOR = mix(vec4(dust_color_with_alpha.rgb, 0.0), dust_color_with_alpha, maskImageBrightness*opacity);
}