Shader "PF/Color"
{
    Properties
    {
        [Header(Settings)]
        [Space(10)]
        
        _Color("Color", Color) = (1, 1, 1, 1)
        
        [Header(Rendering)]
        [Space(10)]
        
        [Toggle] _ZWriteToggle("Z Write", Float) = 0
        [HideInInspector] [KeywordEnum(Off, On)] _ZWrite("", Float) = 0
        
        [KeywordEnum(Normal, Additive, Multiply)] _BlendEnum("Overlay", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend1("", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend2("", Float) = 0
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
            
            #include "Include/Color.cginc"
            
            ENDCG
        }
    }
}
