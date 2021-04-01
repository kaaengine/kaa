$input v_texcoord0

// source: https://www.shadertoy.com/view/Xltfzj


#include <bgfx_shader.sh>

SAMPLER2D(s_texture, 0);
uniform vec4 u_blur;

void main()
{
	float pi_2 = 6.28318530718;
    float directions = 20.;
    float quality = 10.;
    float size = u_blur.x;

	vec2 viewport = (u_viewRect.zw - u_viewRect.xy);
	vec2 radius = size / viewport;
	vec4 color = texture2D(s_texture, v_texcoord0);

	for(float d = 0.; d < pi_2; d += pi_2 / directions) {
		for(float i = 1. / quality; i <= 1.; i += 1. / quality) {
			color += texture2D(
				s_texture, v_texcoord0 + vec2(cos(d), sin(d)) * radius * i
			);
		}
	}
	color /= quality * directions - 15.;
	gl_FragColor = color;
}
