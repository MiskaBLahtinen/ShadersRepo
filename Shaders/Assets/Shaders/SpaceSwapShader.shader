Shader "Custom/SpaceSwapShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
       [KeywordEnum(Object, World, View)]
       _Space("Space", Float) = 0
       //^Täytyy olla sama teksti kuin kohdass TÄSSÄ -----------
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            #pragma vertex Vert
            #pragma fragment Frag

            #pragma shader_feature_local_vertex _SPACE_OBJECT _SPACE_WORLD _SPACE_VIEW
            //                          -------- ^TÄSSÄ ----------


            float4 Vert(float3 positionOS : POSITION) : SV_POSITION
            {
                float4 positionHCS;

                #if _SPACE_OBJECT
                positionHCS = TransformObjectToHClip(positionOS + float3(0,1,0));
                #elif _SPACE_WORLD
                const float3 positionWS = TransformObjectToWorld(positionOS);
                positionHCS = TransformWorldToHClip(positionWS + float3(0,1,0));
                #elif _SPACE_VIEW
                const float3 positionVS = TransformWorldToView(TransformObjectToWorld(positionOS));
                positionHCS = TransformWViewToHClip(positionVS + float3(0,1,0));
                #endif

                return positionHCS;
            }


            float4 Frag() : SV_TARGET
            {
                float4 col = 1;
                return col;
            }

            ENDHLSL

        }
       
    }
}
