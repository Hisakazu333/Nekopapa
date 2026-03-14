# 🐾 Nekonano-Aether (NNA) 团队全流程 Git 实战手册

Git 不是简单的“云盘备份工具”，它是 NNA Core 引擎的**时间机器**。本手册将带你掌握从日常开发到灾难恢复的核心指令，确保我们的开源协同像齿轮一样精密咬合。

## 🛑 第一章：NNA 团队的 Git 绝对禁忌

在敲下任何 Git 命令前，请将以下三条铁律刻在脑子里：

1. **绝对禁止修改 Git 历史：** 严禁在共享分支（如 `dev`、`main`）上使用 `git push -f`（强制推送）。这会抹除其他人的代码。
2. **绝对禁止提交编译产物：** 永远不要把 `build/` 目录、`.user` 文件、`.obj`、`.exe` 或任何由 CMake 自动生成的文件 `git add` 进仓库。
3. **主分支神圣不可侵犯：** 严禁直接在 `dev` 或 `main` 上写代码。所有改动必须在自己的 `feature/` 分支进行。

------

## 🐘 第二章：Git LFS (大文件存储) 必修课

NNA Core 包含 AI 情感引擎的权重文件（如 `.onnx`, `.bin`）以及 Live2D 物理模型资源。普通 Git 无法处理这些大文件，必须使用 Git LFS。

### 1. 初始化 LFS (仅首次克隆项目时需要)

Bash

```
git lfs install
git lfs pull
```

### 2. 追踪新的大文件类别

如果你在项目中引入了新的大文件类型（比如高清材质 `.psd` 或新的模型格式），请告诉 LFS 接管它：

Bash

```
git lfs track "*.psd"
git lfs track "*.onnx"
# 记得把生成的 .gitattributes 文件也提交上去
git add .gitattributes
```

------

## 🔄 第三章：日常开发标准流 (The NNA Workflow)

这是你每天打开电脑写代码时，必须遵循的标准步骤。

### Step 1: 永远从最新的 dev 分支开始

在你决定写新功能前，先同步远程的最新代码。

Bash

```
git checkout dev
git pull origin dev
```

### Step 2: 创建你的专属阵地

切出一个新的特性分支。命名规范：`feature/nna-功能描述-你的名字`。

Bash

```
# 例如：开发 RBF 情绪计算模块
git checkout -b feature/nna-rbf-routing-zj
```

### Step 3: 编写代码并暂存

完成一段逻辑后，将变动加入暂存区（Stage）。

Bash

```
# 查看改了哪些文件
git status 

# 将你的 C++ 源码和 QML 文件加入暂存区
git add src/core/PhysiologySolver.cpp
git add src/ui/NNAWindow.qml

# 警告：不要无脑 git add . 除非你确定没有混入不需要的文件！
```

### Step 4: 语义化提交

Bash

```
git commit -m "feat: 接入 nna::emotion 模块的 RBF 权重重排逻辑"
```

### Step 5: 推送到远程仓库

Bash

```
git push origin feature/nna-rbf-routing-zj
```

*推送完成后，去 GitHub 页面点击 "Compare & pull request"，请求合并到 `dev` 分支。*

------

## ⚔️ 第四章：化解代码冲突 (Merge Conflicts)

**场景：** 你和队友同时修改了 `NNAWindow.cpp` 的同一行代码，当你试图把他的代码拉取下来时，Git 会报红并提示冲突。

**不要慌，千万不要直接关掉终端。**

### 解决步骤：

1. 打开发生冲突的文件（IDE 通常会用高亮标出）。你会看到类似这样的标记：

   C++

   ```
   <<<<<<< HEAD
   m_currentSatiety -= 10.0f; // 你本地写的代码
   =======
   m_currentSatiety -= 15.0f; // 队友在远程写的代码
   >>>>>>> origin/dev
   ```

2. **人工决断：** 删掉 `<<<<<<<`, `=======`, `>>>>>>>` 这些标记符号，并保留正确的代码逻辑。

3. **标记已解决并提交：**

   Bash

   ```
   git add NNAWindow.cpp
   git commit -m "fix: 解决 NNAWindow.cpp 的饥饿值计算冲突"
   ```

------

## ⏪ 第五章：后悔药与时间旅行 (高级技巧)

人在写 Bug 时总会犯错，这里是 Git 提供的“后悔药”。

### 1. 代码写乱了，想重置回最近一次提交的状态

Bash

```
# 放弃所有未提交的本地修改（极度危险，确认你真的不要这些代码了）
git checkout .
```

### 2. 刚才的 Commit 写错了名字，或者漏加了一个文件

Bash

```
git add 漏掉的文件.cpp
# 将改动合并到上一次的 commit 中，并允许你修改 commit 信息
git commit --amend
```

### 3. 想切换分支，但手头的代码还没写完不想 commit

使用“暂存大法”把未完成的代码藏起来。

Bash

```
git stash save "正在写情绪阈值，还没写完"

# 现在你可以安全地切换到别的分支去修 Bug 了
git checkout hotfix/xxx

# 修完回来后，恢复之前藏起来的代码
git checkout feature/nna-rbf-routing-zj
git stash pop
```

------

## 📋 附录：常用的 Git 状态查询

| **命令**            | **作用**                 | **使用场景**                                 |
| ------------------- | ------------------------ | -------------------------------------------- |
| `git status`        | 查看当前工作区状态       | **每天敲 100 遍都不嫌多**，提交前必看。      |
| `git log --oneline` | 查看历史提交记录         | 想看看项目最近合并了什么新功能。             |
| `git diff`          | 查看具体修改了哪些代码行 | `git add` 之前用来做最后的自我 Code Review。 |
| `git branch -a`     | 查看本地和远程的所有分支 | 检查队友的新分支是否已经推送到云端。         |