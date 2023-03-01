Shader "PF/Texture"
{
    Properties
    {
        [Header(Textures)]
        [Space(10)]
        
        _MainTex ("Main", 2D) = "white" {}
        
        [Header(Settings)]
        [Space(10)]
        
        _SpeedX("X Speed", Float) = 0
        _SpeedY("Y Speed", Float) = 0
        
        [Header(Rendering)]
        [Space(10)]
        
        [KeywordEnum(Normal, Additive, Multiply)] _BlendEnum("Overlay", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend1("", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend2("", Float) = 0
        [Space(10)]
                
        _Emission("Emission", Range(0, 10)) = 1
        _Color("Tint Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
            "PreviewType" = "Plane"
        }

        LOD 100

        Pass
        {
            ZWrite On
            Blend [_Blend1] [_Blend2]

            CGPROGRAM

            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "UnityCG.cginc"

            #define USE_SCROLL
            #define USE_OPAQUE

            #include "Include/Unlit.cginc"

            ENDCG
        }
    }
    
    CustomEditor "PFShaderGUI"
}