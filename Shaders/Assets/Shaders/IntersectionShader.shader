Shader "Custom/IntersectionShader"
{
    Properties
	{
		_Color ("Color", Color) = (1,0,0,1)
		_IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }		

		Pass
		{
			Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }

			Cull Back
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM
			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
			};
			
			CBUFFER_START(UnityPerMaterial)
			float4 _Color;
			float4 _IntersectionColor;
			CBUFFER_END

			Varyings Vertex (Attributes input)
			{
				Varyings output;
				output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				return output;
			}

			float4 Fragment (Varyings input) : SV_TARGET
			{
				float4 depthTexture = LinearEyeDepth(SampleSceneDepth(GetNormalizedScreenSpaceUV(input.positionHCS)), _ZBufferParams);
				float4 depthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);

				float l = pow(1 - saturate(depthTexture - depthObject), 10);
				return lerp(_Color, _IntersectionColor, l);
			}
			 ENDHLSL
		}
    }
}
