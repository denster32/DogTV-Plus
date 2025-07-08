# Metal Shaders

## Overview

DogTV+ uses custom Metal shaders optimized for canine vision processing. All shaders are designed around the dichromatic color vision of dogs (blue-yellow spectrum).

## Canine Vision Constants

```metal
constant float3 CANINE_BLUE = float3(0.0, 0.0, 1.0);
constant float3 CANINE_YELLOW = float3(1.0, 1.0, 0.0);
constant float3 CANINE_GRAY = float3(0.5, 0.5, 0.5);
```

## Shader Implementations

### Ocean Wave Shader

Generates calming ocean wave patterns with enhanced blue contrast.

```metal
fragment float4 ocean_wave_shader(float4 position [[stage_in]],
                                 constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / uniforms.resolution.xy;
    float time = uniforms.time * 0.3;
    
    // Create wave pattern
    float wave1 = sin(uv.x * 10.0 + time) * 0.1;
    float wave2 = cos(uv.y * 8.0 + time * 1.5) * 0.08;
    float waves = wave1 + wave2;
    
    // Apply canine color optimization
    float3 baseColor = mix(CANINE_BLUE * 0.6, CANINE_BLUE, waves + 0.5);
    float alpha = 0.8 + waves * 0.2;
    
    return float4(baseColor, alpha);
}
```

### Forest Canopy Shader

Simulates dappled sunlight through leaves with yellow-green tones.

```metal
fragment float4 forest_canopy_shader(float4 position [[stage_in]],
                                    constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / uniforms.resolution.xy;
    float time = uniforms.time * 0.2;
    
    // Create organic patterns
    float2 offset = float2(sin(time + uv.y * 5.0), cos(time + uv.x * 4.0)) * 0.1;
    float noise = fract(sin(dot(uv + offset, float2(12.9898, 78.233))) * 43758.5453);
    
    // Leaf shadows and sunlight
    float light = smoothstep(0.3, 0.7, noise);
    
    // Canine-optimized forest colors
    float3 shadow = CANINE_GRAY * 0.4;
    float3 sunlight = mix(CANINE_YELLOW * 0.8, CANINE_YELLOW, light);
    float3 color = mix(shadow, sunlight, light);
    
    return float4(color, 1.0);
}
```

### Firefly Shader

Creates gentle floating lights optimized for canine attention patterns.

```metal
fragment float4 firefly_shader(float4 position [[stage_in]],
                              constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / uniforms.resolution.xy;
    float time = uniforms.time * 0.5;
    
    float3 color = CANINE_GRAY * 0.1; // Dark background
    
    // Generate multiple fireflies
    for (int i = 0; i < 8; i++) {
        float seed = float(i) * 12.345;
        
        // Firefly position
        float2 pos = float2(
            sin(time * 0.7 + seed) * 0.3 + 0.5,
            cos(time * 0.5 + seed * 1.3) * 0.4 + 0.5
        );
        
        // Distance and glow
        float dist = length(uv - pos);
        float glow = exp(-dist * 20.0) * (0.5 + 0.5 * sin(time * 3.0 + seed));
        
        // Add firefly light
        color += CANINE_YELLOW * glow * 0.8;
    }
    
    return float4(color, 1.0);
}
```

### Gentle Rain Shader

Simulates peaceful rainfall with subtle motion.

```metal
fragment float4 gentle_rain_shader(float4 position [[stage_in]],
                                  constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / uniforms.resolution.xy;
    float time = uniforms.time * 2.0;
    
    // Background
    float3 color = mix(CANINE_GRAY * 0.3, CANINE_BLUE * 0.4, uv.y);
    
    // Rain drops
    for (int i = 0; i < 15; i++) {
        float seed = float(i) * 7.531;
        float x = fract(sin(seed) * 43758.5453);
        float speed = 0.5 + fract(sin(seed * 2.0) * 43758.5453) * 0.5;
        
        float dropY = fract(uv.y - time * speed + seed);
        float dropX = x;
        
        float2 dropPos = float2(dropX, dropY);
        float dist = abs(uv.x - dropX);
        
        if (dist < 0.002 && abs(uv.y - dropY) < 0.02) {
            color += CANINE_BLUE * 0.3;
        }
    }
    
    return float4(color, 1.0);
}
```

### Zen Garden Shader

Creates calming sand patterns with subtle movement.

```metal
fragment float4 zen_garden_shader(float4 position [[stage_in]],
                                 constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / uniforms.resolution.xy;
    float time = uniforms.time * 0.1;
    
    // Base sand color
    float3 sandColor = mix(CANINE_YELLOW * 0.6, CANINE_GRAY * 0.8, 0.5);
    
    // Rake patterns
    float pattern = sin(uv.x * 20.0 + time) * sin(uv.y * 15.0 + time * 0.7);
    pattern = smoothstep(-0.1, 0.1, pattern);
    
    // Add subtle depth
    float3 color = mix(sandColor * 0.9, sandColor * 1.1, pattern);
    
    return float4(color, 1.0);
}
```

### Squirrel Chase Shader

Dynamic scene with moving elements to capture attention.

```metal
fragment float4 squirrel_chase_shader(float4 position [[stage_in]],
                                     constant ProceduralUniforms& uniforms [[buffer(0)]]) {
    float2 uv = position.xy / uniforms.resolution.xy;
    float time = uniforms.time * 1.5;
    
    // Background (grass/dirt)
    float3 background = mix(CANINE_YELLOW * 0.3, CANINE_GRAY * 0.6, uv.y);
    
    // Moving squirrel (simplified)
    float2 squirrelPos = float2(
        fract(time * 0.3),
        0.3 + sin(time * 2.0) * 0.1
    );
    
    float squirrelDist = length(uv - squirrelPos);
    float squirrel = smoothstep(0.05, 0.03, squirrelDist);
    
    // Tree trunk
    float trunk = step(abs(uv.x - 0.8), 0.05) * step(uv.y, 0.7);
    
    float3 color = background;
    color = mix(color, CANINE_GRAY * 0.3, trunk);
    color = mix(color, CANINE_YELLOW * 0.9, squirrel);
    
    return float4(color, 1.0);
}
```

## Performance Considerations

- All shaders target 60 FPS on Apple TV 4K
- Optimized for Metal 2.0+ features
- Reduced complexity for older hardware
- Automatic LOD adjustments based on performance

## Canine Vision Optimization

- **Color Palette**: Restricted to blue-yellow spectrum
- **Contrast**: Enhanced for dichromatic vision
- **Motion**: Optimized for 20-30 FPS perception
- **Brightness**: Adjusted for canine light sensitivity

## Testing

Use the built-in shader validator:

```swift
let validator = ShaderValidator()
try validator.validateShader("ocean_wave_shader")
```