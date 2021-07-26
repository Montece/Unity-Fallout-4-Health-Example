﻿Shader "Scanline Highlight/PBR (metalness workflow)" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo texture (sRGB)", 2D) = "white" {}
		_BumpTex ("Normal texture", 2D) = "bump" {}
		_MetalSmoothTex ("Metalness (R) & Smoothness (A) texture", 2D) = "grey" {}
		[KeywordEnum(Smoothness,Roughness)] _Type ("Smoothness / Roughness texture type", Float) = 0
		_AOTex ("Occlusion / Cavity (R) texture", 2D) = "white" {}
		_LineTex ("Lines (R)", 2D) = "black" {}
		_HighlightColor ("Highlight color (RGB)", Color) = (0.4,1,0.2,1)
		_RimPower ("Edge sharpness", Range(0,16)) = 2
		_LinesX ("Line tiling (X)", Range(0,256)) = 64
		_LinesY ("Line tiling (Y)", Range(0,256)) = 128
		_LineSpeedX ("Line speed (X)", Range(-4,4)) = 0
		_LineSpeedY ("Line speed (Y)", Range(-4,4)) = 0

		_RimVis ("Edge visibility", Range(0,1)) = 1
		_LineVis ("Line visibility", Range(0,1)) = 1
		_BaseVis ("Highlight color overlay visibility", Range(0,1)) = 0.2

	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		//#pragma multi_compile _TYPE_ROUGHNESS, _TYPE_SMOOTHNESS

		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D _MetalSmoothTex;
		sampler2D _AOTex;
		sampler2D _LineTex;

		struct Input 
		{
			float2 uv_MainTex;
			float3 viewDir;
			float4 screenPos;
		};

		fixed4 _Color;
		fixed4 _HighlightColor;
		fixed _RimVis;
		fixed _LineVis;
		fixed _BaseVis;
		half _RimPower;
		half _LineSpeedX;
		half _LineSpeedY;
		int _LinesX;
		int _LinesY;

		float _Type;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Get the color of this pixel
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			// Get Screen space UV
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			if (_LineSpeedX != 0) screenUV.x += _Time.x * 2 * _LineSpeedX;
			if (_LineSpeedY != 0) screenUV.y += _Time.x * 2 * _LineSpeedY;
			screenUV *= float2(_LinesX, _LinesY);
			 
			// Apply line texture on the base texture //
			////////////////////////////////////////////
			// Get the line texture
			fixed lineTex = tex2D(_LineTex, screenUV).r;

			// Get the line color values
			fixed3 highlight = (lineTex.r * _HighlightColor.rgb) * _LineVis;
			// Calculate the blend value between albedo and lines
			fixed value = lineTex.r * _LineVis;
			// Calculate the base color value (albedo blended with the base color overlay)
			fixed3 base = (c.rgb * (1-_BaseVis)) + (_HighlightColor * _BaseVis);
			o.Albedo = (base * (1-value)) + (highlight * value);

			// Apply the normal map
			o.Normal = UnpackNormal (tex2D(_BumpTex, IN.uv_MainTex));

			// Rim highlighting
			fixed rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
			o.Emission = _HighlightColor.rgb * pow(rim, _RimPower) * _RimVis;

			// Apply occlusion
			o.Occlusion = tex2D(_AOTex, IN.uv_MainTex).r;

			// Apply metalness and roughness (the inverted vartiant of a smoothness map)
			fixed4 mrt = tex2D(_MetalSmoothTex, IN.uv_MainTex);
			o.Metallic = mrt.r;
			if (_Type <= 0)
				o.Smoothness = mrt.a;
			else
				o.Smoothness = saturate(1-mrt.a);

			// Apply alpha
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}