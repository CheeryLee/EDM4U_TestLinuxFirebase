Shader "PF/Shine"
{
    Properties
    {
        [Header(Textures)]
        [Space(10)]
        
        _MaskTex("Mask", 2D) = "white" {}
                
        [Header(Settings)]
        [Space(10)]
        
        _Position("Position", Float) = 0
        _Width("Width", Float) = 0
        _Smooth("Smooth", Range (0, 1)) = 0
        [KeywordEnum(Red, Green, Blue, Alpha)] _Channel("Mask Channel", Float) = 0
        [Space(10)]

        _SpeedX("X Speed", Float) = 0
        _SpeedY("Y Speed", Float) = 0
                        
        [Header(Rendering)]
        [Space(10)]
        
        [Toggle] _ZWriteToggle("Z Write", Float) = 0
        [HideInInspector] [KeywordEnum(Off, On)] _ZWrite("", Float) = 0
        
        [KeywordEnum(Normal, Additive, Multiply)] _BlendEnum("Overlay", Float) = 1
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend1("", Float) = 0
        [HideInInspector] [Enum(UnityEngine.Rendering.BlendMode)] _Blend2("", Float) = 0
        [Space(10)]
        
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

            #include "Include/Shine.cginc"

            ENDCG
        }
    }
    
    CustomEditor "PFShaderGUI"
}
