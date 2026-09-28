# 融合版素材来源

## 新增职业素材

融合版4.0.0-fusion.8使用了蜕变像素地牢0.2.9fix4中的五套GPLv3职业素材。原文件保持不变，以新的融合版文件名复制并接入；源工程的 `LICENSE.txt` 为GNU通用公共许可证第三版。

| 融合职业 | 动画来源 | 原画来源 | 融合版文件 |
| --- | --- | --- | --- |
| 魔剑士 | `sprites/princess.png`，第8行来自 `sprites/princess1.png` | 作者手绘（2026-09-29，替换蜕变 `splashes/princess.png`） | `fusion_spellsword.jpg` |
| 演员 | `sprites/freeman.png`，第8行来自 `sprites/freeman1.png` | 作者手绘（2026-09-29，替换蜕变 `splashes/freeman.png`） | `fusion_performer.jpg` |
| 星兵 | `sprites/dm400.png`，第8行来自 `sprites/dm4001.png` | 作者手绘（2026-09-29，替换蜕变 `splashes/dm400.png`） | `fusion_soldier.jpg` |
| 信徒 | `sprites/friar.png`，第8行来自 `sprites/friar1.png` | 作者手绘（2026-09-29，替换蜕变 `splashes/friar.png`） | `fusion_follower.jpg` |
| 苦修者 | `sprites/ninja.png`，第8行取自 `sprites/ninja2.png` 第1行 | 作者手绘（2026-09-29，替换蜕变 `splashes/ninja.png`） | `fusion_ascetic.jpg` |

来源工程位于工作区的 `transformation-pixel-dungeon-master-0.2.9fix4` 目录。五张动画图集保留基础文件的前7行，并使用同一角色备用图集的第8行补齐“异界”外观，不混用其他职业素材。动画图集为256×128像素，职业原画为800×450像素，均通过构建审计验证。

## 原创立绘登记（H 原则）

| 文件 | 内容 | 来源 | 日期 |
| --- | --- | --- | --- |
| `splashes/fusion_spellsword.jpg` | 魔剑士原画 | 作者手绘（原创） | 2026-09-29 |
| `splashes/fusion_performer.jpg` | 演员原画 | 作者手绘（原创） | 2026-09-29 |
| `splashes/fusion_soldier.jpg` | 星兵原画 | 作者手绘（原创） | 2026-09-29 |
| `splashes/fusion_follower.jpg` | 信徒原画 | 作者手绘（原创） | 2026-09-29 |
| `splashes/fusion_ascetic.jpg` | 苦修者原画 | 作者手绘（原创） | 2026-09-29 |
| `splashes/duelist.png` | 决斗家原画 | 作者手绘（原创，替换破碎原版 `duelist.jpg`） | 2026-09-29 |

以上六张 800×450 原画均为作者原创手绘，采用其现行版本为美术基线（图标/原画回归测试哈希以手绘版登记，防止被素材回退覆盖）。

特别惊喜原有的职业图集仍保留在资源目录中，方便后续比较或恢复；当前版本不会覆盖或删除这些原文件。
