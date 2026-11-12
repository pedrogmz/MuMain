struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
}

var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> input_u002e_color_1: vec4<f32>;
var<private> u0040_entryPointOutput: vec4<f32>;

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf41_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    let _e12 = (*input).color[3u];
    return vec4((1f - _e12));
}

fn main_1() {
    var input_1: FSInput;
    var param: FSInput;

    let _e11 = input_u002e_pos_1;
    input_1.pos = _e11;
    let _e13 = input_u002e_uv_1;
    input_1.uv = _e13;
    let _e15 = input_u002e_color_1;
    input_1.color = _e15;
    let _e17 = input_1;
    param = _e17;
    let _e18 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf41_u003b((&param));
    u0040_entryPointOutput = _e18;
    return;
}

@fragment 
fn main(@builtin(position) input_u002e_pos: vec4<f32>, @location(0) input_u002e_uv: vec2<f32>, @location(1) input_u002e_color: vec4<f32>) -> @location(0) vec4<f32> {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    input_u002e_color_1 = input_u002e_color;
    main_1();
    let _e7 = u0040_entryPointOutput;
    return _e7;
}
