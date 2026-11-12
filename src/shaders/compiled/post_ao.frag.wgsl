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

@group(2) @binding(0) 
var depthTexture: texture_2d<f32>;
@group(2) @binding(1) 
var depthSampler: sampler;
@group(3) @binding(0) 
var<uniform> unnamed: AmbientOcclusion;
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> u0040_entryPointOutput: vec4<f32>;

fn ViewPosition_u0028_vf2_u003b_f1_u003b(uv: ptr<function, vec2<f32>>, depth: ptr<function, f32>) -> vec3<f32> {
    var view: vec4<f32>;

    let _e89 = (*uv)[0u];
    let _e93 = (*uv)[1u];
    let _e96 = (*depth);
    let _e99 = unnamed.inverseProjection;
    view = (vec4<f32>(((_e89 * 2f) - 1f), (1f - (_e93 * 2f)), _e96, 1f) * transpose(_e99));
    let _e102 = view;
    let _e105 = view[3u];
    return (_e102.xyz / vec3(_e105));
}

fn SceneDepth_u0028_vf2_u003b(uv_1: ptr<function, vec2<f32>>) -> f32 {
    let _e86 = (*uv_1);
    let _e87 = textureSampleLevel(depthTexture, depthSampler, _e86, 0f);
    return _e87.x;
}

fn ViewPositionAt_u0028_vf2_u003b(uv_2: ptr<function, vec2<f32>>) -> vec3<f32> {
    var centre: vec2<f32>;
    var param: vec2<f32>;
    var param_1: vec2<f32>;
    var param_2: f32;

    let _e90 = (*uv_2);
    let _e92 = unnamed.depthTexelSize;
    let _e100 = unnamed.depthTexelSize;
    centre = ((floor(((_e90 / _e92) + vec2(0.25f))) + vec2(0.5f)) * _e100);
    let _e102 = centre;
    param = _e102;
    let _e103 = SceneDepth_u0028_vf2_u003b((&param));
    let _e104 = centre;
    param_1 = _e104;
    param_2 = _e103;
    let _e105 = ViewPosition_u0028_vf2_u003b_f1_u003b((&param_1), (&param_2));
    return _e105;
}

fn SurfaceNormal_u0028_vf2_u003b_vf3_u003b(uv_3: ptr<function, vec2<f32>>, position: ptr<function, vec3<f32>>) -> vec3<f32> {
    var right: vec3<f32>;
    var param_3: vec2<f32>;
    var left: vec3<f32>;
    var param_4: vec2<f32>;
    var down: vec3<f32>;
    var param_5: vec2<f32>;
    var up: vec3<f32>;
    var param_6: vec2<f32>;
    var alongX: vec3<f32>;
    var alongY: vec3<f32>;
    var normal: vec3<f32>;

    let _e98 = (*uv_3);
    let _e101 = unnamed.depthTexelSize[0u];
    param_3 = (_e98 + vec2<f32>(_e101, 0f));
    let _e104 = ViewPositionAt_u0028_vf2_u003b((&param_3));
    let _e105 = (*position);
    right = (_e104 - _e105);
    let _e107 = (*position);
    let _e108 = (*uv_3);
    let _e111 = unnamed.depthTexelSize[0u];
    param_4 = (_e108 - vec2<f32>(_e111, 0f));
    let _e114 = ViewPositionAt_u0028_vf2_u003b((&param_4));
    left = (_e107 - _e114);
    let _e116 = (*uv_3);
    let _e119 = unnamed.depthTexelSize[1u];
    param_5 = (_e116 + vec2<f32>(0f, _e119));
    let _e122 = ViewPositionAt_u0028_vf2_u003b((&param_5));
    let _e123 = (*position);
    down = (_e122 - _e123);
    let _e125 = (*position);
    let _e126 = (*uv_3);
    let _e129 = unnamed.depthTexelSize[1u];
    param_6 = (_e126 - vec2<f32>(0f, _e129));
    let _e132 = ViewPositionAt_u0028_vf2_u003b((&param_6));
    up = (_e125 - _e132);
    let _e135 = right[2u];
    let _e138 = left[2u];
    let _e141 = right;
    let _e142 = left;
    alongX = select(_e142, _e141, vec3((abs(_e135) < abs(_e138))));
    let _e146 = down[2u];
    let _e149 = up[2u];
    let _e152 = down;
    let _e153 = up;
    alongY = select(_e153, _e152, vec3((abs(_e146) < abs(_e149))));
    let _e156 = alongX;
    let _e157 = alongY;
    normal = normalize(cross(_e156, _e157));
    let _e160 = normal;
    let _e161 = (*position);
    let _e164 = normal;
    let _e166 = normal;
    return select(_e166, -(_e164), vec3((dot(_e160, _e161) > 0f)));
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf21_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    var param_7: vec2<f32>;
    var position_1: vec3<f32>;
    var param_8: vec2<f32>;
    var normal_1: vec3<f32>;
    var param_9: vec2<f32>;
    var param_10: vec3<f32>;
    var cell: vec2<u32>;
    var angle: f32;
    var indexable: array<f32, 16>;
    var turn: vec3<f32>;
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;
    var occlusion: f32;
    var i: u32;
    var offset: vec3<f32>;
    var indexable_1: array<vec3<f32>, 12>;
    var indexable_2: array<vec3<f32>, 12>;
    var indexable_3: array<vec3<f32>, 12>;
    var samplePosition: vec3<f32>;
    var clip: vec4<f32>;
    var sampleUv: vec2<f32>;
    var toOccluder: vec3<f32>;
    var param_11: vec2<f32>;
    var distanceSquared: f32;
    var rise: f32;
    var inRange: f32;
    var visibility: f32;

    let _e114 = (*input).uv;
    param_7 = _e114;
    let _e115 = SceneDepth_u0028_vf2_u003b((&param_7));
    if (_e115 >= 1f) {
        return vec4<f32>(1f, 1f, 1f, 1f);
    }
    let _e118 = (*input).uv;
    param_8 = _e118;
    let _e119 = ViewPositionAt_u0028_vf2_u003b((&param_8));
    position_1 = _e119;
    let _e121 = (*input).uv;
    param_9 = _e121;
    let _e122 = position_1;
    param_10 = _e122;
    let _e123 = SurfaceNormal_u0028_vf2_u003b_vf3_u003b((&param_9), (&param_10));
    normal_1 = _e123;
    let _e125 = (*input).pos;
    cell = (vec2<u32>(_e125.xy) & vec2<u32>(3u, 3u));
    let _e130 = cell[1u];
    let _e133 = cell[0u];
    indexable = array<f32, 16>(0f, 0.5f, 0.125f, 0.625f, 0.75f, 0.25f, 0.875f, 0.375f, 0.1875f, 0.6875f, 0.0625f, 0.5625f, 0.9375f, 0.4375f, 0.8125f, 0.3125f);
    let _e136 = indexable[((_e130 * 4u) + _e133)];
    angle = (6.2831855f * _e136);
    let _e138 = angle;
    let _e140 = angle;
    turn = vec3<f32>(cos(_e138), sin(_e140), 0f);
    let _e143 = turn;
    let _e144 = normal_1;
    let _e145 = turn;
    let _e146 = normal_1;
    tangent = normalize(((_e143 - (_e144 * dot(_e145, _e146))) + vec3<f32>(0.0001f, 0f, 0f)));
    let _e152 = normal_1;
    let _e153 = tangent;
    bitangent = cross(_e152, _e153);
    occlusion = 0f;
    i = 0u;
    loop {
        let _e155 = i;
        if (_e155 < 12u) {
            let _e157 = tangent;
            let _e158 = i;
            indexable_1 = array<vec3<f32>, 12>(vec3<f32>(0.21f, 0.05f, 0.1f), vec3<f32>(-0.1f, 0.25f, 0.15f), vec3<f32>(-0.28f, -0.12f, 0.08f), vec3<f32>(0.14f, -0.3f, 0.2f), vec3<f32>(0.42f, 0.22f, 0.25f), vec3<f32>(-0.35f, 0.4f, 0.12f), vec3<f32>(-0.3f, -0.45f, 0.35f), vec3<f32>(0.38f, -0.36f, 0.42f), vec3<f32>(0.7f, 0.1f, 0.3f), vec3<f32>(-0.15f, 0.72f, 0.45f), vec3<f32>(-0.66f, -0.2f, 0.55f), vec3<f32>(0.2f, -0.62f, 0.7f));
            let _e161 = indexable_1[_e158][0u];
            let _e163 = bitangent;
            let _e164 = i;
            indexable_2 = array<vec3<f32>, 12>(vec3<f32>(0.21f, 0.05f, 0.1f), vec3<f32>(-0.1f, 0.25f, 0.15f), vec3<f32>(-0.28f, -0.12f, 0.08f), vec3<f32>(0.14f, -0.3f, 0.2f), vec3<f32>(0.42f, 0.22f, 0.25f), vec3<f32>(-0.35f, 0.4f, 0.12f), vec3<f32>(-0.3f, -0.45f, 0.35f), vec3<f32>(0.38f, -0.36f, 0.42f), vec3<f32>(0.7f, 0.1f, 0.3f), vec3<f32>(-0.15f, 0.72f, 0.45f), vec3<f32>(-0.66f, -0.2f, 0.55f), vec3<f32>(0.2f, -0.62f, 0.7f));
            let _e167 = indexable_2[_e164][1u];
            let _e170 = normal_1;
            let _e171 = i;
            indexable_3 = array<vec3<f32>, 12>(vec3<f32>(0.21f, 0.05f, 0.1f), vec3<f32>(-0.1f, 0.25f, 0.15f), vec3<f32>(-0.28f, -0.12f, 0.08f), vec3<f32>(0.14f, -0.3f, 0.2f), vec3<f32>(0.42f, 0.22f, 0.25f), vec3<f32>(-0.35f, 0.4f, 0.12f), vec3<f32>(-0.3f, -0.45f, 0.35f), vec3<f32>(0.38f, -0.36f, 0.42f), vec3<f32>(0.7f, 0.1f, 0.3f), vec3<f32>(-0.15f, 0.72f, 0.45f), vec3<f32>(-0.66f, -0.2f, 0.55f), vec3<f32>(0.2f, -0.62f, 0.7f));
            let _e174 = indexable_3[_e171][2u];
            offset = (((_e157 * _e161) + (_e163 * _e167)) + (_e170 * _e174));
            let _e177 = position_1;
            let _e178 = offset;
            let _e180 = unnamed.radius;
            samplePosition = (_e177 + (_e178 * _e180));
            let _e183 = samplePosition;
            let _e189 = unnamed.projection;
            clip = (vec4<f32>(_e183.x, _e183.y, _e183.z, 1f) * transpose(_e189));
            let _e193 = clip[0u];
            let _e195 = clip[3u];
            let _e200 = clip[1u];
            let _e202 = clip[3u];
            sampleUv = vec2<f32>((((_e193 / _e195) * 0.5f) + 0.5f), (0.5f - ((_e200 / _e202) * 0.5f)));
            let _e207 = sampleUv;
            param_11 = _e207;
            let _e208 = ViewPositionAt_u0028_vf2_u003b((&param_11));
            let _e209 = position_1;
            toOccluder = (_e208 - _e209);
            let _e211 = toOccluder;
            let _e212 = toOccluder;
            distanceSquared = dot(_e211, _e212);
            let _e214 = toOccluder;
            let _e215 = normal_1;
            let _e217 = distanceSquared;
            rise = (dot(_e214, _e215) * inverseSqrt(max(_e217, 0.000001f)));
            let _e221 = distanceSquared;
            let _e223 = unnamed.radius;
            let _e225 = unnamed.radius;
            inRange = clamp((1f - (_e221 / (_e223 * _e225))), 0f, 1f);
            let _e230 = rise;
            let _e233 = inRange;
            let _e235 = occlusion;
            occlusion = (_e235 + (clamp((_e230 - 0.15f), 0f, 1f) * _e233));
            continue;
        } else {
            break;
        }
        continuing {
            let _e237 = i;
            i = (_e237 + bitcast<u32>(1i));
        }
    }
    let _e240 = occlusion;
    visibility = (1f - (_e240 / 12f));
    let _e243 = visibility;
    return vec4(_e243);
}

fn main_1() {
    var input_1: FSInput;
    var param_12: FSInput;

    let _e87 = input_u002e_pos_1;
    input_1.pos = _e87;
    let _e89 = input_u002e_uv_1;
    input_1.uv = _e89;
    let _e91 = input_1;
    param_12 = _e91;
    let _e92 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf21_u003b((&param_12));
    u0040_entryPointOutput = _e92;
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
