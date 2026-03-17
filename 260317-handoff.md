## 1. 当前任务目标

继续推进 `FT8CN` 的 Flutter 重构，不再停留在文档和 UI 骨架阶段，而是把旧原生 Android 项目的核心实时能力逐步迁入 Flutter 主控台。

当前阶段的具体目标：
- 把 Flutter 版主控台从“演示壳”推进到“真实原生状态驱动”
- 优先打通真实 `timer`、真实 `rig state`、真实 `decode message stream`
- 在不频繁触发 GitHub Actions 的前提下，攒成一批有价值改动后再 push
- 每完成一个模块/半个模块，在对应目录下持续补 handoff 文档，便于后续 Agent 接手

当前阶段的完成标准：
- Flutter 宿主不再只返回 demo/占位状态，而是消费旧原生 `ft8cn` 核心状态
- 主控台可展示真实 UTC/时隙、真实连接状态、真实解码消息
- 至少一条真实链路（优先 timer + decode stream）稳定进入 Flutter 页面
- 文档同步更新，且 push 后可用 workflow 验证编译状态

## 2. 当前进展

### 已完成的仓库与方案确认
- 项目仓库：`/root/.openclaw/workspace/FT8CN`
- 当前代码仓库实际在：`/root/.openclaw/workspace/FT8CN/ft8cn`
- 当前分支：`feat/ft8zh-flutter-bootstrap`
- 远端：
  - `origin` -> `https://github.com/N0BOY/FT8CN`
  - `ft8zh` -> `https://github.com/LarkerO/FT8ZH`

### 已确认的产品/技术决策（来自与用户的明确对话）
- 项目：用 Flutter 重构 FT8CN
- 平台：先做 Android
- 最终路线：**方案 B**
  - Flutter 负责 UI
  - 业务逻辑逐步迁到 Dart
  - 原生层先保留底层驱动 / so
- 包名：`cn.bg7qvu.ft8zh`
- 最低 Android 版本：Android 7
- 用户确认的优先级：`UI > 收发 > 附属功能 > 设备`
- 用户额外确认：第一阶段不是只做文字状态，**要带一版简化频谱/瀑布**
- 用户要求：push 要节制，避免频繁消耗 workflow 额度；要攒出“有价值的一批”再推

### 之前已完成的文档类工作
根目录已有：
- `FT8CN/PROJECT_STATUS_2026-03-16.md`
- `FT8CN/DEEP_SCAN_MIGRATION_CHECKLIST_2026-03-16.md`

这两份文档已经 push 过，之前 workflow 也跑通过。

### 我本次已完成的实际代码工作
已新增/修改并本地提交（commit: `193bb4f`，message: `feat: add flutter bridge foundation for console migration`）：

#### 新增目录与文件
- `FT8CN/flutter_app/lib/domain/models.dart`
- `FT8CN/flutter_app/lib/application/console_controller.dart`
- `FT8CN/flutter_app/lib/platform_bridge/native_bridge.dart`
- `FT8CN/flutter_app/docs/handoffs/bridge-foundation.md`

#### 修改文件
- `FT8CN/flutter_app/lib/app/app.dart`
- `FT8CN/flutter_app/lib/features/home/home_shell.dart`
- `FT8CN/flutter_app/lib/features/console/console_page.dart`
- `FT8CN/flutter_app/lib/platform/native_bridge.dart`（改成 re-export 兼容层）
- `FT8CN/flutter_app/android/app/src/main/kotlin/cn/bg7qvu/ft8zh/MainActivity.kt`
- 以及格式化导致的少量现有 Flutter 文件改动

#### 本次代码改动的核心内容
1. **Flutter 侧三层结构落地**
   - `domain`：定义 `RigState`、`TimerState`、`DecodeMessage`、`ConsoleSnapshot`
   - `application`：新增 `ConsoleController`，统一拉初始快照、订阅事件流、管理监听开关
   - `platform_bridge`：新增 `NativeBridge`，封装 `MethodChannel + EventChannel`

2. **Android 宿主桥接从 hello world 升级为基础层**
   - `MainActivity.kt` 之前只支持 `getPlatformSummary`
   - 现在支持：
     - `getInitialSnapshot`
     - `startListening`
     - `stopListening`
     - `EventChannel`：`cn.bg7qvu.ft8zh/timer`
     - `EventChannel`：`cn.bg7qvu.ft8zh/state`
   - 目前 timer/state 仍是宿主内生成的动态数据，不是旧原生 `com.bg7yoz.ft8cn.*` 真状态

3. **主控台页面已从纯静态占位升级为响应式页面**
   - 可显示：
     - 实时 UTC / 时隙进度
     - 监听状态切换
     - 简化版频谱/瀑布预览
   - decode list 目前仍是宿主 demo 数据，不是真实 JNI 解码结果

4. **handoff 文档开始落地**
   - 已写：`FT8CN/flutter_app/docs/handoffs/bridge-foundation.md`
   - 内容记录了本批 bridge foundation 的目标、进展、边界、风险、下一步建议

### 已做过的最小验证
在 `FT8CN/flutter_app` 下跑过：
- `flutter analyze`
- 结果：`No issues found!`

注意：这是静态分析通过，不等于 APK 已构建成功。

## 3. 关键上下文

### 重要背景信息
- 旧原生 Android 项目仍完整存在于 `FT8CN/ft8cn`
- 新 Flutter 项目在 `FT8CN/flutter_app`
- 现在仓库是“两套系统并存但尚未真正打通”的状态
- 旧原生项目内有完整的 FT8 编解码、音频、rig connector、频谱/瀑布、自定义视图、日志、地图等能力

### 用户的明确要求
- 继续完成迁移，不要只做总结文档
- push 不要太频繁，因为每次都会触发 GitHub Actions 成本
- 每做完一个模块/半个模块，要写 handoff 文档
- handoff 文档不是给用户看的总结，而是给下一位 Agent 直接接手用的
- 这次要求把本交接文档写到 `./{yymmdd}-handoff.md`，然后一起 push 到 GitHub

### 已知约束
- 本地环境编译能力有限，但 `flutter analyze` 可用
- GitHub Actions 是重要验证手段，但不能滥用
- 旧原生核心体量很大，不能一口气全桥接，否则极易失控
- `brv` / ByteRover 当前环境不可用（未安装，且当前 session 无 elevated 能力安装全局 npm）
- memory 检索没有提供额外项目记录，主要信息都来自仓库现状和当前对话历史

### 已做出的关键决定
- 不走“纯 Flutter 全重写”，仍坚持方案 B
- 第一阶段优先切主控台真实链路，不碰地图/FAQ/统计等外围模块
- 因用户确认 `2B`，第一阶段要带**简化频谱/瀑布**，但可以先做简化版而非完整 DSP
- 当前已接受一个现实：先做 bridge foundation，再逐步把旧原生真实状态接入

### 重要假设
- 下一步最合理的切口不是继续堆 Flutter 页面，而是优先把旧原生 `UtcTimer`、`MainViewModel`、`FT8SignalListener` 的状态流接进宿主
- decode stream 接入时，第一版可以只桥接消息列表，不必同步完成发射控制 / 完整频谱 / 全 rig 兼容

## 4. 关键发现

1. **旧原生真正的状态中心是 `MainViewModel.java`**
   文件：`FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/MainViewModel.java`
   - 它直接持有：
     - `UtcTimer`
     - `FT8SignalListener`
     - `FT8TransmitSignal`
     - `SpectrumListener`
     - `BaseRig`
     - 各类 connector / rig / database / message list LiveData
   - 这意味着 Flutter 迁移不能只看 UI，必须尽早围绕它拆状态边界

2. **旧原生 `UtcTimer.java` 很适合成为第一条真实链路**
   文件：`FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/timer/UtcTimer.java`
   - 独立性强
   - 15 秒时隙逻辑清晰
   - 比直接先接完整 rig / decode 风险低
   - 结论：应优先研究如何在 Flutter Android 宿主中复用它，而不是长期保留 Kotlin 自己算 slot progress 的做法

3. **旧原生 `FT8SignalListener.java` 是 decode stream 的关键入口**
   文件：`FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/ft8listener/FT8SignalListener.java`
   - 内含 `UtcTimer` 触发、音频获取、JNI 解码、deep decode 逻辑
   - `onFt8Listen.afterDecode(...)` 是很明显的桥接点
   - 第一版真实 decode stream 很可能可以围绕 `afterDecode(...)` 或 `mutableFt8MessageList` 做

4. **当前 `193bb4f` 这批改动的性质要判断准确**
   - 它不是“核心迁移完成”
   - 它的价值是：
     - 把 Flutter 结构搭正
     - 把 EventChannel 路子先打通
     - 把主控台从静态壳推进到动态页面
   - 当前 timer/state/decode 仍有 demo 成分，不能误判成已接入旧原生核心

5. **当前项目真实阶段已从“骨架期”进入“bridge foundation 期”**
   - 不是只有文档和 MD3 壳子了
   - 但也远没到真实收发迁移
   - 目前更合理的整体进度估计：20%–25%

6. **之前某些“没推进”的状态已经过时**
   - 早先确实停在文档和骨架阶段
   - 但现在已经有 `193bb4f` 这批代码，下一位 Agent 不要再重复做一遍 bridge foundation

## 5. 未完成事项

按优先级排序：

### P0（必须尽快开始）
1. **把旧原生 `UtcTimer` 真接进 Flutter 宿主**
   - 替换当前 Kotlin 中本地计算的 timer feed
   - 目标：Flutter 吃到旧原生真实 UTC / 时隙状态

2. **接真实 rig state**
   - 不再只用 `isListening` 布尔和 demo label
   - 要梳理 `MainViewModel` / `BaseRig` / connector 层里哪些状态最先暴露给 Flutter
   - 第一版至少要包含：连接状态、模式、频率、音频来源/状态

3. **接真实 decode message stream**
   - 优先桥接 `mutableFt8MessageList` 或 `afterDecode(...)`
   - 目标：主控台消息列表从 demo 数据改为真实解码结果

### P1（在 P0 开始落地后跟进）
4. **补 bridge API 文档**
   - 建议新增：`FT8CN/docs/bridge_api.md` 或放到 `flutter_app/docs/`
   - 明确列出 MethodChannel / EventChannel 的接口名、字段名、事件 payload

5. **补旧类到新模块的映射文档**
   - 建议新增：`migration_map.md`
   - 把 `MainViewModel`、`UtcTimer`、`FT8SignalListener`、`SpectrumListener`、`BaseRig` 等映射到 Flutter 新结构

6. **决定 decode / spectrum 的第一版边界**
   - 建议先接 decode message stream，频谱先保留简化版预览
   - 不要一开始就纯 Flutter 自绘真 DSP 频谱

### P2（之后再做）
7. **发射控制真实接入**
8. **日志 / 设置迁移**
9. **地图 / Grid Tracker / FAQ / 统计 / 导入导出**
10. **设备兼容收尾（USB / 蓝牙 / Wi‑Fi / 各品牌 rig）**

## 6. 建议接手路径

### 优先查看的文件
先看 Flutter 这边：
- `FT8CN/flutter_app/lib/domain/models.dart`
- `FT8CN/flutter_app/lib/application/console_controller.dart`
- `FT8CN/flutter_app/lib/platform_bridge/native_bridge.dart`
- `FT8CN/flutter_app/lib/features/console/console_page.dart`
- `FT8CN/flutter_app/android/app/src/main/kotlin/cn/bg7qvu/ft8zh/MainActivity.kt`
- `FT8CN/flutter_app/docs/handoffs/bridge-foundation.md`

再看旧原生核心：
- `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/MainViewModel.java`
- `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/timer/UtcTimer.java`
- `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/ft8listener/FT8SignalListener.java`
- 如需继续看频谱/瀑布：
  - `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/spectrum/`
  - `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/ui/WaterfallView.java`
  - `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/ui/SpectrumView.java`

### 建议先验证的内容
1. `193bb4f` 之后的工作区是否干净（避免在脏状态上接着干）
   - 命令：
     - `cd /root/.openclaw/workspace/FT8CN/ft8cn && git status --short --branch`

2. Flutter 基础层当前是否仍可静态分析通过
   - 命令：
     - `cd /root/.openclaw/workspace/FT8CN/flutter_app && flutter analyze`

3. 当前 Android 宿主桥接代码是否仍只是 demo state
   - 重点看：`MainActivity.kt` 中 `currentRigState()`、`currentTimerState()`、`demoMessages()`

4. 旧原生 `UtcTimer` / `MainViewModel` 能否在 Flutter Android 宿主里直接复用
   - 先查 gradle/source set/包依赖，避免一上来就改大量结构

### 推荐的下一步动作
**最推荐的下一步：先把旧原生 `UtcTimer` 接到 Flutter 宿主，产出一版“真实时隙流 + handoff 文档”，不要继续往 demo state 上加功能。**

可执行步骤建议：
1. 在 `flutter_app/android/app` 宿主工程里研究是否能直接 import / 复用 `com.bg7yoz.ft8cn.timer.UtcTimer`
2. 如果能，先只替换 timer 流，不动 decode / rig
3. 成功后新增一份 handoff 文档，例如：
   - `FT8CN/flutter_app/docs/handoffs/native-utc-timer.md`
4. 再往下做真实 decode stream
5. 攒够这两步后再统一 push，顺便看 workflow

## 7. 风险与注意事项

1. **不要误判当前进度**
   - 现在不是“只剩打包”
   - 也不是“还什么都没开始”
   - 正确判断：Flutter bridge foundation 已经完成一批，但旧原生真实链路还没接上

2. **不要重复造一遍 bridge foundation**
   - `193bb4f` 已经把 Flutter 三层结构、宿主 EventChannel、主控台响应式页面、handoff 基础文档做出来了
   - 下一位 Agent 应该基于它往下接真实核心，而不是回头再搭一遍骨架

3. **不要继续往 demo 宿主状态上堆业务**
   - `MainActivity.kt` 当前的 `currentTimerState()` / `currentRigState()` / `demoMessages()` 只是临时桥接基础层
   - 再在它上面叠更多 demo 逻辑，只会让后续替换更痛苦

4. **不要一口气全桥接 `MainViewModel`**
   - `MainViewModel.java` 过于庞大
   - 建议切小口：`UtcTimer -> rig state -> decode stream`
   - 否则极易陷入大范围改动、难以验证、难以回滚

5. **不要太早做完整真频谱 / 真瀑布自绘**
   - 用户虽然要求第一阶段带简化频谱/瀑布，但那已经通过当前预览版满足了“可见成果”
   - 真正值得优先做的是状态流与 decode stream

6. **注意包名与旧原生代码的冲突风险**
   - Flutter 宿主包名：`cn.bg7qvu.ft8zh`
   - 旧原生核心包名：`com.bg7yoz.ft8cn`
   - 后续复用旧类时，注意 import、资源、manifest、gradle source set 冲突

7. **控制 push 频率**
   - 用户明确要求不要“改一点 push 一次”
   - 每次 push 都会触发 GitHub Actions，有成本
   - 更合理策略：至少攒到一个完整子模块（如真实 timer + 文档，或 decode stream + 文档）再 push

8. **已验证过、不建议重复花时间的方向**
   - 不要再花时间反复证明“当前 UI 只是占位壳”——这个结论已经过时一部分了，`193bb4f` 之后它至少已经是动态桥接壳
   - 不要重新做根目录总结文档，现有两份足够；下一步更需要模块级 handoff 和 bridge 文档

## 下一位 Agent 的第一步建议

先不要继续写总结，也不要继续堆 demo 页面。

**第一步直接做这件事：**

> 在 `FT8CN/flutter_app/android/app/src/main/kotlin/cn/bg7qvu/ft8zh/MainActivity.kt` 所在宿主层，验证能否复用 `FT8CN/ft8cn/app/src/main/java/com/bg7yoz/ft8cn/timer/UtcTimer.java`，把当前 EventChannel `cn.bg7qvu.ft8zh/timer` 的数据源从 Kotlin 本地计算替换成旧原生真实时隙时钟。

如果这一步打通，整个项目就会从“bridge foundation”正式进入“真实核心迁移”阶段。