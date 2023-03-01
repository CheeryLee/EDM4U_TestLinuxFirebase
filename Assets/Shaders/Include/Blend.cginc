    struct vdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        fixed4 color : COLOR;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct fdata
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        fixed4 color : COLOR;
    };

    sampler2D _MainTex;
    sampler2D _SecondTex;
    float4 _MainTex_ST;
    fixed4 _Color;
    float _Emission;
    float _Blend;
    
    #ifdef USE_CUTOUT
        fixed _Cutout;
    #endif
    
    #ifdef USE_SCROLL
        float _SpeedX;
        float _SpeedY;
    #endif

    fdata vert (vdata i)
    {
        fdata o;
        
        UNITY_SETUP_INSTANCE_ID(i);
        
        // Transform position to clip space
        // More efficient than computing M*VP matrix product
        o.vertex = UnityObjectToClipPos(i.vertex);

        // Calculate tiling and offset
        o.uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
        
        #ifdef USE_SCROLL
            o.uv += frac(float2(_SpeedX, _SpeedY) * _Time.y);
        #endif
        
        // Add vertex color
        o.color = _Color * i.color;
        
        // Add emission
        o.color.rgb *= _Emission;

        return o;
    }

    fixed4 frag (fdata i) : SV_Target
    {
        fixed4 c1 = tex2D(_MainTex, i.uv);
        fixed4 c2 = tex2D(_SecondTex, i.uv);
        
        fixed4 c = lerp(c1, c2, _Blend);
        
        #ifdef USE_CUTOUT
            clip(c.a - _Cutout);
        #endif
        
        // Tint color
        c *= i.color;
        
        #ifdef USE_OPAQUE
            // Fully opaque
            c.a = 1;
        #else
            // Premultiply color
            c.rgb *= c.a;            
        #endif
        
        return c;
    }