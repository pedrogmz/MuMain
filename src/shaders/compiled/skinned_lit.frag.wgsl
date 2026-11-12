struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
    fogFactor: f32,
    eyeDepth: f32,
    normal: vec3<f32>,
    viewVector: vec3<f32>,
    lightDirectionAndSpecular: vec4<f32>,
    worldPositionAndDynamicLights: vec4<f32>,
    worldNormal: vec3<f32>,
    tangent: vec4<f32>,
    worldTangentAndNormalMapScale: vec4<f32>,
}

struct SceneLighting {
    sceneLightDirection: vec4<f32>,
    sceneLightColor: vec4<f32>,
    diffuseCurve: vec4<f32>,
    rimParameters: vec4<f32>,
    specularParameters: vec4<f32>,
    sceneFogColor: vec4<f32>,
    sceneFogParameters: vec4<f32>,
    cameraPosition: vec4<f32>,
    sunViewProjection: mat4x4<f32>,
    sunShadowParameters: vec4<f32>,
    lightingParameters: vec4<f32>,
    cloudParameters: vec4<f32>,
    cloudOffset: vec4<f32>,
    skyFill: vec4<f32>,
    sunTowards: vec4<f32>,
    sunColor: vec4<f32>,
}

struct DynamicLights {
    dynamicLightCount: u32,
    dynamicLightWrap: f32,
    dynamicWorldLightCount: u32,
    groundShadowOpacity: f32,
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
@group(2) @binding(4) 
var sunShadowMap: texture_depth_2d;
@group(2) @binding(5) 
var sunShadowSampler: sampler_comparison;
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
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> input_u002e_color_1: vec4<f32>;
var<private> input_u002e_fogFactor_1: f32;
var<private> input_u002e_eyeDepth_1: f32;
var<private> input_u002e_normal_1: vec3<f32>;
var<private> input_u002e_viewVector_1: vec3<f32>;
var<private> input_u002e_lightDirectionAndSpecular_1: vec4<f32>;
var<private> input_u002e_worldPositionAndDynamicLights_1: vec4<f32>;
var<private> input_u002e_worldNormal_1: vec3<f32>;
var<private> input_u002e_tangent_1: vec4<f32>;
var<private> input_u002e_worldTangentAndNormalMapScale_1: vec4<f32>;
var<private> u0040_entryPointOutput: vec4<f32>;

fn EnhancedFogAmount_u0028_f1_u003b(eyeDepth: ptr<function, f32>) -> f32 {
    var scaledDistance: f32;

    let _e118 = (*eyeDepth);
    let _e121 = unnamed.sceneFogParameters[0u];
    let _e126 = unnamed.sceneFogParameters[2u];
    scaledDistance = (max((_e118 - _e121), 0f) * _e126);
    let _e128 = scaledDistance;
    let _e130 = scaledDistance;
    return clamp((1f - exp((-(_e128) * _e130))), 0f, 1f);
}

fn RollOffChannel_u0028_f1_u003b_f1_u003b(value: ptr<function, f32>, knee: ptr<function, f32>) -> f32 {
    var range: f32;

    let _e119 = (*knee);
    range = (1f - _e119);
    let _e121 = (*value);
    let _e122 = (*knee);
    let _e124 = (*knee);
    let _e125 = range;
    let _e126 = (*value);
    let _e127 = (*knee);
    let _e131 = range;
    let _e137 = (*value);
    return select(_e137, (_e124 + (_e125 * (1f - exp((-(max((_e126 - _e127), 0f)) / _e131))))), (_e121 > _e122));
}

fn RollOffHighlight_u0028_vf3_u003b_f1_u003b(color: ptr<function, vec3<f32>>, knee_1: ptr<function, f32>) -> vec3<f32> {
    var param: f32;
    var param_1: f32;
    var param_2: f32;
    var param_3: f32;
    var param_4: f32;
    var param_5: f32;

    let _e125 = (*color)[0u];
    param = _e125;
    let _e126 = (*knee_1);
    param_1 = _e126;
    let _e127 = RollOffChannel_u0028_f1_u003b_f1_u003b((&param), (&param_1));
    let _e129 = (*color)[1u];
    param_2 = _e129;
    let _e130 = (*knee_1);
    param_3 = _e130;
    let _e131 = RollOffChannel_u0028_f1_u003b_f1_u003b((&param_2), (&param_3));
    let _e133 = (*color)[2u];
    param_4 = _e133;
    let _e134 = (*knee_1);
    param_5 = _e134;
    let _e135 = RollOffChannel_u0028_f1_u003b_f1_u003b((&param_4), (&param_5));
    return clamp(vec3<f32>(_e127, _e131, _e135), vec3(0f), vec3(1f));
}

fn RollsOffHighlight_u0028_f1_u003b(knee_2: ptr<function, f32>) -> bool {
    let _e117 = (*knee_2);
    let _e119 = (*knee_2);
    return ((_e117 > 0f) && (_e119 < 1f));
}

fn SafeNormalize_u0028_vf3_u003b(value_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var lengthSquared: f32;

    let _e118 = (*value_1);
    let _e119 = (*value_1);
    lengthSquared = dot(_e118, _e119);
    let _e121 = lengthSquared;
    let _e123 = (*value_1);
    let _e124 = lengthSquared;
    return select(vec3<f32>(0f, 0f, 0f), (_e123 * inverseSqrt(_e124)), vec3((_e121 > 0.000000000001f)));
}

fn PointLightFalloff_u0028_vf3_u003b_f1_u003b(toLight: ptr<function, vec3<f32>>, radius: ptr<function, f32>) -> f32 {
    var horizontal: f32;

    let _e119 = (*toLight);
    horizontal = length(_e119.xy);
    let _e122 = horizontal;
    let _e123 = (*radius);
    let _e125 = (*radius);
    let _e126 = horizontal;
    let _e128 = (*radius);
    return select(0f, ((_e125 - _e126) / _e128), (_e122 < _e123));
}

fn DynamicLighting_u0028_vf3_u003b_vf3_u003b(worldPosition: ptr<function, vec3<f32>>, worldNormal: ptr<function, vec3<f32>>) -> vec3<f32> {
    var light: vec3<f32>;
    var count: u32;
    var i: u32;
    var positionAndRadius: vec4<f32>;
    var toLight_1: vec3<f32>;
    var falloff: f32;
    var param_6: vec3<f32>;
    var param_7: f32;
    var wrapped: f32;
    var param_8: vec3<f32>;

    light = vec3<f32>(0f, 0f, 0f);
    let _e129 = unnamed_1.dynamicLightCount;
    count = min(_e129, 32u);
    i = 0u;
    loop {
        let _e131 = i;
        let _e132 = count;
        if (_e131 < _e132) {
            let _e134 = i;
            let _e137 = unnamed_1.dynamicLightPositionAndRadius[_e134];
            positionAndRadius = _e137;
            let _e138 = positionAndRadius;
            let _e140 = (*worldPosition);
            toLight_1 = (_e138.xyz - _e140);
            let _e142 = toLight_1;
            param_6 = _e142;
            let _e144 = positionAndRadius[3u];
            param_7 = _e144;
            let _e145 = PointLightFalloff_u0028_vf3_u003b_f1_u003b((&param_6), (&param_7));
            falloff = _e145;
            let _e146 = falloff;
            if (_e146 <= 0f) {
                continue;
            }
            let _e148 = (*worldNormal);
            let _e149 = toLight_1;
            param_8 = _e149;
            let _e150 = SafeNormalize_u0028_vf3_u003b((&param_8));
            let _e153 = unnamed_1.dynamicLightWrap;
            let _e157 = unnamed_1.dynamicLightWrap;
            wrapped = clamp(((dot(_e148, _e150) * (1f - _e153)) + _e157), 0f, 1f);
            let _e160 = i;
            let _e163 = unnamed_1.dynamicLightColor[_e160];
            let _e165 = falloff;
            let _e166 = wrapped;
            let _e169 = light;
            light = (_e169 + (_e163.xyz * (_e165 * _e166)));
            continue;
        } else {
            break;
        }
        continuing {
            let _e171 = i;
            i = (_e171 + bitcast<u32>(1i));
        }
    }
    let _e174 = light;
    return _e174;
}

fn CloudHash_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    let _e117 = (*p);
    return fract((sin(dot(_e117, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn CloudNoise_u0028_vf2_u003b(p_1: ptr<function, vec2<f32>>) -> f32 {
    var cell: vec2<f32>;
    var f: vec2<f32>;
    var u: vec2<f32>;
    var a: f32;
    var param_9: vec2<f32>;
    var b: f32;
    var param_10: vec2<f32>;
    var c: f32;
    var param_11: vec2<f32>;
    var d: f32;
    var param_12: vec2<f32>;

    let _e128 = (*p_1);
    cell = floor(_e128);
    let _e130 = (*p_1);
    f = fract(_e130);
    let _e132 = f;
    let _e133 = f;
    let _e135 = f;
    u = ((_e132 * _e133) * (vec2(3f) - (_e135 * 2f)));
    let _e140 = cell;
    param_9 = _e140;
    let _e141 = CloudHash_u0028_vf2_u003b((&param_9));
    a = _e141;
    let _e142 = cell;
    param_10 = (_e142 + vec2<f32>(1f, 0f));
    let _e144 = CloudHash_u0028_vf2_u003b((&param_10));
    b = _e144;
    let _e145 = cell;
    param_11 = (_e145 + vec2<f32>(0f, 1f));
    let _e147 = CloudHash_u0028_vf2_u003b((&param_11));
    c = _e147;
    let _e148 = cell;
    param_12 = (_e148 + vec2<f32>(1f, 1f));
    let _e150 = CloudHash_u0028_vf2_u003b((&param_12));
    d = _e150;
    let _e151 = a;
    let _e152 = b;
    let _e154 = u[0u];
    let _e156 = c;
    let _e157 = d;
    let _e159 = u[0u];
    let _e162 = u[1u];
    return mix(mix(_e151, _e152, _e154), mix(_e156, _e157, _e159), _e162);
}

fn CloudLight_u0028_vf2_u003b_vf4_u003b_vf2_u003b(xy: ptr<function, vec2<f32>>, parameters: ptr<function, vec4<f32>>, offset: ptr<function, vec2<f32>>) -> f32 {
    var p_2: vec2<f32>;
    var cover: f32;
    var param_13: vec2<f32>;
    var param_14: vec2<f32>;
    var param_15: vec2<f32>;
    var threshold: f32;
    var cloud: f32;

    let _e127 = (*parameters)[0u];
    if (_e127 <= 0f) {
        return 1f;
    }
    let _e129 = (*xy);
    let _e130 = (*offset);
    let _e133 = (*parameters)[1u];
    p_2 = ((_e129 + _e130) * _e133);
    let _e135 = p_2;
    param_13 = _e135;
    let _e136 = CloudNoise_u0028_vf2_u003b((&param_13));
    let _e138 = p_2;
    param_14 = ((_e138 * 2.03f) + vec2(17.1f));
    let _e142 = CloudNoise_u0028_vf2_u003b((&param_14));
    let _e145 = p_2;
    param_15 = ((_e145 * 4.07f) + vec2(31.7f));
    let _e149 = CloudNoise_u0028_vf2_u003b((&param_15));
    cover = (((0.55f * _e136) + (0.3f * _e142)) + (0.15f * _e149));
    let _e153 = (*parameters)[2u];
    threshold = (1f - _e153);
    let _e155 = threshold;
    let _e157 = threshold;
    let _e159 = cover;
    cloud = smoothstep((_e155 - 0.12f), (_e157 + 0.12f), _e159);
    let _e162 = (*parameters)[0u];
    let _e163 = cloud;
    return (1f - (_e162 * _e163));
}

fn SunVisibility_u0028_vf3_u003b_vf3_u003b(worldPosition_1: ptr<function, vec3<f32>>, worldNormal_1: ptr<function, vec3<f32>>) -> f32 {
    var slope: f32;
    var lifted: vec3<f32>;
    var clip: vec4<f32>;
    var ndc: vec3<f32>;
    var uv: vec2<f32>;
    var turn: f32;
    var rotation: mat2x2<f32>;
    var radius_1: f32;
    var visible: f32;
    var total: f32;
    var i_1: i32;
    var offset_1: vec2<f32>;
    var indexable: array<vec2<f32>, 12>;
    var weight: f32;

    let _e134 = unnamed.sunShadowParameters[0u];
    if (_e134 <= 0f) {
        return 1f;
    }
    let _e136 = (*worldNormal_1);
    let _e138 = unnamed.sunTowards;
    slope = (1f - clamp(dot(_e136, normalize(_e138.xyz)), 0f, 1f));
    let _e144 = (*worldPosition_1);
    let _e145 = (*worldNormal_1);
    let _e146 = slope;
    let _e151 = unnamed.sunShadowParameters[3u];
    lifted = (_e144 + (_e145 * ((1.5f + (2f * _e146)) * _e151)));
    let _e155 = lifted;
    let _e161 = unnamed.sunViewProjection;
    clip = (vec4<f32>(_e155.x, _e155.y, _e155.z, 1f) * transpose(_e161));
    let _e164 = clip;
    let _e167 = clip[3u];
    ndc = (_e164.xyz / vec3(_e167));
    let _e171 = ndc[0u];
    let _e175 = ndc[1u];
    uv = vec2<f32>(((_e171 * 0.5f) + 0.5f), (0.5f - (_e175 * 0.5f)));
    let _e179 = uv;
    let _e182 = uv;
    let _e187 = ndc[2u];
    if ((any((_e179 < vec2<f32>(0f, 0f))) || any((_e182 > vec2<f32>(1f, 1f)))) || (_e187 >= 1f)) {
        return 1f;
    }
    let _e190 = (*worldPosition_1);
    turn = (6.2831855f * fract((52.982918f * fract(dot(_e190.xy, vec2<f32>(0.06711056f, 0.00583715f))))));
    let _e197 = turn;
    let _e199 = turn;
    let _e202 = turn;
    let _e204 = turn;
    rotation = mat2x2<f32>(vec2<f32>(cos(_e197), -(sin(_e199))), vec2<f32>(sin(_e202), cos(_e204)));
    let _e211 = unnamed.sunShadowParameters[2u];
    let _e214 = unnamed.sunShadowParameters[1u];
    radius_1 = ((_e211 * max(_e214, 0.25f)) * 1.5f);
    visible = 0f;
    total = 0f;
    i_1 = 0i;
    loop {
        let _e218 = i_1;
        if (_e218 < 12i) {
            let _e220 = i_1;
            indexable = array<vec2<f32>, 12>(vec2<f32>(-0.326f, -0.406f), vec2<f32>(-0.84f, -0.074f), vec2<f32>(-0.696f, 0.457f), vec2<f32>(-0.203f, 0.621f), vec2<f32>(0.962f, -0.195f), vec2<f32>(0.473f, -0.48f), vec2<f32>(0.519f, 0.767f), vec2<f32>(0.185f, -0.893f), vec2<f32>(0.507f, 0.064f), vec2<f32>(0.896f, 0.412f), vec2<f32>(-0.322f, -0.933f), vec2<f32>(-0.792f, -0.598f));
            let _e222 = indexable[_e220];
            let _e223 = rotation;
            offset_1 = (_e222 * _e223);
            let _e225 = offset_1;
            let _e226 = offset_1;
            weight = exp((-2f * dot(_e225, _e226)));
            let _e230 = weight;
            let _e231 = uv;
            let _e232 = offset_1;
            let _e233 = radius_1;
            let _e235 = (_e231 + (_e232 * _e233));
            let _e237 = ndc[2u];
            let _e240 = vec3<f32>(_e235.x, _e235.y, _e237);
            let _e243 = textureSampleCompareLevel(sunShadowMap, sunShadowSampler, _e240.xy, _e240.z);
            let _e245 = visible;
            visible = (_e245 + (_e230 * _e243));
            let _e247 = weight;
            let _e248 = total;
            total = (_e248 + _e247);
            continue;
        } else {
            break;
        }
        continuing {
            let _e250 = i_1;
            i_1 = (_e250 + 1i);
        }
    }
    let _e252 = visible;
    let _e253 = total;
    return (_e252 / _e253);
}

fn PerturbNormal_u0028_vf3_u003b_vf3_u003b_f1_u003b_vf3_u003b(normal: ptr<function, vec3<f32>>, tangent: ptr<function, vec3<f32>>, handedness: ptr<function, f32>, mapped: ptr<function, vec3<f32>>) -> vec3<f32> {
    var n: vec3<f32>;
    var param_16: vec3<f32>;
    var t: vec3<f32>;
    var param_17: vec3<f32>;
    var b_1: vec3<f32>;
    var param_18: vec3<f32>;

    let _e126 = (*normal);
    param_16 = _e126;
    let _e127 = SafeNormalize_u0028_vf3_u003b((&param_16));
    n = _e127;
    let _e128 = (*tangent);
    param_17 = _e128;
    let _e129 = SafeNormalize_u0028_vf3_u003b((&param_17));
    t = _e129;
    let _e130 = n;
    let _e131 = t;
    let _e133 = (*handedness);
    b_1 = (cross(_e130, _e131) * _e133);
    let _e135 = t;
    let _e137 = (*mapped)[0u];
    let _e139 = b_1;
    let _e141 = (*mapped)[1u];
    let _e144 = n;
    let _e146 = (*mapped)[2u];
    param_18 = (((_e135 * _e137) + (_e139 * _e141)) + (_e144 * _e146));
    let _e149 = SafeNormalize_u0028_vf3_u003b((&param_18));
    return _e149;
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf4_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf4_u002d_vf4_u002d_vf3_u002d_vf4_u002d_vf41_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    var texel: vec4<f32>;
    var uvDx: vec2<f32>;
    var uvDy: vec2<f32>;
    var shadingNormal: vec3<f32>;
    var worldNormal_2: vec3<f32>;
    var normalMapScale: f32;
    var mapped_1: vec3<f32>;
    var handedness_1: f32;
    var param_19: vec3<f32>;
    var param_20: vec3<f32>;
    var param_21: f32;
    var param_22: vec3<f32>;
    var param_23: vec3<f32>;
    var param_24: vec3<f32>;
    var param_25: f32;
    var param_26: vec3<f32>;
    var objectLight: vec3<f32>;
    var normal_1: vec3<f32>;
    var param_27: vec3<f32>;
    var view: vec3<f32>;
    var param_28: vec3<f32>;
    var light_1: vec3<f32>;
    var lightDot: f32;
    var inWorld: bool;
    var litNormal: vec3<f32>;
    var param_29: vec3<f32>;
    var sunVisible: f32;
    var param_30: vec3<f32>;
    var param_31: vec3<f32>;
    var param_32: vec2<f32>;
    var param_33: vec4<f32>;
    var param_34: vec2<f32>;
    var sunLight: f32;
    var skyShade: vec3<f32>;
    var luminosity: f32;
    var dynamicLight: vec3<f32>;
    var param_35: vec3<f32>;
    var param_36: vec3<f32>;
    var lit: vec3<f32>;
    var diffuse: vec3<f32>;
    var param_37: f32;
    var param_38: vec3<f32>;
    var param_39: f32;
    var facing: f32;
    var rim: vec3<f32>;
    var towardsSun: f32;
    var specularStrength: f32;
    var specular: vec3<f32>;
    var halfVector: vec3<f32>;
    var param_40: vec3<f32>;
    var param_41: vec3<f32>;
    var highlight: f32;
    var color_1: vec4<f32>;
    var edge: f32;
    var param_42: f32;

    let _e173 = (*input).uv;
    let _e174 = textureSample(tex, s, _e173);
    texel = _e174;
    let _e176 = (*input).uv;
    let _e177 = dpdx(_e176);
    uvDx = _e177;
    let _e179 = (*input).uv;
    let _e180 = dpdy(_e179);
    uvDy = _e180;
    let _e182 = (*input).normal;
    shadingNormal = _e182;
    let _e184 = (*input).worldNormal;
    worldNormal_2 = _e184;
    let _e187 = (*input).worldTangentAndNormalMapScale[3u];
    normalMapScale = _e187;
    let _e188 = normalMapScale;
    let _e192 = (*input).tangent[3u];
    if ((_e188 > 0f) && (_e192 != 0f)) {
        let _e196 = (*input).uv;
        let _e197 = uvDx;
        let _e198 = uvDy;
        let _e199 = textureSampleGrad(normalMap, normalSampler, _e196, _e197, _e198);
        mapped_1 = ((_e199.xyz * 2f) - vec3(1f));
        let _e204 = normalMapScale;
        let _e205 = mapped_1;
        let _e207 = (_e205.xy * _e204);
        mapped_1[0u] = _e207.x;
        mapped_1[1u] = _e207.y;
        let _e214 = (*input).tangent[3u];
        handedness_1 = select(-1f, 1f, (_e214 > 0f));
        let _e218 = (*input).normal;
        param_19 = _e218;
        let _e220 = (*input).tangent;
        param_20 = _e220.xyz;
        let _e222 = handedness_1;
        param_21 = _e222;
        let _e223 = mapped_1;
        param_22 = _e223;
        let _e224 = PerturbNormal_u0028_vf3_u003b_vf3_u003b_f1_u003b_vf3_u003b((&param_19), (&param_20), (&param_21), (&param_22));
        let _e226 = (*input).normal;
        shadingNormal = (_e224 * length(_e226));
        let _e230 = (*input).worldNormal;
        param_23 = _e230;
        let _e232 = (*input).worldTangentAndNormalMapScale;
        param_24 = _e232.xyz;
        let _e234 = handedness_1;
        param_25 = _e234;
        let _e235 = mapped_1;
        param_26 = _e235;
        let _e236 = PerturbNormal_u0028_vf3_u003b_vf3_u003b_f1_u003b_vf3_u003b((&param_23), (&param_24), (&param_25), (&param_26));
        worldNormal_2 = _e236;
    }
    let _e238 = (*input).color;
    objectLight = _e238.xyz;
    let _e240 = shadingNormal;
    param_27 = _e240;
    let _e241 = SafeNormalize_u0028_vf3_u003b((&param_27));
    normal_1 = _e241;
    let _e243 = (*input).viewVector;
    param_28 = _e243;
    let _e244 = SafeNormalize_u0028_vf3_u003b((&param_28));
    view = _e244;
    let _e246 = (*input).lightDirectionAndSpecular;
    light_1 = _e246.xyz;
    let _e248 = shadingNormal;
    let _e249 = light_1;
    lightDot = dot(_e248, _e249);
    let _e253 = (*input).worldPositionAndDynamicLights[3u];
    inWorld = (_e253 > 0.5f);
    let _e255 = worldNormal_2;
    param_29 = _e255;
    let _e256 = SafeNormalize_u0028_vf3_u003b((&param_29));
    litNormal = _e256;
    let _e257 = inWorld;
    let _e260 = unnamed.sunShadowParameters[0u];
    let _e264 = (*input).worldPositionAndDynamicLights;
    param_30 = _e264.xyz;
    let _e266 = litNormal;
    param_31 = _e266;
    let _e267 = SunVisibility_u0028_vf3_u003b_vf3_u003b((&param_30), (&param_31));
    let _e269 = (*input).worldPositionAndDynamicLights;
    param_32 = _e269.xy;
    let _e272 = unnamed.cloudParameters;
    param_33 = _e272;
    let _e274 = unnamed.cloudOffset;
    param_34 = _e274.xy;
    let _e276 = CloudLight_u0028_vf2_u003b_vf4_u003b_vf2_u003b((&param_32), (&param_33), (&param_34));
    sunVisible = select(1f, (_e267 * _e276), (_e257 && (_e260 > 0f)));
    let _e281 = unnamed.sunShadowParameters[0u];
    let _e282 = sunVisible;
    sunLight = (1f - (_e281 * (1f - _e282)));
    let _e287 = unnamed.skyFill;
    let _e291 = unnamed.skyFill[3u];
    let _e292 = sunVisible;
    skyShade = mix(vec3<f32>(1f, 1f, 1f), _e287.xyz, vec3((_e291 * (1f - _e292))));
    let _e297 = lightDot;
    let _e300 = unnamed.diffuseCurve[0u];
    let _e302 = lightDot;
    let _e304 = sunLight;
    let _e309 = unnamed.diffuseCurve[1u];
    let _e313 = unnamed.diffuseCurve[2u];
    luminosity = max((((_e297 * _e300) * select(1f, _e304, (_e302 > 0f))) + _e309), _e313);
    let _e315 = inWorld;
    let _e317 = (*input).worldPositionAndDynamicLights;
    param_35 = _e317.xyz;
    let _e319 = litNormal;
    param_36 = _e319;
    let _e320 = DynamicLighting_u0028_vf3_u003b_vf3_u003b((&param_35), (&param_36));
    dynamicLight = select(vec3<f32>(0f, 0f, 0f), _e320, vec3(_e315));
    let _e323 = objectLight;
    let _e324 = skyShade;
    let _e326 = luminosity;
    let _e328 = dynamicLight;
    lit = (((_e323 * _e324) * _e326) + _e328);
    let _e330 = lit;
    diffuse = clamp(_e330, vec3(0f), vec3(1f));
    let _e336 = unnamed.diffuseCurve[3u];
    param_37 = _e336;
    let _e337 = RollsOffHighlight_u0028_f1_u003b((&param_37));
    if _e337 {
        let _e338 = lit;
        param_38 = _e338;
        let _e341 = unnamed.diffuseCurve[3u];
        param_39 = _e341;
        let _e342 = RollOffHighlight_u0028_vf3_u003b_f1_u003b((&param_38), (&param_39));
        diffuse = _e342;
    }
    let _e343 = normal_1;
    let _e344 = view;
    facing = clamp(abs(dot(_e343, _e344)), 0f, 1f);
    let _e350 = unnamed.rimParameters[0u];
    let _e351 = facing;
    let _e355 = unnamed.rimParameters[1u];
    let _e358 = objectLight;
    rim = (_e358 * (_e350 * pow((1f - _e351), _e355)));
    let _e360 = inWorld;
    let _e363 = unnamed.sunTowards[3u];
    if (_e360 && (_e363 > 0f)) {
        let _e366 = litNormal;
        let _e368 = unnamed.sunTowards;
        let _e375 = sunVisible;
        towardsSun = (clamp(((dot(_e366, normalize(_e368.xyz)) * 0.75f) + 0.25f), 0f, 1f) * _e375);
        let _e377 = rim;
        let _e378 = rim;
        let _e380 = unnamed.sunColor;
        let _e383 = towardsSun;
        let _e388 = unnamed.sunTowards[3u];
        rim = mix(_e377, ((_e378 * _e380.xyz) * (2f * _e383)), vec3(_e388));
    }
    let _e393 = (*input).lightDirectionAndSpecular[3u];
    let _e396 = unnamed.specularParameters[0u];
    specularStrength = (_e393 * _e396);
    specular = vec3<f32>(0f, 0f, 0f);
    let _e398 = specularStrength;
    let _e400 = lightDot;
    if ((_e398 > 0f) && (_e400 > 0f)) {
        let _e403 = light_1;
        param_40 = _e403;
        let _e404 = SafeNormalize_u0028_vf3_u003b((&param_40));
        let _e405 = view;
        param_41 = (_e404 + _e405);
        let _e407 = SafeNormalize_u0028_vf3_u003b((&param_41));
        halfVector = _e407;
        let _e408 = normal_1;
        let _e409 = halfVector;
        let _e414 = unnamed.specularParameters[1u];
        highlight = pow(clamp(dot(_e408, _e409), 0f, 1f), _e414);
        let _e416 = specularStrength;
        let _e417 = highlight;
        let _e419 = sunLight;
        let _e422 = unnamed.sceneLightColor;
        let _e425 = objectLight;
        specular = ((_e422.xyz * ((_e416 * _e417) * _e419)) * _e425);
    }
    let _e427 = texel;
    let _e429 = diffuse;
    let _e431 = rim;
    let _e433 = specular;
    let _e434 = (((_e427.xyz * _e429) + _e431) + _e433);
    let _e436 = texel[3u];
    let _e439 = (*input).color[3u];
    color_1 = vec4<f32>(_e434.x, _e434.y, _e434.z, (_e436 * _e439));
    let _e446 = unnamed_2.alphaToCoverage;
    if (_e446 != 0u) {
        let _e449 = color_1[3u];
        let _e451 = unnamed_2.alphaThreshold;
        let _e454 = color_1[3u];
        let _e455 = fwidth(_e454);
        edge = clamp((((_e449 - _e451) / max(_e455, 0.0001f)) + 0.5f), 0f, 1f);
        let _e460 = edge;
        let _e462 = color_1[3u];
        color_1[3u] = (_e462 * _e460);
        let _e466 = color_1[3u];
        if (_e466 <= 0f) {
            discard;
        }
    } else {
        let _e469 = unnamed_2.alphaDiscardEnabled;
        let _e472 = color_1[3u];
        let _e474 = unnamed_2.alphaThreshold;
        if ((_e469 != 0u) && (_e472 <= _e474)) {
            discard;
        }
    }
    let _e478 = unnamed_2.fogEnabled;
    let _e482 = unnamed.sceneFogColor[3u];
    if ((_e478 != 0u) && (_e482 > 0f)) {
        let _e485 = color_1;
        let _e488 = unnamed.sceneFogColor;
        let _e491 = (*input).eyeDepth;
        param_42 = _e491;
        let _e492 = EnhancedFogAmount_u0028_f1_u003b((&param_42));
        let _e494 = mix(_e485.xyz, _e488.xyz, vec3(_e492));
        color_1[0u] = _e494.x;
        color_1[1u] = _e494.y;
        color_1[2u] = _e494.z;
    }
    let _e501 = color_1;
    return _e501;
}

fn main_1() {
    var input_1: FSInput;
    var param_43: FSInput;

    let _e118 = input_u002e_pos_1;
    input_1.pos = _e118;
    let _e120 = input_u002e_uv_1;
    input_1.uv = _e120;
    let _e122 = input_u002e_color_1;
    input_1.color = _e122;
    let _e124 = input_u002e_fogFactor_1;
    input_1.fogFactor = _e124;
    let _e126 = input_u002e_eyeDepth_1;
    input_1.eyeDepth = _e126;
    let _e128 = input_u002e_normal_1;
    input_1.normal = _e128;
    let _e130 = input_u002e_viewVector_1;
    input_1.viewVector = _e130;
    let _e132 = input_u002e_lightDirectionAndSpecular_1;
    input_1.lightDirectionAndSpecular = _e132;
    let _e134 = input_u002e_worldPositionAndDynamicLights_1;
    input_1.worldPositionAndDynamicLights = _e134;
    let _e136 = input_u002e_worldNormal_1;
    input_1.worldNormal = _e136;
    let _e138 = input_u002e_tangent_1;
    input_1.tangent = _e138;
    let _e140 = input_u002e_worldTangentAndNormalMapScale_1;
    input_1.worldTangentAndNormalMapScale = _e140;
    let _e142 = input_1;
    param_43 = _e142;
    let _e143 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf4_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_vf4_u002d_vf4_u002d_vf3_u002d_vf4_u002d_vf41_u003b((&param_43));
    u0040_entryPointOutput = _e143;
    return;
}

@fragment 
fn main(@builtin(position) input_u002e_pos: vec4<f32>, @location(0) input_u002e_uv: vec2<f32>, @location(1) input_u002e_color: vec4<f32>, @location(2) input_u002e_fogFactor: f32, @location(3) input_u002e_eyeDepth: f32, @location(4) input_u002e_normal: vec3<f32>, @location(5) input_u002e_viewVector: vec3<f32>, @location(6) @interpolate(flat, either) input_u002e_lightDirectionAndSpecular: vec4<f32>, @location(7) input_u002e_worldPositionAndDynamicLights: vec4<f32>, @location(8) input_u002e_worldNormal: vec3<f32>, @location(9) input_u002e_tangent: vec4<f32>, @location(10) input_u002e_worldTangentAndNormalMapScale: vec4<f32>) -> @location(0) vec4<f32> {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    input_u002e_color_1 = input_u002e_color;
    input_u002e_fogFactor_1 = input_u002e_fogFactor;
    input_u002e_eyeDepth_1 = input_u002e_eyeDepth;
    input_u002e_normal_1 = input_u002e_normal;
    input_u002e_viewVector_1 = input_u002e_viewVector;
    input_u002e_lightDirectionAndSpecular_1 = input_u002e_lightDirectionAndSpecular;
    input_u002e_worldPositionAndDynamicLights_1 = input_u002e_worldPositionAndDynamicLights;
    input_u002e_worldNormal_1 = input_u002e_worldNormal;
    input_u002e_tangent_1 = input_u002e_tangent;
    input_u002e_worldTangentAndNormalMapScale_1 = input_u002e_worldTangentAndNormalMapScale;
    main_1();
    let _e25 = u0040_entryPointOutput;
    return _e25;
}
