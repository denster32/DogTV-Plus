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

fragment float4 ocean_fragment_shader(VertexOut in [[stage_in]],
                                     constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    
    // Create wave effect
    float wave1 = sin(uv.x * 10.0 + time) * 0.5 + 0.5;
    float wave2 = sin(uv.x * 20.0 + time * 2.0) * 0.3;
    float wave3 = sin(uv.y * 5.0 + time * 0.5) * 0.2;
    
    // Combine waves
    float wave = wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2;
    
    // Ocean colors
    float3 deepBlue = float3(0.0, 0.2, 0.6);
    float3 lightBlue = float3(0.0, 0.5, 1.0);
    float3 foam = float3(0.9, 0.95, 1.0);
    
    // Mix colors based on wave height
    float3 color = mix(deepBlue, lightBlue, wave);
    color = mix(color, foam, smoothstep(0.8, 1.0, wave));
    
    return float4(color, 1.0);
}
