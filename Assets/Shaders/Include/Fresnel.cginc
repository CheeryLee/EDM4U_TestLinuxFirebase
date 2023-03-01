    struct vdata
    {
        float4 vertex : POSITION;
        float3 normal: NORMAL;
        float2 uv : TEXCOORD0;
        fixed4 color : COLOR;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct fdata
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float rim: TEXCOORD1;  
        fixed4 color : COLOR;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;
    fixed4 _Color;
    float _Rim;
    float _Emission;

    #ifdef USE_MASK
       sampler2D _MaskTex;
    #else
       fixed4 _RimColor;
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
        
        // Add vertex color
        o.color = _Color * i.color;
        
        // Add emission
        o.color.rgb *= _Emission;
        
        float rim = 1.0f - abs(dot(i.normal, normalize(ObjSpaceViewDir(i.vertex))));
        
        o.rim = smoothstep(1.0f - _Rim, 1.0f, rim);

        return o;
    }

    fixed4 frag (fdata i) : SV_Target
    {
        fixed4 c = tex2D(_MainTex, i.uv);
        
        #ifdef USE_MASK
            fixed4 r = tex2D(_MaskTex, i.uv);
        #else
            fixed4 r = _RimColor;
        #endif
        
        // Tint color
        c *= i.color + i.rim * r;
        
        // Fully opaque
        c.a = 1;
        
        return c;
    }