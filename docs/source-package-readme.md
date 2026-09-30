# SPS-SPD 源码包说明

最后更新：2026-09-30

## 项目定位

SPS-SPD 以破碎像素地牢 4.0.0 为引擎基础，实现特别惊喜像素地牢 0.9.8
中可达的旧版功能、玩法、地图、职业、物品、怪物、任务、宠物、商店、挑战路线和
存档流程。验收目标是旧版功能和玩法可用，不要求逐像素、逐动画或逐文案完全一致。

破碎像素地牢原有职业和装备仍保留在源码中，但不会进入正常游戏的选择、生成、
商店和图鉴流程，方便后续测试与调整。旧版中可能导致崩溃、死档、不可达或存档损坏
的问题已按需要修正。

## 仓库结构

Gradle 模块（见 `settings.gradle`）：

- `core/`：全部游戏源码、渲染层、资源与测试。上游的 `SPD-classes`、`services`
  以及三个平台模块的**源码**均已并入本模块；平台目录仍保留为独立 Gradle 模块，
  但只负责打包配置。
- `android/`：Android 打包模块。保留 `src/main/res`、`src/debug/res`、`libs/`、
  `proguard-rules.pro`（Android Gradle 插件约定），源码指向 `core/src/android/java`。
- `desktop/`：桌面打包模块。保留 `macos-entitlements.plist`、`notarize.sh`
  与 jpackage/runtime 配置，源码指向 `core/src/desktop/java`。
- `ios/`：iOS 打包模块。保留 `Info.plist`、`robovm.xml`、`robovm.properties`
  （RoboVM 约定），源码指向 `core/src/ios/java`。

`core/src/` 目录结构（目录即功能地图，不再有 Gradle 默认的 `main` 夹层）：

```
core/src/
  java/            游戏本体与渲染层：pd（游戏）、render（渲染库）
  assets/          图集、字体、音乐音效、messages/<用途>/<语言>/
  test/java/       无图形校验用例（对应 verifySpsXxx 任务）
  android/java/    Android 平台：Launcher、BackupHandler、PlatformSupport 等
  desktop/java/    桌面平台：Launcher、PlatformSupport、WindowListener 等
  desktop/assets/  桌面专用字体与各平台图标
  desktop/test/    桌面烟测（DesktopSmokeCapture）
  ios/java/        iOS 平台：Launcher、PlatformSupport
  ios/assets/      iOS 打包资源（Assets.xcassets、LaunchScreen、music）
  services/java/   新闻与更新服务的调用与调试实现
```

顶层其他目录：

- `metadata/`：发行元数据。
- `gradle/`、`gradlew`、`gradlew.bat`：Gradle 包装器（9.5.0）。
- `tools/`：图集工具链（`atlas-tool.ps1`、`gen-atlas-dict.ps1`）与移植覆盖审计脚本。
- `docs/`：构建说明、迁移清单、完成审计和本说明。
- `output/`：构建产物汇总目录（由 `collectOutputs` 写入，不入库）。
- `_ref/`：参照工程与历史归档（含已归档的上游联网服务），不参与构建。

压缩包不包含 `.gradle`、各模块 `build`、`output`、IDE 缓存、日志和临时文件。
APK 与桌面发行包也不包含在源码包中，可按下述命令重新构建。
`docs/verification-evidence/` 保留了五张最终验收截图。

## 本机开发环境

- JDK：21（Gradle 通过 `java.sourceCompatibility` 编译为 Java 11 兼容字节码）
- Android SDK：`C:\Users\15698\AppData\Local\Android\Sdk`（由 `local.properties` 记录）
- Android 编译/目标 SDK：36；最低版本：API 21（Android 5.0）
- Java 源码兼容级别：Java 11
- Gradle：9.5.0
- 当前项目版本：`0.1.1-alpha`（`appVersionCode` = 923）
- 应用包名（桌面/存档/Apple bundle）：`com.shatteredpixel.shatteredpixeldungeon`
- Android application id：`com.hmdzl.spsexpd`

换到其他电脑后，应把 `local.properties` 中的 `sdk.dir` 改为实际 SDK 位置。
文本、Java 编译和运行时资源统一使用 UTF-8；编辑中文资源时不要转换为 ANSI、GBK
或其他本地编码。

## 构建与验收

在源码根目录打开 PowerShell：

```powershell
# 全量校验（140 个任务，含编译、无图形校验与资源检查）
.\gradlew.bat verifySpsRelease

# 运行桌面版
.\gradlew.bat desktop:debug

# 打包：APK 与桌面 jar/安装包构建完成后会自动汇总到 output/
.\gradlew.bat android:assembleDebug
```

> **门禁说明**：`verifySpsRelease` 会聚合全部 `verifySpsXxx` 校验任务。全量约
> 需 2 分钟；只关心某一项时可单独执行，例如 `.\gradlew.bat :core:verifySpsAlchemy`。
> 注意 `:core:verifySpsRegularLevels` 在并发全量运行下偶发断言失败（测试内部
> 使用 `buildWithRetries`），单独复跑即可通过。

主要产物（均由 `collectOutputs` 平铺复制到 `output/`）：

- Android 调试包：`android/build/outputs/apk/debug/SPSEXPD-debug.apk`
- 桌面可执行 jar：`desktop/build/libs/SPSEXPD*.jar`
- jpackage 安装包（Windows/macOS/Linux）：`desktop/build/jpackage/**`

重新生成旧版源码覆盖审计：

```powershell
.\tools\audit-sps-port.ps1
```

重新校验图集字典与元数据是否一致：

```powershell
.\tools\gen-atlas-dict.ps1 -Check
```

## 验收记录

历史验收结果、产物大小与哈希见：

- `docs/sps-completion-audit.md`：功能、构建、烟测和存档验收结果。
- `docs/sps-port-status.md`：逐项移植状态。
- `docs/sps-migration-inventory.md`：旧版内容迁移清单。
- `docs/fusion-content.md`：融合项目内容说明。
- `docs/art-sources.md`：素材来源说明。
- `docs/art-workflow.md`：图集工具链与美术工作流。

因构建工具、压缩时间戳或环境差异，重新生成的二进制文件不一定具有相同哈希；
应以完整验收任务是否通过为主要判断依据。

## 许可证

项目许可证见根目录 `LICENSE.txt`。上游引擎、旧版项目及美术素材来源说明见根目录
`README.md` 与 `docs/` 内相关文档。