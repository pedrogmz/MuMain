struct BloomUniforms {
    sourceTexelSize: vec2<f32>,
    levelWeight: f32,
    padding: f32,
}

@group(2) @binding(0) var source: texture_2d<f32>;
@group(2) @binding(1) var linearSampler: sampler;
@group(3) @binding(0) var<uniform> bloomUniforms: BloomUniforms;

struct FSInput {
    @builtin(position) pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
}

const kCentreWeight: f32 = 4.0;
const kTotalWeight: f32 = 8.0;

@fragment
fn main(input: FSInput) -> @location(0) vec4<f32> {
    let halfTexel = bloomUniforms.sourceTexelSize * 0.5;
    var sum: vec3<f32> = textureSample(source, linearSampler, input.uv).rgb * kCentreWeight;
    sum += textureSample(source, linearSampler, input.uv - halfTexel).rgb;
    sum += textureSample(source, linearSampler, input.uv + halfTexel).rgb;
    sum += textureSample(source, linearSampler, input.uv + vec2<f32>(halfTexel.x, -halfTexel.y)).rgb;
    sum += textureSample(source, linearSampler, input.uv - vec2<f32>(halfTexel.x, -halfTexel.y)).rgb;
    return vec4<f32>(sum / kTotalWeight, 1.0);
}
