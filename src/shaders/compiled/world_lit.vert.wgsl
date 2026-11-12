struct VSInput {
    pos: vec3<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
    normal: vec3<f32>,
}

struct VSOutput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
    fogFactor: f32,
    eyeDepth: f32,
    worldPosition: vec3<f32>,
    darkening: vec3<f32>,
    clipDist: f32,
}

struct Transform {
    mvp: mat4x4<f32>,
    fogStart: f32,
    fogEnd: f32,
    fogPad: vec2<f32>,
}

struct VertexOutput {
    @builtin(position) member: vec4<f32>,
    @location(0) member_1: vec2<f32>,
    @location(1) member_2: vec4<f32>,
    @location(2) member_3: f32,
    @location(3) member_4: f32,
    @location(4) member_5: vec3<f32>,
    @location(5) member_6: vec3<f32>,
    @location(6) member_7: f32,
}

@group(1) @binding(0) 
var<uniform> unnamed: Transform;
var<private> input_u002e_pos_1: vec3<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> input_u002e_color_1: vec4<f32>;
var<private> input_u002e_normal_1: vec3<f32>;
var<private> u0040_entryPointOutput_u002e_pos: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
var<private> u0040_entryPointOutput_u002e_uv: vec2<f32>;
var<private> u0040_entryPointOutput_u002e_color: vec4<f32>;
var<private> u0040_entryPointOutput_u002e_fogFactor: f32;
var<private> u0040_entryPointOutput_u002e_eyeDepth: f32;
var<private> u0040_entryPointOutput_u002e_worldPosition: vec3<f32>;
var<private> u0040_entryPointOutput_u002e_darkening: vec3<f32>;
var<private> u0040_entryPointOutput_u002e_clipDist: f32;

fn u0040_main_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf2_u002d_vf4_u002d_vf31_u003b(input: ptr<function, VSInput>) -> VSOutput {
    var o: VSOutput;
    var dist: f32;
    var range: f32;

    let _e32 = (*input).pos;
    let _e38 = unnamed.mvp;
    o.pos = (vec4<f32>(_e32.x, _e32.y, _e32.z, 1f) * transpose(_e38));
    let _e43 = (*input).uv;
    o.uv = _e43;
    let _e46 = (*input).color;
    o.color = _e46;
    let _e50 = o.pos[3u];
    o.clipDist = (_e50 - 1f);
    let _e55 = o.pos[3u];
    dist = abs(_e55);
    let _e58 = unnamed.fogEnd;
    let _e60 = unnamed.fogStart;
    range = (_e58 - _e60);
    let _e62 = range;
    let _e65 = unnamed.fogEnd;
    let _e66 = dist;
    let _e68 = range;
    o.fogFactor = select(1f, clamp(((_e65 - _e66) / _e68), 0f, 1f), (_e62 > 0.001f));
    let _e73 = dist;
    o.eyeDepth = _e73;
    let _e76 = (*input).pos;
    o.worldPosition = _e76;
    let _e79 = (*input).normal;
    o.darkening = (_e79 - vec3<f32>(0f, 0f, 1f));
    let _e82 = o;
    return _e82;
}

fn main_1() {
    var input_1: VSInput;
    var flattenTemp: VSOutput;
    var param: VSInput;

    let _e30 = input_u002e_pos_1;
    input_1.pos = _e30;
    let _e32 = input_u002e_uv_1;
    input_1.uv = _e32;
    let _e34 = input_u002e_color_1;
    input_1.color = _e34;
    let _e36 = input_u002e_normal_1;
    input_1.normal = _e36;
    let _e38 = input_1;
    param = _e38;
    let _e39 = u0040_main_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf2_u002d_vf4_u002d_vf31_u003b((&param));
    flattenTemp = _e39;
    let _e41 = flattenTemp.pos;
    u0040_entryPointOutput_u002e_pos = _e41;
    let _e43 = flattenTemp.uv;
    u0040_entryPointOutput_u002e_uv = _e43;
    let _e45 = flattenTemp.color;
    u0040_entryPointOutput_u002e_color = _e45;
    let _e47 = flattenTemp.fogFactor;
    u0040_entryPointOutput_u002e_fogFactor = _e47;
    let _e49 = flattenTemp.eyeDepth;
    u0040_entryPointOutput_u002e_eyeDepth = _e49;
    let _e51 = flattenTemp.worldPosition;
    u0040_entryPointOutput_u002e_worldPosition = _e51;
    let _e53 = flattenTemp.darkening;
    u0040_entryPointOutput_u002e_darkening = _e53;
    let _e55 = flattenTemp.clipDist;
    u0040_entryPointOutput_u002e_clipDist = _e55;
    return;
}

@vertex 
fn main(@location(0) input_u002e_pos: vec3<f32>, @location(1) input_u002e_uv: vec2<f32>, @location(2) input_u002e_color: vec4<f32>, @location(3) input_u002e_normal: vec3<f32>) -> VertexOutput {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    input_u002e_color_1 = input_u002e_color;
    input_u002e_normal_1 = input_u002e_normal;
    main_1();
    let _e16 = u0040_entryPointOutput_u002e_pos;
    let _e17 = u0040_entryPointOutput_u002e_uv;
    let _e18 = u0040_entryPointOutput_u002e_color;
    let _e19 = u0040_entryPointOutput_u002e_fogFactor;
    let _e20 = u0040_entryPointOutput_u002e_eyeDepth;
    let _e21 = u0040_entryPointOutput_u002e_worldPosition;
    let _e22 = u0040_entryPointOutput_u002e_darkening;
    let _e23 = u0040_entryPointOutput_u002e_clipDist;
    return VertexOutput(_e16, _e17, _e18, _e19, _e20, _e21, _e22, _e23);
}
