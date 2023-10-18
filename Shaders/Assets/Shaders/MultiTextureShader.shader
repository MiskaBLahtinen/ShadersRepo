Shader "Custom/MultiShader"
{
    Properties
    {
        _MainTex("Main texture", 2D) = "white" {}
        _SubTex("Sub texture", 2D) = "white" {}
        _DividerTex("Dividing texture", 2D) = "white" {}

        _Offset("Offset", float) = 1.0
        _Blend("Blending", float) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            //Yhdistää TEXTURE2D & SAMPLER? --> voi suoraan sämplätä tex2D(tektuuri, uv)
            sampler2D _MainTex;
            sampler2D _SubTex;
            sampler2D _DividerTex;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _SubTex_ST;
            float4 _DividerTex_ST;
            float _Offset;
            float _Blend;
            CBUFFER_END
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv;

                return output;
            }


            float4 frag (Varyings input) : SV_TARGET
            {
                half4 textureChange;

                if((input.uv.x * _Offset) % 2 < 1)
                    textureChange = tex2D(_DividerTex, input.uv);
                else
                    textureChange = tex2D(_SubTex, input.uv);

                return lerp(tex2D(_MainTex, input.uv), textureChange, _Blend); //Ei varsinaisesti tarpeellinen tällä ratkaisulla, mutta antaa kivan efektin
            }

            ENDHLSL
        }

        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
    
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
    
            HLSLPROGRAM
    
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
             // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
             #include "Common/DepthOnly.hlsl"
             ENDHLSL
        }

        Pass
        {
            Name "Normals"
            Tags { "LightMode" = "DepthNormalsOnly" }
    
            Cull Back
            ZTest LEqual
            ZWrite On
    
            HLSLPROGRAM
    
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag

            #include "Common/DepthNormalsOnly.hlsl"
    
            ENDHLSL
        }

    }
}