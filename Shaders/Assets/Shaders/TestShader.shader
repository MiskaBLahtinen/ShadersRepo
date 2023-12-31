Shader "Custom/TestiShader"
{
    Properties
    {
       _Color("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

             HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXTCOORD0;
                float3 normalDir : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END
            

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                //output.positionHCSoma = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))))
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalDir = TransformObjectToWorld(input.normalOS);

                return output;
            }

            float4 Frag(const Varyings input) : SV_TARGET
            {
                return half4(input.positionWS, 1);
                //return _Color * clamp(input.normalDir.x, -input.normalDir.x, 1);
            }

            ENDHLSL

        }
       
    }
}
