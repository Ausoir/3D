shader_type spatial;

const float PI = 3.1415926536f;

uniform vec4 albedo : hint_color = vec4(1.0f);
uniform sampler2D albedo_texture : hint_albedo;

uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
uniform sampler2D specular_map : hint_albedo;

varying vec3 vertex_pos;
varying vec3 normal;

float split_specular(float specular) {
	return step(0.5f, specular);
}

void vertex() {
	vertex_pos = VERTEX;
	normal = NORMAL;
}

void fragment() {
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
}

void light() {
	float attenuation = ATTENUATION.x;
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);
	
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	diffuse *= diffuse_stepped;
	
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	
	vec3 H = normalize(LIGHT + VIEW);
	float NdotH = dot(NORMAL, H);
	float specular_amount = max(pow(NdotH, specular_shininess*specular_shininess), 0.0f)
						    * texture(specular_map, UV).r
							* attenuation;
	specular_amount = split_specular(specular_amount);
	SPECULAR_LIGHT += specular_strength * specular_amount * LIGHT_COLOR;
}