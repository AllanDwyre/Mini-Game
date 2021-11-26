#if !defined(Ripples_INCLUDED)
#define Ripples_INCLUDED


float _RippleOffsetX, _RippleOffsetY, _RippleScale;
float _RippleFrequence, _RippleSpeed;
float _RippleFallOffX, _RippleFallOffY, _RippleDistance;

float map(float value, float toMin, float toMax) {
	return  smoothstep(toMin, toMax, value);
}

float3 Ripples(float3 worldPos, float3 tangentSpaceNormal) {
	worldPos = float3(worldPos.x - _RippleOffsetX, worldPos.y - _RippleOffsetY, worldPos.z) * 1 / _RippleScale;

	float3 rippleStart = length(worldPos);
	float3 ripplePos = rippleStart * _RippleFrequence;
	ripplePos = sin(ripplePos + _Time.y * -_RippleSpeed);

	ripplePos *= map(rippleStart, _RippleFallOffX * _RippleDistance, _RippleFallOffY * _RippleDistance);

	return ripplePos;
}

#endif