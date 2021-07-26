Shader "Scanline Highlight/Bicolor" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_BumpTex ("Normal texture", 2D) = "bump" {}
		_LineTex ("Lines (R)", 2D) = "black" {}
		_HighlightColor ("Highlight color (RGB)", Color) = (0.4,1,0.2,1)
		_RimPower ("Edge sharpness", Range(0,16)) = 2
		_LinesX ("Line tiling (X)", Range(0,256)) = 64
		_LinesY ("Line tiling (Y)", Range(0,256)) = 128
		_LineSpeedX ("Line speed (X)", Range(-4,4)) = 0
		_LineSpeedY ("Line speed (Y)", Range(-4,4)) = 0

		_RimVis ("Edge visibility", Range(0,1)) = 1
		_LineVis ("Line visibility", Range(0,1)) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _BumpTex;
		sampler2D _LineTex;

		struct Input 
		{
			float2 uv_BumpTex;
			float3 viewDir;
			float4 screenPos;
		};

		fixed4 _Color;
		fixed4 _HighlightColor;
		fixed _RimVis;
		fixed _LineVis;
		half _RimPower;
		half _LineSpeedX;
		half _LineSpeedY;
		int _LinesX;
		int _LinesY;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Get Screen space UV
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			if (_LineSpeedX != 0) screenUV.x += _Time.x * 2 * _LineSpeedX;
			if (_LineSpeedY != 0) screenUV.y += _Time.x * 2 * _LineSpeedY;
			screenUV *= float2(_LinesX, _LinesY);
			 
			// Apply line texture on the base texture //
			////////////////////////////////////////////
			// Get the line texture
			fixed lineTex = tex2D(_LineTex, screenUV).r;

			// ALBEDO - only do the blend calculation if there are visible lines to render
			if (_LineVis > 0)
			{
				// Get the line color values
				fixed3 highlight = (lineTex.r * _HighlightColor.rgb) * _LineVis;
				// Calculate the blend value between albedo and lines
				fixed value = lineTex.r * _LineVis;
				// Calcualate the albedo (blend between the main color and the highlight color)
				o.Albedo = (_Color.rgb * (1-value)) + (_HighlightColor * value);
			}
			else
			{
				o.Albedo = _Color.rgb;
			}

			// Apply the normal map
			o.Normal = UnpackNormal (tex2D(_BumpTex, IN.uv_BumpTex));

			// Rim highlighting (can skip this calculation if _RimVis is smaller or equals to 0)
			if (_RimVis > 0)
			{
				fixed rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
				o.Emission = _HighlightColor.rgb * pow(rim, _RimPower) * _RimVis;
			}

			// Apply alpha extraced from the main texture
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}