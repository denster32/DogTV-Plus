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

fragment float4 stars_fragment_shader(VertexOut in [[stage_in]],
                                     constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    float3 color = float3(0.0, 0.0, 0.1); // Night sky
    
    int numStars = 50;
    for (int i = 0; i < numStars; i++) {
        float2 star_uv = float2(rand(float2(i, i)), rand(float2(i * 2.0, i * 3.0)));
        float dist = distance(uv, star_uv);
        
        float twinkle = sin(time * (rand(float2(i, i)) * 2.0 + 1.0)) * 0.5 + 0.5;
        
        if (dist < 0.01) {
            color += float3(1.0, 1.0, 1.0) * (0.01 - dist) * 100.0 * twinkle;
        }
    }
    
    return float4(color, 1.0);
}
