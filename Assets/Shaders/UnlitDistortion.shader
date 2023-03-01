Shader "PF/Distortion"
{
    Properties
    {
        [Header(Textures)]
        [Space(10)]
        
        _MainTex ("Main", 2D) = "white" {}
        _MaskTex ("Mask", 2D) = "white" {}
        
        [Header(Settings)]
        [Space(10)]
        
        _Strength("Strength", Range(0, 1)) = 0.1
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelX("X Mask Channel", Float) = 0
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelY("Y Mask Channel", Float) = 1

        _DSpeedX("X Distortion Speed", Range(-1, 1)) = 0
        _DSpeedY("Y Distortion Speed", Range(-1, 1)) = 0
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
        [Toggle(USE_DEBUG)] _ViewDis("Debug View", Float) = 0
    }

    SubShader
    {
        Tags
        { 
            "RenderType" = "Opaque" 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
            "PreviewType" = "Plane"
        }

        ZWrite [_ZWrite]
        Blend [_Blend1] [_Blend2]

        Pass
        {
            CGPROGRAM

            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "UnityCG.cginc"

            #pragma shader_feature USE_DEBUG

            #include "Include/Distortion.cginc"

            ENDCG
        }
    }
    
    CustomEditor "PFShaderGUI"
}
