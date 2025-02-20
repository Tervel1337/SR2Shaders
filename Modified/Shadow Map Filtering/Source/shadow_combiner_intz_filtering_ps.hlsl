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

    float2 vogel_disk_16[16] = {
      float2(0.18993645671348536, 0.02708711407659152),
      float2(-0.21261242652069953, 0.2339129324694907),
      float2(0.04771781344140756, -0.3666840644525993),
      float2(0.297730981239584, 0.398259878229082),
      float2(-0.509063425827436, -0.06528681462854097),
      float2(0.507855152944665, -0.2875976005206389),
      float2(-0.15230616564632418, 0.6426121151781916),
      float2(-0.30240170651828074, -0.5805072900736001),
      float2(0.6978019230005561, 0.2771173334141519),
      float2(-0.6990963248129052, 0.3210960724922725),
      float2(0.3565142601623699, -0.7066415061851589),
      float2(0.266890002328106, 0.8360191043249159),
      float2(-0.7515861305520581, -0.4160987619581504),
      float2(0.9102937449894895, -0.17014527555321657),
      float2(-0.5343471434373126, 0.8058593459499529),
      float2(-0.1133270115046468, -0.9490025827627441)
    };

    float texelsize = 1.0f/2048.0f;
    
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
    
    //r1 = tex2Dproj(Shadow_MapSampler, r1);
    float taps = 0.0f;
    for(int i = 0; i < 16; i++){
        taps += tex2Dproj(Shadow_MapSampler, r1 + float4(vogel_disk_16[i] * texelsize, 0.0f, 0.0f)).x;
    }
    r1.x = taps / 16.0f;
    
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