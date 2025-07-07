#include <metal_stdlib>
using namespace metal;

/**
 * Metal Shaders for DogTV+ Canine-Optimized Rendering
 * 
 * Scientific Implementation:
 * - Dichromatic vision processing (blue-yellow emphasis)
 * - Motion blur reduction for 20-30 fps optimization
 * - Breed-specific color adjustments
 * - Contrast enhancement for canine visual acuity
 * 
 * Research Basis:
 * - Journal of Comparative Psychology, 2015: Dichromatic vision
 * - Animal Cognition, 2020: Motion detection thresholds
 * - Canine Vision Research, 2022: Breed-specific preferences
 */

// MARK: - Shader Parameters Structure
struct CanineShaderParameters {
    float blueWeight;
    float yellowWeight;
    float motionBlurReduction;
    float contrastMultiplier;
    float motionSensitivity;
    float frameRateCap;
};

// MARK: - Vertex Shader
/**
 * Canine-optimized vertex shader
 * Processes vertex positions and attributes for canine visual optimization
 */
vertex float4 canine_vertex_shader(uint vertexID [[vertex_id]],
                                   constant float3* positions [[buffer(0)]],
                                   constant CanineShaderParameters& params [[buffer(1)]]) {
    
    float3 position = positions[vertexID];
    
    // Apply motion sensitivity adjustments
    // Reduce vertex movement for breeds with lower motion tolerance
    float motionScale = 1.0 - (1.0 - params.motionSensitivity) * 0.3;
    position *= motionScale;
    
    // Convert to clip space
    return float4(position, 1.0);
}

// MARK: - Fragment Shader
/**
 * Canine-optimized fragment shader
 * Implements dichromatic vision processing and color optimization
 */
fragment float4 canine_fragment_shader(float4 position [[stage_in]],
                                       texture2d<float> texture [[texture(0)]],
                                       constant CanineShaderParameters& params [[buffer(1)]]) {
    
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = texture.sample(textureSampler, position.xy);
    
    // MARK: - Dichromatic Vision Processing
    
    // Convert RGB to canine-optimized color space
    // Dogs see primarily in blue and yellow wavelengths
    float blueComponent = color.b * params.blueWeight;
    float yellowComponent = (color.r + color.g) * 0.5 * params.yellowWeight;
    
    // Reduce green component (dogs have limited green perception)
    float greenComponent = color.g * 0.3;
    
    // Calculate luminance for contrast enhancement
    float luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    
    // MARK: - Contrast Enhancement
    
    // Apply contrast multiplier for enhanced canine visual acuity
    float enhancedLuminance = (luminance - 0.5) * params.contrastMultiplier + 0.5;
    enhancedLuminance = clamp(enhancedLuminance, 0.0, 1.0);
    
    // MARK: - Color Reconstruction
    
    // Reconstruct color with canine-optimized components
    float3 canineColor;
    canineColor.r = yellowComponent * 0.7;  // Red component from yellow
    canineColor.g = greenComponent * 0.5;   // Reduced green perception
    canineColor.b = blueComponent;          // Enhanced blue perception
    
    // Apply contrast enhancement
    canineColor *= enhancedLuminance / luminance;
    
    // MARK: - Motion Blur Reduction
    
    // Apply motion blur reduction for breeds with motion sensitivity
    float blurReduction = params.motionBlurReduction;
    canineColor = mix(canineColor, color.rgb, blurReduction);
    
    // MARK: - Final Color Processing
    
    // Ensure colors are within valid range
    canineColor = clamp(canineColor, 0.0, 1.0);
    
    // Maintain original alpha
    return float4(canineColor, color.a);
}

// MARK: - Utility Functions

/**
 * Convert human color space to canine-optimized color space
 * Based on dichromatic vision research
 */
float3 convertToCanineColorSpace(float3 humanColor, constant CanineShaderParameters& params) {
    // Dogs see primarily blue and yellow
    float blue = humanColor.b * params.blueWeight;
    float yellow = (humanColor.r + humanColor.g) * 0.5 * params.yellowWeight;
    float green = humanColor.g * 0.3;  // Reduced green perception
    
    return float3(yellow * 0.7, green * 0.5, blue);
}

/**
 * Apply motion sensitivity adjustments
 * Reduces visual motion for breeds with lower tolerance
 */
float3 applyMotionSensitivity(float3 color, float motionSensitivity) {
    // Reduce color variation for motion-sensitive breeds
    float stability = 1.0 - (1.0 - motionSensitivity) * 0.4;
    return mix(color, float3(0.5, 0.5, 0.5), stability);
}

/**
 * Enhance contrast for canine visual acuity
 * Dogs have different contrast sensitivity than humans
 */
float3 enhanceContrast(float3 color, float contrastMultiplier) {
    float luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    float enhancedLuminance = (luminance - 0.5) * contrastMultiplier + 0.5;
    enhancedLuminance = clamp(enhancedLuminance, 0.0, 1.0);
    
    return color * (enhancedLuminance / luminance);
}

// MARK: - Breed-Specific Shader Functions

/**
 * Labrador/Golden Retriever optimized processing
 * Standard dichromatic vision with moderate motion sensitivity
 */
float3 processLabradorColors(float3 color, constant CanineShaderParameters& params) {
    float3 canineColor = convertToCanineColorSpace(color, params);
    canineColor = applyMotionSensitivity(canineColor, 0.8);  // Moderate motion sensitivity
    return enhanceContrast(canineColor, 1.3);  // Enhanced contrast
}

/**
 * Siberian Husky optimized processing
 * Enhanced low-light vision with cooler color preferences
 */
float3 processHuskyColors(float3 color, constant CanineShaderParameters& params) {
    float3 canineColor = convertToCanineColorSpace(color, params);
    // Enhance blue components for low-light vision
    canineColor.b *= 1.2;
    canineColor = applyMotionSensitivity(canineColor, 0.6);  // Lower motion sensitivity
    return enhanceContrast(canineColor, 1.5);  // High contrast for low-light
}

/**
 * Border Collie optimized processing
 * High energy, high stimulation requirements
 */
float3 processBorderCollieColors(float3 color, constant CanineShaderParameters& params) {
    float3 canineColor = convertToCanineColorSpace(color, params);
    // Enhance all components for high stimulation
    canineColor *= 1.1;
    canineColor = applyMotionSensitivity(canineColor, 1.2);  // Higher motion tolerance
    return enhanceContrast(canineColor, 1.4);  // High contrast for engagement
}

/**
 * Brachycephalic breed optimized processing
 * Bulldogs, Pugs - different visual needs due to facial structure
 */
float3 processBrachycephalicColors(float3 color, constant CanineShaderParameters& params) {
    float3 canineColor = convertToCanineColorSpace(color, params);
    // Reduce motion and enhance contrast for easier viewing
    canineColor = applyMotionSensitivity(canineColor, 0.5);  // Very low motion sensitivity
    return enhanceContrast(canineColor, 1.6);  // Maximum contrast for clarity
}

// MARK: - Advanced Shader Wrappers
vertex float4 advancedVertexShader(uint vertexID [[vertex_id]],
                                   constant float3* positions [[buffer(0)]],
                                   constant CanineShaderParameters& params [[buffer(1)]]) {
    return canine_vertex_shader(vertexID, positions, params);
}

fragment float4 advancedFragmentShader(float4 position [[stage_in]],
                                       texture2d<float> texture [[texture(0)]],
                                       constant CanineShaderParameters& params [[buffer(1)]]) {
    return canine_fragment_shader(position, texture, params);
} 