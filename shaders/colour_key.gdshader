shader_type canvas_item;


uniform vec4 key_color : source_color = vec4(1,0,1,1); // 颜色键
uniform float tolerance : hint_range(0.0, 1.0) = 0.75; // 容差

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // 计算与指定颜色的差异
    float diff = distance(tex_color.rgb, key_color.rgb);

    // 如果颜色差异小于容差，则将像素设为透明
    if (diff < tolerance) {
        tex_color.a = 0.0;
    }

    COLOR = tex_color;
}
