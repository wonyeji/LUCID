﻿Shader "Custom/MyForceField"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.0
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_RimColor("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower("Rim Power", Range(0.0,10.0)) = 9.0
		_RimTexture("Rim Texture", 2D) = "white"{}
		_AlphaTexture("Alpha Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 200

        Pass{
        //https://docs.unity3d.com/Manual/SL-CullAndDepth.html
            ZWrite Off
            ColorMask 0
		}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _RimTexture;
		sampler2D _AlphaTexture;

       
        struct Input
        {
            float2 uv_MainTex;
			float2 uv_RimTexture;
			float2 uv_AlphaTexture;
			float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		float4 _RimColor;
		float _RimPower;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			fixed4 r = tex2D(_RimTexture, IN.uv_RimTexture);
			fixed4 f = tex2D(_AlphaTexture, IN.uv_AlphaTexture);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			o.Emission = _RimColor.rgb * pow(rim, _RimPower) * r * 2;
			//o.Alpha = c - 1;
            o.Alpha = 0;
            //clip(o.Emission);
        }
        ENDCG
    }
    FallBack "Transparent/VertexLit"
}
