    struct vdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        fixed4 color : COLOR;
    };

    struct fdata
    {
        float4 vertex : SV_POSITION;
        float2 uv1 : TEXCOORD0;
        fixed4 color : COLOR;

        #ifdef USE_MASK
            float2 uv2 : TEXCOORD1;
        #endif
    };

    sampler2D _MainTex;
    float _Emission;
    
    #ifdef USE_MASK
        sampler2D _MaskTex;
        float _Channel;
    #endif
    
    fdata vert (vdata i)
    {
        fdata o;
        
        // Transform position to clip space
        // More efficient than computing M*VP matrix product
        o.vertex = UnityObjectToClipPos(i.vertex);

        // Calculate tiling and offset
        o.uv1 = i.uv;
        
        // Add vertex color
        o.color = i.color;
        
        // Add emission
        o.color.rgb *= _Emission;
        
        #ifdef USE_MASK
            o.uv2 = ComputeScreenPos(o.vertex);
        #endif

        return o;
    }

    fixed4 frag (fdata i) : SV_Target
    {
        fixed4 c = tex2D(_MainTex, i.uv1) * i.color;
        
        #ifdef USE_MASK
            c.a *= tex2D(_MaskTex, i.uv2)[_Channel];
        #endif
        
        // Premultiply color
        c.rgb *= c.a;
        
        return c;
    }