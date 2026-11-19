shader_type spatial;

uniform sampler2D waves: hint_default_black;

void vertex() {
	VERTEX.y += texture(waves, VERTEX.xz).r*2.0;
}

void fragment() {
	ALBEDO.rgb = vec3(0.0f, 0.1f, 1.f);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
