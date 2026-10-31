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
var<private> inputjoints_1: vec4<u32>;
var<private> inputweights_1: vec4<f32>;
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
    var phi_1192_: vec3<f32>;
    var phi_1233_: vec3<f32>;
    var phi_1275_: vec3<f32>;
    var phi_1317_: vec3<f32>;
    var phi_1188_: vec3<f32>;
    var phi_1183_: vec3<f32>;
    var phi_1184_: vec3<f32>;
    var phi_1185_: vec3<f32>;
    var phi_1189_: vec3<f32>;
    var phi_1190_: f32;

    let _e41 = inputpos_1;
    let _e42 = inputcolor_1;
    let _e43 = inputpositionBoneIndex_1;
    switch bitcast<i32>(0u) {
        default: {
            let _e46 = inputweights_1[0u];
            if (_e46 > 0f) {
                let _e51 = vec4<f32>(_e41.x, _e41.y, _e41.z, 1f);
                let _e53 = inputweights_1[0u];
                let _e56 = inputjoints_1[0u];
                let _e59 = unnamed.palette[1u];
                phi_1192_ = vec3<f32>(0f, 0f, 0f);
                if ((_e53 > 0f) && (_e56 < _e59)) {
                    let _e64 = unnamed.palette[0u];
                    let _e66 = inputjoints_1[0u];
                    let _e68 = (_e64 + (_e66 * 3u));
                    let _e70 = inputweights_1[0u];
                    let _e73 = boneRows_1.data[_e68];
                    let _e78 = boneRows_1.data[(_e68 + 1u)];
                    let _e83 = boneRows_1.data[(_e68 + 2u)];
                    phi_1192_ = (vec3<f32>(dot(_e73, _e51), dot(_e78, _e51), dot(_e83, _e51)) * _e70);
                }
                let _e88 = phi_1192_;
                let _e90 = inputweights_1[1u];
                let _e93 = inputjoints_1[1u];
                let _e96 = unnamed.palette[1u];
                phi_1233_ = _e88;
                if ((_e90 > 0f) && (_e93 < _e96)) {
                    let _e101 = unnamed.palette[0u];
                    let _e103 = inputjoints_1[1u];
                    let _e105 = (_e101 + (_e103 * 3u));
                    let _e107 = inputweights_1[1u];
                    let _e110 = boneRows_1.data[_e105];
                    let _e115 = boneRows_1.data[(_e105 + 1u)];
                    let _e120 = boneRows_1.data[(_e105 + 2u)];
                    phi_1233_ = (_e88 + (vec3<f32>(dot(_e110, _e51), dot(_e115, _e51), dot(_e120, _e51)) * _e107));
                }
                let _e126 = phi_1233_;
                let _e128 = inputweights_1[2u];
                let _e131 = inputjoints_1[2u];
                let _e134 = unnamed.palette[1u];
                phi_1275_ = _e126;
                if ((_e128 > 0f) && (_e131 < _e134)) {
                    let _e139 = unnamed.palette[0u];
                    let _e141 = inputjoints_1[2u];
                    let _e143 = (_e139 + (_e141 * 3u));
                    let _e145 = inputweights_1[2u];
                    let _e148 = boneRows_1.data[_e143];
                    let _e153 = boneRows_1.data[(_e143 + 1u)];
                    let _e158 = boneRows_1.data[(_e143 + 2u)];
                    phi_1275_ = (_e126 + (vec3<f32>(dot(_e148, _e51), dot(_e153, _e51), dot(_e158, _e51)) * _e145));
                }
                let _e164 = phi_1275_;
                let _e166 = inputweights_1[3u];
                let _e169 = inputjoints_1[3u];
                let _e172 = unnamed.palette[1u];
                phi_1317_ = _e164;
                if ((_e166 > 0f) && (_e169 < _e172)) {
                    let _e177 = unnamed.palette[0u];
                    let _e179 = inputjoints_1[3u];
                    let _e181 = (_e177 + (_e179 * 3u));
                    let _e183 = inputweights_1[3u];
                    let _e186 = boneRows_1.data[_e181];
                    let _e191 = boneRows_1.data[(_e181 + 1u)];
                    let _e196 = boneRows_1.data[(_e181 + 2u)];
                    phi_1317_ = (_e164 + (vec3<f32>(dot(_e186, _e51), dot(_e191, _e51), dot(_e196, _e51)) * _e183));
                }
                let _e202 = phi_1317_;
                let _e205 = unnamed.palette[2u];
                phi_1188_ = _e202;
                if (_e205 != 0u) {
                    let _e208 = unnamed.bodyOriginAndScale;
                    let _e212 = unnamed.bodyOriginAndScale[3u];
                    phi_1188_ = (_e208.xyz + (_e202 * _e212));
                }
                let _e216 = phi_1188_;
                phi_1189_ = _e216;
                break;
            }
            switch bitcast<i32>(0u) {
                default: {
                    let _e221 = unnamed.palette[1u];
                    if ((_e43 < 0i) || (_e43 >= bitcast<i32>(_e221))) {
                        phi_1185_ = _e41;
                        break;
                    }
                    let _e227 = unnamed.palette[0u];
                    let _e230 = (_e227 + (bitcast<u32>(_e43) * 3u));
                    let _e233 = boneRows_1.data[_e230];
                    local_2 = _e233;
                    let _e237 = boneRows_1.data[(_e230 + 1u)];
                    local_3 = _e237;
                    let _e241 = boneRows_1.data[(_e230 + 2u)];
                    local_4 = _e241;
                    let _e244 = unnamed.boneScaleAndRestPoseScale[0u];
                    if (_e244 == 1f) {
                        let _e248 = unnamed.boneScaleAndRestPoseScale[1u];
                        let _e252 = unnamed.boneScaleAndRestPoseScale[1u];
                        let _e254 = (_e41 * select(1f, _e252, (_e248 != 0f)));
                        let _e258 = vec4<f32>(_e254.x, _e254.y, _e254.z, 1f);
                        phi_1183_ = vec3<f32>(dot(_e233, _e258), dot(_e237, _e258), dot(_e241, _e258));
                    } else {
                        let _e272 = unnamed.boneScaleAndRestPoseScale[0u];
                        let _e275 = local_2[3u];
                        let _e277 = local_3[3u];
                        let _e279 = local_4[3u];
                        phi_1183_ = ((vec3<f32>(dot(_e233.xyz, _e41), dot(_e237.xyz, _e41), dot(_e241.xyz, _e41)) * _e272) + vec3<f32>(_e275, _e277, _e279));
                    }
                    let _e283 = phi_1183_;
                    let _e286 = unnamed.palette[2u];
                    phi_1184_ = _e283;
                    if (_e286 != 0u) {
                        let _e289 = unnamed.bodyOriginAndScale;
                        let _e293 = unnamed.bodyOriginAndScale[3u];
                        phi_1184_ = (_e289.xyz + (_e283 * _e293));
                    }
                    let _e297 = phi_1184_;
                    phi_1185_ = _e297;
                    break;
                }
            }
            let _e299 = phi_1185_;
            phi_1189_ = _e299;
            break;
        }
    }
    let _e301 = phi_1189_;
    let _e303 = unnamed_1.shadowOrigin;
    local_1 = (_e301 - _e303.xyz);
    let _e307 = local_1[2u];
    let _e309 = local_1[0u];
    let _e312 = unnamed_1.shadowProjection[0u];
    let _e316 = local_1[2u];
    let _e319 = unnamed_1.shadowProjection[1u];
    let _e323 = local_1[0u];
    local_1[0u] = (_e323 + ((_e307 * (_e309 + _e312)) / (_e316 - _e319)));
    let _e326 = local_1;
    let _e328 = unnamed_1.shadowOrigin;
    local_5 = (_e326 + _e328.xyz);
    let _e332 = local_5[0u];
    let _e334 = local_5[1u];
    switch bitcast<i32>(0u) {
        default: {
            let _e338 = unnamed_1.shadowProjection[2u];
            if (((_e338 == 0f) || (_e332 < 0f)) || (_e334 < 0f)) {
                phi_1190_ = 0f;
                break;
            }
            let _e344 = (_e332 * 0.01f);
            let _e345 = (_e334 * 0.01f);
            let _e346 = i32(_e344);
            let _e347 = i32(_e345);
            let _e350 = bitcast<u32>(((_e347 * 256i) + _e346));
            let _e357 = terrainWords_1.data[(65536u + (_e350 >> bitcast<u32>(5i)))];
            if ((_e350 >= 65536u) || (((_e357 >> bitcast<u32>((_e350 & 31u))) & 1u) != 0u)) {
                let _e366 = unnamed_1.shadowOrigin[3u];
                phi_1190_ = _e366;
                break;
            }
            let _e370 = (_e345 - f32(_e347));
            let _e379 = terrainWords_1.data[((bitcast<u32>((_e347 & 255i)) * 256u) + bitcast<u32>((_e346 & 255i)))];
            let _e380 = bitcast<f32>(_e379);
            let _e390 = terrainWords_1.data[((bitcast<u32>(((_e347 + 1i) & 255i)) * 256u) + bitcast<u32>((_e346 & 255i)))];
            let _e401 = terrainWords_1.data[((bitcast<u32>((_e347 & 255i)) * 256u) + bitcast<u32>(((_e346 + 1i) & 255i)))];
            let _e402 = bitcast<f32>(_e401);
            let _e413 = terrainWords_1.data[((bitcast<u32>(((_e347 + 1i) & 255i)) * 256u) + bitcast<u32>(((_e346 + 1i) & 255i)))];
            let _e417 = (_e380 + ((bitcast<f32>(_e390) - _e380) * _e370));
            phi_1190_ = (_e417 + (((_e402 + ((bitcast<f32>(_e413) - _e402) * _e370)) - _e417) * (_e344 - f32(_e346))));
            break;
        }
    }
    let _e425 = phi_1190_;
    local_5[2u] = (_e425 + 5f);
    let _e428 = local_5;
    let _e434 = unnamed.mvp;
    let _e436 = (vec4<f32>(_e428.x, _e428.y, _e428.z, 1f) * transpose(_e434));
    local = _e436;
    let _e438 = local[3u];
    let _e442 = unnamed.fogParameters[1u];
    let _e445 = unnamed.fogParameters[0u];
    let _e446 = (_e442 - _e445);
    let _e450 = unnamed.fogParameters[1u];
    let _e452 = local[3u];
    entryPointOutputpos = _e436;
    entryPointOutputuv = vec2<f32>(0f, 0f);
    entryPointOutputcolor = _e42;
    entryPointOutputfogFactor = select(1f, clamp(((_e450 - abs(_e452)) / _e446), 0f, 1f), (_e446 > 0.001f));
    entryPointOutputclipDist = (_e438 - 1f);
    return;
}

@vertex
fn main(@location(0) inputpos: vec3<f32>, @location(3) inputcolor: vec4<f32>, @location(4) inputpositionBoneIndex: i32, @location(6) inputjoints: vec4<u32>, @location(7) inputweights: vec4<f32>) -> VertexOutput {
    inputpos_1 = inputpos;
    inputcolor_1 = inputcolor;
    inputpositionBoneIndex_1 = inputpositionBoneIndex;
    inputjoints_1 = inputjoints;
    inputweights_1 = inputweights;
    main_1();
    let _e15 = entryPointOutputpos;
    let _e16 = entryPointOutputuv;
    let _e17 = entryPointOutputcolor;
    let _e18 = entryPointOutputfogFactor;
    let _e19 = entryPointOutputclipDist;
    return VertexOutput(_e15, _e16, _e17, _e18, _e19);
}
