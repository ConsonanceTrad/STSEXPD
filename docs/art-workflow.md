# 美术工作流（art-workflow）

> SPSEXPD 二期美术工具链：静态图集拆散为单格/变体多帧小图，外部软件重绘后一键回写。
> 生成日期：2026-09-28。工具：`tools/atlas-tool.ps1`（配置驱动）。

## 一、目录结构

```
assets-src/                        美术源目录（不参与游戏打包）
  items/                           items.png 物品图标（含变体族合并）
    _atlas.json                    图集配置（唯一真相）
    _index.csv                     展开索引（file,frameIndex,x,y,w,h）
    armor/ wands/ potions/ documents/ seeds/ stones/ rings/
    artifacts/ foods/ keys/ weapons/ materials/ misc/
    artifacts/horn.png             变体族=多帧横排（4 帧 15x15 = 60x15）
  avatars/ effects/{spell_icons,text_icons,banners,effects}/
  interfaces/{badges,buffs,large_buffs,hero_icons,talent_icons,
              change_icons,icons}/
  environment/<图集名>/             地形块（tile_000.png … 帧号=格序 row*16+col）
tools/atlas-tool.ps1               拆装工具（unpack / pack / check）
```

**命名规则**：
- items：语义名（`weapons/SHORT_SWORD.png`）+ 变体族合并文件（`artifacts/chalice.png`=3 帧横排）
- 其余图集：格号命名（`tile_034.png`、`badge_012.png`、`icon_005.png`），坐标查同目录 `_index.csv`
- tiles 的帧号即 `Terrain`/`SpsTerrainFrames` 语义（index=row*16+col），零映射成本

## 二、日常重绘流程

```powershell
# 1. 在 assets-src 下找到目标小图，用外部图像软件编辑（16x16/多帧横排，勿改尺寸/帧数）
#    变体族文件：整行横向是各变体，帧序 = 左到右（与 _atlas.json 的 frames 顺序一致）

# 2. 回写图集（自动备份为 items.png.pack-backup.png）
powershell -NoProfile -ExecutionPolicy Bypass -File tools\atlas-tool.ps1 pack -Config assets-src\items\_atlas.json

# 3.（可选）只比对不写：把 pack 换成 check
powershell -NoProfile -ExecutionPolicy Bypass -File tools\atlas-tool.ps1 check -Config assets-src\items\_atlas.json

# 4. 像素门禁 + 构建验证
.\gradlew.bat verifySpsRelease
.\gradlew.bat desktop:debug
```

**注意**：脚本含中文，文件带 UTF-8 BOM；执行策略受限时用
`powershell -NoProfile -ExecutionPolicy Bypass -File ...` 调用。

## 三、新增图标/素材

1. 在图集里找空格（或扩行），在 `_atlas.json` 的 `entries` 增加条目：
   ```json
   { "file": "weapons/NEW_ITEM", "frames": [ {"x":224,"y":976,"w":16,"h":16} ] }
   ```
2. `unpack` 生成小图 → 画图 → `pack` 回写。
3. 代码侧：`ItemSpriteSheet` 增加常量 + `assignItemRect(常量, w, h)`（w/h=图形实际尺寸，左上对齐）。
4. `verifySpsRelease` 门禁 + 游戏内目验。

**新变体族**：同一 `file` 的 `frames` 列多个矩形（横向排列）；**同族各帧尺寸必须一致**（工具会校验拒绝）。

## 四、已拆分 / 保留清单

| 类别 | 图集 | 状态 |
|---|---|---|
| 物品图标 | items.png | ✅ 拆分（364 文件/385 帧，7 个变体族：horn/chalice/rose/summon_ele/dewdrop/upgrade_goo/gun） |
| 地形块 | environment/tiles/water 外全部（39 张） | ✅ 拆分（4724 格，格号命名） |
| 界面/特效格表 | badges、buffs、large_buffs、hero_icons、talent_icons、change_icons、avatars、spell_icons、text_icons | ✅ 拆分（1476 格） |
| 手工矩形 | icons（84）、banners（6）、effects.png（10） | ✅ 拆分（矩形由代码 `uvRect(BySize)` 提取） |
| **动画帧（保留整张）** | heroes/mobs/npcs/pets 行走图、fireball、specks | 同动画不同帧不拆（`HeroSprite.java:42` FRAME 12x15、帧序硬编码） |
| **平铺/九宫格（保留整张）** | chrome、shadow、status_pane、arcs1/2、water/* | 无"格"语义：NinePatch 拉伸源 / SkinnedBlock 平铺纹理 |
| **动态坐标 UI 部件（保留）** | menu_button、menu_pane、radial_menu、surface、toolbar、talent_button、boss_hp | 矩形容器非字面量（TextureFilm/运行时计算），整张编辑更合适；boss_hp/menu_pane 当前无引用 |

## 五、验证与安全

- **幂等验证**：`unpack → check` 应为「更新 0 帧」，任何非零差异说明 `_atlas.json` 与图集不同步。
- **备份**：每次 `pack` 写盘前自动备份 `*.pack-backup.png`（同目录）。
- **像素精确**：工具用 LockBits 逐行回写，不做任何重采样/透明像素归一化。
- **打包隔离**：`assets-src/` 位于 `core/src/main/assets` 之外，gradle 不会打包进游戏。
- **颜色数检查**：`docs/art-index.md` 记录 items 每格颜色数（>20 标注 ⚠️ 可能发虚待重绘）。
