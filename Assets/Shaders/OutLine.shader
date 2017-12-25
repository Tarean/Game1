// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/OutLine"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainColor("MainColor",Color) = (1,1,1,1)

		//边缘光颜色
		_RimColor("RimColor",Color) = (1,1,1,1)
		//边缘光强度
		_RimPower("RimPower",Range(0.0001,8.0)) = 3.0

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _RimColor;
			float _RimPower;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
			};
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir = WorldSpaceViewDir(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed4 color = tex2D(_MainTex,i.uv);

				float worldViewDir = normalize(i.worldViewDir);
				float rim = 1-max(0,dot(worldViewDir,worldNormal));
				fixed3 rimColor = _RimColor.rgb * pow(rim,_RimPower);
				color.rgb+= rimColor;

				return fixed4(color);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
