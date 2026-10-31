#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 Ripple(
    float2 position,
    SwiftUI::Layer layer,
    float2 origin,
    float time,
    float amplitude,
    float frequency,
    float decay,
    float speed
) {
    float2 offset = position - origin;
    float radius = length(offset);
    float2 direction = radius > 0.0001 ? offset / radius : float2(0.0, 0.0);
    float wavefrontDelay = radius / speed;
    float localTime = max(0.0, time - wavefrontDelay);
    float displacement = amplitude * sin(frequency * localTime) * exp(-decay * localTime);
    half4 color = layer.sample(position + direction * displacement);
    half lift = half(0.3 * displacement / amplitude) * color.a;
    color.rgb += lift;
    return color;
}
