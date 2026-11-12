struct VSInput {
    pos: vec3<f32>,
    color: vec4<f32>,
    positionBoneIndex: i32,
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
var<private> u0040_entryPointOutput_u002e_pos: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
var<private> u0040_entryPointOutput_u002e_uv: vec2<f32>;
var<private> u0040_entryPointOutput_u002e_color: vec4<f32>;
var<private> u0040_entryPointOutput_u002e_fogFactor: f32;
var<private> u0040_entryPointOutput_u002e_clipDist: f32;

fn clipPosition_u0028_vf3_u003b(position: ptr<function, vec3<f32>>) -> vec4<f32> {
    let _e34 = (*position);
    let _e40 = unnamed.mvp;
    return (vec4<f32>(_e34.x, _e34.y, _e34.z, 1f) * transpose(_e40));
}

fn loadTerrainWord_u0028_u1_u003b(word: ptr<function, u32>) -> u32 {
    let _e34 = (*word);
    let _e37 = terrainWords_1.u0040_data[_e34];
    return _e37;
}

fn terrainCornerHeight_u0028_i1_u003b_i1_u003b(x: ptr<function, i32>, y: ptr<function, i32>) -> f32 {
    var param: u32;

    let _e36 = (*y);
    let _e40 = (*x);
    param = ((bitcast<u32>((_e36 & 255i)) * 256u) + bitcast<u32>((_e40 & 255i)));
    let _e44 = loadTerrainWord_u0028_u1_u003b((&param));
    return bitcast<f32>(_e44);
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

    let _e57 = unnamed_1.shadowProjection[2u];
    let _e59 = (*x_1);
    let _e62 = (*y_1);
    if (((_e57 == 0f) || (_e59 < 0f)) || (_e62 < 0f)) {
        return 0f;
    }
    let _e65 = (*x_1);
    (*x_1) = (_e65 / 100f);
    let _e67 = (*y_1);
    (*y_1) = (_e67 / 100f);
    let _e69 = (*x_1);
    xi = i32(_e69);
    let _e71 = (*y_1);
    yi = i32(_e71);
    let _e73 = yi;
    let _e75 = xi;
    index = bitcast<u32>(((_e73 * 256i) + _e75));
    let _e78 = index;
    let _e80 = index;
    param_1 = (65536u + (_e80 >> bitcast<u32>(5i)));
    let _e84 = loadTerrainWord_u0028_u1_u003b((&param_1));
    let _e85 = index;
    if ((_e78 >= 65536u) || (((_e84 >> bitcast<u32>((_e85 & 31u))) & 1u) != 0u)) {
        let _e94 = unnamed_1.shadowOrigin[3u];
        return _e94;
    }
    let _e95 = (*x_1);
    let _e96 = xi;
    xd = (_e95 - f32(_e96));
    let _e99 = (*y_1);
    let _e100 = yi;
    yd = (_e99 - f32(_e100));
    let _e103 = xi;
    param_2 = _e103;
    let _e104 = yi;
    param_3 = _e104;
    let _e105 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_2), (&param_3));
    h1_ = _e105;
    let _e106 = yi;
    let _e108 = xi;
    param_4 = _e108;
    param_5 = (_e106 + 1i);
    let _e109 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_4), (&param_5));
    h2_ = _e109;
    let _e110 = xi;
    param_6 = (_e110 + 1i);
    let _e112 = yi;
    param_7 = _e112;
    let _e113 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_6), (&param_7));
    h3_ = _e113;
    let _e114 = xi;
    let _e116 = yi;
    param_8 = (_e114 + 1i);
    param_9 = (_e116 + 1i);
    let _e118 = terrainCornerHeight_u0028_i1_u003b_i1_u003b((&param_8), (&param_9));
    h4_ = _e118;
    let _e119 = h1_;
    let _e120 = h2_;
    let _e121 = h1_;
    let _e123 = yd;
    left = (_e119 + ((_e120 - _e121) * _e123));
    let _e126 = h3_;
    let _e127 = h4_;
    let _e128 = h3_;
    let _e130 = yd;
    right = (_e126 + ((_e127 - _e128) * _e130));
    let _e133 = left;
    let _e134 = right;
    let _e135 = left;
    let _e137 = xd;
    return (_e133 + ((_e134 - _e135) * _e137));
}

fn shearShadow_u0028_vf3_u003b(position_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var relative: vec3<f32>;
    var axis: vec2<f32>;
    var along: f32;

    let _e37 = (*position_1);
    let _e39 = unnamed_1.shadowOrigin;
    relative = (_e37 - _e39.xyz);
    let _e44 = unnamed_1.shadowProjection[3u];
    let _e48 = unnamed_1.shadowProjection[3u];
    axis = vec2<f32>(cos(_e44), sin(_e48));
    let _e51 = relative;
    let _e53 = axis;
    along = dot(_e51.xy, _e53);
    let _e55 = axis;
    let _e57 = relative[2u];
    let _e58 = along;
    let _e61 = unnamed_1.shadowProjection[0u];
    let _e65 = relative[2u];
    let _e68 = unnamed_1.shadowProjection[1u];
    let _e72 = relative;
    let _e74 = (_e72.xy + (_e55 * ((_e57 * (_e58 + _e61)) / (_e65 - _e68))));
    relative[0u] = _e74.x;
    relative[1u] = _e74.y;
    let _e79 = relative;
    let _e81 = unnamed_1.shadowOrigin;
    return (_e79 + _e81.xyz);
}

fn loadBoneRow_u0028_u1_u003b(row: ptr<function, u32>) -> vec4<f32> {
    let _e34 = (*row);
    let _e37 = boneRows_1.u0040_data[_e34];
    return _e37;
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

    let _e45 = (*boneIndex);
    let _e47 = (*boneIndex);
    let _e50 = unnamed.palette[1u];
    if ((_e45 < 0i) || (_e47 >= bitcast<i32>(_e50))) {
        let _e54 = (*position_2);
        return _e54;
    }
    let _e57 = unnamed.palette[0u];
    let _e58 = (*boneIndex);
    row_1 = (_e57 + (bitcast<u32>(_e58) * 3u));
    let _e62 = row_1;
    param_10 = _e62;
    let _e63 = loadBoneRow_u0028_u1_u003b((&param_10));
    row0_ = _e63;
    let _e64 = row_1;
    param_11 = (_e64 + 1u);
    let _e66 = loadBoneRow_u0028_u1_u003b((&param_11));
    row1_ = _e66;
    let _e67 = row_1;
    param_12 = (_e67 + 2u);
    let _e69 = loadBoneRow_u0028_u1_u003b((&param_12));
    row2_ = _e69;
    let _e72 = unnamed.boneScaleAndRestPoseScale[0u];
    if (_e72 == 1f) {
        let _e76 = unnamed.boneScaleAndRestPoseScale[1u];
        let _e80 = unnamed.boneScaleAndRestPoseScale[1u];
        restScale = select(1f, _e80, (_e76 != 0f));
        let _e82 = (*position_2);
        let _e83 = restScale;
        let _e84 = (_e82 * _e83);
        restPosition = vec4<f32>(_e84.x, _e84.y, _e84.z, 1f);
        let _e89 = row0_;
        let _e90 = restPosition;
        let _e92 = row1_;
        let _e93 = restPosition;
        let _e95 = row2_;
        let _e96 = restPosition;
        transformed = vec3<f32>(dot(_e89, _e90), dot(_e92, _e93), dot(_e95, _e96));
    } else {
        let _e99 = row0_;
        let _e101 = (*position_2);
        let _e103 = row1_;
        let _e105 = (*position_2);
        let _e107 = row2_;
        let _e109 = (*position_2);
        transformed = vec3<f32>(dot(_e99.xyz, _e101), dot(_e103.xyz, _e105), dot(_e107.xyz, _e109));
        let _e112 = transformed;
        let _e115 = unnamed.boneScaleAndRestPoseScale[0u];
        let _e118 = row0_[3u];
        let _e120 = row1_[3u];
        let _e122 = row2_[3u];
        transformed = ((_e112 * _e115) + vec3<f32>(_e118, _e120, _e122));
    }
    let _e127 = unnamed.palette[2u];
    if (_e127 != 0u) {
        let _e130 = unnamed.bodyOriginAndScale;
        let _e132 = transformed;
        let _e135 = unnamed.bodyOriginAndScale[3u];
        transformed = (_e130.xyz + (_e132 * _e135));
    }
    let _e138 = transformed;
    return _e138;
}

fn skinnedPosition_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i11_u003b(input: ptr<function, VSInput>) -> vec3<f32> {
    var param_13: vec3<f32>;
    var param_14: i32;

    let _e37 = (*input).pos;
    param_13 = _e37;
    let _e39 = (*input).positionBoneIndex;
    param_14 = _e39;
    let _e40 = transformPosition_u0028_vf3_u003b_i1_u003b((&param_13), (&param_14));
    return _e40;
}

fn u0040_main_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i11_u003b(input_1: ptr<function, VSInput>) -> VSOutput {
    var position_3: vec3<f32>;
    var param_15: VSInput;
    var param_16: vec3<f32>;
    var param_17: f32;
    var param_18: f32;
    var output: VSOutput;
    var param_19: vec3<f32>;
    var range: f32;

    let _e42 = (*input_1);
    param_15 = _e42;
    let _e43 = skinnedPosition_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i11_u003b((&param_15));
    param_16 = _e43;
    let _e44 = shearShadow_u0028_vf3_u003b((&param_16));
    position_3 = _e44;
    let _e46 = position_3[0u];
    param_17 = _e46;
    let _e48 = position_3[1u];
    param_18 = _e48;
    let _e49 = terrainHeight_u0028_f1_u003b_f1_u003b((&param_17), (&param_18));
    position_3[2u] = (_e49 + 5f);
    let _e52 = position_3;
    param_19 = _e52;
    let _e53 = clipPosition_u0028_vf3_u003b((&param_19));
    output.pos = _e53;
    output.uv = vec2<f32>(0f, 0f);
    let _e57 = (*input_1).color;
    output.color = _e57;
    let _e61 = output.pos[3u];
    output.clipDist = (_e61 - 1f);
    let _e66 = unnamed.fogParameters[1u];
    let _e69 = unnamed.fogParameters[0u];
    range = (_e66 - _e69);
    let _e71 = range;
    let _e75 = unnamed.fogParameters[1u];
    let _e78 = output.pos[3u];
    let _e81 = range;
    output.fogFactor = select(1f, clamp(((_e75 - abs(_e78)) / _e81), 0f, 1f), (_e71 > 0.001f));
    let _e86 = output;
    return _e86;
}

fn main_1() {
    var input_2: VSInput;
    var flattenTemp: VSOutput;
    var param_20: VSInput;

    let _e36 = input_u002e_pos_1;
    input_2.pos = _e36;
    let _e38 = input_u002e_color_1;
    input_2.color = _e38;
    let _e40 = input_u002e_positionBoneIndex_1;
    input_2.positionBoneIndex = _e40;
    let _e42 = input_2;
    param_20 = _e42;
    let _e43 = u0040_main_u0028_struct_u002d_VSInput_u002d_vf3_u002d_vf4_u002d_i11_u003b((&param_20));
    flattenTemp = _e43;
    let _e45 = flattenTemp.pos;
    u0040_entryPointOutput_u002e_pos = _e45;
    let _e47 = flattenTemp.uv;
    u0040_entryPointOutput_u002e_uv = _e47;
    let _e49 = flattenTemp.color;
    u0040_entryPointOutput_u002e_color = _e49;
    let _e51 = flattenTemp.fogFactor;
    u0040_entryPointOutput_u002e_fogFactor = _e51;
    let _e53 = flattenTemp.clipDist;
    u0040_entryPointOutput_u002e_clipDist = _e53;
    return;
}

@vertex 
fn main(@location(0) input_u002e_pos: vec3<f32>, @location(3) input_u002e_color: vec4<f32>, @location(4) input_u002e_positionBoneIndex: i32) -> VertexOutput {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_color_1 = input_u002e_color;
    input_u002e_positionBoneIndex_1 = input_u002e_positionBoneIndex;
    main_1();
    let _e11 = u0040_entryPointOutput_u002e_pos;
    let _e12 = u0040_entryPointOutput_u002e_uv;
    let _e13 = u0040_entryPointOutput_u002e_color;
    let _e14 = u0040_entryPointOutput_u002e_fogFactor;
    let _e15 = u0040_entryPointOutput_u002e_clipDist;
    return VertexOutput(_e11, _e12, _e13, _e14, _e15);
}
