struct FSInput {
    pos: vec4<f32>,
    uv: vec2<f32>,
    color: vec4<f32>,
    fogFactor: f32,
    eyeDepth: f32,
    worldPosition: vec3<f32>,
    darkening: vec3<f32>,
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
var groundShadowMask: texture_2d<f32>;
@group(2) @binding(3) 
var groundShadowSampler: sampler;
@group(2) @binding(6) 
var terrainSunLight: texture_2d<f32>;
@group(2) @binding(7) 
var terrainSunSampler: sampler;
@group(3) @binding(0) 
var<uniform> unnamed_2: FogUniforms;
var<private> input_u002e_pos_1: vec4<f32>;
var<private> input_u002e_uv_1: vec2<f32>;
var<private> input_u002e_color_1: vec4<f32>;
var<private> input_u002e_fogFactor_1: f32;
var<private> input_u002e_eyeDepth_1: f32;
var<private> input_u002e_worldPosition_1: vec3<f32>;
var<private> input_u002e_darkening_1: vec3<f32>;
var<private> u0040_entryPointOutput: vec4<f32>;

fn EnhancedFogAmount_u0028_f1_u003b(eyeDepth: ptr<function, f32>) -> f32 {
    var scaledDistance: f32;

    let _e113 = (*eyeDepth);
    let _e116 = unnamed.sceneFogParameters[0u];
    let _e121 = unnamed.sceneFogParameters[2u];
    scaledDistance = (max((_e113 - _e116), 0f) * _e121);
    let _e123 = scaledDistance;
    let _e125 = scaledDistance;
    return clamp((1f - exp((-(_e123) * _e125))), 0f, 1f);
}

fn PointLightFalloff_u0028_vf3_u003b_f1_u003b(toLight: ptr<function, vec3<f32>>, radius: ptr<function, f32>) -> f32 {
    var horizontal: f32;

    let _e114 = (*toLight);
    horizontal = length(_e114.xy);
    let _e117 = horizontal;
    let _e118 = (*radius);
    let _e120 = (*radius);
    let _e121 = horizontal;
    let _e123 = (*radius);
    return select(0f, ((_e120 - _e121) / _e123), (_e117 < _e118));
}

fn WorldDynamicLighting_u0028_vf3_u003b(worldPosition: ptr<function, vec3<f32>>) -> vec3<f32> {
    var light: vec3<f32>;
    var count: u32;
    var i: u32;
    var positionAndRadius: vec4<f32>;
    var param: vec3<f32>;
    var param_1: f32;

    light = vec3<f32>(0f, 0f, 0f);
    let _e119 = unnamed_1.dynamicWorldLightCount;
    let _e121 = unnamed_1.dynamicLightCount;
    count = min(min(_e119, _e121), 32u);
    i = 0u;
    loop {
        let _e124 = i;
        let _e125 = count;
        if (_e124 < _e125) {
            let _e127 = i;
            let _e130 = unnamed_1.dynamicLightPositionAndRadius[_e127];
            positionAndRadius = _e130;
            let _e131 = i;
            let _e134 = unnamed_1.dynamicLightColor[_e131];
            let _e136 = positionAndRadius;
            let _e138 = (*worldPosition);
            param = (_e136.xyz - _e138);
            let _e141 = positionAndRadius[3u];
            param_1 = _e141;
            let _e142 = PointLightFalloff_u0028_vf3_u003b_f1_u003b((&param), (&param_1));
            let _e144 = light;
            light = (_e144 + (_e134.xyz * _e142));
            continue;
        } else {
            break;
        }
        continuing {
            let _e146 = i;
            i = (_e146 + bitcast<u32>(1i));
        }
    }
    let _e149 = light;
    return _e149;
}

fn CloudHash_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    let _e112 = (*p);
    return fract((sin(dot(_e112, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn CloudNoise_u0028_vf2_u003b(p_1: ptr<function, vec2<f32>>) -> f32 {
    var cell: vec2<f32>;
    var f: vec2<f32>;
    var u: vec2<f32>;
    var a: f32;
    var param_2: vec2<f32>;
    var b: f32;
    var param_3: vec2<f32>;
    var c: f32;
    var param_4: vec2<f32>;
    var d: f32;
    var param_5: vec2<f32>;

    let _e123 = (*p_1);
    cell = floor(_e123);
    let _e125 = (*p_1);
    f = fract(_e125);
    let _e127 = f;
    let _e128 = f;
    let _e130 = f;
    u = ((_e127 * _e128) * (vec2(3f) - (_e130 * 2f)));
    let _e135 = cell;
    param_2 = _e135;
    let _e136 = CloudHash_u0028_vf2_u003b((&param_2));
    a = _e136;
    let _e137 = cell;
    param_3 = (_e137 + vec2<f32>(1f, 0f));
    let _e139 = CloudHash_u0028_vf2_u003b((&param_3));
    b = _e139;
    let _e140 = cell;
    param_4 = (_e140 + vec2<f32>(0f, 1f));
    let _e142 = CloudHash_u0028_vf2_u003b((&param_4));
    c = _e142;
    let _e143 = cell;
    param_5 = (_e143 + vec2<f32>(1f, 1f));
    let _e145 = CloudHash_u0028_vf2_u003b((&param_5));
    d = _e145;
    let _e146 = a;
    let _e147 = b;
    let _e149 = u[0u];
    let _e151 = c;
    let _e152 = d;
    let _e154 = u[0u];
    let _e157 = u[1u];
    return mix(mix(_e146, _e147, _e149), mix(_e151, _e152, _e154), _e157);
}

fn CloudLight_u0028_vf2_u003b_vf4_u003b_vf2_u003b(xy: ptr<function, vec2<f32>>, parameters: ptr<function, vec4<f32>>, offset: ptr<function, vec2<f32>>) -> f32 {
    var p_2: vec2<f32>;
    var cover: f32;
    var param_6: vec2<f32>;
    var param_7: vec2<f32>;
    var param_8: vec2<f32>;
    var threshold: f32;
    var cloud: f32;

    let _e122 = (*parameters)[0u];
    if (_e122 <= 0f) {
        return 1f;
    }
    let _e124 = (*xy);
    let _e125 = (*offset);
    let _e128 = (*parameters)[1u];
    p_2 = ((_e124 + _e125) * _e128);
    let _e130 = p_2;
    param_6 = _e130;
    let _e131 = CloudNoise_u0028_vf2_u003b((&param_6));
    let _e133 = p_2;
    param_7 = ((_e133 * 2.03f) + vec2(17.1f));
    let _e137 = CloudNoise_u0028_vf2_u003b((&param_7));
    let _e140 = p_2;
    param_8 = ((_e140 * 4.07f) + vec2(31.7f));
    let _e144 = CloudNoise_u0028_vf2_u003b((&param_8));
    cover = (((0.55f * _e131) + (0.3f * _e137)) + (0.15f * _e144));
    let _e148 = (*parameters)[2u];
    threshold = (1f - _e148);
    let _e150 = threshold;
    let _e152 = threshold;
    let _e154 = cover;
    cloud = smoothstep((_e150 - 0.12f), (_e152 + 0.12f), _e154);
    let _e157 = (*parameters)[0u];
    let _e158 = cloud;
    return (1f - (_e157 * _e158));
}

fn SunVisibility_u0028_vf3_u003b_vf3_u003b(worldPosition_1: ptr<function, vec3<f32>>, worldNormal: ptr<function, vec3<f32>>) -> f32 {
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

    let _e129 = unnamed.sunShadowParameters[0u];
    if (_e129 <= 0f) {
        return 1f;
    }
    let _e131 = (*worldNormal);
    let _e133 = unnamed.sunTowards;
    slope = (1f - clamp(dot(_e131, normalize(_e133.xyz)), 0f, 1f));
    let _e139 = (*worldPosition_1);
    let _e140 = (*worldNormal);
    let _e141 = slope;
    let _e146 = unnamed.sunShadowParameters[3u];
    lifted = (_e139 + (_e140 * ((1.5f + (2f * _e141)) * _e146)));
    let _e150 = lifted;
    let _e156 = unnamed.sunViewProjection;
    clip = (vec4<f32>(_e150.x, _e150.y, _e150.z, 1f) * transpose(_e156));
    let _e159 = clip;
    let _e162 = clip[3u];
    ndc = (_e159.xyz / vec3(_e162));
    let _e166 = ndc[0u];
    let _e170 = ndc[1u];
    uv = vec2<f32>(((_e166 * 0.5f) + 0.5f), (0.5f - (_e170 * 0.5f)));
    let _e174 = uv;
    let _e177 = uv;
    let _e182 = ndc[2u];
    if ((any((_e174 < vec2<f32>(0f, 0f))) || any((_e177 > vec2<f32>(1f, 1f)))) || (_e182 >= 1f)) {
        return 1f;
    }
    let _e185 = (*worldPosition_1);
    turn = (6.2831855f * fract((52.982918f * fract(dot(_e185.xy, vec2<f32>(0.06711056f, 0.00583715f))))));
    let _e192 = turn;
    let _e194 = turn;
    let _e197 = turn;
    let _e199 = turn;
    rotation = mat2x2<f32>(vec2<f32>(cos(_e192), -(sin(_e194))), vec2<f32>(sin(_e197), cos(_e199)));
    let _e206 = unnamed.sunShadowParameters[2u];
    let _e209 = unnamed.sunShadowParameters[1u];
    radius_1 = ((_e206 * max(_e209, 0.25f)) * 1.5f);
    visible = 0f;
    total = 0f;
    i_1 = 0i;
    loop {
        let _e213 = i_1;
        if (_e213 < 12i) {
            let _e215 = i_1;
            indexable = array<vec2<f32>, 12>(vec2<f32>(-0.326f, -0.406f), vec2<f32>(-0.84f, -0.074f), vec2<f32>(-0.696f, 0.457f), vec2<f32>(-0.203f, 0.621f), vec2<f32>(0.962f, -0.195f), vec2<f32>(0.473f, -0.48f), vec2<f32>(0.519f, 0.767f), vec2<f32>(0.185f, -0.893f), vec2<f32>(0.507f, 0.064f), vec2<f32>(0.896f, 0.412f), vec2<f32>(-0.322f, -0.933f), vec2<f32>(-0.792f, -0.598f));
            let _e217 = indexable[_e215];
            let _e218 = rotation;
            offset_1 = (_e217 * _e218);
            let _e220 = offset_1;
            let _e221 = offset_1;
            weight = exp((-2f * dot(_e220, _e221)));
            let _e225 = weight;
            let _e226 = uv;
            let _e227 = offset_1;
            let _e228 = radius_1;
            let _e230 = (_e226 + (_e227 * _e228));
            let _e232 = ndc[2u];
            let _e235 = vec3<f32>(_e230.x, _e230.y, _e232);
            let _e238 = textureSampleCompareLevel(sunShadowMap, sunShadowSampler, _e235.xy, _e235.z);
            let _e240 = visible;
            visible = (_e240 + (_e225 * _e238));
            let _e242 = weight;
            let _e243 = total;
            total = (_e243 + _e242);
            continue;
        } else {
            break;
        }
        continuing {
            let _e245 = i_1;
            i_1 = (_e245 + 1i);
        }
    }
    let _e247 = visible;
    let _e248 = total;
    return (_e247 / _e248);
}

fn u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf4_u002d_f1_u002d_f1_u002d_vf3_u002d_vf31_u003b(input: ptr<function, FSInput>) -> vec4<f32> {
    var texel: vec4<f32>;
    var sizeQueryTemp: vec2<u32>;
    var maskWidth: u32;
    var maskHeight: u32;
    var visibility: vec2<f32>;
    var shadow: vec2<f32>;
    var sunShadows: bool;
    var sunVisible: f32;
    var param_9: vec3<f32>;
    var param_10: vec3<f32>;
    var cloud_1: f32;
    var param_11: vec2<f32>;
    var param_12: vec4<f32>;
    var param_13: vec2<f32>;
    var ground: vec3<f32>;
    var cellUv: vec2<f32>;
    var direct: vec3<f32>;
    var skyShade: vec3<f32>;
    var pointLight: vec3<f32>;
    var param_14: vec3<f32>;
    var light_1: vec3<f32>;
    var color: vec4<f32>;
    var edge: f32;
    var param_15: f32;

    let _e137 = (*input).uv;
    let _e138 = textureSample(tex, s, _e137);
    texel = _e138;
    let _e139 = textureDimensions(groundShadowMask, 0i);
    sizeQueryTemp = _e139;
    let _e141 = sizeQueryTemp[0u];
    maskWidth = _e141;
    let _e143 = sizeQueryTemp[1u];
    maskHeight = _e143;
    let _e145 = (*input).pos;
    let _e147 = maskWidth;
    let _e149 = maskHeight;
    let _e153 = textureSample(groundShadowMask, groundShadowSampler, (_e145.xy / vec2<f32>(f32(_e147), f32(_e149))));
    visibility = _e153.xy;
    let _e156 = unnamed_1.groundShadowOpacity;
    let _e157 = visibility;
    shadow = (vec2(1f) - ((vec2(1f) - _e157) * _e156));
    let _e165 = unnamed.sunShadowParameters[0u];
    sunShadows = (_e165 > 0f);
    let _e167 = sunShadows;
    let _e169 = (*input).worldPosition;
    param_9 = _e169;
    param_10 = vec3<f32>(0f, 0f, 1f);
    let _e170 = SunVisibility_u0028_vf3_u003b_vf3_u003b((&param_9), (&param_10));
    sunVisible = select(1f, _e170, _e167);
    let _e174 = unnamed.sunShadowParameters[0u];
    let _e175 = sunVisible;
    let _e180 = shadow[0u];
    shadow[0u] = (_e180 * (1f - (_e174 * (1f - _e175))));
    let _e183 = sunShadows;
    let _e185 = (*input).worldPosition;
    param_11 = _e185.xy;
    let _e188 = unnamed.cloudParameters;
    param_12 = _e188;
    let _e190 = unnamed.cloudOffset;
    param_13 = _e190.xy;
    let _e192 = CloudLight_u0028_vf2_u003b_vf4_u003b_vf2_u003b((&param_11), (&param_12), (&param_13));
    cloud_1 = select(1f, _e192, _e183);
    let _e195 = (*input).color;
    let _e198 = shadow[0u];
    ground = (_e195.xyz * _e198);
    let _e200 = cloud_1;
    let _e204 = unnamed.lightingParameters[1u];
    if ((_e200 < 1f) && (_e204 > 0f)) {
        let _e208 = (*input).worldPosition;
        cellUv = (((_e208.xy / vec2(100f)) + vec2(0.5f)) / vec2(256f));
        let _e216 = cellUv;
        let _e217 = textureSample(terrainSunLight, terrainSunSampler, _e216);
        direct = _e217.xyz;
        let _e219 = ground;
        let _e220 = direct;
        let _e221 = sunVisible;
        let _e223 = cloud_1;
        ground = max((_e219 - ((_e220 * _e221) * (1f - _e223))), vec3<f32>(0f, 0f, 0f));
    }
    let _e229 = unnamed.skyFill;
    let _e233 = unnamed.skyFill[3u];
    let _e234 = sunVisible;
    let _e235 = cloud_1;
    skyShade = mix(vec3<f32>(1f, 1f, 1f), _e229.xyz, vec3((_e233 * (1f - (_e234 * _e235)))));
    let _e242 = (*input).worldPosition;
    param_14 = _e242;
    let _e243 = WorldDynamicLighting_u0028_vf3_u003b((&param_14));
    let _e245 = shadow[1u];
    let _e248 = (*input).darkening;
    pointLight = max(((_e243 * _e245) + _e248), vec3<f32>(0f, 0f, 0f));
    let _e251 = ground;
    let _e252 = skyShade;
    let _e254 = pointLight;
    light_1 = clamp(((_e251 * _e252) + _e254), vec3(0f), vec3(1f));
    let _e259 = texel;
    let _e261 = light_1;
    let _e262 = (_e259.xyz * _e261);
    let _e264 = texel[3u];
    let _e267 = (*input).color[3u];
    color = vec4<f32>(_e262.x, _e262.y, _e262.z, (_e264 * _e267));
    let _e274 = unnamed_2.alphaToCoverage;
    if (_e274 != 0u) {
        let _e277 = color[3u];
        let _e279 = unnamed_2.alphaThreshold;
        let _e282 = color[3u];
        let _e283 = fwidth(_e282);
        edge = clamp((((_e277 - _e279) / max(_e283, 0.0001f)) + 0.5f), 0f, 1f);
        let _e288 = edge;
        let _e290 = color[3u];
        color[3u] = (_e290 * _e288);
        let _e294 = color[3u];
        if (_e294 <= 0f) {
            discard;
        }
    } else {
        let _e297 = unnamed_2.alphaDiscardEnabled;
        let _e300 = color[3u];
        let _e302 = unnamed_2.alphaThreshold;
        if ((_e297 != 0u) && (_e300 <= _e302)) {
            discard;
        }
    }
    let _e306 = unnamed_2.fogEnabled;
    let _e310 = unnamed.sceneFogColor[3u];
    if ((_e306 != 0u) && (_e310 > 0f)) {
        let _e313 = color;
        let _e316 = unnamed.sceneFogColor;
        let _e319 = (*input).eyeDepth;
        param_15 = _e319;
        let _e320 = EnhancedFogAmount_u0028_f1_u003b((&param_15));
        let _e322 = mix(_e313.xyz, _e316.xyz, vec3(_e320));
        color[0u] = _e322.x;
        color[1u] = _e322.y;
        color[2u] = _e322.z;
    }
    let _e329 = color;
    return _e329;
}

fn main_1() {
    var input_1: FSInput;
    var param_16: FSInput;

    let _e113 = input_u002e_pos_1;
    input_1.pos = _e113;
    let _e115 = input_u002e_uv_1;
    input_1.uv = _e115;
    let _e117 = input_u002e_color_1;
    input_1.color = _e117;
    let _e119 = input_u002e_fogFactor_1;
    input_1.fogFactor = _e119;
    let _e121 = input_u002e_eyeDepth_1;
    input_1.eyeDepth = _e121;
    let _e123 = input_u002e_worldPosition_1;
    input_1.worldPosition = _e123;
    let _e125 = input_u002e_darkening_1;
    input_1.darkening = _e125;
    let _e127 = input_1;
    param_16 = _e127;
    let _e128 = u0040_main_u0028_struct_u002d_FSInput_u002d_vf4_u002d_vf2_u002d_vf4_u002d_f1_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_16));
    u0040_entryPointOutput = _e128;
    return;
}

@fragment 
fn main(@builtin(position) input_u002e_pos: vec4<f32>, @location(0) input_u002e_uv: vec2<f32>, @location(1) input_u002e_color: vec4<f32>, @location(2) input_u002e_fogFactor: f32, @location(3) input_u002e_eyeDepth: f32, @location(4) input_u002e_worldPosition: vec3<f32>, @location(5) input_u002e_darkening: vec3<f32>) -> @location(0) vec4<f32> {
    input_u002e_pos_1 = input_u002e_pos;
    input_u002e_uv_1 = input_u002e_uv;
    input_u002e_color_1 = input_u002e_color;
    input_u002e_fogFactor_1 = input_u002e_fogFactor;
    input_u002e_eyeDepth_1 = input_u002e_eyeDepth;
    input_u002e_worldPosition_1 = input_u002e_worldPosition;
    input_u002e_darkening_1 = input_u002e_darkening;
    main_1();
    let _e15 = u0040_entryPointOutput;
    return _e15;
}
