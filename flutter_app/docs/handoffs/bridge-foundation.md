## 1. 当前任务目标

为 Flutter 迁移建立第一批可复用的 bridge 基础层，不再停留在单个 `getPlatformSummary()` 的 hello world。

本批预期产出：
- Flutter 侧领域模型、控制器、平台桥接目录结构落地
- Android 宿主提供 `MethodChannel + EventChannel` 的基础能力
- 主控台改成消费真实原生时钟/状态流，而不是纯静态占位
- 补一份 handoff 文档，方便后续继续做 decode stream / rig state / waterfall

完成标准：
- `flutter_app` 内出现 `domain/`、`application/`、`platform_bridge/` 三层
- Android `MainActivity.kt` 提供初始化快照、监听状态切换、timer/state 流
- 主控台 UI 能展示实时 UTC/时隙进度，并能切换“开始监听/停止监听”状态

## 2. 当前进展

已完成：
- 新增 `lib/domain/models.dart`
  - `RigState`
  - `TimerState`
  - `DecodeMessage`
  - `ConsoleSnapshot`
- 新增 `lib/application/console_controller.dart`
  - 统一拉初始快照
  - 订阅 timer/state 流
  - 提供 `toggleListening()`
- 新增 `lib/platform_bridge/native_bridge.dart`
  - 封装 `getInitialSnapshot`
  - 封装 `startListening/stopListening`
  - 封装 `observeTimer/observeRigState`
- Android 宿主 `android/app/src/main/kotlin/cn/bg7qvu/ft8zh/MainActivity.kt`
  - 从单一 `MethodChannel` 扩展为：
    - `cn.bg7qvu.ft8zh/native`
    - `cn.bg7qvu.ft8zh/timer`
    - `cn.bg7qvu.ft8zh/state`
  - 新增：
    - `getInitialSnapshot`
    - `startListening`
    - `stopListening`
  - 新增实时 timer feed（每秒推送一次）
  - 新增 rig state feed（监听状态切换时推送）
- 主控台 UI `lib/features/console/console_page.dart`
  - 改为响应式页面
  - 展示实时 UTC/时隙/设备信息
  - 加入简化频谱/瀑布预览
  - 监听按钮不再是死按钮
- `lib/platform/native_bridge.dart` 现改成 re-export，避免旧引用直接炸

## 3. 关键上下文

- 用户已明确要求：继续做迁移，不要只写总结文档
- 用户要求控制 push 频率：要攒成有价值的一批再 push，因为每次 push 都会触发 GitHub Actions 计费
- 既定决策仍然有效：
  - 方案 B：Flutter 做 UI，业务逻辑逐步迁到 Dart，底层先保留原生
  - Android 7+
  - 包名 `cn.bg7qvu.ft8zh`
  - 优先级：UI > 收发 > 附属功能 > 设备
  - 用户额外确认：第一阶段要带一版简化频谱/瀑布（不是只做主控台文字状态）
- 当前 `flutter_app` 与旧原生 `ft8cn` 仍是分离状态；目前还没有把旧 `MainViewModel`、`UtcTimer`、`FT8SignalListener` 真实接进 Flutter 宿主

## 4. 关键发现

- 旧原生的真正状态中心仍然是 `ft8cn/app/src/main/java/com/bg7yoz/ft8cn/MainViewModel.java`
  - 它直接持有 `UtcTimer`、`FT8SignalListener`、`FT8TransmitSignal`、`SpectrumListener`、rig connector 等核心对象
- 旧 `UtcTimer.java` 是一个很独立的时隙时钟实现，后续如果把旧原生模块并入 Flutter 宿主，timer 流应该优先复用它，而不是长期保留 Kotlin 自己算时隙
- 这次新增的 timer/state 流是“bridge foundation”，不是最终业务桥；它的价值在于：
  - 把 Flutter 目录和响应式消费方式先搭对
  - 把 EventChannel 路子先打通
  - 把主控台从静态占位拉到半动态状态
- 这批代码里“decode messages”仍然是宿主侧 demo 数据，不是来自 JNI/音频链路；不能把它误判成已完成真实解码迁移
- 简化频谱/瀑布当前是用 timer 驱动的预览条，不是 DSP 结果；它只是兑现用户要求的“先给一版简化版”，不是功能完成

## 5. 未完成事项

按优先级：

1. **P0：把旧原生真实 timer 接入 Flutter 宿主**
   - 优先研究如何在 Flutter Android 宿主中直接复用 `com.bg7yoz.ft8cn.timer.UtcTimer`
   - 替换掉当前 Kotlin 内部计算时隙的实现

2. **P0：接真实 rig state**
   - 不是当前的 `isListening` 布尔切换
   - 要从旧 `MainViewModel` / `BaseRig` / connector 状态中提炼统一模型

3. **P0：接真实 decode stream**
   - 目标是先把 `mutableFt8MessageList` 或 `afterDecode(...)` 的结果桥接出来
   - 第一版不要求完整发射流程，但至少让主控台消息列表吃真实数据

4. **P1：把 Flutter 侧控制器拆成更稳定的数据边界**
   - 当前 `ConsoleController` 还是一个大控制器
   - 后续应拆成 timer / rig / decode 三条 source 或 repository

5. **P1：补 bridge API 文档**
   - 当前只是代码落地，没有正式 `docs/bridge_api.md`
   - 如果下一批开始接真实模块，不写文档会乱

6. **P1：验证 Flutter 工程静态检查/构建**
   - 本地未验证编译
   - 下一次 push 前最好至少跑 `flutter analyze` 或能跑的最小检查

## 6. 建议接手路径

优先看这些文件：
- `flutter_app/lib/domain/models.dart`
- `flutter_app/lib/application/console_controller.dart`
- `flutter_app/lib/platform_bridge/native_bridge.dart`
- `flutter_app/lib/features/console/console_page.dart`
- `flutter_app/android/app/src/main/kotlin/cn/bg7qvu/ft8zh/MainActivity.kt`
- `ft8cn/app/src/main/java/com/bg7yoz/ft8cn/MainViewModel.java`
- `ft8cn/app/src/main/java/com/bg7yoz/ft8cn/timer/UtcTimer.java`
- `ft8cn/app/src/main/java/com/bg7yoz/ft8cn/ft8listener/FT8SignalListener.java`

先验证什么：
1. Flutter 侧新增目录结构是否有导入错误
2. Android 宿主 Kotlin 代码是否与当前 Flutter embedding API 匹配
3. 当前 `EventChannel` 与 `AnimatedBuilder + ChangeNotifier` 的组合是否能稳定工作
4. `MainActivity.kt` 是否还会与后续引入旧原生包名 `com.bg7yoz.ft8cn.*` 产生宿主层冲突

推荐下一步动作：
- **第一步建议：研究如何在 Flutter Android 宿主内直接实例化或桥接旧 `UtcTimer` 与 `MainViewModel`，不要继续往 Kotlin demo 状态层上堆功能。**
- 如果发现直接引旧模块太重，就退一步：先只桥接旧 `UtcTimer` + 一条 `mutableFt8MessageList` 流，最小化切口

## 7. 风险与注意事项

- 当前实现里 `MainActivity.kt` 提供的是“宿主桥接基础层”，不是最终原生业务层；别把 demo state 当成正式完成
- 简化频谱预览是 UI 占位升级版，不是频谱迁移完成
- 旧原生项目包名是 `com.bg7yoz.ft8cn`，Flutter 宿主包名是 `cn.bg7qvu.ft8zh`；后续合并/复用旧类时，要特别注意 import、资源、manifest、gradle source set 的冲突
- `MainViewModel.java` 体量很大，别一口气全桥接；优先切 `timer -> rig state -> decode stream`
- 本地环境较差，未验证编译；下一次 push 前尽量先做本地最小检查，避免把明显语法错误直接扔给 workflow
- `brv`（ByteRover）当前环境未安装，且此会话下没有 elevated 能力安装全局 npm 包；短期内不能依赖它做上下文管理
