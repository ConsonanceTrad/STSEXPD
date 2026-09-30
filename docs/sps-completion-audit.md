# SPS-SPD 功能完成审计

审计日期：2026-09-23（历史记录）

> **现状说明**：本文是 2026-09-23 的验收快照，验收口径与各 `verifySpsXxx` 门禁仍然有效。
> 其中的产物名与文件路径已按当前仓库结构更新；当时的大小与哈希仅作历史留档，重新构建
> 不必与之相同。当前结构与构建方式见 `docs/source-package-readme.md`。

验收口径：以本地 `SPS-PD-0.9.8` 为功能和玩法基准，在破碎像素地牢 4.0
引擎上保留可达内容；不要求逐像素、逐动画或逐文案完全一致。旧版会导致崩溃、
死档、不可达和存档损坏的缺陷允许修复。破碎版独有职业与装备保留源码但不进入
正常游戏流程。

| 要求 | 权威证据 | 结论 |
|---|---|---|
| 旧版源码覆盖 | `tools/audit-sps-port.ps1`：1916 个旧版 Java 文件，1722 个同路径实现、63 个同名适配、131 个有理由的无需独立迁移项、0 个缺失候选 | 通过 |
| 主线地图与流程 | `verifySpsBetweenBuilder`、`verifySpsBetweenLevels`、`verifySpsBspLayout`、`verifySpsRegularLevels`、`verifySpsFixedLevels`、五章首领时序门禁 | 通过 |
| 异界与挑战路线 | `verifySpsAdventureRoutes`、`verifySpsChallengeLevels`、`verifySpsTriangleLevels`、两类日志门禁及固定地图真实死亡/奖励链 | 通过 |
| 八个旧版职业 | `verifySpsMechanics`、`verifySpsClassSkills`、开局与皮肤 1 至 7 门禁；Android 八职业选择页实际截图 | 通过 |
| 旧版装备与消耗品 | 物品目录 371 项，加上武器、防具、法杖、戒指、神器、食物、药物、炼金、弹药和工具专项门禁 | 通过 |
| 怪物、首领与战斗 | 怪物目录 113 项、五章首领逻辑时序、26 张首领图集与切帧、挑战及异界首领死亡链 | 通过 |
| NPC、商店与任务 | 幽灵、法杖匠、铁匠、小恶魔、礼物居民、城镇 NPC、隐藏商店、过渡商店及实体日志页专项门禁 | 通过 |
| 宠物与宠物蛋 | 17 种普通宠物、35 种容魂灯映射、蛋与奖励、跨层携带、有效 50 层宠物之家及存档门禁 | 通过 |
| 存档与坏档恢复 | 旧字段双写迁移、记忆火复制、固定地图往返、首领缺失恢复、BossRush 阶段恢复及覆盖安装存档指纹 | 通过 |
| 隐藏破碎版内容 | `verifySpsMechanics` 检查正常选择、生成、商店和图鉴；Android 选择页仅显示八个旧版职业 | 通过 |
| 中文与资源编码 | `verifySpsContent` 对全部 207 个运行时 properties 文件严格 UTF-8 解码并检查 U+FFFD；中英文资源键一致；桌面和 Android 实际画面中文正常 | 通过 |
| 完整发布门禁 | `verifySpsRelease`：140 个任务成功，134 个执行、6 个命中缓存 | 通过 |
| 桌面构建与烟测 | ZIP 构建成功；OpenGL 标题、教程地图和炼金界面均真实渲染并自动退出；测试进程显式使用 UTF-8 | 通过 |
| Android 构建与烟测 | APK 覆盖安装成功；主菜单和八职业页正常；进程及前台 Activity 存活；日志无致命异常、ANR、原生崩溃、空指针或内存溢出 | 通过 |

所有修改完成后的最终联合命令 `verifySpsRelease desktop:distZip android:assembleDebug`
再次成功，共 187 个任务，其中 137 个执行、50 个命中缓存。以下产物大小和哈希在
联合执行后重新计算，保持一致。

最终桌面 ZIP：`desktop/build/libs/SPSEXPD*.jar`（当时为 `desktop-4.0.0-sps.1.zip`）

- 大小：86,877,816 字节
- SHA-256：`29F21145FD35D428B92A25129BF56122A3508B8FAF49F9AD5D55CE7119B205A5`

最终 Android APK：`android/build/outputs/apk/debug/SPSEXPD-debug.apk`（当时为 `android-debug.apk`）

- 大小：43,642,441 字节
- SHA-256：`00EBBDBCD3D5E1D8FF3CADEE9A47DB044597C2037621499F9248332028123FCC`

模拟器已有 `files/game1/depth1.dat` 在覆盖安装前后保持：3373 字节、Unix 时间戳
1790036527、SHA-256
`cbc2cbd73c88a10e2983a2e9055d1bca059dfab55618c4a1e61463e8c0cf3f18`。

最终画面证据：

- `docs/verification-evidence/sps-final-smoke.png`
- `docs/verification-evidence/sps-final-classes.png`
- `docs/verification-evidence/sps-final-desktop-title.png`
- `docs/verification-evidence/sps-final-desktop-tutorial.png`
- `docs/verification-evidence/sps-final-desktop-alchemy.png`

旧版源码中无获取入口或只有注释调用的原型不属于可达玩法，具体理由记录在
`tools/sps-reviewed-candidates.txt`。逐像素外观和逐帧表现不属于最终功能验收标准；
地图布局、入口出口、可达性、战斗回合、奖励、任务状态和存档结果仍属于验收范围，
并已由上述门禁覆盖。
