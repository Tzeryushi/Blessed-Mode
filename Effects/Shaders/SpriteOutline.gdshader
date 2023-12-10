shader_type canvas_item;
render_mode unshaded;

uniform bool Smooth = true;
uniform float width : hint_range(0.0, 64) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int pixel_size : hint_range(1, 10) = 4;
uniform float width_speed :hint_range(0.1, 10) = 1;
varying flat vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment()
{
    float _width = width + ((sin(TIME*width_speed) + 1.0) -2.0) * 10.0;
    vec2 unit = (1.0/float(pixel_size) ) / vec2(textureSize(TEXTURE, 0));
    vec4 pixel_color = texture(TEXTURE, UV)*modulate;
    if (pixel_color.a == 0.0) {
        pixel_color = outline_color;
        pixel_color.a = 0.0;
        for (float x = -ceil(_width); x <= ceil(_width); x++) {
            for (float y = -ceil(_width); y <= ceil(_width); y++) {
                if (texture(TEXTURE, UV + vec2(x*unit.x, y*unit.y)).a == 0.0 || (x==0.0 && y==0.0)) {
                    continue;
                }
                if (Smooth) {
                    pixel_color.a += outline_color.a / (pow(x,2)+pow(y,2)) * (1.0-pow(2.0, -_width));
                    if (pixel_color.a > 1.0) {
                        pixel_color.a = 1.0;
                    }
                } else {
                    pixel_color.a = outline_color.a;
                }
            }
        }
    } else if (pixel_color.a < 1.0) {
		float alpha = (1.0-pixel_color.a) * outline_color.a + pixel_color.a;
		float red = ((1.0-pixel_color.a)*outline_color.a*outline_color.r + pixel_color.a*pixel_color.r) / alpha;
		float green = ((1.0-pixel_color.a)*outline_color.a*outline_color.g + pixel_color.a*pixel_color.g) / alpha;
		float blue = ((1.0-pixel_color.a)*outline_color.a*outline_color.b + pixel_color.a*pixel_color.b) / alpha;
		pixel_color = vec4(red, green, blue, alpha);
		pixel_color.a = 1.0;
	}
    COLOR = pixel_color;
}