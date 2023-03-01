    struct vdata
    {
        float4 vertex : POSITION;
        fixed4 color : COLOR;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    
    struct fdata
    {
        float4 vertex : SV_POSITION;
        fixed4 color : COLOR;
    };
    
    fixed4 _Color;
    
    fdata vert (vdata i)
    {
        fdata o;
        
        UNITY_SETUP_INSTANCE_ID(i);
        
        // Transform position to clip space
        // More efficient than computing M*VP matrix product
        o.vertex = UnityObjectToClipPos(i.vertex);
        
        // Add vertex color
        o.color = _Color * i.color;
        
        // Premultiply color
        o.color.rgb *= o.color.a;
        
        return o;
    }
    
    fixed4 frag (fdata i) : SV_Target
    {
        return i.color;
    }