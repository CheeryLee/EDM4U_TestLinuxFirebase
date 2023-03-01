Shader "PF/TutorialRT"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "ForceNoShadowCasting" = "True"
            "PreviewType" = "Plane"
        }

        LOD 100
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            
            struct vdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
        
            struct fdata
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };
        
            sampler2D _MainTex;
            float4 _MainTex_ST;

            fdata vert (vdata i)
            {
                fdata o;

                // Transform position to clip space
                // More efficient than computing M*VP matrix product
                o.vertex = UnityObjectToClipPos(i.vertex);
        
                // Calculate tiling and offset
                o.uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                o.color = i.color;

                return o;
            }
        
            fixed4 frag (fdata i) : SV_Target
            {
                fixed a = 1.0f - tex2D(_MainTex, i.uv).r;
                
                fixed4 c = fixed4(i.color.rgb, min(a, i.color.a));
                
                c.rgb *= c.a;
                
                return c;
            }

            ENDCG
        }
    }
}
