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
    
    float4 _MainTex_ST;
    float4 _MaskTex_ST;
    fixed4 _Color;
    float _Emission;

    float _Strength;
    float _Channel;
    
    #ifdef USE_BORDER
        sampler2D _BorderTex;
        fixed4 _BorderColor;    
        float _BorderSize;
        float _BorderSmooth;
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

        // Calculate main tiling and offset
        o.uv1 = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
        
        #ifdef USE_SCROLL
            o.uv1 += frac(float2(_SpeedX, _SpeedY) * _Time.y);
        #endif

        // Calculate mask tiling and offset
        o.uv2 = i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw;

        // Add vertex color
        o.color = _Color * i.color;
        
        // Add emission
        o.color.rgb *= _Emission;

        return o;
    }

    #ifdef USE_BORDER
    
        fixed4 frag (fdata i) : SV_Target
        {
            float e = 0.00001;
            
            fixed4 c = tex2D(_MainTex, i.uv1) * i.color;
            float t = tex2D(_MaskTex, i.uv2)[_Channel] - _Strength;
                    
            float bp = t / _BorderSize * 0.5;
            float4 bc = tex2D(_BorderTex, float2(bp, bp)) * _BorderColor;
            
            float bm = _BorderSmooth + e;
            float bs = _BorderSize + e;
            
            float p1 = bs * bm;
            float p2 = bs * (1 - bm);
            
            float b1 = bs + p2;
            float b2 = b1 + p1;
    
            c = step(t, 0) * fixed4(0, 0, 0, 0) + step(b2, t) * c
                + step(0, t) * step(t, p1) * lerp(fixed4(c.rgb, 0), bc, t / p1)
                + step(p1, t) * step(t, b1) * fixed4(bc.rgb, c.a)
                + step(b1, t) * step(t, b2) * lerp(fixed4(bc.rgb, c.a), c, (t - b1) / p1);
            
            // Premultiply color
            c.rgb *= c.a;
            
            return c;
    
            /*
            
            This is normal version of code for optimized code above (used 'step' function for 'if' conditions)  
            
            if (t <= 0)
                return fixed4(0, 0, 0, 0);
                        
            if (t < p1)
                return lerp(fixed4(c.rgb, 0), bc, t / p1);
                
            if (t < b1)
                return fixed4(bc.rgb, c.a);
                
            if (t < b2)
                return lerp(fixed4(bc.rgb, c.a), c, (t - b1) / p1);
            
            return c;
            
            */
        }
    
    #else
    
        fixed4 frag (fdata i) : SV_Target
        {
            fixed4 c = tex2D(_MainTex, i.uv1) * i.color;
            float t = tex2D(_MaskTex, i.uv2)[_Channel] - _Strength;
            
            c = step(0, t) * c + step(t, 0) * fixed4(0, 0, 0, 0);
            
            // Premultiply color
            c.rgb *= c.a;
            
            return c;

            /*
            
            This is normal version of code for optimized code above (used 'step' function for 'if' conditions)  
            
            if (t <= 0)
                return fixed4(0, 0, 0, 0);
                        
            return c;
            
            */
        }
        
    #endif