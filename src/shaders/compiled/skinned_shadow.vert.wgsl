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
    data: array<vec4<f32>>,
}

struct terrainWords {
    data: array<u32>,
}

struct VertexOutput {
    @builtin(position) member: vec4<f32>,
    @location(0) member_1: vec2<f32>,
    @location(1) member_2: vec4<f32>,
    @location(2) member_3: f32,
    @location(15) member_4: f32,
}

@group(1) @binding(0)
var<uniform> unnamed: Skinning;
@group(1) @binding(1)
var<uniform> unnamed_1: Shadow;
@group(0) @binding(0)
var<storage> boneRows_1: boneRows;
@group(0) @binding(1)
var<storage> terrainWords_1: terrainWords;
var<private> inputpos_1: vec3<f32>;
var<private> inputcolor_1: vec4<f32>;
var<private> inputpositionBoneIndex_1: i32;
var<private> entryPointOutputpos: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
var<private> entryPointOutputuv: vec2<f32>;
var<private> entryPointOutputcolor: vec4<f32>;
var<private> entryPointOutputfogFactor: f32;
var<private> entryPointOutputclipDist: f32;

fn main_1() {
    var local: vec4<f32>;
    var local_1: vec3<f32>;
    var local_2: vec4<f32>;
    var local_3: vec4<f32>;
    var local_4: vec4<f32>;
    var local_5: vec3<f32>;
    var phi_945_: vec3<f32>;
    var phi_946_: vec3<f32>;
    var phi_947_: vec3<f32>;
    var phi_948_: f32;

    let _e38 = inputpos_1;
    let _e39 = inputcolor_1;
    let _e40 = inputpositionBoneIndex_1;
    switch bitcast<i32>(0u) {
        default: {
            let _e45 = unnamed.palette[1u];
            if ((_e40 < 0i) || (_e40 >= bitcast<i32>(_e45))) {
                phi_947_ = _e38;
                break;
            }
            let _e51 = unnamed.palette[0u];
            let _e54 = (_e51 + (bitcast<u32>(_e40) * 3u));
            let _e57 = boneRows_1.data[_e54];
            local_2 = _e57;
            let _e61 = boneRows_1.data[(_e54 + 1u)];
            local_3 = _e61;
            let _e65 = boneRows_1.data[(_e54 + 2u)];
            local_4 = _e65;
            let _e68 = unnamed.boneScaleAndRestPoseScale[0u];
            if (_e68 == 1f) {
                let _e72 = unnamed.boneScaleAndRestPoseScale[1u];
                let _e76 = unnamed.boneScaleAndRestPoseScale[1u];
                let _e78 = (_e38 * select(1f, _e76, (_e72 != 0f)));
                let _e82 = vec4<f32>(_e78.x, _e78.y, _e78.z, 1f);
                phi_945_ = vec3<f32>(dot(_e57, _e82), dot(_e61, _e82), dot(_e65, _e82));
            } else {
                let _e96 = unnamed.boneScaleAndRestPoseScale[0u];
                let _e99 = local_2[3u];
                let _e101 = local_3[3u];
                let _e103 = local_4[3u];
                phi_945_ = ((vec3<f32>(dot(_e57.xyz, _e38), dot(_e61.xyz, _e38), dot(_e65.xyz, _e38)) * _e96) + vec3<f32>(_e99, _e101, _e103));
            }
            let _e107 = phi_945_;
            let _e110 = unnamed.palette[2u];
            phi_946_ = _e107;
            if (_e110 != 0u) {
                let _e113 = unnamed.bodyOriginAndScale;
                let _e117 = unnamed.bodyOriginAndScale[3u];
                phi_946_ = (_e113.xyz + (_e107 * _e117));
            }
            let _e121 = phi_946_;
            phi_947_ = _e121;
            break;
        }
    }
    let _e123 = phi_947_;
    let _e125 = unnamed_1.shadowOrigin;
    local_1 = (_e123 - _e125.xyz);
    let _e129 = local_1[2u];
    let _e131 = local_1[0u];
    let _e134 = unnamed_1.shadowProjection[0u];
    let _e138 = local_1[2u];
    let _e141 = unnamed_1.shadowProjection[1u];
    let _e145 = local_1[0u];
    local_1[0u] = (_e145 + ((_e129 * (_e131 + _e134)) / (_e138 - _e141)));
    let _e148 = local_1;
    let _e150 = unnamed_1.shadowOrigin;
    local_5 = (_e148 + _e150.xyz);
    let _e154 = local_5[0u];
    let _e156 = local_5[1u];
    switch bitcast<i32>(0u) {
        default: {
            let _e160 = unnamed_1.shadowProjection[2u];
            if (((_e160 == 0f) || (_e154 < 0f)) || (_e156 < 0f)) {
                phi_948_ = 0f;
                break;
            }
            let _e166 = (_e154 * 0.01f);
            let _e167 = (_e156 * 0.01f);
            let _e168 = i32(_e166);
            let _e169 = i32(_e167);
            let _e172 = bitcast<u32>(((_e169 * 256i) + _e168));
            let _e179 = terrainWords_1.data[(65536u + (_e172 >> bitcast<u32>(5i)))];
            if ((_e172 >= 65536u) || (((_e179 >> bitcast<u32>((_e172 & 31u))) & 1u) != 0u)) {
                let _e188 = unnamed_1.shadowOrigin[3u];
                phi_948_ = _e188;
                break;
            }
            let _e192 = (_e167 - f32(_e169));
            let _e201 = terrainWords_1.data[((bitcast<u32>((_e169 & 255i)) * 256u) + bitcast<u32>((_e168 & 255i)))];
            let _e202 = bitcast<f32>(_e201);
            let _e212 = terrainWords_1.data[((bitcast<u32>(((_e169 + 1i) & 255i)) * 256u) + bitcast<u32>((_e168 & 255i)))];
            let _e223 = terrainWords_1.data[((bitcast<u32>((_e169 & 255i)) * 256u) + bitcast<u32>(((_e168 + 1i) & 255i)))];
            let _e224 = bitcast<f32>(_e223);
            let _e235 = terrainWords_1.data[((bitcast<u32>(((_e169 + 1i) & 255i)) * 256u) + bitcast<u32>(((_e168 + 1i) & 255i)))];
            let _e239 = (_e202 + ((bitcast<f32>(_e212) - _e202) * _e192));
            phi_948_ = (_e239 + (((_e224 + ((bitcast<f32>(_e235) - _e224) * _e192)) - _e239) * (_e166 - f32(_e168))));
            break;
        }
    }
    let _e247 = phi_948_;
    local_5[2u] = (_e247 + 5f);
    let _e250 = local_5;
    let _e256 = unnamed.mvp;
    let _e258 = (vec4<f32>(_e250.x, _e250.y, _e250.z, 1f) * transpose(_e256));
    local = _e258;
    let _e260 = local[3u];
    let _e264 = unnamed.fogParameters[1u];
    let _e267 = unnamed.fogParameters[0u];
    let _e268 = (_e264 - _e267);
    let _e272 = unnamed.fogParameters[1u];
    let _e274 = local[3u];
    entryPointOutputpos = _e258;
    entryPointOutputuv = vec2<f32>(0f, 0f);
    entryPointOutputcolor = _e39;
    entryPointOutputfogFactor = select(1f, clamp(((_e272 - abs(_e274)) / _e268), 0f, 1f), (_e268 > 0.001f));
    entryPointOutputclipDist = (_e260 - 1f);
    return;
}

@vertex
fn main(@location(0) inputpos: vec3<f32>, @location(3) inputcolor: vec4<f32>, @location(4) inputpositionBoneIndex: i32) -> VertexOutput {
    inputpos_1 = inputpos;
    inputcolor_1 = inputcolor;
    inputpositionBoneIndex_1 = inputpositionBoneIndex;
    main_1();
    let _e11 = entryPointOutputpos;
    let _e12 = entryPointOutputuv;
    let _e13 = entryPointOutputcolor;
    let _e14 = entryPointOutputfogFactor;
    let _e15 = entryPointOutputclipDist;
    return VertexOutput(_e11, _e12, _e13, _e14, _e15);
}
