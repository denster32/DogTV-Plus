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

fragment float4 forest_fragment_shader(VertexOut in [[stage_in]],
                                      constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    
    // Create tree canopy effect
    float noise = fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    float trees = smoothstep(0.3, 0.7, noise);
    
    // Add wind movement
    float wind = sin(uv.x * 5.0 + time * 0.5) * 0.1;
    trees += wind * 0.1;
    
    // Forest colors
    float3 darkGreen = float3(0.1, 0.3, 0.1);
    float3 lightGreen = float3(0.2, 0.5, 0.2);
    float3 sunLight = float3(0.8, 0.7, 0.3);
    
    // Mix colors
    float3 color = mix(darkGreen, lightGreen, trees);
    color += sunLight * smoothstep(0.8, 1.0, uv.y) * 0.3;
    
    return float4(color, 1.0);
}
