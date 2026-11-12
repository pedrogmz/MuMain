struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
}

struct FogUniforms {
    coverageMode: u32,
    alphaDiscardEnabled: u32,
    alphaThreshold: f32,
    alphaToCoverage: u32,
    fogStart: f32,
    fogEnd: f32,
    fogColor: vec4<f32>,
}

@group(2) @binding(0) 
var tex: texture_2d<f32>;
@group(2) @binding(1) 
var s: sampler;
@group(3) @binding(0) 
var<uniform> unnamed: FogUniforms;
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> input_u002e_color_1: vec4<f32>;

fn Dither_u0028_vf2_u003b(position: ptr<function, vec2<f32>>) -> f32 {
    let _e19 = (*position);
    return fract((52.982918f * fract(dot(_e19, vec2<f32>(0.06711056f, 0.00583715f)))));
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf41_u003b(input: ptr<function, FSInput>) {
    var texel: vec4<f32>;
    var coverage: f32;
    var param: vec2<f32>;

    let _e23 = (*input).uv;
    let _e24 = textureSample(tex, s, _e23);
    let _e26 = (*input).color;
    texel = (_e24 * _e26);
    let _e29 = unnamed.coverageMode;
    if (_e29 == 0u) {
        let _e32 = unnamed.alphaDiscardEnabled;
        let _e35 = unnamed.alphaToCoverage;
        let _e39 = texel[3u];
        let _e41 = unnamed.alphaThreshold;
        if (((_e32 != 0u) || (_e35 != 0u)) && (_e39 <= _e41)) {
            discard;
        }
        return;
    }
    let _e45 = unnamed.coverageMode;
    let _e48 = texel[3u];
    let _e50 = texel[0u];
    let _e52 = texel[1u];
    let _e54 = texel[2u];
    let _e58 = texel[3u];
    coverage = select((max(_e50, max(_e52, _e54)) * _e58), _e48, (_e45 == 1u));
    let _e61 = coverage;
    let _e63 = (*input).pos;
    param = _e63.xy;
    let _e65 = Dither_u0028_vf2_u003b((&param));
    if (_e61 <= _e65) {
        discard;
    }
    return;
}

fn main_1() {
    var input_1: FSInput;
    var param_1: FSInput;

    let _e20 = input_u002e_pos_1;
    input_1.pos = _e20;
    let _e22 = input_u002e_uv_1;
    input_1.uv = _e22;
    let _e24 = input_u002e_color_1;
    input_1.color = _e24;
    let _e26 = input_1;
    param_1 = _e26;
    u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf41_u003b((&param_1));
    return;
}

@fragment 
fn main(@builtin(position) input_u002e_pos: vec4<f32>, @location(0) input_u002e_uv: vec2<f32>, @location(1) input_u002e_color: vec4<f32>) {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    input_u002e_color_1 = input_u002e_color;
    main_1();
}
