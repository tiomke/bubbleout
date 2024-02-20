shader_type canvas_item;

uniform sampler2D gradient_texture :hint_default_white; // 声明渐变纹理
uniform float day_night_factor = 1.0;
uniform float day_night_factor2 = 1.0;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    
    // 获取从渐变纹理中采样的颜色值，这里假设你有一个范围在0.0-1.0之间的day_night_factor
    //float day_night_factor = factor; // 根据游戏时间或其他逻辑计算得到
    vec4 gradient_color = texture(gradient_texture, vec2(day_night_factor, 1.0)); // 采样渐变纹理
    
    // 将基础颜色和渐变颜色混合
    COLOR.rgb = mix(base_color.rgb, gradient_color.rgb, day_night_factor2);//gradient_color.a);
    
    // 保持图片原有的alpha通道
    COLOR.a = base_color.a;
}