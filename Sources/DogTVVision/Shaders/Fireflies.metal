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

fragment float4 fireflies_fragment_shader(VertexOut in [[stage_in]],
                                         constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    
    // Create firefly positions
    float2 firefly1 = float2(sin(time * 0.5) * 0.4 + 0.3, cos(time * 0.3) * 0.4 + 0.7);
    float2 firefly2 = float2(sin(time * 0.7) * 0.4 + 0.7, cos(time * 0.5) * 0.4 + 0.3);
    float2 firefly3 = float2(sin(time * 0.3) * 0.4 + 0.5, cos(time * 0.8) * 0.4 + 0.5);
    
    // Calculate distances
    float dist1 = distance(uv, firefly1);
    float dist2 = distance(uv, firefly2);
    float dist3 = distance(uv, firefly3);
    
    // Create pulsing effect
    float pulse1 = sin(time * 2.0) * 0.5 + 0.5;
    float pulse2 = sin(time * 1.5 + 1.0) * 0.5 + 0.5;
    float pulse3 = sin(time * 2.5 + 2.0) * 0.5 + 0.5;
    
    // Firefly glow
    float glow1 = smoothstep(0.05, 0.0, dist1) * pulse1;
    float glow2 = smoothstep(0.05, 0.0, dist2) * pulse2;
    float glow3 = smoothstep(0.05, 0.0, dist3) * pulse3;
    
    // Background
    float3 background = float3(0.0, 0.1, 0.2);
    float3 fireflyColor = float3(1.0, 1.0, 0.5);
    
    float3 color = background;
    color += fireflyColor * (glow1 + glow2 + glow3);
    
    return float4(color, 1.0);
}
