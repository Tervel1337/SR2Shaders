sampler2D Depth_MapSampler : register(s2);
float4 Eye_pos : register(c32);
float4x4 Inv_view_proj : register(c24);
sampler2D Shadow_MapSampler : register(s1);
float4 Shadow_fade_params : register(c10);
float4x4 Shadow_map_matrix : register(c28);
sampler2D Stencil_MapSampler : register(s0);
float4 V_light_atten : register(c0);

float4 main(float4 texcoord : TEXCOORD) : COLOR
{
    float4 o;
    float4 r0;
    float4 r1;
    float4 r2;

    r0 = transpose(Inv_view_proj)[1] * texcoord.w;
    r0 = transpose(Inv_view_proj)[0] * texcoord.z + r0;
    r1 = tex2D(Depth_MapSampler, texcoord);
    r0 = transpose(Inv_view_proj)[2] * r1.x + r0;
    r0 = r0 + transpose(Inv_view_proj)[3];
    r0.w = 1 / r0.w;
    r1.xyz = r0.w * r0.xyz;
    r0.xyz = r0.xyz * r0.w - Eye_pos.xyz;
    r0.x = dot(r0.xyz, r0.xyz);
    r0.x = 1 / sqrt(r0.x);
    r0.x = 1 / r0.x;
    r0.xy = -Shadow_fade_params.yxzw + r0.x;
    r0.xy = saturate(r0.xy * Shadow_fade_params.zw);
    r0.xy = -r0.xy + 1;
    r2 = r1.y * transpose(Shadow_map_matrix)[1];
    r2 = transpose(Shadow_map_matrix)[0] * r1.x + r2;
    r1 = transpose(Shadow_map_matrix)[2] * r1.z + r2;
    r1 = r1 + transpose(Shadow_map_matrix)[3];
    r1 = tex2Dproj(Shadow_MapSampler, r1);
    r0.z = -r1.x + 1;
    r0.y = r0.z * -r0.y + 1;
    r1 = tex2D(Stencil_MapSampler, texcoord);
    r0.z = -r1.x + 1;
    r0.x = r0.x * -r0.z + 1;
    r0.x = r0.x * r0.y + -1;
    r1.x = 1;
    o.xyz = V_light_atten.w * r0.x + r1.x;
    o.w = 1;

    return o;
}