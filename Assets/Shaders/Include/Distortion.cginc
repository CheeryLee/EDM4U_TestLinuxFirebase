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
        float2 uv1 : TEXCOORD0;
        float2 uv2 : TEXCOORD1;
        fixed4 color : COLOR;
    };

    sampler2D _MainTex;
    sampler2D _MaskTex;

    fixed4 _MainTex_ST;
    fixed4 _MaskTex_ST;
    fixed4 _Color;
    float _Emission;

    float _Strength;
    float _ChannelX;
    float _ChannelY;
    float _DSpeedX;
    float _DSpeedY;
    float _DScaleX;
    float _DScaleY;
    
    float _SpeedX;
    float _SpeedY;
                
    fdata vert (vdata i)
    {
        fdata o;

        UNITY_SETUP_INSTANCE_ID(i);
        
        float2 s1 = float2(_SpeedX, _SpeedY);
        float2 s2 = float2(_DSpeedX, _DSpeedY);

        // Transform position to clip space
        // More efficient than computing M*VP matrix product
        o.vertex = UnityObjectToClipPos(i.vertex);

        // Calculate main tiling and offset with scrolling by time
        o.uv1 = i.uv * _MainTex_ST.xy + _MainTex_ST.zw + frac(s1 * _Time.y);
        
        // Calculate mask tiling and offset with scrolling by time
        o.uv2 = i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw + frac(s2 * _Time.y);

        // Add vertex color
        o.color = _Color * i.color;
        
        // Add emission
        o.color.rgb *= _Emission;
        
        return o;
    }

    fixed4 frag (fdata i) : SV_Target
    {
        fixed4 d = tex2D(_MaskTex, frac(i.uv2));

        #ifdef USE_DEBUG
            return d;
        #endif

        float2 offset = _Strength * (float2(d[_ChannelX], d[_ChannelY]) * 2 - 1.0);
        fixed4 c = tex2D(_MainTex, frac(i.uv1) + offset) * i.color;
        
        // Premultiply color
        c.rgb *= c.a;

        return c;
    }