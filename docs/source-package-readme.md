# SPS-SPD 源码包说明

打包日期：2026-09-23

## 项目定位

SPS-SPD 以破碎像素地牢 4.0.0 为引擎基础，实现特别惊喜像素地牢 0.9.8
中可达的旧版功能、玩法、地图、职业、物品、怪物、任务、宠物、商店、挑战路线和
存档流程。验收目标是旧版功能和玩法可用，不要求逐像素、逐动画或逐文案完全一致。

破碎像素地牢原有职业和装备仍保留在源码中，但不会进入正常游戏的选择、生成、
商店和图鉴流程，方便后续测试与调整。旧版中可能导致崩溃、死档、不可达或存档损坏
的问题已按需要修正。

## 源码包内容

- `android/`：Android 启动端、资源和构建配置。
- `core/`：核心玩法、地图、角色、物品、怪物、界面及多语言资源。
- `desktop/`：桌面端启动器和测试代码。
- `ios/`：iOS 端工程源码。
- `services/`：新闻、更新等服务模块。
- `SPD-classes/`：共享类模块。
- `metadata/`：发行元数据。
- `gradle/`、`gradlew`、`gradlew.bat`：Gradle 包装器。
- `tools/`：移植覆盖审计及辅助工具。
- `docs/`：构建说明、迁移清单、完成审计和本说明。

源码包不包含 `.gradle`、各模块 `build`、IDE 缓存、日志和临时文件。APK 与桌面发行包
也不包含在源码包中，可按下述命令重新构建。压缩包中 `docs/verification-evidence/`
保留了五张最终验收截图。

## 本机开发环境

- Android SDK：`G:\Android\Android SDK`
- Android 编译 SDK：36
- Android 最低版本：API 21（Android 5.0）
- Java 源码兼容级别：Java 11
- Gradle 包装器：9.5.0
- 当前项目版本：`4.0.0-sps.1`
- Android application id：`com.hmdzl.spsspd`

`local.properties` 已记录本机 Android SDK 路径。换到其他电脑后，应将其中的
`sdk.dir` 改为实际 SDK 位置。文本、Java 编译和运行时资源统一使用 UTF-8；编辑中文
资源时不要转换为 ANSI、GBK 或其他本地编码。

## 构建与验收

在源码根目录打开 PowerShell：

```powershell
.\gradlew.bat desktop:distZip
.\gradlew.bat android:assembleDebug
```

也可以一次执行两个发行构建：

```powershell
.\gradlew.bat desktop:distZip android:assembleDebug
```

> **门禁说明（2026-09-30 起）**：`verifySpsRelease` 门禁已退出必跑流程（影响演进
> 效率），回归保护改由开发流程中的规划、复检与 commit 存档承担。140 项检查代码
> 与 Gradle 任务全部保留，需要抽查时手动执行，例如：
> `.\gradlew.bat verifySpsRelease`（全量）或 `.\gradlew.bat :core:verifySpsAlchemy`（单项）。

构建完成后，主要产物位于：

- 桌面发行包：`desktop/build/distributions/desktop-4.0.0-sps.1.zip`
- Android 调试包：`android/build/outputs/apk/debug/android-debug.apk`

启动桌面调试版：

```powershell
.\gradlew.bat desktop:debug
```

重新生成旧版源码覆盖审计：

```powershell
.\tools\audit-sps-port.ps1
```

## 最近一次完整验收

2026-09-23 最终联合命令
`verifySpsRelease desktop:distZip android:assembleDebug` 执行成功，共 187 个任务：
137 个实际执行，50 个命中缓存。`verifySpsRelease` 包含 140 项检查。

旧版源码覆盖审计结果：1916 个旧版 Java 文件中，1722 个具有同路径实现，63 个具有
同名适配，131 个经审查无需独立迁移，缺失候选为 0。全部 207 个运行时 properties
文件通过严格 UTF-8 解码和乱码检查。

详细依据见：

- `docs/sps-completion-audit.md`：功能、构建、烟测和存档验收结果。
- `docs/sps-port-status.md`：逐项移植状态。
- `docs/sps-migration-inventory.md`：旧版内容迁移清单。
- `docs/fusion-content.md`：融合项目内容说明。
- `docs/art-sources.md`：素材来源说明。

最近一次生成产物的校验信息仅供构建后比对：

- 桌面 ZIP：86,877,816 字节，SHA-256
  `29F21145FD35D428B92A25129BF56122A3508B8FAF49F9AD5D55CE7119B205A5`
- Android APK：43,642,441 字节，SHA-256
  `00EBBDBCD3D5E1D8FF3CADEE9A47DB044597C2037621499F9248332028123FCC`

因构建工具、压缩时间戳或环境差异，重新生成的二进制文件不一定具有相同哈希；应以
完整验收任务是否通过为主要判断依据。

## 许可证

项目许可证见根目录 `LICENSE.txt`。上游引擎、旧版项目及美术素材来源说明见根目录
`README.md` 与 `docs/` 内相关文档。
