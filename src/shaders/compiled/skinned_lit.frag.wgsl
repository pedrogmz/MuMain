struct FogUniforms {
    fogEnabled: u32,
    alphaDiscardEnabled: u32,
    alphaThreshold: f32,
    alphaToCoverage: u32,
    fogStart: f32,
    fogEnd: f32,
    fogPad: vec2<f32>,
    fogColor: vec4<f32>,
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
}

const MaxDynamicLights: u32 = 32u;
struct DynamicLights {
    dynamicLightCount: u32,
    dynamicLightWrap: f32,
    dynamicLightPadding: vec2<u32>,
    dynamicLightPositionAndRadius: array<vec4<f32>, 32>,
    dynamicLightColor: array<vec4<f32>, 32>,
}

@group(2) @binding(0) var tex: texture_2d<f32>;
@group(2) @binding(1) var s: sampler;
@group(3) @binding(0) var<uniform> fogUniforms: FogUniforms;
@group(3) @binding(1) var<uniform> sceneLighting: SceneLighting;
@group(3) @binding(2) var<uniform> dynamicLights: DynamicLights;

struct FSInput {
    @builtin(position) pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) fogFactor: f32,
    @location(3) eyeDepth: f32,
    @location(4) normal: vec3<f32>,
    @location(5) viewVector: vec3<f32>,
    @location(6) @interpolate(flat) lightDirectionAndSpecular: vec4<f32>,
    @location(7) worldPositionAndDynamicLights: vec4<f32>,
    @location(8) worldNormal: vec3<f32>,
}

fn rollsOffHighlight(knee: f32) -> bool {
    return knee > 0.0 && knee < 1.0;
}

fn rollOffChannel(value: f32, knee: f32) -> f32 {
    let range = 1.0 - knee;
    return select(value, knee + range * (1.0 - exp(-max(value - knee, 0.0) / range)), value > knee);
}

fn rollOffHighlight(color: vec3<f32>, knee: f32) -> vec3<f32> {
    return clamp(vec3<f32>(rollOffChannel(color.r, knee), rollOffChannel(color.g, knee), rollOffChannel(color.b, knee)), vec3<f32>(0.0), vec3<f32>(1.0));
}

fn safeNormalize(value: vec3<f32>) -> vec3<f32> {
    let lengthSquared = dot(value, value);
    return select(vec3<f32>(0.0), value * inverseSqrt(lengthSquared), lengthSquared > 1e-12);
}

fn enhancedFogAmount(eyeDepth: f32) -> f32 {
    let scaledDistance = max(eyeDepth - sceneLighting.sceneFogParameters.x, 0.0) * sceneLighting.sceneFogParameters.z;
    return clamp(1.0 - exp(-(scaledDistance * scaledDistance)), 0.0, 1.0);
}

fn dynamicLighting(worldPosition: vec3<f32>, worldNormal: vec3<f32>) -> vec3<f32> {
    var light = vec3<f32>(0.0);
    let count = min(dynamicLights.dynamicLightCount, MaxDynamicLights);
    for (var i: u32 = 0u; i < count; i = i + 1u) {
        let positionAndRadius = dynamicLights.dynamicLightPositionAndRadius[i];
        let toLight = positionAndRadius.xyz - worldPosition;
        let radius = positionAndRadius.w;
        let horizontalDistance = length(toLight.xy);
        if (horizontalDistance >= radius) {
            continue;
        }
        let falloff = (radius - horizontalDistance) / radius;
        let wrapped = clamp(dot(worldNormal, safeNormalize(toLight)) * (1.0 - dynamicLights.dynamicLightWrap) + dynamicLights.dynamicLightWrap, 0.0, 1.0);
        light += dynamicLights.dynamicLightColor[i].rgb * (falloff * wrapped);
    }
    return light;
}

@fragment
fn main(input: FSInput) -> @location(0) vec4<f32> {
    let objectLight = input.color.rgb;
    let normal = safeNormalize(input.normal);
    let view = safeNormalize(input.viewVector);
    let light = input.lightDirectionAndSpecular.xyz;
    let lightDot = dot(input.normal, light);

    let luminosity = max(lightDot * sceneLighting.diffuseCurve.x + sceneLighting.diffuseCurve.y, sceneLighting.diffuseCurve.z);
    let dynamicLight = select(vec3<f32>(0.0), dynamicLighting(input.worldPositionAndDynamicLights.xyz, safeNormalize(input.worldNormal)), input.worldPositionAndDynamicLights.w > 0.5);
    var diffuse = clamp(objectLight * luminosity + dynamicLight, vec3<f32>(0.0), vec3<f32>(1.0));
    if (rollsOffHighlight(sceneLighting.diffuseCurve.w)) {
        diffuse = rollOffHighlight(objectLight * luminosity + dynamicLight, sceneLighting.diffuseCurve.w);
    }

    let facing = clamp(abs(dot(normal, view)), 0.0, 1.0);
    let rim = sceneLighting.rimParameters.x * pow(1.0 - facing, sceneLighting.rimParameters.y) * objectLight;

    let specularStrength = input.lightDirectionAndSpecular.w * sceneLighting.specularParameters.x;
    var specular = vec3<f32>(0.0);
    if (specularStrength > 0.0 && lightDot > 0.0) {
        let halfVector = safeNormalize(safeNormalize(light) + view);
        let highlight = pow(clamp(dot(normal, halfVector), 0.0, 1.0), sceneLighting.specularParameters.y);
        specular = specularStrength * highlight * sceneLighting.sceneLightColor.rgb * objectLight;
    }

    let texel = textureSample(tex, s, input.uv);
    var color = vec4<f32>(texel.rgb * diffuse + rim + specular, texel.a * input.color.a);
    if (fogUniforms.alphaToCoverage != 0u) {
        let edge = clamp((color.a - fogUniforms.alphaThreshold) / max(fwidth(color.a), 0.0001) + 0.5, 0.0, 1.0);
        color.a *= edge;
        if (color.a <= 0.0) {
            discard;
        }
    } else if (fogUniforms.alphaDiscardEnabled != 0u && color.a <= fogUniforms.alphaThreshold) {
        discard;
    }
    if (fogUniforms.fogEnabled != 0u && sceneLighting.sceneFogColor.w > 0.0) {
        color = vec4<f32>(mix(color.rgb, sceneLighting.sceneFogColor.rgb, enhancedFogAmount(input.eyeDepth)), color.a);
    }
    return color;
}
