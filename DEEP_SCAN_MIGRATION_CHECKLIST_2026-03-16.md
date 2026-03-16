# FT8CN 深扫结果与迁移清单（2026-03-16）

## 结论先说

现在这个仓库不是“没动”，而是处于一个很典型的状态：

- **Flutter 壳子已经搭起来了**
- **原生 Android 老系统还完整躺着**
- **两边几乎还没真正接上**

所以当前项目的真实形态是：

> **旧内核还在，Flutter 新前端刚起步，中间桥还没修好。**

如果按迁移难度看，真正的硬活集中在：

1. FT8 音频/编解码链路
2. 电台连接与设备兼容
3. 实时频谱/瀑布图
4. 日志 / 地图 / 第三方上传
5. 配置与多语言迁移

---

## 一、仓库结构深扫

### 当前存在两套系统

#### 1. 旧 Android 原生项目
目录：`ft8cn/`

特点：
- Java 为主
- 完整业务逻辑、设备能力、UI、自定义 View 都在这里
- 已包含预编译 native so：
  - `arm64-v8a/libft8cn.so`
  - `armeabi-v7a/libft8cn.so`
  - `x86/libft8cn.so`
  - `x86_64/libft8cn.so`

#### 2. 新 Flutter 项目
目录：`flutter_app/`

特点：
- Flutter + Kotlin Android 宿主
- 已有基础 MD3 风格页面壳
- 目前桥接只实现了一个极轻量的 `getPlatformSummary`
- 还没有真正复用旧项目的核心能力

---

## 二、旧原生项目能力拆解

下面这部分，是 Flutter 重构必须面对的“旧能力地图”。

### 1. 应用主干与状态中心
关键文件：
- `MainActivity.java`
- `MainViewModel.java`
- `GeneralVariables.java`
- `FT8Common.java`

这部分基本是旧系统的大脑。

#### MainActivity 负责的事
- 权限申请
- 底部导航 / Fragment 导航
- 蓝牙广播注册
- 全屏、常亮、欢迎动画
- 浮动按钮 / 浮动工具入口
- 观察 ViewModel 并驱动 UI 更新
- 跳转 Grid Tracker / FAQ / 日志导入等能力

#### MainViewModel 负责的事
它几乎是整个业务枢纽，内容非常重：
- FT8 消息列表与解码状态
- UTC 15 秒时隙时钟
- 录音与解码控制
- 发射控制
- 串口 / 蓝牙 / Wi‑Fi / CAT 连接状态
- 电台实例和状态回调
- 日志查询、分享、导入导出
- 第三方服务上传
- Callsign 查询、QTH 查询
- 频谱数据与实时消息

**这意味着：Flutter 版未来不可能只“抄 UI”，必须先把这个状态中心拆出来。**

---

### 2. FT8 核心链路
关键目录：
- `ft8listener/`
- `ft8signal/`
- `ft8transmit/`
- `wave/`
- `timer/`
- `app/libs/*/libft8cn.so`

#### 主要能力
- 音频采集
- 重采样
- FT8 解码
- FT8 发射波形生成
- UTC 时隙同步
- 解码结果结构化为 `Ft8Message`

#### 核心文件示例
- `FT8SignalListener.java`
- `GenerateFT8.java`
- `FT8TransmitSignal.java`
- `HamRecorder.java`
- `MicRecorder.java`
- `FT8Resample.java`
- `UtcTimer.java`

#### 判断
这是**第一优先级的技术核心**。不把这块打通，Flutter 版本只是个界面原型。

---

### 3. 设备连接与电台控制
关键目录：
- `connector/`
- `rigs/`
- `serialport/`
- `bluetooth/`
- `icom/`
- `flex/`
- `x6100/`

#### 能力范围
项目不是只有“一个电台协议”，而是覆盖了多类连接方式：

- USB 串口
- 蓝牙串口
- Wi‑Fi / CAT
- Icom Wi‑Fi
- Flex Radio
- X6100 / Xiegu 系列
- 多品牌 CAT 指令集

#### 这块为什么麻烦
因为这里不是单一接口，而是一整层硬件兼容逻辑：
- 连接器抽象
- 多品牌 rig 实现
- 状态回调
- PTT / 频率 / 模式 / 读写命令
- USB driver 兼容

#### 典型文件
- `BaseRigConnector.java`
- `BluetoothRigConnector.java`
- `CableConnector.java`
- `WifiConnector.java`
- `IComWifiConnector.java`
- `FlexConnector.java`
- `X6100Connector.java`
- `BaseRig.java`
- `IcomRig.java`
- `Flex6000Rig.java`
- `XieGu6100Rig.java`
- `Yaesu*.java`
- `Kenwood*.java`
- `UsbSerial*.java`

#### 判断
这块是**最容易把项目拖死的部分**。如果不做边界隔离，Flutter 层会被设备兼容泥潭拖住。

**建议：这部分先尽量留在原生，Flutter 只吃统一状态与命令接口。**

---

### 4. 频谱 / 瀑布图 / 自绘 UI
关键目录：
- `ui/`
- `spectrum/`

关键文件：
- `SpectrumFragment.java`
- `SpectrumView.java`
- `WaterfallView.java`
- `RulerFrequencyView.java`
- `FlexMeterRulerView.java`
- `ColumnarView.java`

#### 判断
这不是普通表单 UI，而是高频刷新、自绘、实时标记类界面。

Flutter 能做，但不能用“普通组件拼一拼”的思路来做。

### 风险点
- 刷新频率高
- 数据量连续
- 手势 / 标尺 / 标记复杂
- 与解码状态耦合紧

#### 建议
- 第一阶段：先用 Flutter 做“数据驱动版简化频谱/瀑布”
- 第二阶段：再决定是 CustomPainter 重绘，还是把原生视图嵌进去

---

### 5. 日志 / QSO / 导入导出 / 共享
关键目录：
- `log/`
- `database/`
- `html/`

#### 主要能力
- QSO 记录
- 日志查询与过滤
- 共享日志生成
- 导入共享日志
- 本地 HTTP Server
- 第三方上传

典型文件：
- `DatabaseOpr.java`
- `LogFragment.java`
- `ShareLogs.java`
- `ImportSharedLogs.java`
- `LogHttpServer.java`
- `ThirdPartyService.java`

#### 判断
这块是**第二梯队的重要功能**。
不是最先打，但不能忽略，因为它是用户真正会用到的“完成度指标”。

---

### 6. 地图 / Grid Tracker
关键目录：
- `grid_tracker/`
- `maidenhead/`

典型文件：
- `GridTrackerMainActivity.java`
- `GridOsmMapView.java`
- `MaidenheadGrid.java`

依赖线索：
- 原生项目用了 `osmdroid`
- 还用了 `play-services-maps`

#### 判断
地图不是“后面顺手补个页面”那么简单，它牵扯：
- 网格坐标转换
- Marker 样式
- 通联/呼号信息窗
- 历史记录关联

这块建议放在核心链路之后。

---

### 7. 统计、FAQ、配置、多语言
关键目录：
- `count/`
- `ui/ConfigFragment.java`
- `FAQActivity.java`
- `res/values*`

#### 现状
原项目已有：
- 统计图表
- 配置页
- FAQ 页
- 多语言资源
  - 简中
  - 繁中多地区
  - 日文
  - 西班牙文
  - 希腊文
  - night 主题文本

#### 判断
这块迁移难度没前面高，但**零碎且量大**，非常适合在主链路稳定后批量处理。

---

## 三、Flutter 现状深扫

### 已完成的部分

#### 1. 工程基础
- Flutter 工程已创建
- Android 宿主包名为：`cn.bg7qvu.ft8zh`
- GitHub Actions 已配置 Android CI

#### 2. 页面骨架
目前已存在页面：
- `console_page.dart`
- `logbook_page.dart`
- `map_page.dart`
- `settings_page.dart`
- `home_shell.dart`

#### 3. UI 风格
- 已使用 Material 3 风格
- 有基础卡片、指标 chip、连接徽标等组件

#### 4. 桥接现状
当前原生桥接只有：
- `getPlatformSummary`

它只返回：
- 品牌
- 型号
- Android 版本
- 设备信息

**说白了，这还不叫业务桥接，只能算“桥接 hello world”。**

---

## 四、当前最大问题

### 问题 1：Flutter 层还没有“真实业务模型”
现在 Flutter 页面是静态占位数据，缺：
- App 状态模型
- 电台状态模型
- 解码消息模型
- 时隙状态模型
- 日志模型
- 设置模型

### 问题 2：没有统一 Bridge 设计
旧系统能力太散，如果直接一把把 MethodChannel 到处打，会很快变成烂摊子。

### 问题 3：方案 B 最容易半路退化成方案 A
因为业务逻辑迁 Dart 是对的，但只要时间一紧，就会变成：
- Flutter 只包壳
- 所有逻辑都继续留原生

那最后就不是 B 了，而是偷偷滑回 A。

### 问题 4：频谱/瀑布/设备控制都不是普通页面
这些都属于高复杂模块，不能按 CRUD 页面估工。

---

## 五、建议的迁移策略

不是“看到什么就搬什么”，而是按下面顺序推进。

### Phase 1：打通最小真实链路（必须先做）
目标：证明 Flutter 不是纯壳

#### 要做的事
- 定义 Flutter 侧数据模型：
  - `RigState`
  - `DecodeMessage`
  - `TimeSlotState`
  - `AudioState`
  - `AppConfig`
- 定义统一 bridge API：
  - `getInitialState`
  - `observeRigState`
  - `observeDecodeStream`
  - `observeTimer`
  - `startListening`
  - `stopListening`
- 先接**一条真实数据流**到 Flutter：
  - 优先建议：`timer + connection state + decode list`

#### 验收标准
- Flutter 主控台显示真实连接状态
- 显示真实 UTC 时隙
- 显示真实解码消息流（哪怕先不完整）

---

### Phase 2：主控台可用化
目标：把主控台从 demo 变成能联调的页面

#### 要做的事
- 主控台接真实状态
- 消息列表接真实流
- 发射控制有真实 enable/disable 状态
- 频率、模式、音频状态展示真实值
- 错误与告警统一处理

#### 先不要做的事
- 不急着先做华丽动画
- 不急着先抠所有视觉细节

---

### Phase 3：决定频谱/瀑布实现路线
目标：避免后面返工

#### 二选一尽快定
A. Flutter `CustomPainter` 自绘
B. 先嵌原生视图，后续再替换

#### 我的建议
- **先 B 后 A** 更稳
- 因为现在最缺的是联调成果，不是视觉纯度

如果一上来就纯 Flutter 自绘，很容易把时间烧在渲染细节上。

---

### Phase 4：日志与配置迁移
目标：补齐用户感知强的非实时功能

#### 迁移内容
- 日志列表
- QSO 详情
- 查询/筛选
- 配置页
- 呼号/网格/功率等设置
- 第三方上传设置

#### 建议
这部分优先迁 UI + 数据访问，不必一开始就完全 Dart 化数据库层。

---

### Phase 5：地图与附属功能
目标：补完成度

#### 包括
- Grid Tracker
- FAQ
- 统计图表
- 导入导出
- 共享日志

---

### Phase 6：设备兼容层梳理
目标：把“能用”推进到“靠谱”

这是最后的大坑收尾阶段：
- 串口兼容
- 蓝牙兼容
- Wi‑Fi / CAT 兼容
- 品牌特化逻辑整理

这块不适合太早投入大量时间，不然项目会被硬件兼容吃掉。

---

## 六、明确的迁移清单（按优先级）

## P0：马上做
- [ ] 为 Flutter 定义核心领域模型（RigState / DecodeMessage / TimerState / Config）
- [ ] 设计统一桥接协议，而不是零散 MethodChannel 调用
- [ ] 在 Android 宿主侧打通一个真正的业务桥接服务
- [ ] 把真实时隙状态接到 Flutter
- [ ] 把真实解码消息列表接到 Flutter
- [ ] 把真实连接状态接到 Flutter
- [ ] 主控台页面改成消费真实数据，而不是占位数据

## P1：接着做
- [ ] 打通开始监听 / 停止监听
- [ ] 打通发射控制基本动作
- [ ] 显示真实频率 / 模式 / 音频状态
- [ ] 建立统一错误提示与日志上报接口
- [ ] 梳理旧 `MainViewModel` 中哪些逻辑先保留原生，哪些迁到 Dart

## P2：随后做
- [ ] 决定频谱 / 瀑布图先嵌原生还是 Flutter 自绘
- [ ] 迁移日志列表与查询
- [ ] 迁移设置页
- [ ] 迁移多语言资源策略
- [ ] 明确第三方上传接口边界

## P3：补完成度
- [ ] 迁移 Grid Tracker / 地图
- [ ] 迁移 FAQ / 帮助页
- [ ] 迁移统计页面
- [ ] 迁移导入导出 / 日志共享

## P4：硬件兼容收尾
- [ ] USB 串口兼容梳理
- [ ] 蓝牙兼容梳理
- [ ] Icom / Flex / Xiegu / Yaesu / Kenwood 等机型专项验证
- [ ] 兼容性回归测试矩阵

---

## 七、我建议你现在就补的工程文件

这些不是花活，是防止后面失控：

- [ ] `docs/architecture.md`
  - 写清楚 Flutter / Native 的边界
- [ ] `docs/bridge_api.md`
  - 列出所有 MethodChannel / EventChannel 接口
- [ ] `docs/migration_map.md`
  - 把旧类和新模块一一映射
- [ ] `flutter_app/lib/domain/`
  - 放领域模型
- [ ] `flutter_app/lib/application/`
  - 放状态与控制器
- [ ] `flutter_app/lib/platform_bridge/`
  - 放桥接层

否则过几轮之后，代码会越来越像“临时凑出来能跑”的东西。

---

## 八、最终判断

### 现在最该做的，不是继续堆页面
而是：

> **先证明 Flutter 能吃到原生真实数据，并且能稳定展示。**

这一步一旦通了，项目就从“样板工程”升级成“真的在迁移”。

### 最危险的误区
- 误区 1：继续做漂亮占位页
- 误区 2：一上来就纯 Dart 化所有逻辑
- 误区 3：太早陷入设备兼容细节

### 最稳的打法
- 先接主链路
- 再做主控台可用化
- 再决定复杂视图策略
- 再补日志、设置、地图
- 最后啃设备兼容

---

## 一句话总评

**FT8CN 现在不是“快完了”，而是“重构方向已经定了，Flutter 壳子也有了，但真正的迁移才刚开始”。**
