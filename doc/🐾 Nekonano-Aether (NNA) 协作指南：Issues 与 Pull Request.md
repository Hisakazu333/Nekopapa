# 🐾 Nekonano-Aether (NNA) 协作指南：Issues 与 Pull Request

欢迎为 **NNA Core (OpenNeko Engine)** 贡献代码！作为底层的数字生命引擎，我们对代码的健壮性与架构的纯净度有着极高的要求。

为了保证所有开发者（无论是核心团队成员还是开源贡献者）的协作顺畅，请严格按照以下流程提交你的想法与代码。

------

## 🐞 第一部分：如何提交 Issue (提出问题与需求)

**在动手写代码之前，请务必先提交一个 Issue。** 无论是发现了系统的 Bug，还是有了一个绝妙的新功能想法（比如接入某种特定的 IoT 硬件），先建立 Issue 能够让团队提前讨论，避免你白写代码。

### 1. 提交 Bug 报告 (Bug Report)

当你发现引擎崩溃、情绪计算数值异常，或是 UI 渲染黑屏时，请在提交 Issue 时包含以下信息：

Markdown

```
### 🐛 Bug 描述
请简明扼要地描述你遇到的问题。例如：“当连续注入 10 次高强度物理抚摸事件时，引擎的饥饿值下降速度异常，未能在 8 小时内收敛。”

### 💻 环境信息
- **操作系统:** Win11 23H2 / macOS 14.0 / Ubuntu 22.04
- **Qt 版本:** 6.5.3
- **编译器:** MSVC 2022 / Clang 15 / GCC 11
- **分支/Commit Hash:** dev 分支 (commit: a1b2c3d)

### 👣 复现步骤
1. 初始化 NekoEngine 实例。
2. 调用 `soul->InjectEvent()` 传入特定的 Payload。
3. 观察 `GetCurrentState()` 的返回值。

### 📄 期望行为与实际行为
- **期望:** 愉悦度上升，饥饿值平缓下降。
- **实际:** 饥饿值瞬间归零导致引擎抛出异常。
```

### 2. 提交新功能建议 (Feature Request)

对于重大重构或新功能，请使用以下格式：

Markdown

```
### 💡 痛点与需求描述
当前的架构缺少了什么？比如：“目前的跨端 UI 桥接层（nna::ui）缺少对移动端陀螺仪数据的直接捕获。”

### 🛠️ 建议的解决方案
你打算怎么实现？“建议在 nna::ui 中新增一个 `NNASensorBridge` 类，通过 QSensors 读取数据并打包为 UniversalPayload 注入引擎。”

### ⚙️ 替代方案
有没有其他妥协的办法？
```

------

## 🚀 第二部分：如何提交 Pull Request (提交代码)

这是代码合入主干的唯一途径。**严禁任何人直接向 `main` 或 `dev` 分支推送代码。**

### 🚶‍♂️ 完整提交流程 (Step-by-Step)

#### Step 1: 同步最新代码 (极其重要)

在开始写代码前，确保你的本地代码是最新的，防止冲突：

Bash

```
git checkout dev
git pull origin dev
```

#### Step 2: 创建特性分支

遵循我们在《开发规范手册》中的约定，从 `dev` 分支切出一个新的工作分支：

Bash

```
# 格式: feature/nna-<功能名>-<你的名字>
git checkout -b feature/nna-rbf-routing-zj
```

#### Step 3: 编写代码并格式化

完成你的惊艳代码后，**在 Commit 之前，必须执行格式化！**

- 运行项目根目录的 `.clang-format` 确保 C++ 代码风格一致。
- 确保没有任何 `build/` 或 `.user` 文件被包含进来。

#### Step 4: 规范化 Commit

Bash

```
git add .
git commit -m "feat: 新增 nna::emotion 模块的 RBF 权重重排逻辑"
```

#### Step 5: 推送并创建 PR

将你的分支推送到 GitHub：

Bash

```
git push origin feature/nna-rbf-routing-zj
```

然后前往 GitHub 仓库页面，点击 **"Compare & pull request"**。**注意：PR 的目标分支必须是 `dev`，绝对不能是 `main`。**

------

### 📝 PR 描述模板 (Pull Request Template)

在 GitHub 上填写 PR 描述时，请务必复制并填好以下模板，这将极大加速 Code Review 的进度：

Markdown

```
### 🔗 关联的 Issue
Closes # (填写你的 Issue 编号，例如 Closes #12)

### 📝 本次 PR 的主要改动
- 新增了 `NNA_PhysiologySolver` 类的多线程计算支持。
- 重构了 QML 端的 `NNAAvatarCanvas.qml`，将状态刷新与渲染解耦。
- 修复了极端输入下的除零异常。

### 🧪 测试覆盖情况
- [ ] 已在 Windows (MSVC) 下编译并运行测试通过。
- [ ] 已在 macOS/Linux 下编译通过（如涉及跨平台）。
- [ ] 连续运行 4 小时以上，内存无泄漏，情绪收敛正常。

### ✅ 提交前自查清单 (Checklist)
请仔细核对，并在方括号内打叉 `[x]`：
- [ ] 我的代码完全遵循了 `nna` 命名空间与 `NNA_` 前缀规范。
- [ ] 我已经运行过 `.clang-format` 格式化了所有 C++ 代码。
- [ ] 我没有在 QML 文件中混入复杂的业务逻辑。
- [ ] 涉及到新 API，我已经更新了头文件中的代码注释。
```

------

## 👁️ 第三部分：Code Review (代码审查)

提交 PR 后，请耐心等待核心维护者（Nekonano-Aether 团队成员）的 Review。

1. **交流与修改：** 维护者可能会在你的代码行下面留下评论。请保持开放的心态，这都是为了让引擎变得更好。
2. **如何更新 PR：** 你不需要关闭 PR 重新开。只需在本地继续修改代码，然后 `git commit` 并 `git push` 到你原来的分支，PR 会自动更新。
3. **合并 (Merge)：** 一旦获得 `Approve` (批准)，维护者会将你的代码 `Squash and Merge` (压缩合并) 到 `dev` 分支中。

感谢你为构建真实的数字生命做出的贡献！🐈