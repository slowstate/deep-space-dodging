shader_type canvas_item;

uniform sampler2D mask_gradient;

void fragment(){
	vec4 mask_color = texture(mask_gradient,UV);
	vec4 orig_color = texture(TEXTURE,UV);
	COLOR.rgb = orig_color.rgb;
	COLOR *= mask_color;
}
