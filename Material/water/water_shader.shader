//https://catlikecoding.com/unity/tutorials/flow/looking-through-water/
Shader "Custom/water_shader"
{
	Properties
	{
		[Space]
		[Header(Distortion parameter)]
		[Space]
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset] _FlowMap("Flow (RG, B speed, A noise)", 2D) = "black" {}
		[NoScaleOffset] _DerivHeightMap("Deriv (AG) Height (B)", 2D) = "black" {}
		_UJump("U jump per phase", Range(-0.25, 0.25)) = 0.25
		_VJump("V jump per phase", Range(-0.25, 0.25)) = 0.25
		_Tiling("Tiling", Float) = 1
		_Speed("Speed", Float) = 1
		_FlowStrength("Flow Strength", Float) = 1
		_FlowOffset("Flow Offset", Float) = 0
		_HeightScale("Height Scale, Constant", Float) = 0.25
		_HeightScaleModulated("Height Scale, Modulated", Float) = 0.75

		[Space]
		[Header(Water Fog parameter)]
		[Space]
		_WaterFogColor("Water Fog Color", Color) = (0, 0, 0, 0)
		_WaterFogDensity("Water Fog Density", Range(0, 2)) = 0.1
		_RefractionStrength("Refraction Strength", Range(0, 2)) = 0.25
		[Space]
		[Header(Intersection parameter)]
		[Space]
		_FoamAmount("Foam Amount",Float) = 1
		_FoamSpeed("Foam Speed",Float) = 1
		_FoamCutOff("Foam CutOff",Float) = 1
		_FoamScale("Foam Scale",Float) = 1
		_FoamColor("Foam Color",Color) = (0, 0, 0, 0)
		[Space]
		[Header(Ripples parameter)]
		[Space]
		[Toggle]_RippleDebugMode("Ripple DebugMode",Int) = 1
		_RippleFrequence("Ripple Frequence",Float) = 1
		_RippleDistance("Ripple Distance",Float) = 1
		_RippleFallOffX("Ripple FallOff X",Range(-1, 1)) = 1
		_RippleFallOffY("Ripple FallOff Y",Range(-1, 1)) = 1
		_RippleSpeed("Ripple Speed",Float) = 1
		_RippleScale("Ripple Scale",Float) = 1
		_RippleOffsetX("Ripple Offset X",Float) = 0
		_RippleOffsetY("Ripple Offset Y",Float) = 0

		[Space]
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader
		{
			Tags {"RenderType" = "Transparent" "Queue" = "Transparent" }
			LOD 200
			//Cull Off

			GrabPass { "_WaterBackground" }// ajuster la couleur de l'arrière-plan

			CGPROGRAM
			#pragma surface surf Standard alpha finalcolor:ResetAlpha
			#pragma target 3.0

			//Distortion var :
			sampler2D _MainTex, _FlowMap, _DerivHeightMap;
			float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;
			float _HeightScale, _HeightScaleModulated;
			int _RippleDebugMode;
			#include "Flow.cginc"
			#include "Ripples.cginc"

			#include "LookingThroughWater.cginc"
			#include "SurfaceIntersection.cginc"
			struct Input
			{
				float2 uv_MainTex;
				float4 screenPos;
				float3 worldPos;
			};



			half _Glossiness;
			half _Metallic;
			fixed4 _Color , _FoamColor;

			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_INSTANCING_BUFFER_END(Props)

			float3 UnpackDerivativeHeight(float4 textureData) {
				float3 dh = textureData.agb;
				dh.xy = dh.xy * 2 - 1;
				return dh;
			}

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				// Flow
				float3 flow = tex2D(_FlowMap, IN.uv_MainTex).rgb;
				flow.xy = flow.xy * 2 - 1;
				flow *= _FlowStrength;

				float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
				float time = _Time.y * _Speed + noise;
				float2 jump = float2(_UJump, _VJump);

				float3 uvwA = FlowUVW(IN.uv_MainTex, jump, _FlowOffset, _Tiling, flow.xy, time, false);
				float3 uvwB = FlowUVW(IN.uv_MainTex, jump, _FlowOffset, _Tiling, flow.xy, time, true);

				fixed4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
				fixed4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;

				fixed4 c = (texA + texB) * _Color;

				float finalHeightScale = length(flow.z) * _HeightScaleModulated + _HeightScale;
				float3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy)) * (uvwA.z * finalHeightScale);
				float3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy)) * (uvwB.z * finalHeightScale);

				// Foam
				fixed4 foam = Intersection(IN.screenPos, IN.uv_MainTex) * _FoamColor.a;

				o.Albedo = c.rgb;
				o.Normal = normalize(float3(-(dhA.xy + dhB.xy) + Ripples(IN.worldPos, o.Normal), 1));
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;

				// Below Water
				if (_RippleDebugMode == 1) {
					o.Emission = Ripples(IN.worldPos, o.Normal);
				}
				else {
					o.Emission = ColorBelowWater(IN.screenPos, o.Normal) * (1 - c.a) + foam.rgb;
				}
			}

			void ResetAlpha(Input IN, SurfaceOutputStandard o, inout fixed4 color) {
				color.a = 1;
			}
			ENDCG
		}
}
