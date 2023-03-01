Shader "PF/ParticleMask"
{
    Properties
    {
        [Header(Textures)]
        [Space(10)]
        
        _MainTex ("Main", 2D) = "white" {}
        [NoScaleOffset] _MaskTex ("Mask", 2D) = "white" {}
        
        [Header(Rendering)]
        [Space(10)]
        
        [KeywordEnum(Red, Green, Blue, Alpha)] _Channel("Mask Channel", Float) = 3

        _Emission("Emission", Range(0, 10)) = 1
        [KeywordEnum(Normal, Additive, Multiply)] _BlendEnum("Overlay", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend1("", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend2("", Float) = 0
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
            Cull Off
            ZWrite Off
            Blend [_Blend1] [_Blend2]

            CGPROGRAM

            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
    
            #define USE_MASK
            
            #include "Include/Particle.cginc"
            
            ENDCG
        }
    }
    
    CustomEditor "PFShaderGUI"
}