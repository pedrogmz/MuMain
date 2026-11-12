struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
    fogFactor: f32,
    eyeDepth: f32,
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
    sunViewProjection: mat4x4<f32>,
    sunShadowParameters: vec4<f32>,
    lightingParameters: vec4<f32>,
    cloudParameters: vec4<f32>,
    cloudOffset: vec4<f32>,
    skyFill: vec4<f32>,
    sunTowards: vec4<f32>,
    sunColor: vec4<f32>,
}

struct FogUniforms {
    fogEnabled: u32,
    alphaDiscardEnabled: u32,
    alphaThreshold: f32,
    alphaToCoverage: u32,
    fogStart: f32,
    fogEnd: f32,
    fogColor: vec4<f32>,
}

@group(3) @binding(1) 
var<uniform> unnamed: SceneLighting;
@group(2) @binding(0) 
var tex: texture_2d<f32>;
@group(2) @binding(1) 
var s: sampler;
@group(3) @binding(0) 
var<uniform> unnamed_1: FogUniforms;
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> input_u002e_color_1: vec4<f32>;
var<private> input_u002e_fogFactor_1: f32;
var<private> input_u002e_eyeDepth_1: f32;
var<private> u0040_entryPointOutput: vec4<f32>;

fn EnhancedFogAmount_u0028_f1_u003b(eyeDepth: ptr<function, f32>) -> f32 {
    var scaledDistance: f32;

    let _e27 = (*eyeDepth);
    let _e30 = unnamed.sceneFogParameters[0u];
    let _e35 = unnamed.sceneFogParameters[2u];
    scaledDistance = (max((_e27 - _e30), 0f) * _e35);
    let _e37 = scaledDistance;
    let _e39 = scaledDistance;
    return clamp((1f - exp((-(_e37) * _e39))), 0f, 1f);
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf4_u002d_f1_u002d_f11_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    var color: vec4<f32>;
    var edge: f32;
    var param: f32;

    let _e30 = (*input).uv;
    let _e31 = textureSample(tex, s, _e30);
    let _e33 = (*input).color;
    color = (_e31 * _e33);
    let _e36 = unnamed_1.alphaToCoverage;
    if (_e36 != 0u) {
        let _e39 = color[3u];
        let _e41 = unnamed_1.alphaThreshold;
        let _e44 = color[3u];
        let _e45 = fwidth(_e44);
        edge = clamp((((_e39 - _e41) / max(_e45, 0.0001f)) + 0.5f), 0f, 1f);
        let _e50 = edge;
        let _e52 = color[3u];
        color[3u] = (_e52 * _e50);
        let _e56 = color[3u];
        if (_e56 <= 0f) {
            discard;
        }
    } else {
        let _e59 = unnamed_1.alphaDiscardEnabled;
        let _e62 = color[3u];
        let _e64 = unnamed_1.alphaThreshold;
        if ((_e59 != 0u) && (_e62 <= _e64)) {
            discard;
        }
    }
    let _e68 = unnamed_1.fogEnabled;
    let _e72 = unnamed.sceneFogColor[3u];
    if ((_e68 != 0u) && (_e72 > 0f)) {
        let _e75 = color;
        let _e78 = unnamed.sceneFogColor;
        let _e81 = (*input).eyeDepth;
        param = _e81;
        let _e82 = EnhancedFogAmount_u0028_f1_u003b((&param));
        let _e84 = mix(_e75.xyz, _e78.xyz, vec3(_e82));
        color[0u] = _e84.x;
        color[1u] = _e84.y;
        color[2u] = _e84.z;
    }
    let _e91 = color;
    return _e91;
}

fn main_1() {
    var input_1: FSInput;
    var param_1: FSInput;

    let _e27 = input_u002e_pos_1;
    input_1.pos = _e27;
    let _e29 = input_u002e_uv_1;
    input_1.uv = _e29;
    let _e31 = input_u002e_color_1;
    input_1.color = _e31;
    let _e33 = input_u002e_fogFactor_1;
    input_1.fogFactor = _e33;
    let _e35 = input_u002e_eyeDepth_1;
    input_1.eyeDepth = _e35;
    let _e37 = input_1;
    param_1 = _e37;
    let _e38 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf4_u002d_f1_u002d_f11_u003b((&param_1));
    u0040_entryPointOutput = _e38;
    return;
}

@fragment 
fn main(@builtin(position) input_u002e_pos: vec4<f32>, @location(0) input_u002e_uv: vec2<f32>, @location(1) input_u002e_color: vec4<f32>, @location(2) input_u002e_fogFactor: f32, @location(3) input_u002e_eyeDepth: f32) -> @location(0) vec4<f32> {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    input_u002e_color_1 = input_u002e_color;
    input_u002e_fogFactor_1 = input_u002e_fogFactor;
    input_u002e_eyeDepth_1 = input_u002e_eyeDepth;
    main_1();
    let _e11 = u0040_entryPointOutput;
    return _e11;
}
