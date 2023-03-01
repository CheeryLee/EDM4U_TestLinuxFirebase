Shader "PF/MaskToBackground"
{
 Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [NoScaleOffset] _BackTex ("Back Texture", 2D) = "white" {}
        [KeywordEnum(Red, Green, Blue, Alpha)] _Channel("Mask Channel", Float) = 3
        [HideInInspector] _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        
        _ScaleFactorX ("X scale factor", float) = 0
		_ScaleFactorY ("Y scale factor", float) = 1
		_xOffset ("X background offset", float) = 0
		_yOffset ("Y background offset", float) = 0
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
        Blend SrcAlpha OneMinusSrcAlpha

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
                float2 backcoord: TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _BackTex;
            fixed _ScaleFactorX;
			fixed _ScaleFactorY;
			fixed _xOffset;
			fixed _yOffset;

            fdata vert (appdata_t IN)
            {
                fdata OUT;
            
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                          
                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color * _RendererColor;
            
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif
                
                float2 scaleFactor = float2(_ScaleFactorX, _ScaleFactorY);
                OUT.backcoord = ComputeScreenPos(OUT.vertex)*scaleFactor + float2(_xOffset, _yOffset);
            
                return OUT;
            }
            
            fixed4 frag (fdata IN) : SV_Target
            {
                fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;

                c.rgb = tex2D(_BackTex, IN.backcoord).rgb;
                
                
                return c;
            }
        ENDCG
        }
    }
    
}
