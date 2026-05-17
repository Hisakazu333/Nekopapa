# OpenNeko Engine — Gitee Issues 提交清单

> 最后更新: 2026-03-18
>
> 每个 Issue 可直接复制标题和正文到 https://gitee.com/Hisakazu/open-neko-engine/issues 提交。
> 标签建议写在每个 Issue 开头，提交时手动选择对应标签。

---

## ISS-001 | 缺少 nna_c_api.h 稳定 C ABI 接口

**标题:** `[P0][基础设施] 缺少 nna_c_api.h 稳定 C ABI 接口`

**标签:** `优先级: 紧急` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

engine/ 目前只有 C++ 类 `NNAEngine`，没有 `extern "C"` 导出层。

### 影响

- 无法作为闭源 .dll/.dylib 被第三方或插件系统安全调用
- ABI 随编译器/版本变化会断裂

### 期望目标

在 `engine/include/nna/c_api/nna_c_api.h` 中实现：
- opaque handle 设计
- 纯 C 函数导出，覆盖 init / tick / shutdown / getState / injectEvent 等核心操作

### 关联

- 插件系统 (#ISS-014) 和 ToolCall 安全执行引擎 (#ISS-021) 依赖此接口

---

## ISS-002 | 缺少 .clang-format / .clang-tidy 配置文件

**标题:** `[P1][基础设施] 缺少 .clang-format / .clang-tidy 配置文件`

**标签:** `优先级: 高` `类型: 新功能` `模块: 工程规范`

**正文:**

### 问题描述

开发规范手册要求 4 空格缩进 + K&R 大括号，但项目根目录没有实际配置文件来强制执行。

### 期望目标

- 根目录创建 `.clang-format`（BasedOnStyle: Google，按规范手册调整缩进等参数）
- 根目录创建 `.clang-tidy`（启用 modernize-\*、bugprone-\*、performance-\* 检查集）

### 关联

- CI/CD (#ISS-003) 依赖此配置运行静态分析

---

## ISS-003 | 缺少 CI/CD Pipeline

**标题:** `[P1][基础设施] 缺少 CI/CD Pipeline`

**标签:** `优先级: 高` `类型: 新功能` `模块: 工程规范`

**正文:**

### 问题描述

项目目前没有任何自动化构建/测试流水线。

### 期望目标

配置 Gitee Go 或 GitHub Actions：
- macOS + Windows + Linux 三平台构建
- clang-tidy 静态分析
- 单元测试自动运行

### 前置依赖

- #ISS-002 (.clang-tidy 配置)

---

## ISS-004 | 缺少 Issue / PR 模板文件

**标题:** `[P2][基础设施] 缺少 Issue / PR 模板文件`

**标签:** `优先级: 中` `类型: 新功能` `模块: 工程规范`

**正文:**

### 问题描述

`doc/` 里有协作指南文档描述了模板格式，但实际的模板文件不存在。

### 期望目标

- 创建 `.gitee/ISSUE_TEMPLATE/bug_report.md`
- 创建 `.gitee/ISSUE_TEMPLATE/feature_request.md`
- 创建 `.gitee/PULL_REQUEST_TEMPLATE.md`

将文档中已有的模板格式落地为实际文件。

---

## ISS-005 | 缺少单元测试框架

**标题:** `[P2][基础设施] 缺少单元测试框架`

**标签:** `优先级: 中` `类型: 新功能` `模块: 工程规范`

**正文:**

### 问题描述

`tests/` 目录不存在，项目无任何测试代码。

### 期望目标

- 引入 GoogleTest
- 创建 `tests/CMakeLists.txt`
- 至少覆盖 engine stub 的 init / tick / getState 基本流程

### 前置依赖

- #ISS-009 (有真实 ODE 代码后才有实质性测试内容)

---

## ISS-006 | 缺少 CHANGELOG.md + 语义化版本管理

**标题:** `[P3][基础设施] 缺少 CHANGELOG.md + 语义化版本管理`

**标签:** `优先级: 低` `类型: 新功能` `模块: 工程规范`

**正文:**

### 问题描述

CMakeLists.txt 写了 `VERSION 0.1.0` 但无 CHANGELOG 文件。

### 期望目标

- 根目录创建 `CHANGELOG.md`，遵循 [Keep a Changelog](https://keepachangelog.com/) 格式
- 记录从 0.1.0 开始的变更历史

---

## ISS-007 | 缺少 CONTRIBUTING.md

**标题:** `[P3][基础设施] 缺少 CONTRIBUTING.md`

**标签:** `优先级: 低` `类型: 新功能` `模块: 工程规范`

**正文:**

### 问题描述

协作指南在 `doc/` 里，但根目录没有标准的 CONTRIBUTING.md（Gitee/GitHub 自动识别的入口）。

### 期望目标

- 根目录创建 `CONTRIBUTING.md`，引用 `doc/` 下的详细文档

---

## ISS-008 | CMake 模块化拆分

**标题:** `[P3][基础设施] CMake 模块化拆分`

**标签:** `优先级: 低` `类型: 优化` `模块: 构建系统`

**正文:**

### 问题描述

根 CMakeLists.txt 目前只有 26 行，够用但随着子系统增加会膨胀。当前 `cmake/` 目录下只有 `FindLive2D.cmake`。

### 期望目标

在 `cmake/` 目录下拆分：
- `NNAOptions.cmake` — 编译选项定义
- `NNACompilerFlags.cmake` — 编译器标志
- `NNADependencies.cmake` — 第三方依赖查找
- `NNAInstall.cmake` — 安装规则

### 备注

可等引擎子系统增多后再做，当前不急。

---

## ISS-009 | engine/ 只有 stub，无真实 ODE 内核

**标题:** `[P0][引擎核心] engine/ 只有 stub，无真实 ODE 内核`

**标签:** `优先级: 紧急` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

`engine_stub.cpp` 用 sin 波 mock 所有数值，没有真正的微分方程求解。

### 期望目标

从 NekoCore-Nano (HarmonyOS C++ 引擎) 迁入以下核心模块到 `engine/src/`，加 `nna::` 命名空间：

- `nna::core` — 7 层 ODE 生理计算 (soul_math_models)
- `nna::core` — PADState / PhysiologicalState 真实结构体（替换 types.h 中的简化版）
- `nna::core` — MetabolismConfig + chaosFactor + maxDecayMultiplier（含衰减乘数溢出修复）

### 迁移来源

`Neko-Buddy-APPWEB/NekoCore-Nano/` 中已有完整 C++ 实现。

### 注意事项

迁移时需去除 HarmonyOS NAPI 依赖，保持纯 C++ 零平台依赖。

### 关联

此 Issue 是大量下游子系统的前置依赖（双PAD、裁剪层、积分器、记忆、角色、存储、表情驱动等）。

---

## ISS-010 | 缺少双 PAD 空间融合 (dual_pad)

**标题:** `[P0][引擎核心] 缺少双 PAD 空间融合 (dual_pad)`

**标签:** `优先级: 紧急` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

types.h 只有单一 PADState {pleasure, arousal, dominance}，缺少认知-躯体双通道融合。

### 期望目标

实现认知 E_mind + 躯体 E_body 双 PAD 融合，对应设计文档 `dual_pad.h` 的规划。

### 前置依赖

- #ISS-009 (ODE 内核)

---

## ISS-011 | 缺少生理裁剪层 Φ (physio_clipper)

**标题:** `[P1][引擎核心] 缺少生理裁剪层 Φ (physio_clipper)`

**标签:** `优先级: 高` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无外部载荷裁剪机制。

### 期望目标

实现 Tanh 钳制外部载荷，防止极端输入导致 ODE 发散。

### 前置依赖

- #ISS-009 (ODE 内核)

---

## ISS-012 | 缺少混合数值积分器 (hybrid_integrator)

**标题:** `[P1][引擎核心] 缺少混合数值积分器 (hybrid_integrator)`

**标签:** `优先级: 高` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前 stub 中使用简单 sin 波模拟，无真实数值积分。

### 期望目标

实现 RKF45 自适应步长 + 辛积分器，替代 stub 中的简单 sin 波。

### 前置依赖

- #ISS-009 (ODE 内核)

---

## ISS-013 | 缺少事件总线 (events)

**标题:** `[P1][引擎核心] 缺少事件总线 (events)`

**标签:** `优先级: 高` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

`NNAEngine::injectEvent` 直接操作内部状态，无发布/订阅机制，子系统间耦合严重。

### 期望目标

实现 `nna::core::EventBus`：
- 类型安全的事件分发
- 支持引擎内部子系统间解耦通信

### 关联

行为树 (#ISS-017)、环境嗅探 (#ISS-020)、ToolCall (#ISS-021) 依赖此组件。

---

## ISS-014 | 插件系统

**标题:** `[P1][子系统] 插件系统`

**标签:** `优先级: 高` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无插件加载机制。

### 期望目标

- dlopen / LoadLibrary 动态加载 .so / .dll
- 插件通过 C API 交互

### 前置依赖

- #ISS-001 (C API)

---

## ISS-015 | 记忆系统 (memory/)

**标题:** `[P1][子系统] 记忆系统 (memory/)`

**标签:** `优先级: 高` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无记忆管理模块。

### 期望目标

- 分层记忆管理
- 情感引力场重排
- 不应期机制

### 迁移来源

NekoCore-Nano 已有 `gravity_reranker.h/.cpp` 可迁移。

### 前置依赖

- #ISS-009 (ODE 内核)

---

## ISS-016 | AI/LLM 具身内分泌计算 (ai/)

**标题:** `[P1][子系统] AI/LLM 具身内分泌计算 (ai/)`

**标签:** `优先级: 高` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无 LLM 对接层和生理变量→解码超参绑定。

### 期望目标

- ILLMProvider 抽象接口
- 生理变量→解码超参绑定（PAD → temperature / maxTokens）

### 迁移来源

NekoCore-Nano 已有 `endocrine_modulator.h/.cpp`。

### 前置依赖

- #ISS-009 (ODE 内核)
- #ISS-010 (双PAD)

---

## ISS-017 | 行为决策 (behavior/)

**标题:** `[P2][子系统] 行为决策 (behavior/)`

**标签:** `优先级: 中` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无行为决策模块。

### 期望目标

- 行为树 (BT) Selector / Sequence / Decorator
- FSM 有限状态机
- JSON / Lua 加载行为树定义

### 前置依赖

- #ISS-013 (事件总线)

---

## ISS-018 | 暗影管道 & DPO 训练 (evolution/)

**标题:** `[P2][子系统] 暗影管道 & DPO 训练 (evolution/)`

**标签:** `优先级: 中` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无暗影生成管道和 DPO 训练支持。

### 期望目标

- 暗影生成管道
- 生理沙盒推演
- JSONL DPO 持久化
- LoRA 微调代理

### 迁移来源

NekoCore-Nano 已有 `shadow_pipeline` / `physiology_sandbox` / `jsonl_dpo_storage`。

### 前置依赖

- #ISS-009 (ODE 内核)
- #ISS-016 (AI/LLM)

---

## ISS-019 | 梦境系统 (dream/)

**标题:** `[P2][子系统] 梦境系统 (dream/)`

**标签:** `优先级: 中` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

UI 有 DreamPage.qml 占位，引擎无实现。

### 期望目标

- 图游走算法梦境合成
- 潜意识层
- 异步情感打标

### 前置依赖

- #ISS-015 (记忆系统)

---

## ISS-020 | 环境嗅探 (perception/)

**标题:** `[P2][子系统] 环境嗅探 (perception/)`

**标签:** `优先级: 中` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

UI 有 PerceptionPage.qml 占位，引擎无实现。

### 期望目标

- OS 进程/状态监听
- 感觉过滤 Sigmoid 阈值
- 多模态融合

### 前置依赖

- #ISS-013 (事件总线)

---

## ISS-021 | ToolCall 安全执行引擎 (toolcall/)

**标题:** `[P2][子系统] ToolCall 安全执行引擎 (toolcall/)`

**标签:** `优先级: 中` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

UI 有 ToolCallPage.qml 占位，引擎无实现。

### 期望目标

- 工具注册表
- 指令解析器
- 本地执行器
- 安全沙盒
- HITL (Human-In-The-Loop) 审批

### 前置依赖

- #ISS-001 (C API)
- #ISS-013 (事件总线)

---

## ISS-022 | 角色系统 (character/)

**标题:** `[P2][子系统] 角色系统 (character/)`

**标签:** `优先级: 中` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

types.h 有简化的 CharacterInfo，UI 有 CharacterPage.qml，但缺少完整的角色系统。

### 期望目标

- 完整的 Soul + 外观 + 行为树 + 记忆容器
- 性格矩阵 / PAD 基线
- 成长 / 进化曲线

### 前置依赖

- #ISS-009 (ODE 内核)
- #ISS-015 (记忆系统)
- #ISS-017 (行为决策)

---

## ISS-023 | 音频/语音 (audio/)

**标题:** `[P3][子系统] 音频/语音 (audio/)`

**标签:** `优先级: 低` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无音频/语音模块。

### 期望目标

- TTS / STT 引擎抽象
- VAD (Voice Activity Detection)
- BGM 情绪联动

### 备注

需要 VITS / Whisper 等第三方库，优先级较低。

---

## ISS-024 | 同步引擎 (sync/)

**标题:** `[P3][子系统] 同步引擎 (sync/)`

**标签:** `优先级: 低` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无跨设备同步机制。

### 期望目标

- 后端中转：HTTP 客户端拉取 RUOYI ODE 快照
- 局域网直连：mDNS + WebSocket

### 备注

桌面端与手机端联动的基础。

---

## ISS-025 | 存储引擎 (storage/)

**标题:** `[P3][子系统] 存储引擎 (storage/)`

**标签:** `优先级: 低` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无本地持久化存储。

### 期望目标

- SQLite 存储
- ChaCha20 AEAD 加密持久化
- 数据迁移机制

### 前置依赖

- #ISS-009 (ODE 内核)

---

## ISS-026 | IoT 硬件联动 (iot/)

**标题:** `[P3][子系统] IoT 硬件联动 (iot/)`

**标签:** `优先级: 低` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

UI 有 IoTPage.qml 占位，引擎无实现。

### 期望目标

- 串口 / UDP / MQTT 桥接
- 情绪→硬件指令协议

---

## ISS-027 | Lua 脚本绑定 (scripting/)

**标题:** `[P3][子系统] Lua 脚本绑定 (scripting/)`

**标签:** `优先级: 低` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

CMake 有 `NNA_ENABLE_LUA` 选项但无实现代码。

### 期望目标

- Lua 运行时集成
- 热重载
- 行为树 Lua 节点

### 前置依赖

- #ISS-017 (行为决策)

---

## ISS-028 | 调试协议 (debug/)

**标题:** `[P3][子系统] 调试协议 (debug/)`

**标签:** `优先级: 低` `类型: 新功能` `模块: engine`

**正文:**

### 问题描述

当前无远程调试/遥测能力。

### 期望目标

- WebSocket 调试服务
- 遥测数据导出

---

## ISS-029 | Live2D ExpressionDriver 缺失

**标题:** `[P1][桌面端UI] Live2D ExpressionDriver 缺失`

**标签:** `优先级: 高` `类型: 新功能` `模块: app`

**正文:**

### 问题描述

Live2D 模型能渲染和显示，但没有 PAD → Live2D 参数的表情驱动。

### 期望目标

实现 `ExpressionDriver`，将引擎输出的 PAD 值映射到 Live2D 表情参数：
- ParamEyeLOpen / ParamEyeROpen
- ParamMouthForm / ParamMouthOpenY
- ParamBrowLY / ParamBrowRY
- 等

### 前置依赖

- #ISS-009 (需要真实 PAD 数据)

---

## ISS-030 | 聊天功能未接通

**标题:** `[P2][桌面端UI] 聊天功能未接通`

**标签:** `优先级: 中` `类型: 新功能` `模块: app`

**正文:**

### 问题描述

HomePage.qml 有聊天输入框 UI，但无后端 / LLM 对接。

### 期望目标

接通 LLM Provider，实现基本的 聊天 → 引擎注入 → 回复 流程。

### 前置依赖

- #ISS-016 (AI/LLM)

---

## ISS-031 | 大量子页面为占位状态

**标题:** `[P2][桌面端UI] 大量子页面为占位状态`

**标签:** `优先级: 中` `类型: 跟踪` `模块: app`

**正文:**

### 问题描述

以下页面均为 PlaceholderPage，无实质内容：
- MemoryPage
- DreamPage
- StatusPage
- ToolCallPage
- AgentPage
- EvolutionPage
- PerceptionPage
- IoTPage
- SettingsPage

### 备注

这不是一个单独的任务，而是跟随各子系统 Issue 逐步完成。随对应引擎子系统实现逐步替换为真实 UI。

---

## ISS-032 | 设置页功能

**标题:** `[P3][桌面端UI] 设置页功能`

**标签:** `优先级: 低` `类型: 新功能` `模块: app`

**正文:**

### 问题描述

SettingsPage.qml 为占位状态。

### 期望目标

- 模型选择
- 主题切换
- 引擎参数调节
- 账号登录入口

---

## ISS-033 | README.md 中的路径为 Windows 硬编码

**标题:** `[P2][Bug] README.md 中的路径为 Windows 硬编码`

**标签:** `优先级: 中` `类型: Bug` `模块: 文档`

**正文:**

### 问题描述

README.md 和 README_EN.md 中的文档链接使用了 Windows 绝对路径 `F:\open-neko-engine\doc\...`，在 macOS / Linux 和 Gitee 网页上无法点击。

### 受影响文件

- `README.md`（3 处）
- `README_EN.md`（2 处）

### 修复方案

将所有 `F:\open-neko-engine\...` 改为相对路径 `doc/...`。

---

## ISS-034 | macOS AGL.framework workaround 需要长期方案

**标题:** `[P2][技术债] macOS AGL.framework workaround 需要长期方案`

**标签:** `优先级: 中` `类型: 技术债` `模块: 构建系统`

**正文:**

### 问题描述

macOS 26.2 SDK 移除了 AGL tbd stub，当前用 CMake strip WrapOpenGL 的 AGL 链接项绕过。

### 期望目标

跟踪 Qt 上游修复（QTBUG-xxx），SDK 更新后移除 workaround。

---

## ISS-035 | engine/ 头文件目录结构与设计文档不一致

**标题:** `[P3][跟踪] engine/ 头文件目录结构与设计文档不一致`

**标签:** `优先级: 低` `类型: 跟踪` `模块: engine`

**正文:**

### 问题描述

设计文档规划了 `include/nna/` 下 20+ 子目录，实际只有 `core/` 和 `graphics/live2d/` 下的头文件 + `export.h`。

### 备注

跟踪性 Issue，随各子系统实现逐步补齐，不需要提前创建空文件。

---

## 依赖关系总览

提交 Issue 时可在描述中用 `#ISS-xxx` 互相引用。实际 Gitee Issue 编号会在创建后自动分配，届时替换为真实编号即可。

```
ISS-001 (C API) ──┬──→ ISS-014 (插件系统)
                   └──→ ISS-021 (ToolCall)

ISS-009 (ODE 内核) ──┬──→ ISS-010 (双PAD)  ──→ ISS-016 (AI/LLM)
                      ├──→ ISS-011 (裁剪层)
                      ├──→ ISS-012 (积分器)
                      ├──→ ISS-015 (记忆)    ──→ ISS-019 (梦境)
                      ├──→ ISS-022 (角色)
                      ├──→ ISS-025 (存储)
                      └──→ ISS-029 (表情驱动)

ISS-013 (事件总线) ──┬──→ ISS-017 (行为树)  ──→ ISS-027 (Lua)
                      ├──→ ISS-020 (环境嗅探)
                      └──→ ISS-021 (ToolCall)

ISS-016 (AI/LLM) ───→ ISS-018 (暗影/DPO)
                  ───→ ISS-030 (聊天接通)

ISS-002 (clang) ────→ ISS-003 (CI/CD)
```

## 建议提交顺序

1. **ISS-001** + **ISS-009** — 并行，最高优先级
2. **ISS-002** + **ISS-005** + **ISS-013** — 基础设施 + 事件总线
3. **ISS-010** ~ **ISS-012** — 双PAD / 裁剪层 / 积分器
4. **ISS-003** — CI/CD
5. **ISS-015** + **ISS-016** + **ISS-029** — 记忆 + AI/LLM + 表情驱动
6. **ISS-014** + **ISS-017** — 插件系统 + 行为树
7. 其余子系统按需推进
