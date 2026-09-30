# 美术工作流（art-workflow）

> SPSEXPD 图集工具链与工作约定。工具：`tools/atlas-tool.ps1`（配置驱动，unpack / pack / check）。
> 更新：2026-09-30（源码目录上提为 core/src/assets；门禁入口 verifySpsRelease）。

## 零、两条核心原则

1. **单一真相源 = `core/src/assets` 的图集**。
   不再有常驻的"源小图副本目录"（原 `assets-src/` 已归档至 `_ref/assets-src-archive/`，不再维护、不参与构建）。
   一切素材以 **core 图集为唯一事实**，从根上避免"多重事实 / 编译覆盖"（历史上多次发生：源小图与图集不同步、pack 反向覆盖手绘图、游戏实读构建产物等）。
2. **图集抽取 / 新建优先**。
   新增或修正素材时，**优先新建独立图集**（新 `_atlas.json` + `Assets` 常量 + 引用侧改造），**不在旧大图集（items / tiles 等）上就地改动**；仅"整张编辑更合适"的平铺 / 九宫格类（water、chrome…）例外。
   旧图集保持**只读**，其历史遗留内容（如地形图集第 4 行的 48-63 段）不再被新逻辑引用。

## 一、目录结构

```
core/src/assets/**             ★ 真相源：所有图集（png）
tools/atlas-tool.ps1                拆装工具（unpack / pack / check）
tools/atlas-meta/<图集名>/
  _atlas.json                       图集元数据：atlas(core 路径) + outDir(work) + entries(帧矩形)
  _index.csv                        展开索引（file,frameIndex,x,y,w,h）
  work/                             临时工作目录（unpack 生成，编辑后 pack 回 core；不入库，可随时删除）
_ref/assets-src-archive/            已归档的旧源小图目录（只作历史留档，禁止再引用）
```

**命名规则**：
- items：语义名（`weapons/SHORT_SWORD`）+ 变体族合并（`artifacts/chalice` = 3 帧横排）
- 其余图集：格号命名（`tile_034`、`badge_012`、`icon_005`），坐标查同目录 `_index.csv`
- tiles 的帧号即 `Terrain` / `SpsTerrainFrames` 语义（index = row*16+col），零映射成本

## 二、日常重绘流程（闭环，全程以 core 为准）

```powershell
# 1. 从 core 图集切出单格到 work 目录
.\tools\atlas-tool.ps1 unpack -Config tools\atlas-meta\items\_atlas.json

# 2. 在 tools/atlas-meta/items/work/ 下用外部软件编辑（勿改尺寸/帧数；变体族整行横向=各变体）

# 3.（可选）只比对不写：把 pack 换成 check
.\tools\atlas-tool.ps1 pack  -Config tools\atlas-meta\items\_atlas.json

# 4. 构建 + 游戏内目验（需要时手动跑 verifySpsRelease）
.\gradlew.bat desktop:debug
```

**注意**：脚本含中文，文件带 UTF-8 BOM；执行策略受限时用
`powershell -NoProfile -ExecutionPolicy Bypass -File ...` 调用。
`work/` 是草稿区，随时可删；删除后重新 `unpack` 即可从 core 复原。

## 三、新增素材 / 新增图集

**A. 在既有图集加一格**（仅限确有必要时；优先考虑新建图集）：
1. 在图集里找空格（避开已知空白陷阱区），在 `tools/atlas-meta/<图集>/_atlas.json` 的 `entries` 增加条目：
   ```json
   { "file": "weapons/NEW_ITEM", "frames": [ {"x":224,"y":976,"w":16,"h":16} ] }
   ```
2. `unpack` 生成小图 → 画图 → `pack` 回写。
3. 代码侧：加常量 + 尺寸登记（`ItemSpriteSheet.assignItemRect` / `Icons.uvRectBySize` 等）。

**B. 新建独立图集（推荐路径）**：
1. 用脚本从既有 core 图集**逐像素抽取**所需帧 → 直接生成新图集 png（放 `core/src/assets/**` 合适目录）；
2. 新建 `tools/atlas-meta/<新图集>/_atlas.json`（`atlas` = 新图集 core 路径、`outDir` = `tools/atlas-meta/<新图集>/work`）+ `_index.csv`；
3. 代码侧：`Assets` 加常量 + 引用侧改造（渲染层 / UI），旧图集对应内容**保留为只读遗留**、不再引用；
4. 目验。
   **先例**：水缝合边（`environment/water/sps_water_edges_*.png`，7 张/区域，帧 0-15 = 缝合 bit），
   由 `SpsWaterEdgesTilemap` 独立层渲染 —— 根治了"地形图集体系不同导致水渲染错帧"（铁砧/雕像等图标）。

**新变体族**：同一 `file` 的 `frames` 列多个矩形（横向排列）；同族各帧尺寸必须一致（工具校验拒绝）。

## 四、已拆分 / 保留清单

| 类别 | 图集 | 状态 |
|---|---|---|
| 物品图标 | items.png | ✅ 拆分（364 文件/385 帧，7 个变体族） |
| 地形块 | environment/tiles 全部（39 张） | ✅ 拆分（4724 格，格号命名） |
| **水缝合边（独立抽取）** | environment/water/sps_water_edges_*.png（7 张，256x16） | ✅ 独立图集（帧 0-15 = 缝合 bit，`SpsWaterEdgesTilemap` 独立层） |
| 界面/特效格表 | badges、buffs、large_buffs、hero_icons、talent_icons、change_icons、avatars、spell_icons、text_icons | ✅ 拆分（1476 格） |
| 手工矩形 | icons（含新增）、banners、effects | ✅ 拆分（矩形由代码 `uvRect(BySize)` 提取） |
| **动画帧（保留整张）** | heroes/mobs/npcs/pets 行走图、fireball、specks | 同动画不同帧不拆 |
| **平铺/九宫格（保留整张）** | chrome、shadow、status_pane、arcs1/2、water/sps_water_*.png（水面平铺） | 无"格"语义：NinePatch / SkinnedBlock 平铺纹理 |

## 五、验证与安全

- **幂等验证**：`unpack → pack` 应为「更新 0 帧」，非零差异说明 `_atlas.json` 与图集不同步。
- **备份**：每次 `pack` 写盘前自动备份 `*.pack-backup.png`（同目录，用完请删，勿入库、勿进包）。
- **像素精确**：工具用 LockBits 逐行回写，不做重采样/透明像素归一化；**禁止用 GDI+ DrawImage 改图集**（会做 alpha 混色改色）。
- **单一事实**：任何情况下不得再建立"常驻源小图副本目录"；`work/` 仅临时。
- **构建同步**：改完图集必须走一次 gradle 构建并重启游戏进程（游戏读构建产物 `desktop/build/resources/main`）。
- **颜色数检查**：`docs/art-index.md` 记录 items 每格颜色数（>20 标注 ⚠️ 可能发虚待重绘）。
