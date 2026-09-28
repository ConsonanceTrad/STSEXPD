# 融合版素材来源

## 新增职业素材

融合版4.0.0-fusion.8使用了蜕变像素地牢0.2.9fix4中的五套GPLv3职业素材。原文件保持不变，以新的融合版文件名复制并接入；源工程的 `LICENSE.txt` 为GNU通用公共许可证第三版。

| 融合职业 | 动画来源 | 原画来源 | 融合版文件 |
| --- | --- | --- | --- |
| 魔剑士 | `sprites/princess.png`，第8行来自 `sprites/princess1.png` | `splashes/princess.png` | `fusion_spellsword.png` |
| 演员 | `sprites/freeman.png`，第8行来自 `sprites/freeman1.png` | `splashes/freeman.png` | `fusion_performer.png` |
| 星兵 | `sprites/dm400.png`，第8行来自 `sprites/dm4001.png` | `splashes/dm400.png` | `fusion_soldier.png` |
| 信徒 | `sprites/friar.png`，第8行来自 `sprites/friar1.png` | `splashes/friar.png` | `fusion_follower.png` |
| 苦修者 | `sprites/ninja.png`，第8行取自 `sprites/ninja2.png` 第1行 | `splashes/ninja.png` | `fusion_ascetic.png` |

来源工程位于工作区的 `transformation-pixel-dungeon-master-0.2.9fix4` 目录。五张动画图集保留基础文件的前7行，并使用同一角色备用图集的第8行补齐“异界”外观，不混用其他职业素材。动画图集为256×128像素，职业原画为800×450像素，均通过构建审计验证。

特别惊喜原有的职业图集仍保留在资源目录中，方便后续比较或恢复；当前版本不会覆盖或删除这些原文件。
