Shader "Custom/voronoi_noise" {
	Properties{
		[Space]
		[Header(Voronoi parameter)]
		[Space]
		_CellSize("Cell Size", Range(0, 5)) = 2
		_ShiftSpeed("Shift Speed", Range(0, 1)) = 0.5
		_Amplitude("Amplitude",Float) = 16.0
		_Density("Density",Range(0, 1)) = .5
		[Space]
		[Header(Texture parameter)]
		[Space]
		_Color("Color", Color) = (1,1,1,1)
	}
		SubShader{
			Tags{ "RenderType" = "Transparent" "Queue" = "Transparent"}

			CGPROGRAM

			#pragma surface surf Standard alpha
			#include "Random.cginc"

			float _CellSize;
			float _ShiftSpeed;
			float3 _BorderColor;
			float _Amplitude;
			fixed4 _Color;
			float _Density;

			struct Input {
				float3 worldPos;
			};

			float3 voronoiNoise(float3 value) {
				float3 baseCell = floor(value);

				//first pass to find the closest cell
				float minDistToCell = 10;
				float3 toClosestCell;
				float3 closestCell;
				[unroll]
				for (int x1 = -1; x1 <= 1; x1++) {
					[unroll]
					for (int y1 = -1; y1 <= 1; y1++) {
						[unroll]
						for (int z1 = -1; z1 <= 1; z1++) {
							float3 cell = baseCell + float3(x1, y1, z1);
							float3 cellPosition = cell + rand3dTo3d(cell);
							float3 toCell = cellPosition - value;
							float distToCell = length(toCell);
							if (distToCell < minDistToCell) {
								minDistToCell = distToCell;
								closestCell = cell;
								toClosestCell = toCell;
							}
						}
					}
				}

				//second pass to find the distance to the closest edge
				float minEdgeDistance = 10;
				[unroll]
				for (int x2 = -1; x2 <= 1; x2++) {
					[unroll]
					for (int y2 = -1; y2 <= 1; y2++) {
						[unroll]
						for (int z2 = -1; z2 <= 1; z2++) {
							float3 cell = baseCell + float3(x2, y2, z2);
							float3 cellPosition = cell + rand3dTo3d(cell);
							float3 toCell = cellPosition - value;

							float3 diffToClosestCell = abs(closestCell - cell);
							bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
							if (!isClosestCell) {
								float3 toCenter = (toClosestCell + toCell) * 0.5;
								float3 cellDifference = normalize(toCell - toClosestCell);
								float edgeDistance = dot(toCenter, cellDifference);
								minEdgeDistance = min(minEdgeDistance, edgeDistance);
							}
						}
					}
				}

				float random = rand3dTo1d(closestCell);
				return float3(minDistToCell, random, minEdgeDistance);
		}

			void surf(Input i, inout SurfaceOutputStandard o) {
				float3 value = i.worldPos.xyz / _CellSize;
				value.z += _Time.y * _ShiftSpeed;
				float3 noise = voronoiNoise(value);

				noise.x = smoothstep(0, _Density, noise.x);
				o.Albedo = _Color;
				o.Normal = sin((noise.x) * _Amplitude); +smoothstep(0, .1, _ShiftSpeed);
			}

		ENDCG
		}
			//FallBack "Diffuse"
}