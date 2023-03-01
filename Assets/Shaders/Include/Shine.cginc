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

    sampler2D _MaskTex;
    
    float4 _MaskTex_ST;
    fixed4 _Color;
    
    float _Position;
    float _Width;
    float _Smooth;
    float _Channel;
    
    float _SpeedX;
    float _SpeedY;    

    fdata vert (vdata i)
    {
        fdata o;

        UNITY_SETUP_INSTANCE_ID(i);
        
        // Transform position to clip space
        // More efficient than computing M*VP matrix product
        o.vertex = UnityObjectToClipPos(i.vertex);

        // Calculate main tiling and offset
        o.uv = i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw + frac(float2(_SpeedX, _SpeedY) * _Time.y);
        
        // Add vertex color
        o.color = _Color * i.color;

        return o;
    }
    
    fixed4 frag (fdata i) : SV_Target
    {
        fixed4 c = i.color;
        float t = abs(tex2D(_MaskTex, i.uv)[_Channel] - _Position);
        
        float w1 = _Width;
        float w2 = w1 * _Smooth;
        float w3 = w1 * (1 - _Smooth);
        
        c = step(w1, t) * fixed4(0, 0, 0, 0) +
            step(w2, t) * step(t, w1) * lerp(c, fixed4(c.rgb, 0), (t - w2) / w3) +
            step(t, w2) * c;
            
        // Premultiply color
        c.rgb *= c.a;
        
        return c;
        
        /*
        
        This is normal version of code for optimized code above (used 'step' function for 'if' conditions)
        
        if (t <= w2)
            return c;

        if (t <= w1)
            return lerp(c, fixed4(c.rgb, 0), (t - w2) / w3);
            
        return fixed4(0, 0, 0, 0);
        
        */
    }
