<p align="center">
  <img src="assets/cat_moon_icon_no_black_corners.png" alt="NekoPapa App Logo" width="180">
</p>

# NekoPapa

[简体中文](README.md) | English

NekoPapa is a desktop digital-life experiment built on OpenNeko Engine. NekoPapa is the current product, desktop package, and GitHub repository name; OpenNeko Engine is the underlying C++ engine name; NekoCore-Nano is an optional private Core integration, not the current Native Stage build target.

The current version combines a Tauri 2 control console, an embedded Live2D character in the cabin view, and a separate native desktop Stage.

The project is a development preview. Current work is focused on the cabin home screen, Live2D presentation, and Native Stage lifecycle. Conversation, memory, world, and Agent screens are still primarily UI prototypes and do not imply that their backing services are complete.

## Current Status

| Component | Status | Notes |
| --- | --- | --- |
| Desktop control console | In development | Tauri 2 + Rust + React + TypeScript |
| Embedded cabin Live2D | Development model integrated | Rendered in the WebView with Pixi.js and `pixi-live2d-display` |
| Native desktop Stage | v0 development build target | C++17 + GLFW + OpenGL + Cubism Native in a separate transparent window; release runtime behavior still requires gate verification |
| Stage lifecycle | Basic control implemented | The Rust host starts, queries, and stops the sidecar |
| C++ engine | Stub mode | Native Stage uses `engine_stub.cpp` by default; `source`/`binary` Core modes are currently wired only to the legacy Qt path |
| Stage Protocol v1 | Draft | JSON Schemas exist, while the runtime still uses unversioned v0 messages |
| Conversation, memory, world, Agent | UI prototypes | Complete services and persistence flows are not connected |
| Legacy Qt client | Migration reference | Disabled by default and not the current desktop entry point |

The repository currently uses the official Momose Hiyori Live2D sample model for development. It is not the final Lumia character asset.

## Architecture

```text
                         NekoPapa desktop

  React / TypeScript UI                         C++ Native Stage
  - cabin and control UI                        - separate transparent window
  - Cubism Web / Pixi.js                       - GLFW / OpenGL
              |                                - Cubism Native
              v                                       ^
        Tauri 2 / Rust host ---------------------------|
        - application and window lifecycle
        - capability boundary
        - Stage sidecar supervision
              |
              v
        OpenNeko C++ engine
        - Native Stage uses Stub by default
        - private Core integration still needs boundary wiring
```

The embedded Live2D character and the native desktop Stage are separate rendering surfaces:

- The WebView character uses Cubism Web and participates in normal DOM layout, clipping, and input.
- The desktop character uses Cubism Native in a separate top-level window.
- Tauri owns process lifecycle and permissions, not Live2D frame rendering.
- Persistent companion state is intended to be owned by the C++ engine. During the Stub phase, the full domain state is not connected yet.

See [Desktop Runtime Boundaries](doc/architecture/desktop-runtime-boundaries.md) for the complete ownership rules.

## Quick Start

### Browser preview prerequisites

- Node.js and npm; the current LTS release is recommended

### Desktop build prerequisites

- Node.js and npm
- Rust 1.96 or newer
- CMake 3.21 or newer
- Ninja
- A C++17 toolchain
- OpenGL development support
- [Tauri 2 platform prerequisites](https://v2.tauri.app/start/prerequisites/)

Native Stage development targets macOS and Windows. A Linux source path exists, but this repository does not provide release-level cross-platform verification. The repository includes Cubism SDK and development model resources; their use and redistribution remain subject to Live2D license terms.

During the first Native Stage configuration, CMake uses a system GLFW 3.4 package when available and otherwise fetches a pinned version through `FetchContent`. It also fetches nlohmann/json 3.11.3 through `FetchContent` when that target has not already been defined. The first configure may therefore need GitHub access.

### Browser-only preview

The browser preview is intended for cabin and control-console development. It does not launch the real Native Stage; Stage status shown in this mode is simulated.

```bash
git clone https://github.com/Hisakazu333/Nekopapa.git
cd Nekopapa
npm --prefix app/control-desktop ci
npm --prefix app/control-desktop run dev
```

Open `http://127.0.0.1:1420/`.

### Desktop application

```bash
cd Nekopapa
npm --prefix app/control-desktop ci
npm --prefix app/control-desktop run tauri -- dev
```

The Tauri development command runs `npm run stage:prepare` first:

1. Build `openneko-live2d-stage` with CMake and Ninja.
2. Copy the sidecar for the active Rust target triple into `src-tauri/binaries/`.
3. Start Vite, the Tauri main window, and the real Native Stage control path.

### Build Native Stage separately

```bash
cd Nekopapa
cmake -S . -B build/stage -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DNNA_BUILD_APP=OFF \
  -DNNA_BUILD_LIVE2D_STAGE=ON \
  -DNNA_ENABLE_LIVE2D=ON

cmake --build build/stage --target openneko_live2d_stage
```

After building, run a bounded health check:

```bash
./build/stage/bin/openneko-live2d-stage \
  --health-check \
  --model assets/live2d/hiyori/hiyori_pro_t11.model3.json
```

The default root CMake options are:

- `NNA_BUILD_LIVE2D_STAGE=ON`
- `NNA_ENABLE_LIVE2D=ON`
- `NNA_BUILD_APP=OFF`
- `NNA_CORE_NANO_MODE=stub`

## Development Checks

```bash
cd Nekopapa
npm --prefix app/control-desktop run check
npm --prefix app/control-desktop run build

cargo fmt --manifest-path app/control-desktop/src-tauri/Cargo.toml -- --check
cargo clippy --manifest-path app/control-desktop/src-tauri/Cargo.toml --all-targets -- -D warnings
cargo test --manifest-path app/control-desktop/src-tauri/Cargo.toml
```

A successful build only proves that the named target compiles. It does not verify transparent-window behavior, a real model, cross-platform installers, or release readiness. See [Desktop Build and Test Gates](doc/architecture/build-and-test-gates.md) for the acceptance levels.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `app/control-desktop/` | Tauri 2 control console, React frontend, and Rust host |
| `app/live2d-stage/` | Independent C++ Native Stage |
| `app/stage-desktop/` | Legacy Qt client retained during migration |
| `engine/` | OpenNeko C++ library and Cubism Native adapter |
| `assets/live2d/` | Development model assets shared by Cubism Web and the Native Stage |
| `protocol/stage/v1/` | Draft Stage JSONL v1 contract and examples |
| `doc/architecture/` | Desktop architecture, migration plan, and verification gates |

## Known Limitations

- Browser preview does not launch the real Native Stage.
- The embedded and desktop models currently use the Momose Hiyori sample assets, not the final Lumia model.
- Conversation, memory, weather, sync, world, and Agent features are not complete end-to-end product flows.
- Stage runtime messages are still v0 and must not be described as compliant with `protocol/stage/v1/`.
- Native Stage uses Stub by default; `source`/`binary` Core modes are currently wired only to the legacy Qt path.
- Legacy Qt build scripts are not the recommended entry point.
- macOS/Windows installers, signing, notarization, and cross-platform CI have not reached release-verified status.

## Documentation

- [Desktop Architecture Notes](doc/architecture/README.md)
- [Desktop Runtime Boundaries](doc/architecture/desktop-runtime-boundaries.md)
- [Qt to Tauri Migration Plan](doc/architecture/qt-to-tauri-migration.md)
- [Desktop Build and Test Gates](doc/architecture/build-and-test-gates.md)
- [Stage Protocol v1 Draft](protocol/stage/v1/README.md)
- [Digital Life Vision](doc/OpenNeko%20Engine%20—%20数字生命愿景书.md)
- [World and Character Guide](doc/OpenNeko%20Engine%20—%20世界观与猫娘人设集.md)

## License

Repository-owned code is licensed under the [Apache License 2.0](LICENSE).

The Live2D Cubism SDK, Cubism Core, and Momose Hiyori sample model are not covered solely by Apache-2.0. Use and redistribution must also comply with the applicable Live2D licenses and model terms. See [Live2D Assets](assets/live2d/README.md) and the Cubism SDK license files included in this repository.
