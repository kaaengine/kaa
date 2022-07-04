@output {
    vec4 v_color0 : COLOR0;
    vec2 v_texcoord0 : TEXCOORD0;
}

#include <bgfx_shader.sh>

void main()
{
    mat4 projView = mul(u_proj, u_view);
    gl_Position = mul(projView, vec4(a_position, 1.0));

    v_color0 = a_color0;
    v_texcoord0 = a_texcoord0;
}
