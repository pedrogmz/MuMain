struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
}

struct CompositeUniforms {
    inverseTargetSize: vec2<f32>,
    bloomScale: f32,
    gradingStrength: f32,
    toneMapKnee: f32,
    ditherAmount: f32,
    ambientOcclusionStrength: f32,
    ambientOcclusionEffects: f32,
}

@group(3) @binding(0) 
var<uniform> unnamed: CompositeUniforms;
@group(2) @binding(0) 
var scene: texture_2d<f32>;
@group(2) @binding(1) 
var sceneSampler: sampler;
@group(2) @binding(2) 
var bloom: texture_2d<f32>;
@group(2) @binding(3) 
var bloomSampler: sampler;
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> u0040_entryPointOutput: vec4<f32>;
@group(2) @binding(4) 
var grading: texture_2d<f32>;
@group(2) @binding(5) 
var gradingSampler: sampler;
@group(2) @binding(6) 
var ambientOcclusion: texture_2d<f32>;
@group(2) @binding(7) 
var ambientOcclusionSampler: sampler;
@group(2) @binding(8) 
var bloomSource: texture_2d<f32>;
@group(2) @binding(9) 
var bloomSourceSampler: sampler;

fn DitherNoise_u0028_vf2_u003b(pixel: ptr<function, vec2<f32>>) -> f32 {
    let _e42 = (*pixel);
    return fract((52.982918f * fract(dot(_e42, vec2<f32>(0.06711056f, 0.00583715f)))));
}

fn Grade_u0028_vf3_u003b(color: ptr<function, vec3<f32>>) -> vec3<f32> {
    var blue: f32;
    var lowerSlice: f32;
    var upperSlice: f32;
    var sliceBlend: f32;
    var x: f32;
    var y: f32;
    var lower: vec3<f32>;
    var upper: vec3<f32>;

    let _e51 = (*color)[2u];
    blue = (_e51 * 31f);
    let _e53 = blue;
    lowerSlice = floor(_e53);
    let _e55 = lowerSlice;
    upperSlice = min((_e55 + 1f), 31f);
    let _e58 = blue;
    let _e59 = lowerSlice;
    sliceBlend = (_e58 - _e59);
    let _e62 = (*color)[0u];
    x = (((_e62 * 31f) + 0.5f) / 1024f);
    let _e67 = (*color)[1u];
    y = (((_e67 * 31f) + 0.5f) / 32f);
    let _e71 = x;
    let _e72 = lowerSlice;
    let _e75 = y;
    let _e77 = textureSample(grading, gradingSampler, vec2<f32>((_e71 + (_e72 * 0.03125f)), _e75));
    lower = _e77.xyz;
    let _e79 = x;
    let _e80 = upperSlice;
    let _e83 = y;
    let _e85 = textureSample(grading, gradingSampler, vec2<f32>((_e79 + (_e80 * 0.03125f)), _e83));
    upper = _e85.xyz;
    let _e87 = lower;
    let _e88 = upper;
    let _e89 = sliceBlend;
    return mix(_e87, _e88, vec3(_e89));
}

fn ToneMapChannel_u0028_f1_u003b(value: ptr<function, f32>) -> f32 {
    var range: f32;

    let _e44 = unnamed.toneMapKnee;
    range = (1f - _e44);
    let _e46 = (*value);
    let _e48 = unnamed.toneMapKnee;
    let _e51 = unnamed.toneMapKnee;
    let _e52 = range;
    let _e53 = (*value);
    let _e55 = unnamed.toneMapKnee;
    let _e58 = range;
    let _e64 = (*value);
    return select(_e64, (_e51 + (_e52 * (1f - exp((-((_e53 - _e55)) / _e58))))), (_e46 > _e48));
}

fn AmbientOcclusion_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> f32 {
    var visibility: f32;
    var effectLight: f32;

    let _e44 = (*uv);
    let _e45 = textureSample(ambientOcclusion, ambientOcclusionSampler, _e44);
    visibility = _e45.x;
    let _e48 = unnamed.ambientOcclusionEffects;
    if (_e48 > 0f) {
        let _e50 = (*uv);
        let _e51 = textureSample(bloomSource, bloomSourceSampler, _e50);
        effectLight = dot(_e51.xyz, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
        let _e54 = visibility;
        let _e55 = effectLight;
        visibility = mix(_e54, 1f, clamp((_e55 * 4f), 0f, 1f));
    }
    let _e59 = visibility;
    let _e62 = unnamed.ambientOcclusionStrength;
    return max((1f - ((1f - _e59) * _e62)), 0f);
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf21_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var color_1: vec4<f32>;
    var param: vec2<f32>;
    var param_1: f32;
    var param_2: f32;
    var param_3: f32;
    var glow: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec2<f32>;

    let _e52 = (*input).pos;
    let _e55 = unnamed.inverseTargetSize;
    uv_1 = (_e52.xy * _e55);
    let _e57 = uv_1;
    let _e58 = textureSample(scene, sceneSampler, _e57);
    color_1 = _e58;
    let _e60 = unnamed.ambientOcclusionStrength;
    if (_e60 > 0f) {
        let _e62 = uv_1;
        param = _e62;
        let _e63 = AmbientOcclusion_u0028_vf2_u003b((&param));
        let _e64 = color_1;
        let _e66 = (_e64.xyz * _e63);
        color_1[0u] = _e66.x;
        color_1[1u] = _e66.y;
        color_1[2u] = _e66.z;
    }
    let _e74 = unnamed.toneMapKnee;
    if (_e74 < 1f) {
        let _e76 = color_1;
        let _e78 = max(_e76.xyz, vec3<f32>(0f, 0f, 0f));
        color_1[0u] = _e78.x;
        color_1[1u] = _e78.y;
        color_1[2u] = _e78.z;
        let _e86 = color_1[0u];
        param_1 = _e86;
        let _e87 = ToneMapChannel_u0028_f1_u003b((&param_1));
        let _e89 = color_1[1u];
        param_2 = _e89;
        let _e90 = ToneMapChannel_u0028_f1_u003b((&param_2));
        let _e92 = color_1[2u];
        param_3 = _e92;
        let _e93 = ToneMapChannel_u0028_f1_u003b((&param_3));
        let _e94 = vec3<f32>(_e87, _e90, _e93);
        color_1[0u] = _e94.x;
        color_1[1u] = _e94.y;
        color_1[2u] = _e94.z;
    }
    let _e102 = unnamed.bloomScale;
    if (_e102 > 0f) {
        let _e104 = uv_1;
        let _e105 = textureSample(bloom, bloomSampler, _e104);
        let _e108 = unnamed.bloomScale;
        glow = clamp((_e105.xyz * _e108), vec3(0f), vec3(1f));
        let _e113 = color_1;
        let _e117 = glow;
        let _e122 = (vec3(1f) - ((vec3(1f) - _e113.xyz) * (vec3(1f) - _e117)));
        color_1[0u] = _e122.x;
        color_1[1u] = _e122.y;
        color_1[2u] = _e122.z;
    }
    let _e130 = unnamed.gradingStrength;
    if (_e130 > 0f) {
        let _e132 = color_1;
        let _e134 = color_1;
        param_4 = _e134.xyz;
        let _e136 = Grade_u0028_vf3_u003b((&param_4));
        let _e138 = unnamed.gradingStrength;
        let _e140 = mix(_e132.xyz, _e136, vec3(_e138));
        color_1[0u] = _e140.x;
        color_1[1u] = _e140.y;
        color_1[2u] = _e140.z;
    }
    let _e148 = unnamed.ditherAmount;
    if (_e148 > 0f) {
        let _e151 = (*input).pos;
        param_5 = _e151.xy;
        let _e153 = DitherNoise_u0028_vf2_u003b((&param_5));
        let _e156 = unnamed.ditherAmount;
        let _e158 = color_1;
        let _e161 = (_e158.xyz + vec3(((_e153 - 0.5f) * _e156)));
        color_1[0u] = _e161.x;
        color_1[1u] = _e161.y;
        color_1[2u] = _e161.z;
    }
    let _e168 = color_1;
    return _e168;
}

fn main_1() {
    var input_1: FSInput;
    var param_6: FSInput;

    let _e43 = input_u002e_pos_1;
    input_1.pos = _e43;
    let _e45 = input_u002e_uv_1;
    input_1.uv = _e45;
    let _e47 = input_1;
    param_6 = _e47;
    let _e48 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf21_u003b((&param_6));
    u0040_entryPointOutput = _e48;
    return;
}

@fragment 
fn main(@builtin(position) input_u002e_pos: vec4<f32>, @location(0) input_u002e_uv: vec2<f32>) -> @location(0) vec4<f32> {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    main_1();
    let _e5 = u0040_entryPointOutput;
    return _e5;
}
