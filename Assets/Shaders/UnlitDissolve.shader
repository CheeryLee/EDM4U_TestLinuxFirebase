Shader "PF/Dissolve"
{
    Properties
    {
        [Header(Textures)]
        [Space(10)]
        
        _MainTex("Main", 2D) = "white" {}
        _MaskTex("Mask", 2D) = "white" {}
                
        [Header(Settings)]
        [Space(10)]
        
        _Strength("Strength", Float) = 0
        [KeywordEnum(Red, Green, Blue, Alpha)] _Channel("Mask Channel", Float) = 0
        [Space(10)]
        
        _SpeedX("X Speed", Float) = 0
        _SpeedY("Y Speed", Float) = 0
                
        [Header(Rendering)]
        [Space(10)]
        
        [Toggle] _ZWriteToggle("Z Write", Float) = 0
        [HideInInspector] [KeywordEnum(Off, On)] _ZWrite("", Float) = 0
        
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
            "RenderType" = "Transparent"
            "Queue" = "Transparent+500"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
            "PreviewType" = "Plane"
        }

        LOD 100

        Pass
        {
            ZWrite [_ZWrite]
            Blend [_Blend1] [_Blend2]

            CGPROGRAM

            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "UnityCG.cginc"

            #define USE_SCROLL
            
            #include "Include/Dissolve.cginc"

            ENDCG
        }
    }
    
    CustomEditor "PFShaderGUI"
}
