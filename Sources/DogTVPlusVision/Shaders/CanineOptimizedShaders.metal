#include <metal_stdlib>
using namespace metal;

// Canine vision constants (dichromatic, blue-yellow sensitive)
constant float3 CANINE_BLUE = float3(0.0, 0.0, 1.0);
constant float3 CANINE_YELLOW = float3(1.0, 1.0, 0.0);
constant float3 CANINE_GRAY = float3(0.5, 0.5, 0.5);

// Uniform structure for procedural content
struct ProceduralUniforms {
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
    float4x4 modelMatrix;
    float3 colorPalette[4];
    float motionIntensity;
    float contrastLevel;
    float brightness;
    float saturation;
    float animationSpeed;
    float complexity;
    float time;
    float3 cameraPosition;
};

// Vertex shader for full-screen quad
vertex float4 vertex_shader(uint vertexID [[vertex_id]],
                           constant float2* positions [[buffer(0)]],
                           constant ProceduralUniforms& uniforms [[buffer(1)]]) {
    float4 position = float4(positions[vertexID], 0.0, 1.0);
    
    // Apply gentle motion based on canine preferences
    float motion = sin(uniforms.time * uniforms.animationSpeed) * uniforms.motionIntensity;
    position.x += motion * 0.05;
    position.y += cos(uniforms.time * uniforms.animationSpeed * 0.7) * uniforms.motionIntensity * 0.025;
    
    return position;
}

// Fragment shader for calming ocean waves
fragment float4 ocean_wave_shader(float4 position [[stage_in]],
                                 constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / float2(1920.0, 1080.0); // Assuming 1920x1080 resolution
    
    // Create gentle, rhythmic wave patterns optimized for dogs
    float wave1 = sin(uv.x * 3.0 + uniforms.time * 0.5) * 0.3;
    float wave2 = sin(uv.x * 1.5 + uniforms.time * 0.3) * 0.2;
    float wave3 = cos(uv.x * 2.0 + uniforms.time * 0.4) * 0.15;
    
    float combinedWave = (wave1 + wave2 + wave3) * uniforms.motionIntensity;
    
    // Canine-optimized color palette (blues and soft grays)
    float3 baseColor = mix(CANINE_BLUE * 0.3, CANINE_GRAY * 0.7, 0.6);
    float3 waveColor = CANINE_BLUE * 0.4 * (0.5 + combinedWave);
    
    // Smooth color transition
    float3 finalColor = mix(baseColor, waveColor, smoothstep(0.0, 0.1, abs(combinedWave)));
    
    // Apply canine-specific adjustments
    finalColor = enhanceForCanineVision(finalColor, uniforms);
    
    return float4(finalColor, 1.0);
}

// Fragment shader for forest canopy movement
fragment float4 forest_canopy_shader(float4 position [[stage_in]],
                                    constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / float2(1920.0, 1080.0);
    
    // Simulate gentle tree movement
    float wind = sin(uniforms.time * 0.2) * 0.1;
    float leaf1 = sin(uv.x * 8.0 + uniforms.time * 0.3 + wind) * 0.2;
    float leaf2 = sin(uv.x * 5.0 + uniforms.time * 0.2 + wind * 0.5) * 0.15;
    float leaf3 = cos(uv.x * 6.0 + uniforms.time * 0.25 + wind * 0.3) * 0.1;
    
    float leafMovement = (leaf1 + leaf2 + leaf3) * uniforms.motionIntensity * 0.3;
    
    // Canine-optimized forest colors (yellows and soft greens)
    float3 baseColor = mix(CANINE_YELLOW * 0.4, float3(0.2, 0.4, 0.1), 0.7);
    float3 highlightColor = CANINE_YELLOW * 0.6 * (0.5 + leafMovement);
    
    float3 finalColor = mix(baseColor, highlightColor, smoothstep(0.0, 0.1, abs(leafMovement)));
    
    // Apply canine-specific adjustments
    finalColor = enhanceForCanineVision(finalColor, uniforms);
    
    return float4(finalColor, 1.0);
}

// Fragment shader for firefly effect
fragment float4 firefly_shader(float4 position [[stage_in]],
                              constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / float2(1920.0, 1080.0);
    
    // Create multiple firefly points
    float3 fireflies = float3(0.0);
    
    for (int i = 0; i < 8; i++) {
        float2 fireflyPos = float2(
            fract(sin(float(i) * 123.456) + uniforms.time * 0.1),
            fract(cos(float(i) * 789.012) + uniforms.time * 0.15)
        );
        
        float distance = length(uv - fireflyPos);
        float brightness = exp(-distance * 20.0) * (0.5 + 0.5 * sin(uniforms.time * 2.0 + float(i)));
        
        fireflies += CANINE_YELLOW * brightness * 0.3 * uniforms.motionIntensity;
    }
    
    // Dark background with gentle glow
    float3 background = float3(0.05, 0.1, 0.15);
    float3 finalColor = background + fireflies;
    
    // Apply canine-specific adjustments
    finalColor = enhanceForCanineVision(finalColor, uniforms);
    
    return float4(finalColor, 1.0);
}

// Fragment shader for gentle rain effect
fragment float4 gentle_rain_shader(float4 position [[stage_in]],
                                  constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / float2(1920.0, 1080.0);
    
    // Create gentle rain drops
    float rain = 0.0;
    for (int i = 0; i < 20; i++) {
        float2 dropPos = float2(
            fract(sin(float(i) * 456.789) * 43758.5453),
            fract(uniforms.time * 0.5 + float(i) * 0.1)
        );
        
        float dropDistance = length(uv - dropPos);
        rain += smoothstep(0.02, 0.0, dropDistance) * 0.5;
    }
    
    // Soft blue background with rain overlay
    float3 skyColor = CANINE_BLUE * 0.6;
    float3 rainColor = CANINE_GRAY * rain * uniforms.motionIntensity;
    
    float3 finalColor = skyColor + rainColor;
    
    // Apply canine-specific adjustments
    finalColor = enhanceForCanineVision(finalColor, uniforms);
    
    return float4(finalColor, 1.0);
}

// Fragment shader for calming zen garden
fragment float4 zen_garden_shader(float4 position [[stage_in]],
                                 constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / float2(1920.0, 1080.0);
    
    // Create subtle ripple patterns in sand
    float ripple1 = sin(length(uv - float2(0.3, 0.3)) * 20.0 + uniforms.time * 0.5) * 0.1;
    float ripple2 = sin(length(uv - float2(0.7, 0.7)) * 15.0 + uniforms.time * 0.3) * 0.08;
    
    float totalRipple = (ripple1 + ripple2) * uniforms.motionIntensity * 0.2;
    
    // Soft sand color with subtle variations
    float3 sandColor = float3(0.9, 0.9, 0.8) + totalRipple * 0.1;
    
    // Add occasional floating leaves
    float leaf = smoothstep(0.02, 0.0, length(uv - float2(
        0.5 + sin(uniforms.time * 0.1) * 0.2,
        0.6 + cos(uniforms.time * 0.08) * 0.1
    ))) * 0.3;
    
    float3 leafColor = CANINE_YELLOW * 0.5 * leaf;
    float3 finalColor = sandColor + leafColor;
    
    // Apply canine-specific adjustments
    finalColor = enhanceForCanineVision(finalColor, uniforms);
    
    return float4(finalColor, 1.0);
}

// Fragment shader for stimulating squirrel chase
fragment float4 squirrel_chase_shader(float4 position [[stage_in]],
                                     constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / float2(1920.0, 1080.0);
    
    // Create multiple moving squirrels
    float3 squirrels = float3(0.0);
    
    for (int i = 0; i < 3; i++) {
        float2 squirrelPos = float2(
            fract(sin(float(i) * 234.567) + uniforms.time * 0.8),
            0.3 + sin(uniforms.time * 1.5 + float(i)) * 0.2
        );
        
        float distance = length(uv - squirrelPos);
        float squirrel = smoothstep(0.05, 0.02, distance);
        
        squirrels += CANINE_YELLOW * squirrel * uniforms.motionIntensity;
    }
    
    // Forest background
    float3 background = mix(float3(0.2, 0.4, 0.1), float3(0.1, 0.3, 0.05), uv.y);
    float3 finalColor = background + squirrels;
    
    // Apply canine-specific adjustments
    finalColor = enhanceForCanineVision(finalColor, uniforms);
    
    return float4(finalColor, 1.0);
}

// Helper function to enhance colors for canine vision
float3 enhanceForCanineVision(float3 color, constant ProceduralUniforms& uniforms) {
    // Enhance blue and yellow components (dogs see these best)
    color.b *= 1.2; // Enhance blue
    color.r *= 0.8; // Reduce red (dogs see red poorly)
    color.g *= 1.1; // Enhance green (part of yellow perception)
    
    // Apply contrast enhancement (dogs need higher contrast)
    color = (color - 0.5) * uniforms.contrastLevel + 0.5;
    
    // Apply brightness adjustment
    color *= uniforms.brightness;
    
    // Apply saturation adjustment
    float luminance = dot(color, float3(0.299, 0.587, 0.114));
    color = mix(float3(luminance), color, uniforms.saturation);
    
    return clamp(color, 0.0, 1.0);
}

// Vertex shader for particle systems
vertex float4 particle_vertex_shader(uint vertexID [[vertex_id]],
                                    constant float3* positions [[buffer(0)]],
                                    constant ProceduralUniforms& uniforms [[buffer(1)]]) {
    float3 position = positions[vertexID];
    
    // Apply particle motion
    float time = uniforms.time * uniforms.animationSpeed;
    position.x += sin(time + position.y * 10.0) * uniforms.motionIntensity * 0.1;
    position.y += cos(time + position.x * 8.0) * uniforms.motionIntensity * 0.05;
    
    return uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(position, 1.0);
}

// Compute shader for procedural content generation
kernel void procedural_compute_shader(texture2d<float, access::write> outputTexture [[texture(0)]],
                                     constant ProceduralUniforms& uniforms [[buffer(0)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    if (gid.x >= outputTexture.get_width() || gid.y >= outputTexture.get_height()) {
        return;
    }
    
    float2 uv = float2(gid) / float2(outputTexture.get_width(), outputTexture.get_height());
    
    // Generate procedural pattern
    float pattern = sin(uv.x * 10.0 + uniforms.time) * cos(uv.y * 8.0 + uniforms.time * 0.5);
    pattern *= uniforms.complexity;
    
    // Apply canine-optimized colors
    float3 color = mix(CANINE_BLUE, CANINE_YELLOW, (pattern + 1.0) * 0.5);
    color = enhanceForCanineVision(color, uniforms);
    
    outputTexture.write(float4(color, 1.0), gid);
}