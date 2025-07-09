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

fragment float4 sunset_fragment_shader(VertexOut in [[stage_in]],
                                      constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    
    // Create gradient from bottom to top
    float gradient = uv.y;
    
    // Sunset colors
    float3 skyBlue = float3(0.5, 0.7, 1.0);
    float3 sunsetOrange = float3(1.0, 0.6, 0.3);
    float3 sunsetPink = float3(1.0, 0.4, 0.6);
    float3 nightBlue = float3(0.1, 0.1, 0.3);
    
    // Mix colors based on height
    float3 color;
    if (gradient < 0.3) {
        color = mix(sunsetOrange, sunsetPink, smoothstep(0.0, 0.3, gradient));
    } else if (gradient < 0.7) {
        color = mix(sunsetPink, skyBlue, smoothstep(0.3, 0.7, gradient));
    } else {
        color = mix(skyBlue, nightBlue, smoothstep(0.7, 1.0, gradient));
    }
    
    // Add sun
    float2 sunPos = float2(0.8, 0.2 + sin(time * 0.1) * 0.1);
    float sunDist = distance(uv, sunPos);
    float sun = smoothstep(0.1, 0.05, sunDist);
    color += float3(1.0, 0.9, 0.5) * sun;
    
    return float4(color, 1.0);
}
