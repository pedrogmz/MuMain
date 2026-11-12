struct VSInput {
    pos: vec3<f32>,
    color: vec4<f32>,
    positionBoneIndex: i32,
    joints: vec4<u32>,
    weights: vec4<f32>,
}

struct VSOutput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
    fogFactor: f32,
    clipDist: f32,
}

struct Skinning {
    mvp: mat4x4<f32>,
    bodyOriginAndScale: vec4<f32>,
    boneScaleAndRestPoseScale: vec4<f32>,
    palette: vec4<u32>,
    lightDirection: vec4<f32>,
    fogParameters: vec4<f32>,
    textureCoordinateMode: vec4<u32>,
    chromeParameters: vec4<f32>,
    textureCoordinateParameters: vec4<f32>,
}

struct Shadow {
    shadowOrigin: vec4<f32>,
    shadowProjection: vec4<f32>,
}

struct boneRows {
    u0040_data: array<vec4<f32>>,
}

struct terrainWords {
    u0040_data: array<u32>,
}

struct VertexOutput {
    @builtin(position) member: vec4<f32>,
    @location(0) member_1: vec2<f32>,
    @location(1) member_2: vec4<f32>,
    @location(2) member_3: f32,
    @location(3) member_4: f32,
}

@group(1) @binding(0) 
var<uniform> unnamed: Skinning;
@group(1) @binding(1) 
var<uniform> unnamed_1: Shadow;
@group(0) @binding(0) 
var<storage> boneRows_1: boneRows;
@group(0) @binding(1) 
var<storage> terrainWords_1: terrainWords;
var<private> input_u002e_pos_1: vec3<f32>;
var<private> input_u002e_color_1: vec4<f32>;
var<private> input_u002e_positionBoneIndex_1: i32;
var<private> input_u002e_joints_1: vec4<u32>;
var<private> input_u002e_weights_1: vec4<f32>;
var<private> u0040_entryPointOutput_u002e_pos: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
var<private> u0040_entryPointOutput_u002e_uv: vec2<f32>;
var<private> u0040_entryPointOutput_u002e_color: vec4<f32>;
var<private> u0040_entryPointOutput_u002e_fogFactor: f32;
var<private> u0040_entryPointOutput_u002e_clipDist: f32;

fn clipPosition_u0028_vf3_u003b(position: ptr<function, vec3<f32>>) -> vec4<f32> {
    let _e38 = (*position);
    let _e44 = unnamed.mvp;
    return (vec4<f32>(_e38.x, _e38.y, _e38.z, 1f) * transpose(_e44));
}

fn loadTerrainWord_u0028_u1_u003b(word: ptr<function, u32>) -> u32 {
    let _e38 = (*word);
    let _e41 = terrainWords_1.u0040_data[_e38];
    return _e41;
}

fn terrainCornerHeight_u0028_i1_u003b_i1_u003b(x: ptr<function, i32>, y: ptr<function, i32>) -> f32 {
    var param: u32;

    let _e40 = (*y);
    let _e44 = (*x);
    param = ((bitcast<u32>((_e40 & 255i)) * 256u) + bitcast<u32>((_e44 & 255i)));
    let _e48 = loadTerrainWord_u0028_u1_u003b((&param));
    return bitcast<f32>(_e48);
}

fn terrainHeight_u0028_f1_u003b_f1_u003b(x_1: ptr<function, f32>, y_1: ptr<function, f32>) -> f32 {
    var xi: i32;
    var yi: i32;
    var index: u32;
    var param_1: u32;
    var xd: f32;
    var yd: f32;
    var h1_: f32;
    var param_2: i32;
    var param_3: i32;
    var h2_: f32;
    var param_4: i32;
    var param_5: i32;
    var h3_: f32;
    var param_6: i32;
    var param_7: i32;
    var h4_: f32;
    var param_8: i32;
    var param_9: i32;
    var left: f32;
    var right: f32;

    let _e61 = unnamed_1.shadowProjection[2u];
    let _e63 = (*x_1);
    let _e66 = (*y_1);
    if (((_e61 == 0f) || (_e63 < 0f)) || (_e66 < 0f)) {
        return 0f;
    }
    let _e69 = (*x_1);
    (*x_1) = (_e69 / 100f);
    let _e71 = (*y_1);
    (*y_1) = (_e71 / 100f);
    let _e73 = (*x_1);
    xi = i32(_e73);
    let _e75 = (*y_1);
    yi = i32(_e75);
    let _e77 = yi;
    let _e79 = xi;
    index = bitcast<u32>(((_e77 * 256i) + _e79));
    let _e82 = index;
    let _e84 = index;
    param_1 = (65536u + (_e84 >> bitcast<u32>(5i)));
    let _e88 = loadTerrainWord_u0028_u1_u003b((&param_1));
    let _e89 = index;
    if ((_e82 >= 65536u) || (((_e88 >> bitcast<u32>((_e89 & 31u))) & 1u) != 0u)) {
        let _e98 = unnamed_1.shadowOrigin[3u];
        return _e98;
    }
    let _e99 = (*x_1);
    let _e100 = xi;
    xd = (_e99 - f32(_e100));
    let _e103 = (*y_1);
    let _e104 = yi;
    yd = (_e103 - f32(_e104));
    let _e107 = xi;
    param_2 = _e107;
    let _e108 = yi;
    param_3 = _e108;
    let _e109 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_2), (&param_3));
    h1_ = _e109;
    let _e110 = yi;
    let _e112 = xi;
    param_4 = _e112;
    param_5 = (_e110 + 1i);
    let _e113 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_4), (&param_5));
    h2_ = _e113;
    let _e114 = xi;
    param_6 = (_e114 + 1i);
    let _e116 = yi;
    param_7 = _e116;
    let _e117 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_6), (&param_7));
    h3_ = _e117;
    let _e118 = xi;
    let _e120 = yi;
    param_8 = (_e118 + 1i);
    param_9 = (_e120 + 1i);
    let _e122 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_8), (&param_9));
    h4_ = _e122;
    let _e123 = h1_;
    let _e124 = h2_;
    let _e125 = h1_;
    let _e127 = yd;
    left = (_e123 + ((_e124 - _e125) * _e127));
    let _e130 = h3_;
    let _e131 = h4_;
    let _e132 = h3_;
    let _e134 = yd;
    right = (_e130 + ((_e131 - _e132) * _e134));
    let _e137 = left;
    let _e138 = right;
    let _e139 = left;
    let _e141 = xd;
    return (_e137 + ((_e138 - _e139) * _e141));
}

fn shearShadow_u0028_vf3_u003b(position_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var relative: vec3<f32>;
    var axis: vec2<f32>;
    var along: f32;

    let _e41 = (*position_1);
    let _e43 = unnamed_1.shadowOrigin;
    relative = (_e41 - _e43.xyz);
    let _e48 = unnamed_1.shadowProjection[3u];
    let _e52 = unnamed_1.shadowProjection[3u];
    axis = vec2<f32>(cos(_e48), sin(_e52));
    let _e55 = relative;
    let _e57 = axis;
    along = dot(_e55.xy, _e57);
    let _e59 = axis;
    let _e61 = relative[2u];
    let _e62 = along;
    let _e65 = unnamed_1.shadowProjection[0u];
    let _e69 = relative[2u];
    let _e72 = unnamed_1.shadowProjection[1u];
    let _e76 = relative;
    let _e78 = (_e76.xy + (_e59 * ((_e61 * (_e62 + _e65)) / (_e69 - _e72))));
    relative[0u] = _e78.x;
    relative[1u] = _e78.y;
    let _e83 = relative;
    let _e85 = unnamed_1.shadowOrigin;
    return (_e83 + _e85.xyz);
}

fn loadBoneRow_u0028_u1_u003b(row: ptr<function, u32>) -> vec4<f32> {
    let _e38 = (*row);
    let _e41 = boneRows_1.u0040_data[_e38];
    return _e41;
}

fn transformPosition_u0028_vf3_u003b_i1_u003b(position_2: ptr<function, vec3<f32>>, boneIndex: ptr<function, i32>) -> vec3<f32> {
    var row_1: u32;
    var row0_: vec4<f32>;
    var param_10: u32;
    var row1_: vec4<f32>;
    var param_11: u32;
    var row2_: vec4<f32>;
    var param_12: u32;
    var restScale: f32;
    var restPosition: vec4<f32>;
    var transformed: vec3<f32>;

    let _e49 = (*boneIndex);
    let _e51 = (*boneIndex);
    let _e54 = unnamed.palette[1u];
    if ((_e49 < 0i) || (_e51 >= bitcast<i32>(_e54))) {
        let _e58 = (*position_2);
        return _e58;
    }
    let _e61 = unnamed.palette[0u];
    let _e62 = (*boneIndex);
    row_1 = (_e61 + (bitcast<u32>(_e62) * 3u));
    let _e66 = row_1;
    param_10 = _e66;
    let _e67 = loadBoneRow_u0028_u1_u003b((&param_10));
    row0_ = _e67;
    let _e68 = row_1;
    param_11 = (_e68 + 1u);
    let _e70 = loadBoneRow_u0028_u1_u003b((&param_11));
    row1_ = _e70;
    let _e71 = row_1;
    param_12 = (_e71 + 2u);
    let _e73 = loadBoneRow_u0028_u1_u003b((&param_12));
    row2_ = _e73;
    let _e76 = unnamed.boneScaleAndRestPoseScale[0u];
    if (_e76 == 1f) {
        let _e80 = unnamed.boneScaleAndRestPoseScale[1u];
        let _e84 = unnamed.boneScaleAndRestPoseScale[1u];
        restScale = select(1f, _e84, (_e80 != 0f));
        let _e86 = (*position_2);
        let _e87 = restScale;
        let _e88 = (_e86 * _e87);
        restPosition = vec4<f32>(_e88.x, _e88.y, _e88.z, 1f);
        let _e93 = row0_;
        let _e94 = restPosition;
        let _e96 = row1_;
        let _e97 = restPosition;
        let _e99 = row2_;
        let _e100 = restPosition;
        transformed = vec3<f32>(dot(_e93, _e94), dot(_e96, _e97), dot(_e99, _e100));
    } else {
        let _e103 = row0_;
        let _e105 = (*position_2);
        let _e107 = row1_;
        let _e109 = (*position_2);
        let _e111 = row2_;
        let _e113 = (*position_2);
        transformed = vec3<f32>(dot(_e103.xyz, _e105), dot(_e107.xyz, _e109), dot(_e111.xyz, _e113));
        let _e116 = transformed;
        let _e119 = unnamed.boneScaleAndRestPoseScale[0u];
        let _e122 = row0_[3u];
        let _e124 = row1_[3u];
        let _e126 = row2_[3u];
        transformed = ((_e116 * _e119) + vec3<f32>(_e122, _e124, _e126));
    }
    let _e131 = unnamed.palette[2u];
    if (_e131 != 0u) {
        let _e134 = unnamed.bodyOriginAndScale;
        let _e136 = transformed;
        let _e139 = unnamed.bodyOriginAndScale[3u];
        transformed = (_e134.xyz + (_e136 * _e139));
    }
    let _e142 = transformed;
    return _e142;
}

fn skinWeightedPosition_u0028_vf3_u003b_vu4_u003b_vf4_u003b(position_3: ptr<function, vec3<f32>>, joints: ptr<function, vec4<u32>>, weights: ptr<function, vec4<f32>>) -> vec3<f32> {
    var bindPosition: vec4<f32>;
    var transformed_1: vec3<f32>;
    var k: u32;
    var row_2: u32;
    var param_13: u32;
    var param_14: u32;
    var param_15: u32;

    let _e47 = (*position_3);
    bindPosition = vec4<f32>(_e47.x, _e47.y, _e47.z, 1f);
    transformed_1 = vec3<f32>(0f, 0f, 0f);
    k = 0u;
    loop {
        let _e52 = k;
        if (_e52 < 4u) {
            let _e54 = k;
            let _e56 = (*weights)[_e54];
            let _e58 = k;
            let _e60 = (*joints)[_e58];
            let _e63 = unnamed.palette[1u];
            if ((_e56 > 0f) && (_e60 < _e63)) {
                let _e68 = unnamed.palette[0u];
                let _e69 = k;
                let _e71 = (*joints)[_e69];
                row_2 = (_e68 + (_e71 * 3u));
                let _e74 = k;
                let _e76 = (*weights)[_e74];
                let _e77 = row_2;
                param_13 = _e77;
                let _e78 = loadBoneRow_u0028_u1_u003b((&param_13));
                let _e79 = bindPosition;
                let _e81 = row_2;
                param_14 = (_e81 + 1u);
                let _e83 = loadBoneRow_u0028_u1_u003b((&param_14));
                let _e84 = bindPosition;
                let _e86 = row_2;
                param_15 = (_e86 + 2u);
                let _e88 = loadBoneRow_u0028_u1_u003b((&param_15));
                let _e89 = bindPosition;
                let _e93 = transformed_1;
                transformed_1 = (_e93 + (vec3<f32>(dot(_e78, _e79), dot(_e83, _e84), dot(_e88, _e89)) * _e76));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e95 = k;
            k = (_e95 + bitcast<u32>(1i));
        }
    }
    let _e100 = unnamed.palette[2u];
    if (_e100 != 0u) {
        let _e103 = unnamed.bodyOriginAndScale;
        let _e105 = transformed_1;
        let _e108 = unnamed.bodyOriginAndScale[3u];
        transformed_1 = (_e103.xyz + (_e105 * _e108));
    }
    let _e111 = transformed_1;
    return _e111;
}

fn skinnedPosition_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i1_u002d_vu4_u002d_vf41_u003b(input: ptr<function, VSInput>) -> vec3<f32> {
    var param_16: vec3<f32>;
    var param_17: vec4<u32>;
    var param_18: vec4<f32>;
    var param_19: vec3<f32>;
    var param_20: i32;

    let _e45 = (*input).weights[0u];
    if (_e45 > 0f) {
        let _e48 = (*input).pos;
        param_16 = _e48;
        let _e50 = (*input).joints;
        param_17 = _e50;
        let _e52 = (*input).weights;
        param_18 = _e52;
        let _e53 = skinWeightedPosition_u0028_vf3_u003b_vu4_u003b_vf4_u003b((&param_16), (&param_17), (&param_18));
        return _e53;
    }
    let _e55 = (*input).pos;
    param_19 = _e55;
    let _e57 = (*input).positionBoneIndex;
    param_20 = _e57;
    let _e58 = transformPosition_u0028_vf3_u003b_i1_u003b((&param_19), (&param_20));
    return _e58;
}

fn u0040_main_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i1_u002d_vu4_u002d_vf41_u003b(input_1: ptr<function, VSInput>) -> VSOutput {
    var position_4: vec3<f32>;
    var param_21: VSInput;
    var param_22: vec3<f32>;
    var param_23: f32;
    var param_24: f32;
    var output: VSOutput;
    var param_25: vec3<f32>;
    var range: f32;

    let _e46 = (*input_1);
    param_21 = _e46;
    let _e47 = skinnedPosition_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i1_u002d_vu4_u002d_vf41_u003b((&param_21));
    param_22 = _e47;
    let _e48 = shearShadow_u0028_vf3_u003b((&param_22));
    position_4 = _e48;
    let _e50 = position_4[0u];
    param_23 = _e50;
    let _e52 = position_4[1u];
    param_24 = _e52;
    let _e53 = terrainHeight_u0028_f1_u003b_f1_u003b((&param_23), (&param_24));
    position_4[2u] = (_e53 + 5f);
    let _e56 = position_4;
    param_25 = _e56;
    let _e57 = clipPosition_u0028_vf3_u003b((&param_25));
    output.pos = _e57;
    output.uv = vec2<f32>(0f, 0f);
    let _e61 = (*input_1).color;
    output.color = _e61;
    let _e65 = output.pos[3u];
    output.clipDist = (_e65 - 1f);
    let _e70 = unnamed.fogParameters[1u];
    let _e73 = unnamed.fogParameters[0u];
    range = (_e70 - _e73);
    let _e75 = range;
    let _e79 = unnamed.fogParameters[1u];
    let _e82 = output.pos[3u];
    let _e85 = range;
    output.fogFactor = select(1f, clamp(((_e79 - abs(_e82)) / _e85), 0f, 1f), (_e75 > 0.001f));
    let _e90 = output;
    return _e90;
}

fn main_1() {
    var input_2: VSInput;
    var flattenTemp: VSOutput;
    var param_26: VSInput;

    let _e40 = input_u002e_pos_1;
    input_2.pos = _e40;
    let _e42 = input_u002e_color_1;
    input_2.color = _e42;
    let _e44 = input_u002e_positionBoneIndex_1;
    input_2.positionBoneIndex = _e44;
    let _e46 = input_u002e_joints_1;
    input_2.joints = _e46;
    let _e48 = input_u002e_weights_1;
    input_2.weights = _e48;
    let _e50 = input_2;
    param_26 = _e50;
    let _e51 = u0040_main_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i1_u002d_vu4_u002d_vf41_u003b((&param_26));
    flattenTemp = _e51;
    let _e53 = flattenTemp.pos;
    u0040_entryPointOutput_u002e_pos = _e53;
    let _e55 = flattenTemp.uv;
    u0040_entryPointOutput_u002e_uv = _e55;
    let _e57 = flattenTemp.color;
    u0040_entryPointOutput_u002e_color = _e57;
    let _e59 = flattenTemp.fogFactor;
    u0040_entryPointOutput_u002e_fogFactor = _e59;
    let _e61 = flattenTemp.clipDist;
    u0040_entryPointOutput_u002e_clipDist = _e61;
    return;
}

@vertex 
fn main(@location(0) input_u002e_pos: vec3<f32>, @location(3) input_u002e_color: vec4<f32>, @location(4) input_u002e_positionBoneIndex: i32, @location(6) input_u002e_joints: vec4<u32>, @location(7) input_u002e_weights: vec4<f32>) -> VertexOutput {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_color_1 = input_u002e_color;
    input_u002e_positionBoneIndex_1 = input_u002e_positionBoneIndex;
    input_u002e_joints_1 = input_u002e_joints;
    input_u002e_weights_1 = input_u002e_weights;
    main_1();
    let _e15 = u0040_entryPointOutput_u002e_pos;
    let _e16 = u0040_entryPointOutput_u002e_uv;
    let _e17 = u0040_entryPointOutput_u002e_color;
    let _e18 = u0040_entryPointOutput_u002e_fogFactor;
    let _e19 = u0040_entryPointOutput_u002e_clipDist;
    return VertexOutput(_e15, _e16, _e17, _e18, _e19);
}
