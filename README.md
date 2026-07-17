<p align="center">
  <img src="assets/cat_moon_icon_no_black_corners.png" alt="NekoPapa App Logo" width="180">
</p>

# NekoPapa

[English](README_EN.md) | 简体中文

NekoPapa 是基于 OpenNeko Engine 构建的桌面数字生命实验项目。NekoPapa 是当前产品、桌面包和 GitHub 仓库名称；OpenNeko Engine 是底层 C++ 引擎名称；NekoCore-Nano 是可选的私有 Core 接入，不是当前 Native Stage 的构建目标。

当前版本由一个 Tauri 2 主控制台、一个嵌入小屋页面的 Live2D 角色，以及一个独立运行的原生桌面 Stage 组成。

项目处于开发预览阶段。当前重点是小屋主界面、Live2D 展示和桌面 Stage 生命周期；对话、记忆、世界和 Agent 页面仍以界面原型为主，不代表对应服务已经接入。

## 当前状态

| 模块 | 状态 | 说明 |
| --- | --- | --- |
| 桌面主控制台 | 开发中 | Tauri 2 + Rust + React + TypeScript |
| 小屋 Live2D | 已接入开发模型 | Pixi.js + `pixi-live2d-display`，在 WebView 中渲染 |
| 原生桌面 Stage | v0 开发构建目标 | C++17 + GLFW + OpenGL + Cubism Native，独立透明窗口；发布运行行为仍需按门禁验证 |
| Stage 生命周期 | 已实现基础控制 | Rust host 负责启动、查询和停止 sidecar |
| C++ 引擎 | Stub 模式 | Native Stage 默认使用 `engine_stub.cpp`；`source/binary` Core 接入目前只连接到 legacy Qt 路径 |
| Stage Protocol v1 | 草案 | 已有 JSON Schema，当前运行时仍是未版本化的 v0 消息 |
| 对话、记忆、世界、Agent | 界面原型 | 尚未接入完整业务服务和持久化链路 |
| Legacy Qt 客户端 | 迁移参考 | 默认不构建，不是当前桌面入口 |

当前仓库使用 Live2D 官方示例模型桃濑日和（Momose Hiyori）进行开发验证。它不是 Lumia 的正式角色资产。

## 架构

```text
                         NekoPapa desktop

  React / TypeScript UI                         C++ Native Stage
  - 小屋与控制界面                              - 独立透明窗口
  - Cubism Web / Pixi.js                       - GLFW / OpenGL
              |                                - Cubism Native
              v                                       ^
        Tauri 2 / Rust host ---------------------------|
        - 应用与窗口生命周期
        - 权限边界
        - Stage sidecar 监督
              |
              v
        OpenNeko C++ engine
        - Native Stage 当前默认使用 Stub
        - 私有 Core 接入仍需完成边界 wiring
```

主窗口中的 Live2D 与原生桌面 Stage 是两个独立渲染面：

- WebView 内的角色使用 Cubism Web，参与正常的 DOM 布局、裁剪和交互。
- 桌面角色使用 Cubism Native，在独立顶层窗口中运行。
- Tauri 负责进程和权限，不负责 Live2D 帧渲染。
- 角色持久状态最终应由 C++ 引擎统一负责；当前 Stub 阶段不代表完整领域状态已经接入。

更多边界说明见 [桌面运行时边界](doc/architecture/desktop-runtime-boundaries.md)。

## 快速开始

### 浏览器预览要求

- Node.js 与 npm，推荐使用当前 LTS

### 桌面构建要求

- Node.js 与 npm
- Rust 1.96 或更高版本
- CMake 3.21 或更高版本
- Ninja
- 支持 C++17 的编译器
- OpenGL 开发环境
- [Tauri 2 平台依赖](https://v2.tauri.app/start/prerequisites/)

Native Stage 的开发目标是 macOS 和 Windows；Linux 源码路径存在，但仓库没有发布级跨平台验证。仓库包含 Cubism SDK 和开发模型资源，使用和再分发仍受 Live2D 许可约束。

首次配置 Native Stage 时，GLFW 3.4 会优先使用系统 CMake package，否则通过 `FetchContent` 获取固定版本；nlohmann/json 3.11.3 在 target 尚未定义时也会通过 `FetchContent` 获取。因此首次配置可能需要访问 GitHub。

### 仅启动浏览器预览

浏览器预览适合开发小屋和控制台界面，不会启动真实的原生 Stage；页面中的 Stage 状态是模拟值。

```bash
git clone https://github.com/Hisakazu333/Nekopapa.git
cd Nekopapa
npm --prefix app/control-desktop ci
npm --prefix app/control-desktop run dev
```

打开 `http://127.0.0.1:1420/`。

### 启动桌面应用

```bash
cd Nekopapa
npm --prefix app/control-desktop ci
npm --prefix app/control-desktop run tauri -- dev
```

Tauri 的开发命令会先执行 `npm run stage:prepare`：

1. 使用 CMake 和 Ninja 构建 `openneko-live2d-stage`。
2. 按 Rust target triple 复制 sidecar 到 `src-tauri/binaries/`。
3. 启动 Vite、Tauri 主窗口和真实的 Native Stage 控制链路。

### 单独构建 Native Stage

```bash
cd Nekopapa
cmake -S . -B build/stage -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DNNA_BUILD_APP=OFF \
  -DNNA_BUILD_LIVE2D_STAGE=ON \
  -DNNA_ENABLE_LIVE2D=ON

cmake --build build/stage --target openneko_live2d_stage
```

构建后可以运行一次有界健康检查：

```bash
./build/stage/bin/openneko-live2d-stage \
  --health-check \
  --model assets/live2d/hiyori/hiyori_pro_t11.model3.json
```

默认情况下：

- `NNA_BUILD_LIVE2D_STAGE=ON`
- `NNA_ENABLE_LIVE2D=ON`
- `NNA_BUILD_APP=OFF`
- `NNA_CORE_NANO_MODE=stub`

## 开发检查

```bash
cd Nekopapa
npm --prefix app/control-desktop run check
npm --prefix app/control-desktop run build

cargo fmt --manifest-path app/control-desktop/src-tauri/Cargo.toml -- --check
cargo clippy --manifest-path app/control-desktop/src-tauri/Cargo.toml --all-targets -- -D warnings
cargo test --manifest-path app/control-desktop/src-tauri/Cargo.toml
```

构建成功只代表对应目标可以编译，不代表透明窗口、真实模型、跨平台安装包或发布质量已经验证。完整验收标准见 [构建与测试门禁](doc/architecture/build-and-test-gates.md)。

## 目录

| 路径 | 用途 |
| --- | --- |
| `app/control-desktop/` | Tauri 2 主控制台、React 前端和 Rust host |
| `app/live2d-stage/` | 独立 C++ Native Stage |
| `app/stage-desktop/` | Legacy Qt 客户端，迁移期间保留 |
| `engine/` | OpenNeko C++ 库和 Live2D Native 适配层 |
| `assets/live2d/` | Cubism Web 与 Native Stage 共用的开发模型资源 |
| `protocol/stage/v1/` | Stage JSONL v1 草案与示例 |
| `doc/architecture/` | 桌面架构、迁移计划和验证门禁 |

## 已知限制

- 浏览器预览不会启动真实的原生 Stage。
- 当前嵌入模型与桌面模型使用桃濑日和示例资产，不是正式 Lumia 模型。
- 对话、记忆、天气、同步、世界和 Agent 尚未形成完整业务闭环。
- Stage 当前消息格式仍是 v0，不能宣称已经兼容 `protocol/stage/v1/`。
- Native Stage 默认使用 Stub；私有 Core 接入目前仍限定在 legacy Qt 构建路径。
- Legacy Qt 构建脚本不是当前推荐入口。
- macOS/Windows 安装包、签名、公证和跨平台 CI 尚未达到发布验证级别。

## 文档

- [桌面架构说明](doc/architecture/README.md)
- [桌面运行时边界](doc/architecture/desktop-runtime-boundaries.md)
- [Qt 到 Tauri 迁移计划](doc/architecture/qt-to-tauri-migration.md)
- [构建与测试门禁](doc/architecture/build-and-test-gates.md)
- [Stage Protocol v1 草案](protocol/stage/v1/README.md)
- [数字生命愿景书](doc/OpenNeko%20Engine%20—%20数字生命愿景书.md)
- [世界观与角色设定](doc/OpenNeko%20Engine%20—%20世界观与猫娘人设集.md)

## 许可证

仓库自有代码采用 [Apache License 2.0](LICENSE)。

Live2D Cubism SDK、Cubism Core 和桃濑日和示例模型不只受 Apache-2.0 约束，使用和再分发必须同时遵守 Live2D 的相关许可及模型条款。详细说明见 [Live2D 资源说明](assets/live2d/README.md) 和仓库内的 Cubism SDK 许可文件。
