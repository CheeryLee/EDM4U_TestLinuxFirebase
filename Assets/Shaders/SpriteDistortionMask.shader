Shader "PF/SpriteDistortionMask"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        
        [Header(Textures)]
        [Space(10)]
        
        _DistTex ("Distortion Texture", 2D) = "white" {}
        [NoScaleOffset] _MaskTex ("Sprite Mask", 2D) = "white" {}
        
        [Header(Settings)]
        [Space(10)]
                
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelMask("Mask Channel", Float) = 3

        _Strength("Strength", Range(0, 1)) = 0.1
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelX("X Distortion Channel", Float) = 0
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelY("Y Distortion Channel", Float) = 1

        _DSpeedX("X Distortion Speed", Range(-1, 1)) = 0
        _DSpeedY("Y Distortion Speed", Range(-1, 1)) = 0
        [Space(10)]

        _SpeedX("X Speed", Float) = 0
        _SpeedY("Y Speed", Float) = 0
        
        [HideInInspector] _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            
            #include "UnitySprites.cginc"
            
            struct fdata
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                float2 maskcoord: TEXCOORD1;
                float2 distcoord: TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _DistTex;
            sampler2D _MaskTex;
        
            fixed4 _MainTex_ST;
            fixed4 _DistTex_ST;
        
            float _ChannelMask;
            float _Strength;
            float _ChannelX;
            float _ChannelY;
            float _DSpeedX;
            float _DSpeedY;
            float _DScaleX;
            float _DScaleY;
            
            float _SpeedX;
            float _SpeedY;
            
            fdata vert (appdata_t IN)
            {
                fdata OUT;
            
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
            
                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                
                float2 s1 = float2(_SpeedX, _SpeedY);
                float2 s2 = float2(_DSpeedX, _DSpeedY);
        
                // Calculate main tiling and offset with scrolling by time
                OUT.texcoord = IN.texcoord * _MainTex_ST.xy + _MainTex_ST.zw + frac(s1 * _Time.y);
        
                // Calculate distortion tiling and offset with scrolling by time
                OUT.distcoord = IN.texcoord * _DistTex_ST.xy + _DistTex_ST.zw + frac(s2 * _Time.y);
        
                OUT.color = IN.color * _Color * _RendererColor;
            
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif
                
                OUT.maskcoord = ComputeScreenPos(OUT.vertex);
            
                return OUT;
            }
            
            fixed4 frag (fdata IN) : SV_Target
            {
                fixed4 d = tex2D(_DistTex, frac(IN.distcoord));
                
                float2 offset = _Strength * (float2(d[_ChannelX], d[_ChannelY]) * 2 - 1.0);
                fixed4 c = SampleSpriteTexture(frac(IN.texcoord) + offset) * IN.color;
                
                c.a *= tex2D(_MaskTex, IN.maskcoord)[_ChannelMask];
                c.rgb *= c.a;
                
                return c;
            }
        ENDCG
        }
    }
}