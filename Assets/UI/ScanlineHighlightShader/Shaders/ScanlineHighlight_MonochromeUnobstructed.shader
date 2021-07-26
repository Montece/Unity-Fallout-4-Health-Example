Shader "Scanline Highlight/Monochromatic Unobstructed" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_BumpTex ("Normal texture", 2D) = "bump" {}
		_LineTex ("Lines (R)", 2D) = "white" {}
		_RimPower ("Edge sharpness", Range(0,16)) = 2

		_LinesX ("Line tiling (X)", Range(0,256)) = 64
		_LinesY ("Line tiling (Y)", Range(0,256)) = 128
		_LineSpeedX ("Line speed (X)", Range(-4,4)) = 0
		_LineSpeedY ("Line speed (Y)", Range(-4,4)) = 0

		_RimVis ("Edge visibility", Range(0,1)) = 1
		_LineVis ("Line Constrast", Range(0,1)) = 0.5
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		ZTest Always
		ZWrite On
		
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
			 
			// Get the line texture
			fixed lineTex = tex2D(_LineTex, screenUV).r;

			// Calculate albedo
			if (_LineVis >= 1)
			{
				o.Albedo = _Color.rgb;
			}
			else
			{
				o.Albedo = _Color.rgb * saturate(lineTex/(1+(1-_LineVis*2)));
			}

			// Apply the normal map
			o.Normal = UnpackNormal (tex2D(_BumpTex, IN.uv_BumpTex));

			// Rim highlighting (can skip this calculation if _RimVis is smaller or equals to 0)
			if (_RimVis > 0)
			{
				fixed rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
				o.Emission = _Color.rgb * pow(rim, _RimPower) * _RimVis;
			}

			// Apply alpha extraced from the main texture
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}