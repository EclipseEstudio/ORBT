shader_type canvas_item;
render_mode unshaded;
uniform vec2 centro;
uniform vec2 tamanho = vec2(180.0, 320.0);
uniform float raio = 90.0;

void fragment() {
	vec2 pixel = SCREEN_UV * tamanho;
	float distancia = length(pixel - centro);
	float borda = smoothstep(raio * 0.78, raio, distancia);
	// Fora do alcance a opacidade é exatamente 1: nenhum obstáculo vaza.
	float nuvem = sin(pixel.x * 0.035 + TIME * 0.08) * cos(pixel.y * 0.028 - TIME * 0.05);
	vec3 azul = mix(vec3(0.025, 0.045, 0.085), vec3(0.05, 0.08, 0.13), nuvem * 0.5 + 0.5);
	COLOR = vec4(azul, borda);
}
