shader_type spatial;
render_mode world_vertex_coords2;

varying vec3 world_pos;

void vertex() {
	world_pos = VERTEX;
}

uniform float mountain_height = 0.55;
uniform float land_height = 0.35;
uniform float amp = 1.0f;
const float transition_len = 0.2f;
const vec3 s_col = vec3(0.8, 0.90, 1.0);
const vec3 m_col = vec3(0.85, 0.85, 0.85);
const vec3 l_col = vec3(0.2, 1.0, 0.15);
const vec3 w_col = vec3(1.0, 1.0, 0.3);


void fragment() {

	if (world_pos.y > mountain_height) { 
		ALBEDO.rgb = m_col;
	} 
	else if (world_pos.y > mountain_height - transition_len) {
		ALBEDO.rgb = mix(l_col, m_col, (1.f/transition_len)*(world_pos.y-(mountain_height - transition_len)));
	}
	else if (world_pos.y > land_height) {
		ALBEDO.rgb = l_col;
	}
	else if (world_pos.y > land_height - transition_len) {
		ALBEDO.rgb = mix(w_col, l_col, (1.f/transition_len)*(world_pos.y-(land_height - transition_len)));
	}
	else {
		ALBEDO.rgb = w_col;
	}
	SPECULAR = 0.3f;
	ROUGHNESS = 0.7f;
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
