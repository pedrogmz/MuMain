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
var<private> inputjoints_1: vec4<u32>;
var<private> inputweights_1: vec4<f32>;
var<private> inputtangent_1: vec4<f32>;
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
    var phi_2256_: vec3<f32>;
    var phi_2571_: vec3<f32>;
    var phi_2613_: vec3<f32>;
    var phi_2655_: vec3<f32>;
    var phi_2233_: vec3<f32>;
    var phi_2257_: vec3<f32>;
    var phi_2439_: vec3<f32>;
    var phi_2484_: vec3<f32>;
    var phi_2529_: vec3<f32>;
    var phi_2236_: vec3<f32>;
    var phi_2227_: vec3<f32>;
    var phi_2228_: vec3<f32>;
    var phi_2229_: vec3<f32>;
    var phi_2230_: vec3<f32>;
    var phi_2241_: vec3<f32>;
    var phi_2237_: vec3<f32>;
    var phi_2242_: vec2<f32>;
    var phi_2259_: vec3<f32>;
    var phi_2304_: vec3<f32>;
    var phi_2349_: vec3<f32>;
    var phi_2394_: vec3<f32>;
    var phi_2251_: vec3<f32>;
    var phi_2252_: vec3<f32>;

    let _e70 = inputpos_1;
    let _e71 = inputnormal_1;
    let _e72 = inputuv_1;
    let _e73 = inputcolor_1;
    let _e74 = inputpositionBoneIndex_1;
    let _e75 = inputnormalBoneIndex_1;
    let _e76 = inputtangent_1;
    let _e78 = inputweights_1[0u];
    if (_e78 > 0f) {
        let _e83 = vec4<f32>(_e70.x, _e70.y, _e70.z, 1f);
        let _e85 = inputweights_1[0u];
        let _e88 = inputjoints_1[0u];
        let _e91 = unnamed.palette[1u];
        phi_2256_ = vec3<f32>(0f, 0f, 0f);
        if ((_e85 > 0f) && (_e88 < _e91)) {
            let _e95 = inputjoints_1[0u];
            let _e98 = unnamed.palette[0u];
            let _e100 = (_e98 + (_e95 * 3u));
            let _e103 = boneRows_1.data[_e100];
            let _e107 = boneRows_1.data[(_e100 + 1u)];
            let _e111 = boneRows_1.data[(_e100 + 2u)];
            let _e113 = inputweights_1[0u];
            phi_2256_ = (vec3<f32>(dot(_e103, _e83), dot(_e107, _e83), dot(_e111, _e83)) * _e113);
        }
        let _e120 = phi_2256_;
        let _e122 = inputweights_1[1u];
        let _e125 = inputjoints_1[1u];
        let _e128 = unnamed.palette[1u];
        phi_2571_ = _e120;
        if ((_e122 > 0f) && (_e125 < _e128)) {
            let _e132 = inputjoints_1[1u];
            let _e135 = unnamed.palette[0u];
            let _e137 = (_e135 + (_e132 * 3u));
            let _e140 = boneRows_1.data[_e137];
            let _e144 = boneRows_1.data[(_e137 + 1u)];
            let _e148 = boneRows_1.data[(_e137 + 2u)];
            let _e150 = inputweights_1[1u];
            phi_2571_ = (_e120 + (vec3<f32>(dot(_e140, _e83), dot(_e144, _e83), dot(_e148, _e83)) * _e150));
        }
        let _e158 = phi_2571_;
        let _e160 = inputweights_1[2u];
        let _e163 = inputjoints_1[2u];
        let _e166 = unnamed.palette[1u];
        phi_2613_ = _e158;
        if ((_e160 > 0f) && (_e163 < _e166)) {
            let _e170 = inputjoints_1[2u];
            let _e173 = unnamed.palette[0u];
            let _e175 = (_e173 + (_e170 * 3u));
            let _e178 = boneRows_1.data[_e175];
            let _e182 = boneRows_1.data[(_e175 + 1u)];
            let _e186 = boneRows_1.data[(_e175 + 2u)];
            let _e188 = inputweights_1[2u];
            phi_2613_ = (_e158 + (vec3<f32>(dot(_e178, _e83), dot(_e182, _e83), dot(_e186, _e83)) * _e188));
        }
        let _e196 = phi_2613_;
        let _e198 = inputweights_1[3u];
        let _e201 = inputjoints_1[3u];
        let _e204 = unnamed.palette[1u];
        phi_2655_ = _e196;
        if ((_e198 > 0f) && (_e201 < _e204)) {
            let _e208 = inputjoints_1[3u];
            let _e211 = unnamed.palette[0u];
            let _e213 = (_e211 + (_e208 * 3u));
            let _e216 = boneRows_1.data[_e213];
            let _e220 = boneRows_1.data[(_e213 + 1u)];
            let _e224 = boneRows_1.data[(_e213 + 2u)];
            let _e226 = inputweights_1[3u];
            phi_2655_ = (_e196 + (vec3<f32>(dot(_e216, _e83), dot(_e220, _e83), dot(_e224, _e83)) * _e226));
        }
        let _e234 = phi_2655_;
        let _e237 = unnamed.palette[2u];
        phi_2233_ = _e234;
        if (_e237 != 0u) {
            let _e240 = unnamed.bodyOriginAndScale;
            let _e244 = unnamed.bodyOriginAndScale[3u];
            phi_2233_ = (_e240.xyz + (_e234 * _e244));
        }
        let _e248 = phi_2233_;
        let _e250 = inputweights_1[0u];
        let _e253 = inputjoints_1[0u];
        let _e256 = unnamed.palette[1u];
        phi_2257_ = vec3<f32>(0f, 0f, 0f);
        if ((_e250 > 0f) && (_e253 < _e256)) {
            let _e260 = inputjoints_1[0u];
            let _e263 = unnamed.palette[0u];
            let _e265 = (_e263 + (_e260 * 3u));
            let _e268 = boneRows_1.data[_e265];
            let _e272 = boneRows_1.data[(_e265 + 1u)];
            let _e276 = boneRows_1.data[(_e265 + 2u)];
            let _e278 = inputweights_1[0u];
            phi_2257_ = (vec3<f32>(dot(_e268.xyz, _e71), dot(_e272.xyz, _e71), dot(_e276.xyz, _e71)) * _e278);
        }
        let _e288 = phi_2257_;
        let _e290 = inputweights_1[1u];
        let _e293 = inputjoints_1[1u];
        let _e296 = unnamed.palette[1u];
        phi_2439_ = _e288;
        if ((_e290 > 0f) && (_e293 < _e296)) {
            let _e300 = inputjoints_1[1u];
            let _e303 = unnamed.palette[0u];
            let _e305 = (_e303 + (_e300 * 3u));
            let _e308 = boneRows_1.data[_e305];
            let _e312 = boneRows_1.data[(_e305 + 1u)];
            let _e316 = boneRows_1.data[(_e305 + 2u)];
            let _e318 = inputweights_1[1u];
            phi_2439_ = (_e288 + (vec3<f32>(dot(_e308.xyz, _e71), dot(_e312.xyz, _e71), dot(_e316.xyz, _e71)) * _e318));
        }
        let _e329 = phi_2439_;
        let _e331 = inputweights_1[2u];
        let _e334 = inputjoints_1[2u];
        let _e337 = unnamed.palette[1u];
        phi_2484_ = _e329;
        if ((_e331 > 0f) && (_e334 < _e337)) {
            let _e341 = inputjoints_1[2u];
            let _e344 = unnamed.palette[0u];
            let _e346 = (_e344 + (_e341 * 3u));
            let _e349 = boneRows_1.data[_e346];
            let _e353 = boneRows_1.data[(_e346 + 1u)];
            let _e357 = boneRows_1.data[(_e346 + 2u)];
            let _e359 = inputweights_1[2u];
            phi_2484_ = (_e329 + (vec3<f32>(dot(_e349.xyz, _e71), dot(_e353.xyz, _e71), dot(_e357.xyz, _e71)) * _e359));
        }
        let _e370 = phi_2484_;
        let _e372 = inputweights_1[3u];
        let _e375 = inputjoints_1[3u];
        let _e378 = unnamed.palette[1u];
        phi_2529_ = _e370;
        if ((_e372 > 0f) && (_e375 < _e378)) {
            let _e382 = inputjoints_1[3u];
            let _e385 = unnamed.palette[0u];
            let _e387 = (_e385 + (_e382 * 3u));
            let _e390 = boneRows_1.data[_e387];
            let _e394 = boneRows_1.data[(_e387 + 1u)];
            let _e398 = boneRows_1.data[(_e387 + 2u)];
            let _e400 = inputweights_1[3u];
            phi_2529_ = (_e370 + (vec3<f32>(dot(_e390.xyz, _e71), dot(_e394.xyz, _e71), dot(_e398.xyz, _e71)) * _e400));
        }
        let _e411 = phi_2529_;
        let _e414 = unnamed.boneScaleAndRestPoseScale[1u];
        let _e418 = unnamed.boneScaleAndRestPoseScale[1u];
        let _e422 = unnamed.boneScaleAndRestPoseScale[0u];
        let _e426 = unnamed.boneScaleAndRestPoseScale[0u];
        let _e429 = (_e411 / vec3(select(_e426, select(1f, _e418, (_e414 != 0f)), (_e422 == 1f))));
        let _e431 = inputweights_1[1u];
        phi_2236_ = _e429;
        if (_e431 > 0f) {
            let _e433 = dot(_e429, _e429);
            phi_2236_ = select(_e429, (_e429 * inverseSqrt(_e433)), vec3((_e433 > 0.000000000000000000000001f)));
        }
        let _e440 = phi_2236_;
        phi_2241_ = _e440;
        phi_2237_ = _e248;
    } else {
        switch bitcast<i32>(0u) {
            default: {
                let _e445 = unnamed.palette[1u];
                if ((_e74 < 0i) || (_e74 >= bitcast<i32>(_e445))) {
                    phi_2229_ = _e70;
                    break;
                }
                let _e452 = unnamed.palette[0u];
                let _e454 = (_e452 + (bitcast<u32>(_e74) * 3u));
                let _e457 = boneRows_1.data[_e454];
                let _e461 = boneRows_1.data[(_e454 + 1u)];
                let _e465 = boneRows_1.data[(_e454 + 2u)];
                local_3 = _e457;
                local_4 = _e461;
                local_5 = _e465;
                let _e468 = unnamed.boneScaleAndRestPoseScale[0u];
                if (_e468 == 1f) {
                    let _e472 = unnamed.boneScaleAndRestPoseScale[1u];
                    let _e476 = unnamed.boneScaleAndRestPoseScale[1u];
                    let _e478 = (_e70 * select(1f, _e476, (_e472 != 0f)));
                    let _e482 = vec4<f32>(_e478.x, _e478.y, _e478.z, 1f);
                    phi_2227_ = vec3<f32>(dot(_e457, _e482), dot(_e461, _e482), dot(_e465, _e482));
                } else {
                    let _e496 = unnamed.boneScaleAndRestPoseScale[0u];
                    let _e499 = local_3[3u];
                    let _e501 = local_4[3u];
                    let _e503 = local_5[3u];
                    phi_2227_ = ((vec3<f32>(dot(_e457.xyz, _e70), dot(_e461.xyz, _e70), dot(_e465.xyz, _e70)) * _e496) + vec3<f32>(_e499, _e501, _e503));
                }
                let _e507 = phi_2227_;
                let _e510 = unnamed.palette[2u];
                phi_2228_ = _e507;
                if (_e510 != 0u) {
                    let _e513 = unnamed.bodyOriginAndScale;
                    let _e517 = unnamed.bodyOriginAndScale[3u];
                    phi_2228_ = (_e513.xyz + (_e507 * _e517));
                }
                let _e521 = phi_2228_;
                phi_2229_ = _e521;
                break;
            }
        }
        let _e523 = phi_2229_;
        switch bitcast<i32>(0u) {
            default: {
                let _e528 = unnamed.palette[1u];
                if ((_e75 < 0i) || (_e75 >= bitcast<i32>(_e528))) {
                    phi_2230_ = _e71;
                    break;
                }
                let _e535 = unnamed.palette[0u];
                let _e537 = (_e535 + (bitcast<u32>(_e75) * 3u));
                let _e540 = boneRows_1.data[_e537];
                let _e544 = boneRows_1.data[(_e537 + 1u)];
                let _e548 = boneRows_1.data[(_e537 + 2u)];
                phi_2230_ = vec3<f32>(dot(_e540.xyz, _e71), dot(_e544.xyz, _e71), dot(_e548.xyz, _e71));
                break;
            }
        }
        let _e557 = phi_2230_;
        phi_2241_ = _e557;
        phi_2237_ = _e523;
    }
    let _e559 = phi_2241_;
    let _e561 = phi_2237_;
    let _e567 = unnamed.mvp;
    let _e569 = (vec4<f32>(_e561.x, _e561.y, _e561.z, 1f) * transpose(_e567));
    local_1 = _e569;
    local_6 = _e559;
    switch bitcast<i32>(0u) {
        default: {
            let _e573 = unnamed.textureCoordinateMode[0u];
            let _e576 = unnamed.chromeParameters[0u];
            let _e579 = unnamed.chromeParameters[1u];
            let _e581 = unnamed.chromeParameters;
            local_2 = _e581.zw;
            let _e584 = unnamed.textureCoordinateParameters;
            let _e585 = _e584.xy;
            if (_e573 == 1u) {
                let _e588 = local_6[2u];
                let _e592 = local_6[1u];
                phi_2242_ = vec2<f32>(((_e588 * 0.5f) + _e576), ((_e592 * 0.5f) + (_e576 * 2f)));
                break;
            }
            if (_e573 == 2u) {
                let _e599 = local_6[2u];
                let _e601 = local_6[0u];
                let _e607 = local_6[1u];
                let _e609 = local_6[0u];
                phi_2242_ = vec2<f32>((((_e599 + _e601) * 0.8f) + (_e579 * 2f)), ((_e607 + _e609) + (_e579 * 3f)));
                break;
            }
            if (_e573 == 3u) {
                let _e615 = dot(_e559, vec3<f32>(0f, -0.1f, -0.8f));
                phi_2242_ = vec2<f32>(_e615, (1f - _e615));
                break;
            }
            if ((_e573 == 4u) || (_e573 == 5u)) {
                let _e624 = dot(_e559, vec3<f32>(_e581.z, _e581.w, 1f));
                let _e634 = local_6[1u];
                let _e638 = local_2[1u];
                let _e643 = local_6[2u];
                phi_2242_ = (vec2<f32>(((_e624 + (_e634 * select(3f, 0.5f, (_e573 == 4u)))) + (_e638 * select(5f, 3f, (_e573 == 4u)))), (((1f - _e624) - (_e643 * select(2.5f, 0.5f, (_e573 == 4u)))) - (_e576 * select(1f, 3f, (_e573 == 4u))))) + _e585);
                break;
            }
            if (_e573 == 6u) {
                let _e652 = local_6[2u];
                let _e654 = local_6[0u];
                phi_2242_ = vec2((((_e652 + _e654) * 0.8f) + (_e579 * 2f)));
                break;
            }
            if (_e573 == 7u) {
                let _e662 = local_6[2u];
                let _e664 = local_6[0u];
                let _e669 = unnamed.textureCoordinateParameters[2u];
                phi_2242_ = vec2((((_e662 + _e664) * 0.8f) + _e669));
                break;
            }
            if (_e573 == 8u) {
                phi_2242_ = ((_e559.xy * _e72) + _e585);
                break;
            }
            if (_e573 == 9u) {
                let _e678 = local_6[2u];
                let _e682 = local_6[1u];
                phi_2242_ = vec2<f32>(((_e678 * 0.5f) + 0.2f), ((_e682 * 0.5f) + 0.5f));
                break;
            }
            phi_2242_ = _e72;
            break;
        }
    }
    let _e687 = phi_2242_;
    local = _e73;
    let _e690 = unnamed.palette[3u];
    if (_e690 == 1u) {
        let _e693 = unnamed.lightDirection;
        let _e698 = max(((dot(_e559, _e693.xyz) * 0.8f) + 0.4f), 0.2f);
        let _e699 = local;
        let _e702 = clamp((_e699.xyz * _e698), vec3<f32>(0f, 0f, 0f), vec3<f32>(1f, 1f, 1f));
        local[0u] = _e702.x;
        local[1u] = _e702.y;
        local[2u] = _e702.z;
        let _e711 = unnamed.lightDirection[3u];
        if ((_e711 > 0f) && (_e711 < 1f)) {
            local_7 = (_e73.xyz * _e698);
            let _e719 = unnamed.lightDirection[3u];
            let _e721 = local_7[0u];
            let _e722 = (1f - _e719);
            let _e734 = local_7[1u];
            let _e735 = (1f - _e719);
            let _e747 = local_7[2u];
            let _e748 = (1f - _e719);
            let _e760 = clamp(vec3<f32>(select(_e721, (_e719 + (_e722 * (1f - exp((-(max((_e721 - _e719), 0f)) / _e722))))), (_e721 > _e719)), select(_e734, (_e719 + (_e735 * (1f - exp((-(max((_e734 - _e719), 0f)) / _e735))))), (_e734 > _e719)), select(_e747, (_e719 + (_e748 * (1f - exp((-(max((_e747 - _e719), 0f)) / _e748))))), (_e747 > _e719))), vec3<f32>(0f, 0f, 0f), vec3<f32>(1f, 1f, 1f));
            local[0u] = _e760.x;
            local[1u] = _e760.y;
            local[2u] = _e760.z;
        }
    }
    let _e768 = local_1[3u];
    let _e772 = unnamed.fogParameters[1u];
    let _e775 = unnamed.fogParameters[0u];
    let _e776 = (_e772 - _e775);
    let _e780 = unnamed.fogParameters[1u];
    let _e782 = local_1[3u];
    let _e789 = local_1[3u];
    let _e792 = unnamed.eyePositionAndSpecular;
    let _e796 = unnamed.lightDirection;
    let _e799 = unnamed.eyePositionAndSpecular[3u];
    let _e807 = vec4<f32>(_e561.x, _e561.y, _e561.z, 1f);
    let _e810 = unnamed.vertexToWorldRows[0i];
    let _e814 = unnamed.vertexToWorldRows[1i];
    let _e818 = unnamed.vertexToWorldRows[2i];
    let _e822 = unnamed.palette[3u];
    let _e828 = unnamed.vertexToWorldRows[0i];
    let _e833 = unnamed.vertexToWorldRows[1i];
    let _e838 = unnamed.vertexToWorldRows[2i];
    let _e844 = unnamed.palette[3u];
    let _e847 = inputweights_1[0u];
    let _e851 = inputtangent_1[3u];
    let _e856 = unnamed.textureCoordinateParameters[3u];
    let _e858 = ((((_e844 >= 2u) && (_e847 > 0f)) && (_e851 != 0f)) && (_e856 != 0f));
    phi_2252_ = vec3<f32>(0f, 0f, 0f);
    if _e858 {
        let _e859 = _e76.xyz;
        let _e861 = inputweights_1[0u];
        let _e864 = inputjoints_1[0u];
        let _e867 = unnamed.palette[1u];
        phi_2259_ = vec3<f32>(0f, 0f, 0f);
        if ((_e861 > 0f) && (_e864 < _e867)) {
            let _e871 = inputjoints_1[0u];
            let _e874 = unnamed.palette[0u];
            let _e876 = (_e874 + (_e871 * 3u));
            let _e879 = boneRows_1.data[_e876];
            let _e883 = boneRows_1.data[(_e876 + 1u)];
            let _e887 = boneRows_1.data[(_e876 + 2u)];
            let _e889 = inputweights_1[0u];
            phi_2259_ = (vec3<f32>(dot(_e879.xyz, _e859), dot(_e883.xyz, _e859), dot(_e887.xyz, _e859)) * _e889);
        }
        let _e899 = phi_2259_;
        let _e901 = inputweights_1[1u];
        let _e904 = inputjoints_1[1u];
        let _e907 = unnamed.palette[1u];
        phi_2304_ = _e899;
        if ((_e901 > 0f) && (_e904 < _e907)) {
            let _e911 = inputjoints_1[1u];
            let _e914 = unnamed.palette[0u];
            let _e916 = (_e914 + (_e911 * 3u));
            let _e919 = boneRows_1.data[_e916];
            let _e923 = boneRows_1.data[(_e916 + 1u)];
            let _e927 = boneRows_1.data[(_e916 + 2u)];
            let _e929 = inputweights_1[1u];
            phi_2304_ = (_e899 + (vec3<f32>(dot(_e919.xyz, _e859), dot(_e923.xyz, _e859), dot(_e927.xyz, _e859)) * _e929));
        }
        let _e940 = phi_2304_;
        let _e942 = inputweights_1[2u];
        let _e945 = inputjoints_1[2u];
        let _e948 = unnamed.palette[1u];
        phi_2349_ = _e940;
        if ((_e942 > 0f) && (_e945 < _e948)) {
            let _e952 = inputjoints_1[2u];
            let _e955 = unnamed.palette[0u];
            let _e957 = (_e955 + (_e952 * 3u));
            let _e960 = boneRows_1.data[_e957];
            let _e964 = boneRows_1.data[(_e957 + 1u)];
            let _e968 = boneRows_1.data[(_e957 + 2u)];
            let _e970 = inputweights_1[2u];
            phi_2349_ = (_e940 + (vec3<f32>(dot(_e960.xyz, _e859), dot(_e964.xyz, _e859), dot(_e968.xyz, _e859)) * _e970));
        }
        let _e981 = phi_2349_;
        let _e983 = inputweights_1[3u];
        let _e986 = inputjoints_1[3u];
        let _e989 = unnamed.palette[1u];
        phi_2394_ = _e981;
        if ((_e983 > 0f) && (_e986 < _e989)) {
            let _e993 = inputjoints_1[3u];
            let _e996 = unnamed.palette[0u];
            let _e998 = (_e996 + (_e993 * 3u));
            let _e1001 = boneRows_1.data[_e998];
            let _e1005 = boneRows_1.data[(_e998 + 1u)];
            let _e1009 = boneRows_1.data[(_e998 + 2u)];
            let _e1011 = inputweights_1[3u];
            phi_2394_ = (_e981 + (vec3<f32>(dot(_e1001.xyz, _e859), dot(_e1005.xyz, _e859), dot(_e1009.xyz, _e859)) * _e1011));
        }
        let _e1022 = phi_2394_;
        let _e1025 = unnamed.boneScaleAndRestPoseScale[1u];
        let _e1029 = unnamed.boneScaleAndRestPoseScale[1u];
        let _e1033 = unnamed.boneScaleAndRestPoseScale[0u];
        let _e1037 = unnamed.boneScaleAndRestPoseScale[0u];
        let _e1040 = (_e1022 / vec3(select(_e1037, select(1f, _e1029, (_e1025 != 0f)), (_e1033 == 1f))));
        let _e1042 = inputweights_1[1u];
        phi_2251_ = _e1040;
        if (_e1042 > 0f) {
            let _e1044 = dot(_e1040, _e1040);
            phi_2251_ = select(_e1040, (_e1040 * inverseSqrt(_e1044)), vec3((_e1044 > 0.000000000000000000000001f)));
        }
        let _e1051 = phi_2251_;
        phi_2252_ = _e1051;
    }
    let _e1053 = phi_2252_;
    let _e1055 = inputtangent_1[3u];
    let _e1064 = unnamed.vertexToWorldRows[0i];
    let _e1069 = unnamed.vertexToWorldRows[1i];
    let _e1074 = unnamed.vertexToWorldRows[2i];
    let _e1079 = unnamed.textureCoordinateParameters[3u];
    let _e1082 = local;
    entryPointOutputpos = _e569;
    entryPointOutputuv = _e687;
    entryPointOutputcolor = _e1082;
    entryPointOutputfogFactor = select(1f, clamp(((_e780 - abs(_e782)) / _e776), 0f, 1f), (_e776 > 0.001f));
    entryPointOutputeyeDepth = abs(_e789);
    entryPointOutputnormal = _e559;
    entryPointOutputviewVector = (_e792.xyz - _e561);
    entryPointOutputlightDirectionAndSpecular = vec4<f32>(_e796.x, _e796.y, _e796.z, _e799);
    entryPointOutputworldPositionAndDynamicLights = vec4<f32>(dot(_e810, _e807), dot(_e814, _e807), dot(_e818, _e807), select(0f, 1f, (_e822 == 3u)));
    entryPointOutputworldNormal = vec3<f32>(dot(_e828.xyz, _e559), dot(_e833.xyz, _e559), dot(_e838.xyz, _e559));
    entryPointOutputtangent = vec4<f32>(_e1053.x, _e1053.y, _e1053.z, select(0f, sign(_e1055), _e858));
    entryPointOutputworldTangentAndNormalMapScale = vec4<f32>(dot(_e1064.xyz, _e1053), dot(_e1069.xyz, _e1053), dot(_e1074.xyz, _e1053), select(0f, _e1079, _e858));
    entryPointOutputclipDist = (_e768 - 1f);
    return;
}

@vertex
fn main(@location(0) inputpos: vec3<f32>, @location(1) inputnormal: vec3<f32>, @location(2) inputuv: vec2<f32>, @location(3) inputcolor: vec4<f32>, @location(4) inputpositionBoneIndex: i32, @location(5) inputnormalBoneIndex: i32, @location(6) inputjoints: vec4<u32>, @location(7) inputweights: vec4<f32>, @location(8) inputtangent: vec4<f32>) -> VertexOutput {
    inputpos_1 = inputpos;
    inputnormal_1 = inputnormal;
    inputuv_1 = inputuv;
    inputcolor_1 = inputcolor;
    inputpositionBoneIndex_1 = inputpositionBoneIndex;
    inputnormalBoneIndex_1 = inputnormalBoneIndex;
    inputjoints_1 = inputjoints;
    inputweights_1 = inputweights;
    inputtangent_1 = inputtangent;
    main_1();
    let _e31 = entryPointOutputpos;
    let _e32 = entryPointOutputuv;
    let _e33 = entryPointOutputcolor;
    let _e34 = entryPointOutputfogFactor;
    let _e35 = entryPointOutputeyeDepth;
    let _e36 = entryPointOutputnormal;
    let _e37 = entryPointOutputviewVector;
    let _e38 = entryPointOutputlightDirectionAndSpecular;
    let _e39 = entryPointOutputworldPositionAndDynamicLights;
    let _e40 = entryPointOutputworldNormal;
    let _e41 = entryPointOutputtangent;
    let _e42 = entryPointOutputworldTangentAndNormalMapScale;
    let _e43 = entryPointOutputclipDist;
    return VertexOutput(_e31, _e32, _e33, _e34, _e35, _e36, _e37, _e38, _e39, _e40, _e41, _e42, _e43);
}
