Shader "Sprites/Distortion"
{
    Properties
    {
        [PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}
        [PerRendererData] _Color ("Tint", Color) = (1, 1, 1, 1)

        [NoScaleOffset] _DisTex ("Distortion Texture", 2D) = "white" {}

        _DisPower("Distortion Power", Range(0, 1)) = 0.1

        _DisSpeedX("X Distortion Scroll Speed", Range(-1, 1)) = 0
        _DisSpeedY("Y Distortion Scroll Speed", Range(-1, 1)) = 0
        
        _DisScaleX("X Distortion Scale", float) = 1.0
        _DisScaleY("Y Distortion Scale", float) = 1.0

        _MainSpeedX("X Texture Scroll Speed", Range(-1, 1)) = 0
        _MainSpeedY("Y Texture Scroll Speed", Range(-1, 1)) = 0


        [Toggle(VIEW_DIS)] _ViewDis("Debug View Distortion", Float) = 0
    }

    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Opaque" 
            "PreviewType" = "Plane"
            "CanUseSrpiteAtlas" = "True"
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

            #pragma shader_feature VIEW_DIS

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                half2 uv1 : TEXCOORD0;
                half2 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _DisTex;

            fixed4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            fixed4 _Color;

            float _DisPower;
            float _DisSpeedX;
            float _DisSpeedY;
            float _DisScaleX;
            float _DisScaleY;
            float _MainSpeedX;
            float _MainSpeedY;
                        
            v2f vert (appdata i)
            {
                half2 mspeed = half2(_MainSpeedX, _MainSpeedY);
                half2 dspeed = half2(_DisSpeedX, _DisSpeedY);
                half2 dscale = half2(_DisScaleX, _DisScaleY);

                v2f o;
                
                o.vertex = UnityObjectToClipPos(i.vertex);
                o.color = i.color * _Color;


                o.uv1 = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv2 = dscale * (o.uv1 + dspeed * _Time.y);
                o.uv1 += mspeed * _Time.y - _MainTex_TexelSize.xy * 0.5;
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half2 offset = _DisPower * (tex2D(_DisTex, frac(i.uv2)) * 2 - 1.0);

                #ifdef VIEW_DIS
                    fixed4 c = tex2D(_DisTex, frac(i.uv2));
                #else
                    fixed4 c = tex2D(_MainTex, frac(i.uv1) + offset) * i.color;
                #endif

                c.rgb *= c.a;

                return c;
            }
            ENDCG
        }
    }
}