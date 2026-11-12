struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
}

struct AmbientOcclusion {
    projection: mat4x4<f32>,
    inverseProjection: mat4x4<f32>,
    depthTexelSize: vec2<f32>,
    radius: f32,
    padding: f32,
}

@group(3) @binding(0) 
var<uniform> unnamed: AmbientOcclusion;
@group(2) @binding(0) 
var depthTexture: texture_2d<f32>;
@group(2) @binding(1) 
var depthSampler: sampler;
@group(2) @binding(2) 
var occlusionTexture: texture_2d<f32>;
@group(2) @binding(3) 
var occlusionSampler: sampler;
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> u0040_entryPointOutput: vec4<f32>;

fn ViewPosition_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> vec3<f32> {
    var depth: f32;
    var view: vec4<f32>;

    let _e26 = (*uv);
    let _e28 = unnamed.depthTexelSize;
    let _e36 = unnamed.depthTexelSize;
    (*uv) = ((floor(((_e26 / _e28) + vec2(0.25f))) + vec2(0.5f)) * _e36);
    let _e38 = (*uv);
    let _e39 = textureSampleLevel(depthTexture, depthSampler, _e38, 0f);
    depth = _e39.x;
    let _e42 = (*uv)[0u];
    let _e46 = (*uv)[1u];
    let _e49 = depth;
    let _e52 = unnamed.inverseProjection;
    view = (vec4<f32>(((_e42 * 2f) - 1f), (1f - (_e46 * 2f)), _e49, 1f) * transpose(_e52));
    let _e55 = view;
    let _e58 = view[3u];
    return (_e55.xyz / vec3(_e58));
}

fn SurfaceNormal_u0028_vf2_u003b_vf3_u003b(uv_1: ptr<function, vec2<f32>>, position: ptr<function, vec3<f32>>) -> vec3<f32> {
    var right: vec3<f32>;
    var param: vec2<f32>;
    var left: vec3<f32>;
    var param_1: vec2<f32>;
    var down: vec3<f32>;
    var param_2: vec2<f32>;
    var up: vec3<f32>;
    var param_3: vec2<f32>;
    var alongX: vec3<f32>;
    var alongY: vec3<f32>;

    let _e35 = (*uv_1);
    let _e38 = unnamed.depthTexelSize[0u];
    param = (_e35 + vec2<f32>(_e38, 0f));
    let _e41 = ViewPosition_u0028_vf2_u003b((&param));
    let _e42 = (*position);
    right = (_e41 - _e42);
    let _e44 = (*position);
    let _e45 = (*uv_1);
    let _e48 = unnamed.depthTexelSize[0u];
    param_1 = (_e45 - vec2<f32>(_e48, 0f));
    let _e51 = ViewPosition_u0028_vf2_u003b((&param_1));
    left = (_e44 - _e51);
    let _e53 = (*uv_1);
    let _e56 = unnamed.depthTexelSize[1u];
    param_2 = (_e53 + vec2<f32>(0f, _e56));
    let _e59 = ViewPosition_u0028_vf2_u003b((&param_2));
    let _e60 = (*position);
    down = (_e59 - _e60);
    let _e62 = (*position);
    let _e63 = (*uv_1);
    let _e66 = unnamed.depthTexelSize[1u];
    param_3 = (_e63 - vec2<f32>(0f, _e66));
    let _e69 = ViewPosition_u0028_vf2_u003b((&param_3));
    up = (_e62 - _e69);
    let _e72 = right[2u];
    let _e75 = left[2u];
    let _e78 = right;
    let _e79 = left;
    alongX = select(_e79, _e78, vec3((abs(_e72) < abs(_e75))));
    let _e83 = down[2u];
    let _e86 = up[2u];
    let _e89 = down;
    let _e90 = up;
    alongY = select(_e90, _e89, vec3((abs(_e83) < abs(_e86))));
    let _e93 = alongX;
    let _e94 = alongY;
    return normalize(cross(_e93, _e94));
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf21_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    var centre: vec3<f32>;
    var param_4: vec2<f32>;
    var normal: vec3<f32>;
    var param_5: vec2<f32>;
    var param_6: vec3<f32>;
    var occlusionTexelSize: vec2<f32>;
    var planeTolerance: f32;
    var sum: f32;
    var weightSum: f32;
    var y: i32;
    var x: i32;
    var uv_2: vec2<f32>;
    var offPlane: f32;
    var param_7: vec2<f32>;
    var weight: f32;
    var visibility: f32;

    let _e41 = (*input).uv;
    param_4 = _e41;
    let _e42 = ViewPosition_u0028_vf2_u003b((&param_4));
    centre = _e42;
    let _e44 = (*input).uv;
    param_5 = _e44;
    let _e45 = centre;
    param_6 = _e45;
    let _e46 = SurfaceNormal_u0028_vf2_u003b_vf3_u003b((&param_5), (&param_6));
    normal = _e46;
    let _e48 = unnamed.depthTexelSize;
    occlusionTexelSize = (_e48 * 2f);
    let _e51 = unnamed.radius;
    planeTolerance = (_e51 * 0.25f);
    sum = 0f;
    weightSum = 0f;
    y = -2i;
    loop {
        let _e53 = y;
        if (_e53 < 2i) {
            x = -2i;
            loop {
                let _e55 = x;
                if (_e55 < 2i) {
                    let _e58 = (*input).uv;
                    let _e59 = x;
                    let _e61 = y;
                    let _e64 = occlusionTexelSize;
                    uv_2 = (_e58 + (vec2<f32>(f32(_e59), f32(_e61)) * _e64));
                    let _e67 = uv_2;
                    param_7 = _e67;
                    let _e68 = ViewPosition_u0028_vf2_u003b((&param_7));
                    let _e69 = centre;
                    let _e71 = normal;
                    offPlane = abs(dot((_e68 - _e69), _e71));
                    let _e74 = offPlane;
                    let _e75 = planeTolerance;
                    weight = (clamp((1f - (_e74 / _e75)), 0f, 1f) + 0.001f);
                    let _e80 = uv_2;
                    let _e81 = textureSampleLevel(occlusionTexture, occlusionSampler, _e80, 0f);
                    let _e83 = weight;
                    let _e85 = sum;
                    sum = (_e85 + (_e81.x * _e83));
                    let _e87 = weight;
                    let _e88 = weightSum;
                    weightSum = (_e88 + _e87);
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e90 = x;
                    x = (_e90 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e92 = y;
            y = (_e92 + 1i);
        }
    }
    let _e94 = sum;
    let _e95 = weightSum;
    visibility = (_e94 / _e95);
    let _e97 = visibility;
    return vec4(_e97);
}

fn main_1() {
    var input_1: FSInput;
    var param_8: FSInput;

    let _e25 = input_u002e_pos_1;
    input_1.pos = _e25;
    let _e27 = input_u002e_uv_1;
    input_1.uv = _e27;
    let _e29 = input_1;
    param_8 = _e29;
    let _e30 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf21_u003b((&param_8));
    u0040_entryPointOutput = _e30;
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
