# ADR 0004: WebGPU Compatibility Mode Is Not a WebGL Fallback

**Status:** Accepted

**Date:** 2026-11-03

**Follow-up:** [#2](https://github.com/pedrogmz/MuMain/issues/2) tracks the
two-client maintenance plan.

## Context

The browser client is built on SDL_GPU and WebGPU. On old GPUs and drivers,
Chrome's WebGPU blocklist or the D3D12 driver minimum can make
`requestAdapter()` return `null` even though the machine can still render
WebGL2.

WebGPU compatibility mode (Chrome/Edge 146+) is a restricted subset of WebGPU
that runs on D3D11/GLES 3.1-class hardware. It is **still WebGPU**: the browser
must expose `navigator.gpu` and return an adapter for
`requestAdapter({ featureLevel: "compatibility" })`. It is not a WebGL
renderer, and it cannot help a browser with no WebGPU adapter at all.

A spike on a compatibility adapter reached the login screen with the existing
SDL_GPU renderer after these changes:

- `@interpolate(flat)` became `@interpolate(flat, either)`.
- Vertex `clipDist` outputs moved off `@location(15)`; compatibility mode
  allows at most 15 inter-stage variables.
- Pipelines no longer request `unclippedDepth` without `DepthClipControl`.
- The device requests the adapter's storage-buffer and uniform-buffer limits
  (`maxStorageBuffersInVertexStage`, `maxUniformBufferBindingSize`, and
  `maxStorageBufferBindingSize`).

A VM with Firefox 157 and Mesa llvmpipe had WebGL2 but returned `null` for
core, compatibility, fallback and compatibility+fallback adapters. That is the
separate "no WebGPU adapter" case, not the "old driver" case. Firefox does not
implement compatibility mode, and a browser without an adapter has nothing to
request in any WebGPU mode.

The `MuMain/analysis` WebGL build cannot be reproduced: its source is not
available, its assets are incomplete and it will drift from the server protocol.
It is a reference, not a maintainable fallback.

## Decision

The web client uses a capability ladder, not a user-agent list:

1. `navigator.gpu` exists and a **core** adapter is available: run the normal
   WebGPU client.
2. Core adapter is `null`, but a **compatibility** adapter is available: run the
   same client with `window.MU_WEBGPU_COMPAT = true`. `XDL_wgpu` requests
   `WGPUFeatureLevel_Compatibility` and relaxes the core-only features.
3. No adapter at all (including `navigator.gpu` missing): redirect to a
   **separate WebGL client** when one is configured; otherwise show the
   unsupported message.

The WebGL client is a separate deployment with its own build, release and
maintenance. **Do not add a WebGL renderer to this client.** The WebGL URL is
configured with `<meta name="mu-webgl-client-url">` or
`window.MU_WEBGL_CLIENT_URL`; `?compat=1` forces compatibility mode for
diagnostics and suppresses the redirect.

## Consequences

- Compatibility mode only covers users whose browser exposes WebGPU. Users with
  no adapter need the separate WebGL client or the unsupported message.
- The compatibility path must stay inside its limits: no compute pipelines, no
  vertex-stage storage buffers on hardware with
  `maxStorageBuffersInVertexStage = 0`, a 16 KB `maxUniformBufferBindingSize`,
  no `DepthClipControl`, no clip distances and at most 15 inter-stage variables.
- The spike can request higher limits when the adapter exposes them, but the
  production path is not done until `boneRows` and `terrainWords` leave the
  vertex stage and the 32 KB uniform buffer fits the compat limit (or moves to a
  storage buffer).
- The spike edits the checked-in WGSL blobs directly because the repository has
  no checked-in WGSL generation step. A reproducible source-level path for
  compatibility-mode WGSL is a prerequisite for production.
- Core features may still be used when the device has
  `core-features-and-limits`; the compatibility path needs its own tests.
- Two clients mean two deployments, two QA matrices and protocol-compatibility
  work. The WebGL client needs an owner and must remain reproducible.
- Before investing in a WebGL renderer, record the preflight result
  (`navigator.gpu`, core adapter, compatibility adapter, user agent and WebGL
  renderer) in telemetry. If the no-WebGPU segment is small, accepting the
  unsupported message is cheaper than maintaining a second renderer.

## Considered options

- **WebGL renderer inside this client.** Rejected: it is a second renderer,
  a second shader language, a second RmlUi backend and permanent dual
  maintenance.
- **Reuse the `analysis` WebGL build.** Rejected: it cannot be rebuilt, its
  provenance and assets are incomplete, and it will diverge from the server.
- **Compatibility mode only, no WebGL client.** Acceptable when the no-WebGPU
  segment is small; the preflight shows the unsupported message.
- **Separate WebGL deployment.** Chosen for the no-WebGPU segment; the
  capability ladder keeps it out of the WebGPU client.

## References

- [Compatibility-mode spike and measurements](../../../openmu-browser-stack/docs/webgpu-compat-spike.md)
- [Capability probe](../../../openmu-browser-stack/public/compat-probe.html)
- [WebGPU backend switching](../../src/dependencies/XDL_wgpu/src/SDL_gpu_webgpu.c)
- [Web preflight and redirect](../../../openmu-browser-stack/public/index.html)
