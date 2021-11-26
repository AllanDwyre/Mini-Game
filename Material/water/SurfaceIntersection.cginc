#if !defined(SurfaceIntersection_INCLUDED)
#define SurfaceIntersection_INCLUDED

float _FoamAmount, _FoamCutOff;
float _FoamSpeed, _FoamScale;

float DepthFade(float4 screenPos)
{
	float2 uv = screenPos.xy / screenPos.w;

	float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
	float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);

	float depthDifference = backgroundDepth - surfaceDepth;

	return saturate(depthDifference / _FoamAmount);
}

float2 Movement(float2 uv) {
	//float2 uv = screenPos.xy / screenPos.w;
	uv *= _FoamScale;
	uv += _Time.y * _FoamSpeed;
	return uv;
}

float2 unity_gradientNoise_dir(float2 p)
{
	p = p % 289;
	float x = (34 * p.x + 1) * p.x % 289 + p.y;
	x = (34 * x + 1) * x % 289;
	x = frac(x / 41) * 2 - 1;
	return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float unity_gradientNoise(float2 p)
{
	float2 ip = floor(p);
	float2 fp = frac(p);
	float d00 = dot(unity_gradientNoise_dir(ip), fp);
	float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
	float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
	float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
	fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
	return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float Intersection(float4 screenPos, float2 uv)
{
	float depth = DepthFade(screenPos) * _FoamCutOff;
	float noise = unity_gradientNoise(Movement(uv)) + 0.5;
	return step(depth, noise);
}
#endif