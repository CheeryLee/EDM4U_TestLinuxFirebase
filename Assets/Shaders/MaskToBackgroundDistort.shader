Shader "PF/MaskToBackgroundDistort"
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
		
		
        _DistTex ("Distortion Texture", 2D) = "white" {}
        
        _Strength("Strength", Range(0, 1)) = 0.1
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelX("X Distortion Channel", Float) = 0
        [KeywordEnum(Red, Green, Blue, Alpha)] _ChannelY("Y Distortion Channel", Float) = 1

        _DSpeedX("X Distortion Speed", Range(-1, 1)) = 0
        _DSpeedY("Y Distortion Speed", Range(-1, 1)) = 0
        [Space(10)]

        _SpeedX("X Speed", Float) = 0
        _SpeedY("Y Speed", Float) = 0
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
                float2 distcoord: TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _BackTex;
             sampler2D _DistTex;
               
            fixed _ScaleFactorX;
			fixed _ScaleFactorY;
			fixed _xOffset;
			fixed _yOffset;
			
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
                
                OUT.color = IN.color * _Color * _RendererColor;
                
                float2 s1 = float2(_SpeedX, _SpeedY);
                float2 s2 = float2(_DSpeedX, _DSpeedY);
            
                // Calculate main tiling and offset with scrolling by time
                OUT.texcoord = IN.texcoord * _MainTex_ST.xy + _MainTex_ST.zw + frac(s1 * _Time.y);
        
                // Calculate distortion tiling and offset with scrolling by time
                OUT.distcoord = IN.texcoord * _DistTex_ST.xy + _DistTex_ST.zw + frac(s2 * _Time.y);
            
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif
                
                float2 scaleFactor = float2(_ScaleFactorX, _ScaleFactorY);
                OUT.backcoord = ComputeScreenPos(OUT.vertex)*scaleFactor + float2(_xOffset, _yOffset);
            
                return OUT;
            }
            
            fixed4 frag (fdata IN) : SV_Target
            {
               // fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;


                fixed4 d = tex2D(_DistTex, frac(IN.distcoord));
                
                float2 offset = _Strength * (float2(d[_ChannelX], d[_ChannelY]) * 2 - 1.0);
                fixed4 c = SampleSpriteTexture(frac(IN.texcoord) + offset) * IN.color;

	            fixed4 alpha = tex2D (_MainTex, IN.texcoord); 
				c.a *= alpha.a;
                c.rgb = tex2D(_BackTex, IN.backcoord).rgb;
                
                return c;
            }
        ENDCG
        }
    }
    
}
