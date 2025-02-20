float4 Tint : register( c4 );
float3 BCS : register( c7 );
float2 max_distortion_offset : register( c24 );
float4 fullscreen_distortion_strength : register( c25 );
float Bleach_bypass_strength : register( c26 );
sampler2D base_sampler : register( s0 );
sampler2D distortion_sampler : register( s1 );
sampler2D fullscreen_distortion_sampler : register( s2 );

struct PS_IN
{
	float2 texcoord : TEXCOORD;
	float4 texcoord1 : TEXCOORD1;
};

// Gamma conversion functions taken from the Source SDK, all credits to Valve - https://github.com/ValveSoftware/source-sdk-2013/blob/master/src/materialsystem/stdshaders/common_fxc.h#L255

float X360LinearToGamma( float flLinearValue )
{
	float fl360GammaValue;

	flLinearValue = saturate( flLinearValue );
	if ( flLinearValue < ( 128.0f / 1023.0f ) )
	{
		if ( flLinearValue < ( 64.0f / 1023.0f ) )
		{
			fl360GammaValue = flLinearValue * ( 1023.0f * ( 1.0f / 255.0f ) );
		}
		else
		{
			fl360GammaValue = flLinearValue * ( ( 1023.0f / 2.0f ) * ( 1.0f / 255.0f ) ) + ( 32.0f / 255.0f );
		}
	}
	else
	{
		if ( flLinearValue < ( 512.0f / 1023.0f ) )
		{
			fl360GammaValue = flLinearValue * ( ( 1023.0f / 4.0f ) * ( 1.0f / 255.0f ) ) + ( 64.0f / 255.0f );
		}
		else
		{
			fl360GammaValue = flLinearValue * ( ( 1023.0f /8.0f ) * ( 1.0f / 255.0f ) ) + ( 128.0f /255.0f ); // 1.0 -> 1.0034313725490196078431372549016
			if ( fl360GammaValue > 1.0f )
			{
				fl360GammaValue = 1.0f;
			}
		}
	}

	fl360GammaValue = saturate( fl360GammaValue );
	return fl360GammaValue;
}

float SrgbGammaToLinear( float flSrgbGammaValue )
{
	float x = saturate( flSrgbGammaValue );
	return ( x <= 0.04045f ) ? ( x / 12.92f ) : ( pow( ( x + 0.055f ) / 1.055f, 2.4f ) );
}

float SrgbGammaTo360Gamma( float flSrgbGammaValue )
{
	float flLinearValue = SrgbGammaToLinear( flSrgbGammaValue );
	float fl360GammaValue = X360LinearToGamma( flLinearValue );
	return fl360GammaValue;
}

float4 main(PS_IN i) : COLOR
{
	float4 o;

	float4 r1;
	float4 r0;
	float4 r2;
	r1 = tex2D(distortion_sampler, i.texcoord);
	r0 = tex2D(fullscreen_distortion_sampler, i.texcoord1);
	r2.xy = 2 * r0.xy + -1.0039216;
	r0.xy = 2 * r1.xy + -1.0039216;
	r1.xy = r2.xy * fullscreen_distortion_strength.xy;
	r2.xy = r0.xy * max_distortion_offset.xy + r1.xy;
	r1 = tex2D(fullscreen_distortion_sampler, i.texcoord1.zwzw);
	r0.xy = 2 * r1.xy + -1.0039216;
	r1.xy = r0.xy * fullscreen_distortion_strength.xy + r2.xy;
	r0.xy = r0.zw * r1.wz;
	r1.xy = r1.xy + i.texcoord.xy;
	r1 = tex2D(base_sampler, r1);
	r0.xy = r0.xy * fullscreen_distortion_strength.z;
	r2.w = saturate(r0.y + r0.x);
	r0 = lerp( r1, float4(0.6, 0.6, 0.6, 1), r2.w );
	r1.w = dot(r0.xyz, float3(0.3, 0.59, 0.11));
	r2.w = -r1.w + 1;
	r1.xyz = -r0.xyz + 1;
	r2.w = r2.w + r2.w;
	r1.xyz = r2.w * -r1.xyz + 1;
	r2.xyz = r0.xyz * r1.w;
	r1.w = r1.w + -0.45;
	r1.xyz = 2 * -r2.xyz + r1.xyz;
	r2.xyz = r2.xyz + r2.xyz;
	r1.w = saturate(r1.w * 10);
	r2.xyz = r1.w * r1.xyz + r2.xyz;
	r1.xyz = lerp(r0.xyz, r2.xyz, Bleach_bypass_strength.x);
	r0.z = dot(r1.xyz, float3(0.3, 0.59, 0.11));
	r0.x = 1;
	r0.xy = r0.x + -BCS.zy;
	r0.z = r0.z * r0.x;
	r1.w = r0.y * 0.5;
	r0.xyz = BCS.z * r1.xyz + r0.z;
	r0 = r0 * BCS.y + r1.w;
	r0 = r0 + BCS.x;
	o = r0 * Tint;
	
	o.x = SrgbGammaTo360Gamma(o.x);
    o.y = SrgbGammaTo360Gamma(o.y);
    o.z = SrgbGammaTo360Gamma(o.z);
	
	return o;
}
