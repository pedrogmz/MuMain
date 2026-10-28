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

const kDiagonalWeight: f32 = 2.0;
const kTotalWeight: f32 = 12.0;

@fragment
fn main(input: FSInput) -> @location(0) vec4<f32> {
    let halfTexel = bloomUniforms.sourceTexelSize * 0.5;
    let uv = input.uv;
    var sum: vec3<f32> = textureSample(source, linearSampler, uv + vec2<f32>(-halfTexel.x * 2.0, 0.0)).rgb;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(halfTexel.x * 2.0, 0.0)).rgb;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(0.0, -halfTexel.y * 2.0)).rgb;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(0.0, halfTexel.y * 2.0)).rgb;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(-halfTexel.x, -halfTexel.y)).rgb * kDiagonalWeight;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(halfTexel.x, -halfTexel.y)).rgb * kDiagonalWeight;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(-halfTexel.x, halfTexel.y)).rgb * kDiagonalWeight;
    sum += textureSample(source, linearSampler, uv + vec2<f32>(halfTexel.x, halfTexel.y)).rgb * kDiagonalWeight;
    return vec4<f32>(sum / kTotalWeight * bloomUniforms.levelWeight, 1.0);
}
