struct SceneLighting {
    sceneLightDirection: vec4<f32>,
    sceneLightColor: vec4<f32>,
    diffuseCurve: vec4<f32>,
    rimParameters: vec4<f32>,
    specularParameters: vec4<f32>,
    sceneFogColor: vec4<f32>,
    sceneFogParameters: vec4<f32>,
    cameraPosition: vec4<f32>,
}

struct DynamicLights {
    dynamicLightCount: u32,
    dynamicLightWrap: f32,
    dynamicLightPadding: vec2<u32>,
    dynamicLightPositionAndRadius: array<vec4<f32>, 32>,
    dynamicLightColor: array<vec4<f32>, 32>,
}

struct FogUniforms {
    fogEnabled: u32,
    alphaDiscardEnabled: u32,
    alphaThreshold: f32,
    alphaToCoverage: u32,
    fogStart: f32,
    fogEnd: f32,
    fogColor: vec4<f32>,
}

@group(3) @binding(1)
var<uniform> unnamed: SceneLighting;
@group(3) @binding(2)
var<uniform> unnamed_1: DynamicLights;
@group(2) @binding(0)
var tex: texture_2d<f32>;
@group(2) @binding(1)
var s: sampler;
@group(2) @binding(2)
var normalMap: texture_2d<f32>;
@group(2) @binding(3)
var normalSampler: sampler;
@group(3) @binding(0)
var<uniform> unnamed_2: FogUniforms;
var<private> inputuv_1: vec2<f32>;
var<private> inputcolor_1: vec4<f32>;
var<private> inputeyeDepth_1: f32;
var<private> inputnormal_1: vec3<f32>;
var<private> inputviewVector_1: vec3<f32>;
var<private> inputlightDirectionAndSpecular_1: vec4<f32>;
var<private> inputworldPositionAndDynamicLights_1: vec4<f32>;
var<private> inputworldNormal_1: vec3<f32>;
var<private> inputtangent_1: vec4<f32>;
var<private> inputworldTangentAndNormalMapScale_1: vec4<f32>;
var<private> entryPointOutput: vec4<f32>;

fn main_1() {
    var phi_1458_: vec3<f32>;
    var phi_1457_: vec3<f32>;
    var phi_1460_: vec3<f32>;
    var phi_1459_: u32;
    var phi_1467_: vec3<f32>;
    var local: vec3<f32>;
    var phi_1462_: vec3<f32>;
    var phi_1463_: vec3<f32>;
    var phi_1464_: vec4<f32>;
    var phi_1465_: vec4<f32>;

    let _e39 = inputuv_1;
    let _e40 = inputcolor_1;
    let _e41 = inputeyeDepth_1;
    let _e42 = inputnormal_1;
    let _e43 = inputviewVector_1;
    let _e44 = inputlightDirectionAndSpecular_1;
    let _e45 = inputworldPositionAndDynamicLights_1;
    let _e46 = inputworldNormal_1;
    let _e47 = inputtangent_1;
    let _e48 = inputworldTangentAndNormalMapScale_1;
    let _e49 = textureSample(tex, s, _e39);
    let _e50 = dpdx(_e39);
    let _e51 = dpdy(_e39);
    phi_1458_ = _e46;
    phi_1457_ = _e42;
    if ((_e48.w > 0f) && (_e47.w != 0f)) {
        let _e57 = textureSampleGrad(normalMap, normalSampler, _e39, _e50, _e51);
        let _e60 = ((_e57.xyz * 2f) - vec3<f32>(1f, 1f, 1f));
        let _e62 = (_e60.xy * _e48.w);
        let _e67 = select(-1f, 1f, (_e47.w > 0f));
        let _e68 = _e47.xyz;
        let _e69 = dot(_e42, _e42);
        let _e74 = select(vec3<f32>(0f, 0f, 0f), (_e42 * inverseSqrt(_e69)), vec3((_e69 > 0.000000000001f)));
        let _e75 = dot(_e68, _e68);
        let _e80 = select(vec3<f32>(0f, 0f, 0f), (_e68 * inverseSqrt(_e75)), vec3((_e75 > 0.000000000001f)));
        let _e88 = (((_e80 * _e62.x) + ((cross(_e74, _e80) * _e67) * _e62.y)) + (_e74 * _e60.z));
        let _e89 = dot(_e88, _e88);
        let _e97 = _e48.xyz;
        let _e98 = dot(_e46, _e46);
        let _e103 = select(vec3<f32>(0f, 0f, 0f), (_e46 * inverseSqrt(_e98)), vec3((_e98 > 0.000000000001f)));
        let _e104 = dot(_e97, _e97);
        let _e109 = select(vec3<f32>(0f, 0f, 0f), (_e97 * inverseSqrt(_e104)), vec3((_e104 > 0.000000000001f)));
        let _e117 = (((_e109 * _e62.x) + ((cross(_e103, _e109) * _e67) * _e62.y)) + (_e103 * _e60.z));
        let _e118 = dot(_e117, _e117);
        phi_1458_ = select(vec3<f32>(0f, 0f, 0f), (_e117 * inverseSqrt(_e118)), vec3((_e118 > 0.000000000001f)));
        phi_1457_ = (select(vec3<f32>(0f, 0f, 0f), (_e88 * inverseSqrt(_e89)), vec3((_e89 > 0.000000000001f))) * length(_e42));
    }
    let _e125 = phi_1458_;
    let _e127 = phi_1457_;
    let _e128 = _e40.xyz;
    let _e129 = dot(_e127, _e127);
    let _e134 = select(vec3<f32>(0f, 0f, 0f), (_e127 * inverseSqrt(_e129)), vec3((_e129 > 0.000000000001f)));
    let _e135 = dot(_e43, _e43);
    let _e140 = select(vec3<f32>(0f, 0f, 0f), (_e43 * inverseSqrt(_e135)), vec3((_e135 > 0.000000000001f)));
    let _e141 = _e44.xyz;
    let _e142 = dot(_e127, _e141);
    let _e145 = unnamed.diffuseCurve[0u];
    let _e149 = unnamed.diffuseCurve[1u];
    let _e153 = unnamed.diffuseCurve[2u];
    let _e154 = max(((_e142 * _e145) + _e149), _e153);
    let _e157 = dot(_e125, _e125);
    let _e165 = unnamed_1.dynamicLightCount;
    phi_1460_ = vec3<f32>(0f, 0f, 0f);
    phi_1459_ = 0u;
    loop {
        let _e168 = phi_1460_;
        let _e170 = phi_1459_;
        local = _e168;
        if (_e170 < min(_e165, 32u)) {
            let _e174 = unnamed_1.dynamicLightPositionAndRadius[_e170];
            let _e176 = (_e174.xyz - _e45.xyz);
            let _e179 = length(_e176.xy);
            if (_e179 >= _e174.w) {
                phi_1467_ = _e168;
                continue;
            }
            let _e183 = dot(_e176, _e176);
            let _e191 = unnamed_1.dynamicLightWrap;
            let _e195 = unnamed_1.dynamicLightWrap;
            let _e200 = unnamed_1.dynamicLightColor[_e170];
            phi_1467_ = (_e168 + (_e200.xyz * (((_e174.w - _e179) / _e174.w) * clamp(((dot(select(vec3<f32>(0f, 0f, 0f), (_e125 * inverseSqrt(_e157)), vec3((_e157 > 0.000000000001f))), select(vec3<f32>(0f, 0f, 0f), (_e176 * inverseSqrt(_e183)), vec3((_e183 > 0.000000000001f)))) * (1f - _e191)) + _e195), 0f, 1f))));
            continue;
        } else {
            break;
        }
        continuing {
            let _e206 = phi_1467_;
            phi_1460_ = _e206;
            phi_1459_ = (_e170 + bitcast<u32>(1i));
        }
    }
    let _e211 = local;
    let _e212 = select(vec3<f32>(0f, 0f, 0f), _e211, vec3((_e45.w > 0.5f)));
    let _e218 = unnamed.diffuseCurve[3u];
    phi_1462_ = clamp(((_e128 * _e154) + _e212), vec3<f32>(0f, 0f, 0f), vec3<f32>(1f, 1f, 1f));
    if ((_e218 > 0f) && (_e218 < 1f)) {
        let _e223 = ((_e128 * _e154) + _e212);
        let _e226 = unnamed.diffuseCurve[3u];
        let _e228 = (1f - _e226);
        let _e240 = (1f - _e226);
        let _e252 = (1f - _e226);
        phi_1462_ = clamp(vec3<f32>(select(_e223.x, (_e226 + (_e228 * (1f - exp((-(max((_e223.x - _e226), 0f)) / _e228))))), (_e223.x > _e226)), select(_e223.y, (_e226 + (_e240 * (1f - exp((-(max((_e223.y - _e226), 0f)) / _e240))))), (_e223.y > _e226)), select(_e223.z, (_e226 + (_e252 * (1f - exp((-(max((_e223.z - _e226), 0f)) / _e252))))), (_e223.z > _e226))), vec3<f32>(0f, 0f, 0f), vec3<f32>(1f, 1f, 1f));
    }
    let _e266 = phi_1462_;
    let _e272 = unnamed.rimParameters[0u];
    let _e276 = unnamed.rimParameters[1u];
    let _e283 = unnamed.specularParameters[0u];
    let _e284 = (_e44.w * _e283);
    phi_1463_ = vec3<f32>(0f, 0f, 0f);
    if ((_e284 > 0f) && (_e142 > 0f)) {
        let _e288 = dot(_e141, _e141);
        let _e294 = (select(vec3<f32>(0f, 0f, 0f), (_e141 * inverseSqrt(_e288)), vec3((_e288 > 0.000000000001f))) + _e140);
        let _e295 = dot(_e294, _e294);
        let _e305 = unnamed.specularParameters[1u];
        let _e309 = unnamed.sceneLightColor;
        phi_1463_ = ((_e309.xyz * (_e284 * pow(clamp(dot(_e134, select(vec3<f32>(0f, 0f, 0f), (_e294 * inverseSqrt(_e295)), vec3((_e295 > 0.000000000001f)))), 0f, 1f), _e305))) * _e128);
    }
    let _e314 = phi_1463_;
    let _e318 = (((_e49.xyz * _e266) + (_e128 * (_e272 * pow((1f - clamp(abs(dot(_e134, _e140)), 0f, 1f)), _e276)))) + _e314);
    let _e321 = (_e49.w * _e40.w);
    let _e325 = vec4<f32>(_e318.x, _e318.y, _e318.z, _e321);
    let _e327 = unnamed_2.alphaToCoverage;
    if (_e327 != 0u) {
        let _e330 = unnamed_2.alphaThreshold;
        let _e332 = fwidth(_e321);
        let _e337 = (_e321 * clamp((((_e321 - _e330) / max(_e332, 0.0001f)) + 0.5f), 0f, 1f));
        if (_e337 <= 0f) {
            discard;
        }
        phi_1464_ = vec4<f32>(_e325.x, _e325.y, _e325.z, _e337);
    } else {
        let _e345 = unnamed_2.alphaDiscardEnabled;
        let _e348 = unnamed_2.alphaThreshold;
        if ((_e345 != 0u) && (_e321 <= _e348)) {
            discard;
        }
        phi_1464_ = _e325;
    }
    let _e352 = phi_1464_;
    let _e354 = unnamed_2.fogEnabled;
    let _e358 = unnamed.sceneFogColor[3u];
    phi_1465_ = _e352;
    if ((_e354 != 0u) && (_e358 > 0f)) {
        let _e363 = unnamed.sceneFogColor;
        let _e367 = unnamed.sceneFogParameters[0u];
        let _e372 = unnamed.sceneFogParameters[2u];
        let _e373 = (max((_e41 - _e367), 0f) * _e372);
        let _e380 = mix(_e352.xyz, _e363.xyz, vec3(clamp((1f - exp((-(_e373) * _e373))), 0f, 1f)));
        let _e386 = vec4<f32>(_e380.x, _e352.y, _e352.z, _e352.w);
        let _e392 = vec4<f32>(_e386.x, _e380.y, _e386.z, _e386.w);
        phi_1465_ = vec4<f32>(_e392.x, _e392.y, _e380.z, _e392.w);
    }
    let _e400 = phi_1465_;
    entryPointOutput = _e400;
    return;
}

@fragment
fn main(@location(0) inputuv: vec2<f32>, @location(1) inputcolor: vec4<f32>, @location(3) inputeyeDepth: f32, @location(4) inputnormal: vec3<f32>, @location(5) inputviewVector: vec3<f32>, @location(6) @interpolate(flat) inputlightDirectionAndSpecular: vec4<f32>, @location(7) inputworldPositionAndDynamicLights: vec4<f32>, @location(8) inputworldNormal: vec3<f32>, @location(9) inputtangent: vec4<f32>, @location(10) inputworldTangentAndNormalMapScale: vec4<f32>) -> @location(0) vec4<f32> {
    inputuv_1 = inputuv;
    inputcolor_1 = inputcolor;
    inputeyeDepth_1 = inputeyeDepth;
    inputnormal_1 = inputnormal;
    inputviewVector_1 = inputviewVector;
    inputlightDirectionAndSpecular_1 = inputlightDirectionAndSpecular;
    inputworldPositionAndDynamicLights_1 = inputworldPositionAndDynamicLights;
    inputworldNormal_1 = inputworldNormal;
    inputtangent_1 = inputtangent;
    inputworldTangentAndNormalMapScale_1 = inputworldTangentAndNormalMapScale;
    main_1();
    let _e21 = entryPointOutput;
    return _e21;
}
