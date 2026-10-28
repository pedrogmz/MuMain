struct CompositeUniforms {
    inverseTargetSize: vec2<f32>,
    bloomScale: f32,
    gradingStrength: f32,
}

@group(2) @binding(0) var scene: texture_2d<f32>;
@group(2) @binding(1) var sceneSampler: sampler;
@group(2) @binding(2) var bloom: texture_2d<f32>;
@group(2) @binding(3) var bloomSampler: sampler;
@group(2) @binding(4) var grading: texture_2d<f32>;
@group(2) @binding(5) var gradingSampler: sampler;
@group(3) @binding(0) var<uniform> compositeUniforms: CompositeUniforms;

struct FSInput {
    @builtin(position) pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
}

const kGradingSize: f32 = 32.0;

fn grade(color: vec3<f32>) -> vec3<f32> {
    let lastEntry = kGradingSize - 1.0;
    let blue = color.b * lastEntry;
    let lowerSlice = floor(blue);
    let upperSlice = min(lowerSlice + 1.0, lastEntry);
    let sliceBlend = blue - lowerSlice;

    let x = (color.r * lastEntry + 0.5) / (kGradingSize * kGradingSize);
    let y = (color.g * lastEntry + 0.5) / kGradingSize;

    let lowerUv = vec2<f32>(x + lowerSlice / kGradingSize, y);
    let upperUv = vec2<f32>(x + upperSlice / kGradingSize, y);

    let lowerSample = textureSample(grading, gradingSampler, lowerUv).rgb;
    let upperSample = textureSample(grading, gradingSampler, upperUv).rgb;
    return mix(lowerSample, upperSample, sliceBlend);
}

@fragment
fn main(input: FSInput) -> @location(0) vec4<f32> {
    let uv = input.pos.xy * compositeUniforms.inverseTargetSize;
    var color: vec4<f32> = textureSample(scene, sceneSampler, uv);
    if (compositeUniforms.bloomScale > 0.0) {
        let glow = clamp(textureSample(bloom, bloomSampler, uv).rgb * compositeUniforms.bloomScale, vec3<f32>(0.0), vec3<f32>(1.0));
        color = vec4<f32>(vec3<f32>(1.0) - (vec3<f32>(1.0) - color.rgb) * (vec3<f32>(1.0) - glow), color.a);
    }
    if (compositeUniforms.gradingStrength > 0.0) {
        color = vec4<f32>(mix(color.rgb, grade(color.rgb), compositeUniforms.gradingStrength), color.a);
    }
    return color;
}
