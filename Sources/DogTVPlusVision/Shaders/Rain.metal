#include <metal_stdlib>
using namespace metal;

#include "../Vertex.h"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_shader(const device Vertex *vertices [[buffer(0)]],
                              uint vertexID [[vertex_id]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID].position, 0.0, 1.0);
    out.texCoord = vertices[vertexID].texCoord;
    return out;
}

float rand(float2 co){
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

fragment float4 rain_fragment_shader(VertexOut in [[stage_in]],
                                    constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    float3 color = float3(0.2, 0.3, 0.4); // Background color
    
    float speed = 0.5;
    float density = 20.0;
    
    for (float i = 0.0; i < density; i++) {
        float start = rand(float2(i, i * 2.0));
        float2 drop_uv = float2(start, fract(start + time * speed));
        
        float dist = distance(uv, drop_uv);
        
        if (dist < 0.02) {
            color += float3(0.7, 0.8, 1.0) * (0.02 - dist) * 50.0;
        }
    }
    
    return float4(color, 1.0);
}
