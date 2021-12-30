@output {
    vec2 v_texcoord0 : TEXCOORD0;
}

#include <kaa.sh>

void main()
{
	gl_Position = mul(u_viewProjMat, vec4(a_position, 1.0));
	v_texcoord0 = a_texcoord0;
}
