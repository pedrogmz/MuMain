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
    eyePositionAndSpecular: vec4<f32>,
    vertexToWorldRows: array<vec4<f32>, 3>,
}

struct boneRows {
    data: array<vec4<f32>>,
}

struct VertexOutput {
    @builtin(position) member: vec4<f32>,
    @location(0) member_1: vec2<f32>,
    @location(1) member_2: vec4<f32>,
    @location(2) member_3: f32,
    @location(3) member_4: f32,
    @location(4) member_5: vec3<f32>,
    @location(5) member_6: vec3<f32>,
    @location(6) @interpolate(flat) member_7: vec4<f32>,
    @location(7) member_8: vec4<f32>,
    @location(8) member_9: vec3<f32>,
    @location(9) member_10: vec4<f32>,
    @location(10) member_11: vec4<f32>,
    @location(15) member_12: f32,
}

@group(1) @binding(0)
var<uniform> unnamed: Skinning;
@group(0) @binding(0)
var<storage> boneRows_1: boneRows;
var<private> inputpos_1: vec3<f32>;
var<private> inputnormal_1: vec3<f32>;
var<private> inputuv_1: vec2<f32>;
var<private> inputcolor_1: vec4<f32>;
var<private> inputpositionBoneIndex_1: i32;
var<private> inputnormalBoneIndex_1: i32;
var<private> entryPointOutputpos: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
var<private> entryPointOutputuv: vec2<f32>;
var<private> entryPointOutputcolor: vec4<f32>;
var<private> entryPointOutputfogFactor: f32;
var<private> entryPointOutputeyeDepth: f32;
var<private> entryPointOutputnormal: vec3<f32>;
var<private> entryPointOutputviewVector: vec3<f32>;
var<private> entryPointOutputlightDirectionAndSpecular: vec4<f32>;
var<private> entryPointOutputworldPositionAndDynamicLights: vec4<f32>;
var<private> entryPointOutputworldNormal: vec3<f32>;
var<private> entryPointOutputtangent: vec4<f32>;
var<private> entryPointOutputworldTangentAndNormalMapScale: vec4<f32>;
var<private> entryPointOutputclipDist: f32;

fn main_1() {
    var local: vec4<f32>;
    var local_1: vec4<f32>;
    var local_2: vec2<f32>;
    var local_3: vec4<f32>;
    var local_4: vec4<f32>;
    var local_5: vec4<f32>;
    var local_6: vec3<f32>;
    var local_7: vec3<f32>;
    var phi_1555_: vec3<f32>;
    var phi_1556_: vec3<f32>;
    var phi_1557_: vec3<f32>;
    var phi_1558_: vec3<f32>;
    var phi_1559_: vec2<f32>;

    let _e67 = inputpos_1;
    let _e68 = inputnormal_1;
    let _e69 = inputuv_1;
    let _e70 = inputcolor_1;
    let _e71 = inputpositionBoneIndex_1;
    let _e72 = inputnormalBoneIndex_1;
    switch bitcast<i32>(0u) {
        default: {
            let _e77 = unnamed.palette[1u];
            if ((_e71 < 0i) || (_e71 >= bitcast<i32>(_e77))) {
                phi_1557_ = _e67;
                break;
            }
            let _e84 = unnamed.palette[0u];
            let _e86 = (_e84 + (bitcast<u32>(_e71) * 3u));
            let _e89 = boneRows_1.data[_e86];
            let _e93 = boneRows_1.data[(_e86 + 1u)];
            let _e97 = boneRows_1.data[(_e86 + 2u)];
            local_3 = _e89;
            local_4 = _e93;
            local_5 = _e97;
            let _e100 = unnamed.boneScaleAndRestPoseScale[0u];
            if (_e100 == 1f) {
                let _e104 = unnamed.boneScaleAndRestPoseScale[1u];
                let _e108 = unnamed.boneScaleAndRestPoseScale[1u];
                let _e110 = (_e67 * select(1f, _e108, (_e104 != 0f)));
                let _e114 = vec4<f32>(_e110.x, _e110.y, _e110.z, 1f);
                phi_1555_ = vec3<f32>(dot(_e89, _e114), dot(_e93, _e114), dot(_e97, _e114));
            } else {
                let _e128 = unnamed.boneScaleAndRestPoseScale[0u];
                let _e131 = local_3[3u];
                let _e133 = local_4[3u];
                let _e135 = local_5[3u];
                phi_1555_ = ((vec3<f32>(dot(_e89.xyz, _e67), dot(_e93.xyz, _e67), dot(_e97.xyz, _e67)) * _e128) + vec3<f32>(_e131, _e133, _e135));
            }
            let _e139 = phi_1555_;
            let _e142 = unnamed.palette[2u];
            phi_1556_ = _e139;
            if (_e142 != 0u) {
                let _e145 = unnamed.bodyOriginAndScale;
                let _e149 = unnamed.bodyOriginAndScale[3u];
                phi_1556_ = (_e145.xyz + (_e139 * _e149));
            }
            let _e153 = phi_1556_;
            phi_1557_ = _e153;
            break;
        }
    }
    let _e155 = phi_1557_;
    switch bitcast<i32>(0u) {
        default: {
            let _e160 = unnamed.palette[1u];
            if ((_e72 < 0i) || (_e72 >= bitcast<i32>(_e160))) {
                phi_1558_ = _e68;
                break;
            }
            let _e167 = unnamed.palette[0u];
            let _e169 = (_e167 + (bitcast<u32>(_e72) * 3u));
            let _e172 = boneRows_1.data[_e169];
            let _e176 = boneRows_1.data[(_e169 + 1u)];
            let _e180 = boneRows_1.data[(_e169 + 2u)];
            phi_1558_ = vec3<f32>(dot(_e172.xyz, _e68), dot(_e176.xyz, _e68), dot(_e180.xyz, _e68));
            break;
        }
    }
    let _e189 = phi_1558_;
    let _e195 = unnamed.mvp;
    let _e197 = (vec4<f32>(_e155.x, _e155.y, _e155.z, 1f) * transpose(_e195));
    local_1 = _e197;
    local_6 = _e189;
    switch bitcast<i32>(0u) {
        default: {
            let _e201 = unnamed.textureCoordinateMode[0u];
            let _e204 = unnamed.chromeParameters[0u];
            let _e207 = unnamed.chromeParameters[1u];
            let _e209 = unnamed.chromeParameters;
            local_2 = _e209.zw;
            let _e212 = unnamed.textureCoordinateParameters;
            let _e213 = _e212.xy;
            if (_e201 == 1u) {
                let _e216 = local_6[2u];
                let _e220 = local_6[1u];
                phi_1559_ = vec2<f32>(((_e216 * 0.5f) + _e204), ((_e220 * 0.5f) + (_e204 * 2f)));
                break;
            }
            if (_e201 == 2u) {
                let _e227 = local_6[2u];
                let _e229 = local_6[0u];
                let _e235 = local_6[1u];
                let _e237 = local_6[0u];
                phi_1559_ = vec2<f32>((((_e227 + _e229) * 0.8f) + (_e207 * 2f)), ((_e235 + _e237) + (_e207 * 3f)));
                break;
            }
            if (_e201 == 3u) {
                let _e243 = dot(_e189, vec3<f32>(0f, -0.1f, -0.8f));
                phi_1559_ = vec2<f32>(_e243, (1f - _e243));
                break;
            }
            if ((_e201 == 4u) || (_e201 == 5u)) {
                let _e252 = dot(_e189, vec3<f32>(_e209.z, _e209.w, 1f));
                let _e262 = local_6[1u];
                let _e266 = local_2[1u];
                let _e271 = local_6[2u];
                phi_1559_ = (vec2<f32>(((_e252 + (_e262 * select(3f, 0.5f, (_e201 == 4u)))) + (_e266 * select(5f, 3f, (_e201 == 4u)))), (((1f - _e252) - (_e271 * select(2.5f, 0.5f, (_e201 == 4u)))) - (_e204 * select(1f, 3f, (_e201 == 4u))))) + _e213);
                break;
            }
            if (_e201 == 6u) {
                let _e280 = local_6[2u];
                let _e282 = local_6[0u];
                phi_1559_ = vec2((((_e280 + _e282) * 0.8f) + (_e207 * 2f)));
                break;
            }
            if (_e201 == 7u) {
                let _e290 = local_6[2u];
                let _e292 = local_6[0u];
                let _e297 = unnamed.textureCoordinateParameters[2u];
                phi_1559_ = vec2((((_e290 + _e292) * 0.8f) + _e297));
                break;
            }
            if (_e201 == 8u) {
                phi_1559_ = ((_e189.xy * _e69) + _e213);
                break;
            }
            if (_e201 == 9u) {
                let _e306 = local_6[2u];
                let _e310 = local_6[1u];
                phi_1559_ = vec2<f32>(((_e306 * 0.5f) + 0.2f), ((_e310 * 0.5f) + 0.5f));
                break;
            }
            phi_1559_ = _e69;
            break;
        }
    }
    let _e315 = phi_1559_;
    local = _e70;
    let _e318 = unnamed.palette[3u];
    if (_e318 == 1u) {
        let _e321 = unnamed.lightDirection;
        let _e326 = max(((dot(_e189, _e321.xyz) * 0.8f) + 0.4f), 0.2f);
        let _e327 = local;
        let _e330 = clamp((_e327.xyz * _e326), vec3<f32>(0f, 0f, 0f), vec3<f32>(1f, 1f, 1f));
        local[0u] = _e330.x;
        local[1u] = _e330.y;
        local[2u] = _e330.z;
        let _e339 = unnamed.lightDirection[3u];
        if ((_e339 > 0f) && (_e339 < 1f)) {
            local_7 = (_e70.xyz * _e326);
            let _e347 = unnamed.lightDirection[3u];
            let _e349 = local_7[0u];
            let _e350 = (1f - _e347);
            let _e362 = local_7[1u];
            let _e363 = (1f - _e347);
            let _e375 = local_7[2u];
            let _e376 = (1f - _e347);
            let _e388 = clamp(vec3<f32>(select(_e349, (_e347 + (_e350 * (1f - exp((-(max((_e349 - _e347), 0f)) / _e350))))), (_e349 > _e347)), select(_e362, (_e347 + (_e363 * (1f - exp((-(max((_e362 - _e347), 0f)) / _e363))))), (_e362 > _e347)), select(_e375, (_e347 + (_e376 * (1f - exp((-(max((_e375 - _e347), 0f)) / _e376))))), (_e375 > _e347))), vec3<f32>(0f, 0f, 0f), vec3<f32>(1f, 1f, 1f));
            local[0u] = _e388.x;
            local[1u] = _e388.y;
            local[2u] = _e388.z;
        }
    }
    let _e396 = local_1[3u];
    let _e400 = unnamed.fogParameters[1u];
    let _e403 = unnamed.fogParameters[0u];
    let _e404 = (_e400 - _e403);
    let _e408 = unnamed.fogParameters[1u];
    let _e410 = local_1[3u];
    let _e417 = local_1[3u];
    let _e420 = unnamed.eyePositionAndSpecular;
    let _e424 = unnamed.lightDirection;
    let _e427 = unnamed.eyePositionAndSpecular[3u];
    let _e435 = vec4<f32>(_e155.x, _e155.y, _e155.z, 1f);
    let _e438 = unnamed.vertexToWorldRows[0i];
    let _e442 = unnamed.vertexToWorldRows[1i];
    let _e446 = unnamed.vertexToWorldRows[2i];
    let _e450 = unnamed.palette[3u];
    let _e456 = unnamed.vertexToWorldRows[0i];
    let _e461 = unnamed.vertexToWorldRows[1i];
    let _e466 = unnamed.vertexToWorldRows[2i];
    let _e470 = local;
    entryPointOutputpos = _e197;
    entryPointOutputuv = _e315;
    entryPointOutputcolor = _e470;
    entryPointOutputfogFactor = select(1f, clamp(((_e408 - abs(_e410)) / _e404), 0f, 1f), (_e404 > 0.001f));
    entryPointOutputeyeDepth = abs(_e417);
    entryPointOutputnormal = _e189;
    entryPointOutputviewVector = (_e420.xyz - _e155);
    entryPointOutputlightDirectionAndSpecular = vec4<f32>(_e424.x, _e424.y, _e424.z, _e427);
    entryPointOutputworldPositionAndDynamicLights = vec4<f32>(dot(_e438, _e435), dot(_e442, _e435), dot(_e446, _e435), select(0f, 1f, (_e450 == 3u)));
    entryPointOutputworldNormal = vec3<f32>(dot(_e456.xyz, _e189), dot(_e461.xyz, _e189), dot(_e466.xyz, _e189));
    entryPointOutputtangent = vec4<f32>(0f, 0f, 0f, 0f);
    entryPointOutputworldTangentAndNormalMapScale = vec4<f32>(0f, 0f, 0f, 0f);
    entryPointOutputclipDist = (_e396 - 1f);
    return;
}

@vertex
fn main(@location(0) inputpos: vec3<f32>, @location(1) inputnormal: vec3<f32>, @location(2) inputuv: vec2<f32>, @location(3) inputcolor: vec4<f32>, @location(4) inputpositionBoneIndex: i32, @location(5) inputnormalBoneIndex: i32) -> VertexOutput {
    inputpos_1 = inputpos;
    inputnormal_1 = inputnormal;
    inputuv_1 = inputuv;
    inputcolor_1 = inputcolor;
    inputpositionBoneIndex_1 = inputpositionBoneIndex;
    inputnormalBoneIndex_1 = inputnormalBoneIndex;
    main_1();
    let _e25 = entryPointOutputpos;
    let _e26 = entryPointOutputuv;
    let _e27 = entryPointOutputcolor;
    let _e28 = entryPointOutputfogFactor;
    let _e29 = entryPointOutputeyeDepth;
    let _e30 = entryPointOutputnormal;
    let _e31 = entryPointOutputviewVector;
    let _e32 = entryPointOutputlightDirectionAndSpecular;
    let _e33 = entryPointOutputworldPositionAndDynamicLights;
    let _e34 = entryPointOutputworldNormal;
    let _e35 = entryPointOutputtangent;
    let _e36 = entryPointOutputworldTangentAndNormalMapScale;
    let _e37 = entryPointOutputclipDist;
    return VertexOutput(_e25, _e26, _e27, _e28, _e29, _e30, _e31, _e32, _e33, _e34, _e35, _e36, _e37);
}
