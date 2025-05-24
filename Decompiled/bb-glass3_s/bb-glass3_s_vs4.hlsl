column_major float4x4 V_MVP_matrix : register(vs_3_0, c4);
float3 V_eye_pos : register(vs_3_0, c10);
column_major float4x4 V_model_matrix : register(vs_3_0, c244);
struct VertexMain_Input
{
    float4 position : POSITION;
    float4 normal : NORMAL;
    float4 texcoord : TEXCOORD;
};

struct VertexMain_Output
{
    float2 texcoord : TEXCOORD;
    float3 texcoord1 : TEXCOORD1;
    float3 texcoord2 : TEXCOORD2;
    float3 texcoord3 : TEXCOORD3;
    float3 texcoord4 : TEXCOORD4;
    float4 position : POSITION;
};

VertexMain_Output main(VertexMain_Input i)
{
    VertexMain_Output o;
    float4 temp0;

    float3 rawNormal = i.normal * 2.f - 1.f;

    temp0 = i.position.xyzx * float4(1, 1, 1, 0) + float4(0, 0, 0, 1);
    o.texcoord = float4(0.0009765625, 0.0009765625, 0.0009765625, 0.0009765625) * i.texcoord;
    o.position.x = dot(temp0, (V_MVP_matrix._m00_m10_m20_m30));
    o.position.y = dot(temp0, (V_MVP_matrix._m01_m11_m21_m31));
    o.position.z = dot(temp0, (V_MVP_matrix._m02_m12_m22_m32));
    o.position.w = dot(temp0, (V_MVP_matrix._m03_m13_m23_m33));
    o.texcoord3.x = dot(rawNormal.xyz, (V_model_matrix._m00_m10_m20_m30).xyz);
    o.texcoord3.y = dot(rawNormal.xyz, (V_model_matrix._m01_m11_m21_m31).xyz);
    temp0.xyz = V_eye_pos.xyz + -i.position.xyz;
    o.texcoord3.z = dot(rawNormal.xyz, (V_model_matrix._m02_m12_m22_m32).xyz);
    o.texcoord4.x = dot(temp0.xyz, (V_model_matrix._m00_m10_m20_m30).xyz);
    o.texcoord4.y = dot(temp0.xyz, (V_model_matrix._m01_m11_m21_m31).xyz);
    o.texcoord4.z = dot(temp0.xyz, (V_model_matrix._m02_m12_m22_m32).xyz);
    o.texcoord2 = temp0;
    o.texcoord1 = rawNormal;

    return o;
}
