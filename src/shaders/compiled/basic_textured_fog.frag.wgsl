struct FogUniforms {
    fogEnabled: u32,
    alphaDiscardEnabled: u32,
    alphaThreshold: f32,
    alphaToCoverage: u32,
    fogStart: f32,
    fogEnd: f32,
    fogPad: vec2<f32>,
    fogColor: vec4<f32>,
}

struct SceneLighting {
    sceneLightDirection: vec4<f32>,
    sceneLightColor: vec4<f32>,
    diffuseCurve: vec4<f32>,
    rimParameters: vec4<f32>,
    specularParameters: vec4<f32>,
    sceneFogColor: vec4<f32>,
    sceneFogParameters: vec4<f32>,
    cameraPosition: vec4<f32>,
}

@group(2) @binding(0) var tex: texture_2d<f32>;
@group(2) @binding(1) var s: sampler;
@group(3) @binding(0) var<uniform> fogUniforms: FogUniforms;
@group(3) @binding(1) var<uniform> sceneLighting: SceneLighting;

struct FSInput {
    @builtin(position) pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) fogFactor: f32,
    @location(3) eyeDepth: f32,
}

fn enhancedFogAmount(eyeDepth: f32) -> f32 {
    let scaledDistance = max(eyeDepth - sceneLighting.sceneFogParameters.x, 0.0) * sceneLighting.sceneFogParameters.z;
    return clamp(1.0 - exp(-(scaledDistance * scaledDistance)), 0.0, 1.0);
}

@fragment
fn main(input: FSInput) -> @location(0) vec4<f32> {
    var color: vec4<f32> = textureSample(tex, s, input.uv) * input.color;
    if (fogUniforms.alphaToCoverage != 0u) {
        let edge = clamp((color.a - fogUniforms.alphaThreshold) / max(fwidth(color.a), 0.0001) + 0.5, 0.0, 1.0);
        color.a *= edge;
        if (color.a <= 0.0) {
            discard;
        }
    } else if (fogUniforms.alphaDiscardEnabled != 0u && color.a <= fogUniforms.alphaThreshold) {
        discard;
    }
    if (fogUniforms.fogEnabled != 0u && sceneLighting.sceneFogColor.w > 0.0) {
        color = vec4<f32>(mix(color.rgb, sceneLighting.sceneFogColor.rgb, enhancedFogAmount(input.eyeDepth)), color.a);
    }
    return color;
}
