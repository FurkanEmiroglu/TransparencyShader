Shader "Unlit/WaveShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
		
		ZTest GEqual
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert alpha
			#pragma fragment frag alpha
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			// light properties
			uniform float3 _lightDirection;
			uniform float4 _lightColor;

			// dissolve starting wp
			uniform float3 _dissolveStartingPos;

			// vertex anim properties
			uniform float _animationSpeed;
			uniform float _deformAmount;

			// transparency distance
			uniform float _transparencyDistance;

			struct meshData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct Interpolators
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 vertexWP : TEXCOORD2;
				float vertexDistance : TEXCOORD3;
				UNITY_FOG_COORDS(1)
			};

			Interpolators vert (meshData v)
			{
				Interpolators o;
				o.uv = v.uv;
				o.vertex = v.vertex;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.vertexDistance = distance(mul(unity_ObjectToWorld, v.vertex).xyz, _dissolveStartingPos);

				float3 deformDirection = o.normal.xyz;
				o.vertex.xyz += abs(sin(_Time.y * _animationSpeed)) * deformDirection * _deformAmount;
				
				// calculating world position
				o.vertexWP = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				// clip positioning
				o.vertex = UnityObjectToClipPos(o.vertex);
				
				// applying texture
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (Interpolators i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				float light = dot(-_lightDirection, i.normal.xyz);
				float4 returningColor;
				
				if (i.vertexDistance < _transparencyDistance)
					returningColor = fixed4(0,0,0,0);
				else if (i.vertexDistance < _transparencyDistance + 0.02)
				{
					fixed col = abs(sin(_Time.y * 250));
					returningColor = fixed4(col.xxx,1);
				}
					
				else
				{
					returningColor = col * (light * _lightColor);
					returningColor.a = 1;
				}

				return returningColor;
			}
			ENDCG
		}
	}
}