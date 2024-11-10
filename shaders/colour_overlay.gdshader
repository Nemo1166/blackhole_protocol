shader_type canvas_item;

uniform vec4 overlay_color:source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	// 将基础颜色和半透明层混合
	COLOR = mix(base_color, overlay_color, overlay_color.a);
}
