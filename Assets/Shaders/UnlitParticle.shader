Shader "PF/Particle"
{
    Properties
    {
        [Header(Textures)]
        [Space(10)]
        
        _MainTex ("Main", 2D) = "white" {}
        
        [Header(Rendering)]
        [Space(10)]

        _Emission("Emission", Range(0, 10)) = 1
        [KeywordEnum(Normal, Additive, Multiply)] _BlendEnum("Overlay", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend1("", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend2("", Float) = 0
        
        [Header(Stecil)]
        [Space(10)]

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
            "PreviewType" = "Plane"
        }

        LOD 100

        Pass
        {
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }

            Cull Off
            ZWrite Off
            Blend [_Blend1] [_Blend2]
            ColorMask [_ColorMask]

            CGPROGRAM

            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #include "Include/Particle.cginc"
            
            ENDCG
        }
    }
    
    CustomEditor "PFShaderGUI"
}
