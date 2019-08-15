vec4 fg = vec4(1, 1, 1.1, 1.);
vec4 bg = vec4(0, 0, 0, 0);

in vec2 geom_p;
out vec4 c;

float remap(float low1, float high1, float low2, float high2, float value){
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}


void main() {
	float al = texture(iA, geom_p).r;

	float zz = texture(iSoundR, geom_p.y).r;
	vec4 new_color = 5.*mix(bg, fg, al);
	vec4 old_color = texture(iB, geom_p);

	c = mix(old_color, new_color, (remap(-1, 1, 0, 1, zz)));
	c.a = 1.; // Replaces colo
}


