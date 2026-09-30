# SPS-SPD port status

> **Note on evidence paths:** the `build/reports/sps-*.png` files referenced below were
> captured into the build output directory, which is not tracked by git. The final
> acceptance screenshots kept in the repository are under `docs/verification-evidence/`.
> The current repository structure and build commands are in `docs/source-package-readme.md`.

## Definition of complete

The port is functionally complete when the player-visible SPS-PD 0.9.8 systems
and progression can be played on the Shattered 4.0 base: heroes, skills, items,
recipes, buffs, mobs, bosses, NPC quests and shops, pets, routes, maps, traps,
plants, journals, persistence, and endings. Exact pixel, animation, and wording
parity is not required where it does not change gameplay. Merely retaining a
class name or image still does not count as a behavioral port.

## Current baseline

The first SPS-SPD baseline preserves the compilable work from the earlier local
Fusion project. Its verified content includes:

- 25 optional adventure destinations and eight challenge destinations;
- persistent one-time route rewards and return paths;
- companion selection and summoning, a Sokoban block, and adventure NPCs;
- eight SPS-PD hero choices, eight combat styles, and nine quickslots;
- a first set of SPS weapons, armor, artifacts, rings, wands, food, and medicine;
- English and Simplified Chinese strings for the migrated content.

This is not yet a claim of full parity. The legacy tree contains 1,916 Java
files and 307 PNG plus 49 MP3 assets. After the medicine, plant-food, plant-product,
associated potion, class-skill, map, armor, glyph, wand, ranged-weapon, gun,
special-ammunition, ordinary-melee, weapon-enchantment, skin-seven, Rock-code,
basic-food, special-food, SPS holiday-pasty, enhanced-plant, tutorial, fishing-boss,
first-run intro, test-time loadout, relic-weapon, legacy-bag, glass-totem,
fly-chain, utility-item, coconut-summon, soul-lamp, town block-weapon,
dangerous-bomb, HBB-flag, Orb-of-Zot, Dolya-slate, ChallengeBook, physical-journal,
Tengu-key, special-arrow, DewVial, transmutation-well, old-high-grass, and SPS
mainland-guide, complete item-catalog, and complete creature-catalog migrations,
the audit reports 1,722 exact relative-path matches, 63 additional class-name matches,
131 reviewed adaptations, and no candidates still requiring review. These
are conservative source-review figures, not
claims that every matched upstream class already reproduces SPS behavior.

The main route now follows the actual local SPS-PD 0.9.8 depth table: peaceful
transition floors at 1/6/11/16/21, three ordinary floors per chapter, bosses at
5/10/15/20/25, and the ending floor at 26. The transition level has an SPS shop,
the four first-floor berries, and a functional tent room using the original tent
and anvil pixels. Tent rest consumes one food item, advances by that food's energy,
cleanses the legacy status set, and grants temporary concealment and terrain
immunity. The anvil currently implements the legacy recipes whose ingredients
have been migrated, including all 19 special-ammunition recipes: two pieces of
stone ore make heavy ammo, and stone ore plus each corresponding seed makes the
other 17 ammo types, with both rotberry and freshberry accepted for rot ammo.
Water plus any SPS meat food now also produces the legacy medium steak. The
remaining source forge branches are restored as well: five nuts make six
cookies, four ore plus water makes the advanced time pill, the five food groups
make eight mixed pizzas, fruit-water-ore makes two candies, a built bomb plus
two seeds rolls the original bomb pool, dark gold makes a Pocket Ball, Magical
Infusion becomes a Great Rune, and Gel becomes a Torch. Output quantities and
the original recipe priority are covered by the headless forge gate.
The first floor also contains the legacy mushroom and
Tinkerer1 interaction: its exit remains locked until the mushroom is delivered,
the chosen waterskin mode is saved, and the researcher cannot be damaged. The
shop/tent adjacency and all eleven gift residents now include their friendship,
reward, pet-egg, hatching, companion, and persistence flows. Shop tents generate
one resident while ordinary tents generate two protected depth-85 guards, matching
the source. All five transition floors now render through their original 256 by 64
terrain atlases and original water textures; a valid modern atlas remains underneath
only to satisfy Shattered's raised-tile renderer. The common transition painter also
restores the legacy water/grass, old-high-grass, decoration, visible-door and entrance-sign
rules. Oversized layouts are retried before painting so rooms cannot exceed the legacy
48 by 48 boundary, and the complete-map gate checks 250 fixed seeds in addition to the
2,500 topology seeds. The complete three-stage dew upgrade chain is now reachable from
Tinkerer1, Tinkerer2, and TrianglePLevel. Colored stacks heal at their full quantity,
Warden drinking restores four percent per drop, planting fills legacy flower pots from
the SEED4 deck, dew-water grows over old high grass, and cleansing removes Tar and
STRDown. Capacity, overflow, mode persistence, final 200-point expansion, upgrade-item
consumption, bilingual strings, and all three world sources are covered by the utility gate.

The five ordinary main-route regions now use a separate SPS generator instead
of Shattered's loop and figure-eight builders. It restores the legacy 48 by 48
BSP split, minimum room count, distant entrance/exit choice, two weighted main
paths, 50%-70% connected-room target, old standard/tunnel assignment, door
probabilities, 13-20+depth/2 trap density, entrance sign, old floor-feeling
probabilities, and the original per-region water/grass/chasm patch parameters.
The standard-room pass now also matches the source's adjacent-room merging,
randomized odd tunnel centers, inset entrance/exit cells, prison/city perimeter
passages, and all seven standard-room switch variants (graveyard, striped,
shelved or statue study, bridge, fissure, burned, and the empty fallback).
Special rooms use an independent SPS candidate rotation with the original
shuffle/move-to-end behavior, and that rotation is saved and restored without
depending on Shattered's special-room deck.
It now also restores the exact sewer water-wall and four-neighbour decoration,
prison corner and torch decoration, cave corner closures, decorated doors and
unconnected-room chasm seams, city floor/wall decoration, and halls eight-neighbour
decoration. Every ordinary halls exit is locked and paired with one same-depth SPS
skeleton key; its floor-start torch count is restored from two to the legacy one.
Generation is capped at 64 layout attempts and the engine-level build loop is
capped at 100 attempts. Fixed-seed tests currently cover 5,000 BSP layouts and
2,000 complete five-region terrain maps, including bounds and entrance-to-exit
reachability, regional decoration, halls locks, and exit keys. Initial ordinary
enemy counts use the source formula on floors 1-24, including its post-amulet
branch. Initial cave, city, and halls enemies receive physical and magical armor
of depth times 5, 10, and 15 respectively, with one glass-shield layer in halls;
quest characters are excluded from the initial-enemy clear gate. Material, cooking,
jungle, ruin, wishing-pool, memory-fire, hidden
shop, tent, glass, and barricaded rooms now have dedicated SPS implementations.
The original blacksmith painter and all seven weighted hidden-room painters have
been checked directly against 0.9.8, including terrain, doors, NPCs, rewards,
well effects, and the deliberate repeated entries in the hidden-room deck.
The hidden shop restores its six permanent-life offers, eight gold offers,
three original keepers, random free-cell keeper placement, pedestal area, hidden
entrance, and replenishment after a life purchase. The transition shops restore
the five depth-specific inventories, perimeter placement, chapter gun/bow tiers,
summon slot, rocket, ankh, sand bags, rare slot, and depth-21 imp water ring.
Every non-shop ordinary exit room now receives
the source-weighted SPS guard for its depth, including the legacy physical and
magical armor and one-hit `ExProtect` transition into `BoxStar`. Every main-route
non-shop ordinary floor now also places exactly one of the 19 source-weighted
enhanced plants inside its entrance room. Shop floors and branches suppress this
placement, and signs and dew blessings cannot overwrite the plant.

All five main-route boss floors now render through the matching original SPS
terrain atlas and water texture while retaining a compatible modern atlas below
the complete-map overlay. The depth-5 and depth-10 source layouts are checked
cell by cell; depths 15, 20, and 25 retain their source procedural geometry and
decoration. Runtime entrance sealing, arena-door opening, final-hall wall removal,
exit unlocking, and save restoration all update and preserve the legacy overlay.
The fixed-level gate checks all 2,304 cells for 2,500 seeds in each of the three
procedural boss floors, in addition to the two fixed layouts, and rejects every
legacy-atlas index outside its 64 cells. The main-route boss animation pass has
now been audited against 0.9.8. The 26 main-route boss and minion sprite sheets
are byte-matched to 0.9.8 and checked for valid
frame ranges. The prison wanderer, Tank, and Tower frame timing and sequences are
restored, and SPS Tengu now uses the original 159 by 32 sheet instead of Shattered's
same-name texture. The interaction audit also restores the DM-300 tower's charged-dew
burst, electric resistance and gas defenses; the dwarf king undead's toxic-gas clearing
and bone sound; and Yog's original dark, psionic and elemental defenses. Ranged boss
callbacks now settle safely when a target sprite or field-of-view array is unavailable.
Save recovery no longer mistakes an orphan sewer lasher or shadow rat for a living Sewer
Heart or Plague Doctor, which previously left the exit permanently sealed. Full visible
combat timing across all variants still needs device-level runtime review. The original title, gameplay,
and surface tracks (`theme.mp3`, `game.mp3`, and `surface.mp3`) are now copied
byte-for-byte from 0.9.8 and used in the same three scene roles. Quest-music
callbacks also return to the single legacy gameplay track. All 46 sound effects
and all three music files are byte-matched to 0.9.8, and release validation pins
the SHA-256 hash of every one of the 49 MP3 assets.

The animation engine now has an explicit primitive `int[]` frame overload. This
fixes a Java varargs mismatch which treated data-backed frame lists as one object
and produced a null first frame. It covers gift residents and the shared sewer,
prison, cave, city, halls, challenge, and Yog-fist sprite builders. The eleven gift
residents also restore their separate idle/run/attack/death rates and complete
source frame sequences; the meat seller coin and Torch burning effects are active.

The hidden-room pass now also restores the SPS pit instead of routing it through
Shattered's weak-floor room. It has an open interior, a far-corner dry well, a
broken one-way entrance, a persistent dedicated sign, and the original skeletal
cache containing teleportation, equipment, an ankh, two fadeleaf seeds, and one
or two extra prizes. The magic-well room keeps its hidden entrance, omits the
modern iron key, and plants one of the three SPS special plants beside an equally
weighted awareness, health, or transmutation well. Glass-room rewards use the
legacy fixed center. Barricaded-room bookshelf lengths now account for Shattered's
inclusive room dimensions and retain the old fallback reward pool. All random
placement loops use bounded candidate lists.

The ending floor now uses the legacy 48 by 48 fixed geometry, including entrance
1456, pedestal 592, its central corridor, statues, water pattern, solid chasms,
and eight-cell view distance. It drops the SPS chocolate pudding and opens the
pudding scene instead of exposing Shattered's amulet ending. The memory-fire
multi-save flow now copies the active run only into an empty slot, refuses to
overwrite an existing run, validates every copied bundle, and removes an
incomplete destination after failure.

The Palantir now enters a dedicated branch containing the legacy 48 by 48 Zot
prison generator. Zot retains its 25,000 HP, regeneration, ranged attack,
teleportation, phase and magic-eye summons, persistent kill gate, soul reward,
and Palantir-only return path. The Gnoll King treasure-map branch and the
five-stone Power Hand ending path have likewise been restored with persistent
state and missing-boss recovery. These dedicated branches do not make the
generic adventure destinations with similar names complete.

Adventure destinations 9 through 12 no longer use the generic AdventureLevel.
The infestation route restores the 48 by 48 central holding room, eight-rectangle
outer arena, visible traps, twenty Gold Orc/Fiend residents, and the ten-Shadow-Yog
encounter. Shadow Yog keeps its health thresholds, teleports, trap conversion,
Fiend summons, and last-copy completion gate. The hidden-Tengu route now has a
dedicated 48 by 48 loop, concealed chest annex, and the original 2,000-HP TenguDen
with periodic jumps and assassin reinforcements. Skeleton King and Crab King use
their separate legacy long halls, original terrain sheets, trigger-based parties,
stats, status attacks, drops, and journal completion. The lightning shell now
actually receives damage absorbed by hermit crabs; the legacy zero-charge random
crash and unbounded teleport searches are fixed. The Tengu maze uses its exact
legacy four-leg BSP loop. Destinations 13 through
18 now use dedicated maps: the thief king hall, Gnoll King field arena, honey
safe room, painter town, fixed dragon cave, and the depth-41 four-leg pursuit
BSP. The pursuit branch retains its shared entrance/return room, attached royal
chamber, water and grass parameters, single Bandit King, countdown-and-flee
behavior, and completion gate. Its BSP searches are bounded and covered by 250
graph seeds plus 250 complete-map seeds. Destination 19 reuses the original
energy-core layout as the old deep-mine descent did, while Otiluke now completes
the correct journal route for both entries. Destination 20 restores the fixed
grass treasure room, its 29% chest placement, first-visit gold range, rare
upgrade scrolls, and guaranteed upgradable Lucky Badge; the unused legacy
portal and sheep tables remain empty as in the source. Destination 21 now enters
the nine-stage Boss Rush arena from the journal as well as the original challenge
item, completes the journal after the final UAmulet stage, and suppresses the
fight on completed revisits. Destination 22 now uses the depth-85 Chaos floor's
48 by 48 SPS BSP with six-cell minimum partitions, legacy water/grass ratios,
Distortion traps, pedestal endpoints, chasm removal, and journal completion at
the exit. Its 16-18 initial enemies now use the complete 43-species depth-85
pool, including the restored Wraith Warrior, Bokoblin, and Wisdom Protector with
their original sprites and combat behavior. The old source routes journal pages
23 and 24 to `DeadEndLevel`; it contains no Zot temple or throne map to port, so
the corresponding generic destinations remain explicitly identified placeholders
rather than invented replicas.

The hidden-Tengu route now uses the original four-leg random BSP loop instead of
the provisional hand-authored five-room map. Its independent concealed chamber
restores the perimeter chest layout, legacy egg/seed/berry/summon/bomb/gold prize
pool, and Storm and Rain treasure hunter. Both the graph builder and passable
boss-cell selection are bounded and covered by 250 complete-map seeds.

All three prison boss variants now also drop the physical `TenguKey`. It preserves
the source's main-route floor restrictions, exact return depth and cell, black
glow, no-return gate until TenguDen dies, and one-use consumption on return. The
kill state is saved independently so a key-only run cannot become trapped without
an Adventure Journal; completed early-port journal saves remain accepted. Its
sprite is copied pixel-for-pixel from the 0.9.8 atlas and the dedicated headless
gate exercises the actual common prison-boss reward path.

The legacy special-arrow path now has exact `Arrows`, `MagicHand`, and `RiceBall`
classes. Magic Hand keeps its 1-5 damage, 3-4 random stack, 20-gold unit value,
five-item transition-shop source, and one special-loot theft per monster. Rice
Ball keeps its 1 damage, 10-gold value, living-target property exclusions,
drowsiness, and relocation to a random respawn cell. The exact 15-entry `ARROWS`
pool, including the duplicated Charm Fruit entry, again supplies all three drops
from Huntress skill three; the separate seven-entry `RANGEWEAPON` pool is also
restored. Both new categories were appended after the old generator ordinals so
existing category numbers remain stable. Non-mob hits, null loot, missing heap
sprites, absent maps, and 20 failed relocation attempts are handled safely. Both
icons are copied pixel-for-pixel from the 0.9.8 atlas, and the bilingual resources
and all acquisition paths are covered by a dedicated headless gate.

The Shadow Eater quest chain now restores Honey Poooot's post-Otiluke challenge
invitation, its saved one-claim guard, the one-use honey-refuge trip and Empty
Body reward, Ice13's Power Hand exchange for the Chaos Contract, and the existing
SaidBySun Curse Blood purchase. Bringing all three materials to the troll
blacksmith consumes them and forges the actual Shadow Eater weapon, rather than
the separate unused portal prototype. The weapon retains the source's fixed
strength requirement, damage scaling, curse suppression, self-debuff proc,
kill charge and awakening. The prototype portal remains loadable and usable for
content/save parity, and both portal items preserve their exact return floor,
branch and position. All four item icons are copied pixel-for-pixel from the
legacy item sheet, and a headless test covers material rules, forging, charge,
awakening and persistence.

The legacy Lucky Badge and Bandit King boomerang are now functional rather than
placeholder rewards. The badge restores its level, Soldier, Superstar, and
Afly-blessing luck formula, rare-drop chance, ordinary-floor extra-item loop,
and monster drop bonus, with a 64-item guard against malformed random streams.
The boomerang keeps its original strength and damage growth, can be upgraded,
never loses durability, and returns immediately after either a hit or miss.
It can consume and retain any of the 18 special ammo coatings. Every old ammo
effect has been restored, including elemental damage, status effects, gold
consumption, execution, and evolve-to-life-cell behavior. Evolve ammo does not
transform bosses or award false kill experience, gold cannot become negative,
and thorn/dew random bounds are safe at zero or low damage. English and
Simplified Chinese strings, the original boomerang and badge icons, and the
original 256 by 32 life-cell sprite are covered by automated resource checks.

Shattered-only Duelist, Cleric, and Spellsword code and assets remain in the
tree for later testing, but normal class selection and randomization expose
only the eight SPS-PD classes. Confirmed Shattered-only equipment has also been
removed from the primary generation/catalog decks, and transition shops use a
separate SPS inventory. Shared-name equipment enters SPS generation only through
the explicitly audited category gates below; all other Shattered implementations
remain hidden from the normal SPS flow.

The complete SPS ordinary armor path is now separate from Shattered's retained
armor classes. It contains all 18 normal armors, their fixed strength
requirements, defense growth, evasion, stealth and class-skill energy stats,
and the source generator's two-choice strength matching. All 13 source armor
glyphs are in the normal glyph pool, including mutually exclusive elemental
resistances, delayed ice damage, revival and terrain/status effects. Armor kits
produce the eight SPS class-specific passive armors; Shattered class armor code
remains compiled but is no longer produced by this route.

The first complete ordinary melee slice likewise uses independent SPS classes,
leaving every Shattered implementation in the source tree. Its 20 weapons use
the original equal-weight pool and two-choice strength matching, fixed base
damage and strength, per-upgrade damage/accuracy/delay/reach changes, bleeding,
cripple, paralysis, root, armor-break and extra-hit effects, save restoration,
English and Simplified Chinese text, and 20 pixel-identical source icons. Unsafe
legacy random ranges at zero or very low damage are clamped instead of crashing.
The source's 14 ordinary weapon enchantments now replace Shattered's enchantments
in the normal random pool while all Shattered classes remain compiled. Their
light and heavy elemental damage, Four Clover bonus, burning, tar, growth,
roots, ooze, terror, shadow curse, one-hit damage charge, physical shield,
wet, cold, frost, frostbite, blindness, holy-light mark, static shock, and
single-path lightning chain are restored. The source's unsafe equal or reversed
random damage bounds and edge-wrapping lightning search are explicitly guarded.
The event weapon pool, relic group, musical and utility weapons, and all special
and starting groups now have strict per-item or behavior gates; the abrasion
durability challenge is restored as part of the same release suite.

The source generator's three overlapping weapon pools are now distinct again:
`WEAPON` contains all 60 legacy entries in source order, `MELEEWEAPON` contains
the first 40 and performs the legacy two-candidate strength comparison, and
`OLDWEAPON` contains the first 20 for statues, sentinels, and Xixi Box rewards.
The 60-entry pool includes the 20 bows and guns and therefore uses the common
`Weapon` type instead of an unsafe melee cast. Stone Cross, Mirror Doll, Hand
Light, Curse Box, Small Chakram, Huge Shuriken, and Tamahawk were added with
their source stats, effects, direct drops, bilingual text, persistence, and
pixel-identical icons. Fixed-level testing exposed and fixed a construction-time
crash where a mine sentinel could upgrade a thrown weapon before a hero existed;
the three legacy sentinels now draw from the source's 20-entry base pool.

All eight default SPS hero loadouts now use their legacy equipment and food while
the Shattered-only classes and equipment remain compiled but hidden from the
normal flow. The follower starts with Wooden Staff, Cloth Armor, healing potion,
Sign Box and Moon Cake; the ascetic starts with Weird Sand, Vest Armor, Big
Battery, Active Mr Destructo and three Fruit Candies. Wooden Staff restores its
eight-hit five-times strike with per-item saved charge, Weird Sand restores its
two-cell silence and shield punishment, and Big Battery restores both its
seven-effect empowerment and visible-enemy fatigue overload. The five faiths
use the original SPS faction groups and 50% outgoing/25% incoming modifiers;
legacy faction properties have been restored alongside compatibility mappings
for Shattered elemental and inorganic properties. Skin set 1 now restores all
eight legacy loadouts, their twelve exclusive tools, artifacts and weapons,
two-ring and secondary-weapon slots, original item art, persistence, and runtime
charge, kill and damage hooks. Skin sets 2 through 7 have also been restored and
covered by dedicated tests for all eight heroes, including their source-specific
loadouts, mechanics, state persistence, and original item icons. The skin-seven
Performer path additionally includes all 12 Rock-code chips, their saved energy
and combat effects, and the ten source boss drops gated to Performer skin 7.

Four source defects were corrected in these slices: Wooden Staff charge is no
longer a static value shared by every staff, fatigue counters are no longer
shared globally by every affected character, and Holy Mace and Brave Book
imbue levels no longer leak between separate item instances. The item-atlas updater now copies
raw ARGB pixels instead of drawing through GDI+, which had normalized transparent
pixels when the script was rerun; its regression coverage includes all restored
wand, gun, bow, armor, melee, food and starting-item slots.

The first migrated vertical slice is the complete legacy medicine family: the
Pill base plus 19 concrete SPS medicines. They use Shattered buffs and save
semantics, have English and Simplified Chinese text, and are registered as a
normal dungeon generation category. The earlier Fusion-only mending tonic is
retained as a twentieth generated medicine.

The ordinary food deck now uses the legacy ration, SPS holiday pasty, and
small-ration weights of 8:2:5. Shattered's pasty remains compiled but is hidden
from the SPS start and generation paths. The SPS pasty restores all nine source
date rules, effects, names, descriptions, and pixel-identical icons. Raw meat is
again dropped by early SPS enemies and can be
processed by fire, ice, lightning, darkness, earth, or light into the six source
variants without losing stack quantity. Their hunger values, healing, barkskin,
invisibility, cleansing, leftover-meat and long-duration funny effects are
covered by a headless test. Fish crackers, honey,
both pet foods, harmful waste, medium steak, nut pudding, sashimi, Nian cake,
and zongzi now retain their source energy, prices, health changes, shields, and
status effects. Nian cake summons the separate roaming Year Beast on depth 25;
quick kills drop the Spring Festival location page, which can be recorded in the
adventure journal. The source's unsafe unbounded spawn search is replaced with
a finite scan, and empty off-map heap reactions no longer crash. Alchemy now
restores all 54 deterministic recipes from the source window, including their
zero energy cost, exact per-slot consumption, stacked outputs, and ordered
Seedpod override. Generic three-seed brewing also follows the source rule of
selecting one of the three ingredient seeds and producing its corresponding
potion, without Shattered's unrelated random-potion branch. The interface has
3 slots normally and expands to 4 or 5 at equipped toolkit levels 5 or 10. The
reachable town NPC routes also restore
HBB's fish-cracker drop and Shower's fish-flavored pet-food drop. Cooked
blandfruit is again a separate Brewed item with the source potion effects,
eight class bonuses, two-turn use, save data, glow colors, and shopping-cart
support. Invalid combinations produce one pixel-identical garbage item per
occupied slot. Focused food and alchemy tests pass. The real OpenGL alchemy UI
has also been rendered at 540 by 960 and 960 by 540: the Chinese title and
description, three input slots, combine/output controls, guide, and energy row
are visible without clipping, overlap, or mojibake. Every legacy town-NPC
`SupercreateLoot` acquisition route, plus the tutorial guide, first-floor
tinkerer, and Rat King, is restored and covered by the town-NPC gate. The source warrior
healing roll is clamped near maximum HP to avoid its reversed random range.

The eight SPS-only plant and seed types are also present and registered in the
seed deck: dewcatcher, dreamfoil, freshberry, nut vine, phase-pitcher, seed-pod,
SiO2 flower, and upgrade eater. Effects are expressed through Shattered items
and buffs so the plants participate in current saves, generation, and Warden
interactions.

All 19 legacy seed types now have their separate enhanced entrance-room form,
including the source plant frame and seed icon. Their exact harvest counts and
drop decks are restored: ten fruit missiles, blandfruit, berries, norn stones,
upgrade eaters, transmutation balls, green spores, glass fruit, and rotberry's
center seed plus adjacent gold. The nine previously missing fruit missiles
restore their fixed damage, direct-hit buffs, and ground blobs or terrain
effects. A headless test covers all mappings, unique adjacent drops, boundary
behavior, save restoration, combat effects, 2,000 generated ordinary maps, and
37 pixel-identical source sprites. Rotberry's enhanced form explicitly names
`Rotberry.Seed`; this fixes Java resolving the unqualified legacy name to the
generic `Plant.Seed` class.

The plant reward chain now uses SPS content rather than placeholder Shattered
items. It includes eight fruits, six vegetables, three colored dewdrops, the
phase-pitcher fruit, star-eater fruit, three strengthening essences, and the
silica flower's glass fruit projectile. Four legacy berries have their original
weighted generation deck, and all migrated food has dedicated English and
Simplified Chinese text plus original SPS pixel art where available.

Five SPS plant-associated potions are also present: mending, might, mixing,
shielding, and overhealing. They use a separate identified potion category so
the original Shattered twelve-color identification pool and its saved state are
not expanded beyond their supported size. Nut vine, phase-pitcher, seed-pod,
SiO2 flower, and star-eater seeds are connected to these potions through the
current seed alchemy recipe.

The main-route enemy rotations for depths 2-4, 7-9, 12-14, 17-19, and 22-24
now use the legacy SPS-PD species and exact relative weights. The depth 22-24
slice includes demon goo splitting and water healing, thief-imp theft and item
return, demon-flower burst attacks and weakening spores, sufferer erosion and
glass shielding, and the demon shooter's charged ranged attack, corruption gas,
retreat, and mutually exclusive drops. Their transient states are persisted and
unsafe legacy neighbor indexing and reversed random bounds are corrected. The
ordinary-floor room painters and regional secondary decoration are covered by
source comparison and fixed-seed map gates; unresolved parity work is tracked
in the boss, UI, animation, and edge-interaction sections instead.

The sewer boss floor now selects all three SPS-PD depth-5 encounters: SPS Goo,
the Sewer Heart, and the Plague Doctor. The Heart and Doctor include their
legacy summons and expose Missile Shield and Potion of Mage through their
special-loot methods. Performer skin 7 also receives Gleaf or Dpotion from the
corresponding boss. All eight class-skill items are now registered. Their four
level-gated actions restore the legacy rewards, summons, terrain edits,
permanent-health costs, cooldowns, and level-56 upgrades. Sixteen supporting
buffs are connected to Shattered's current strength, damage, defense, speed,
magic-shield, kill, and save flows. The unreachable Huntress frost branch,
overlapping war-tree spawn, and unsafe terrain edges were corrected. Prison and
caves bosses now drop the actual class Skill Book rather than temporary
attribute books. A headless test covers all eight mappings, representative skill
effects, cooldown persistence, buff persistence, and terrain boundaries.

The legacy `TEST_TIME` challenge now restores its complete developer start after
normal class initialization. Both journals are unlocked to all 25 adventure and
eight challenge routes; the five legacy bags, gateway and utility items, test
weapon, mastery tome, three eggs, ten pocket balls, all 199- and 10-item stacks,
five Norn-stone colors, twelve identified +10 rings, +5 thieves' armband, 10,000
gold, and 10,000 maximum/current HP are present. Page and slate items whose only
purpose was route registration are represented by the journals rather than
duplicated inventory entries. The backpack expands to at least 64 slots only
while this challenge is active, preventing the old oversized loadout from being
silently discarded without changing ordinary runs. The restored seed pouch and
wand holster each provide their original thirty slots and category rules.

The dummy scroll again creates the source 30-HP doll or the empowered 50-HP doll,
with fixed two-point incoming damage, one-point pre-hit recovery, turn decay, and
the matching concealment effects. Its adjacent-cell scan now checks map bounds,
and spawning without an initialized render scene has a sprite-free placement
path; these fix the source edge crash and a partial-scene null dereference.

The five Norn-stone relic weapons now use the source-compatible relic base and
their five dedicated enchantments. Their tier-six damage formulas, fixed 20
strength requirement, reinforced flag, +2/+4 upgrade growth, 1,000-charge active
powers, source prices, enchantment persistence, and charge save state are covered
by runtime tests. Ares restores delayed soul healing, Loki uses its stronger
duration-based poison, Neptune chains through adjacent creatures, Crom applies
the best repeated damage roll, and Jupiter terrifies targets. The old overloads
silently disabled three intended enchantments; the port executes the documented
effects and replaces Neptune's fixed 20-target chain buffer with a bounded visited
set to prevent overflow. Jupiter's particles now tolerate a partially initialized
render scene while its damage still resolves.

A localization audit found 317 English/Chinese key pairs carrying the full Java
package prefix. The runtime strips that prefix before lookup, so those entries
could display inherited or missing text despite valid UTF-8 bytes. Existing
canonical duplicates were retained, every other key was normalized, and the
content gate now rejects the invalid prefix in any message bundle.

The two ordinary-start containers omitted by the earlier port are restored.
`ArrowCollecter` holds ranged and missile weapons, while `KeyRing` holds dungeon
and SPS boss keys, Triforce route items, rings, maps, and the two route journals;
both use the source thirty-slot capacity and `50 * quantity` value. Every one of
the eight playable classes receives both bags, while the isolated `NEWPLAYER`
tutorial does not. Their source sprites are copied pixel-for-pixel into reserved
atlas cells without changing the then-current 256 by 944 sheet dimensions.

`GlassTotem` is back in the artifact deck and in the Gnoll and Lich Dancer loot
paths. It charges once per five turns to 100, upgrades through the full-charge
attack blessing, applies the source 200-turn paired attack/vulnerability values,
and retains the two-level defensive exhaustion, two-hit glass shield, cursed
backlash, full-charge short blessing, and save state. `FlyChains` is again a
separate zero-weight artifact and the equipped +3 item for skin 3 on all eight
classes. It reuses the modern chain's hardened pulling and collision code, but
restores the source recharge curve, kill-experience thresholds, charge caps, and
level-consuming 90-percent attack seal with Locked, Silent, and Slow. Unused
`GlassTotem` imports in the old gift NPC files are not treated as acceptance
rules: none of their actual `loveitem` methods accepted the artifact.

Five remaining legacy utility items are now functional. Green dewdrops heal
directly without a waterskin or add the source's randomized reserve amount when
one is carried; the Iron Maker's one-seed result now produces this item. Gold can
be packed in 10,000-unit bags and unpacked without value loss. Special Coin keeps
the source's intentionally incomplete pickup behavior rather than silently
becoming ordinary gold. Mit Bottle permanently adds one strength and ten maximum
health, immediately heals to the new maximum, and persists through `HTBoost`.
Ordinary starts now instantiate the exact legacy `DewVial` class; it inherits the
already migrated waterskin implementation so early port saves containing
`Waterskin` remain readable while new saves use the source class path.
Unblessed Ankh consumes 100 reserve dew to create a normal Ankh, dropping the
result safely when the backpack is full. Strength Potion transmutation now yields
Mit Bottle, and Zombie special loot again yields the unblessed cross. A headless
suite covers quantities, sources, persistence, full-backpack handling, bilingual
UTF-8 strings, and seven pixel-identical source icons. It also caught and fixed a
port bug where Mit Bottle raised maximum health without filling current health. The same
gate now exercises the entire dew-vial upgrade chain, including colored stack healing,
normal and Warden efficiency, flower-pot planting, old-high-grass conversion, legacy
debuff cleansing, all capacity boundaries, and the three upgrade sources.

The coconut summon key again creates either four ordinary coconut cats or one
leader adjacent to the hero. Their source health, defense, accuracy, damage,
self-decay, bomb chances, four-cell reach, total buff immunity, and ranged dung
projectile animation are restored. Spawn searches are bounded and reject map
edges and occupied cells; failed placement does not crash or consume unrelated
state. The summon key is accepted by Scroll Holder and uses the original icon and
cat sheet.

The full Pocket Ball soul lamp now stores and restores all 35 legacy pet types,
including current health and reward cooldown. It supports release on the source
depths, recall, guard and hidden commands, and refuses unknown pet identifiers or
maps without a legal adjacent cell without consuming itself. Empty Pocket Ball
capture now returns the captured pet's original egg instead of a generic egg, and
`CapturedPetEgg` can hatch every one of the 35 types rather than only 13. These
changes fix the port's loss of 22 ordinary pet hatch paths while retaining full
save compatibility. Runtime tests cover mapping, capture, release, recall,
commands, persistence, and failure protection.

The reachable town event-weapon reward pool is complete again. Its original
fifteen equal-weight entries now include the restored Hook and Ham, Key Weapon,
Lollipop, Paper Fan, Christmas Tree, Mini Moai, Brick, Dragon Boat, and the
previously implemented SJRB Music. The four thrown event weapons can be equipped
for melee or thrown and recovered, retain the source strength and upgrade curves,
and restore splash damage, healing, crowd control, random gifts, break rewards,
and permanent Lollipop backlash. Paper Fan charge is now per item and persisted,
fixing the source's cross-instance static state. Unsafe low-damage random ranges,
edge-adjacent splash and knockback, headless break messages, healing overflow,
and broken-projectile redrops are guarded. Six icons required a new final atlas
row while Brick and Key Weapon reuse existing pixel-identical cells, bringing the
sheet to 256 by 960. All eight source icons are hash checked.

Three reachable special reward weapons are now restored. REN grants Goei once
all four challenge kill counters exceed 50; it deals 35 percent bonus damage to
demons and undead and repeats full damage every sixth hit with per-item persisted
charge. The prison Assassin exposes Tekko-Kagi as special loot and drops one at
the 100-kill milestone; its 20 percent proc deals one quarter to one half of the
target's maximum health. Dried Rose's ghost carries Wraith Breath at the source's
stated 20 percent weapon-drop chance; it retains range four, 0.75 accuracy,
+2/+3 upgrade growth, and its combined terror and vertigo proc. The Assassin
counter and Goei one-time marker persist, and all three source icons and bilingual
UTF-8 keys are checked. REN now marks the one-time reward when granting it, fixing
the legacy call that only queried the marker, while the ghost preserves the first
20 percent assignment instead of the later accidental overwrite.

The two reachable town weapon shops now restore Goblin Shield and Special
Knuckles. After Otiluke is rescued, Goblin Player has the source one-in-three
chance to open the shield shop, while Shower has a one-in-four chance to open
the knuckle shop. Both preserve the strict greater-than-3000 gold check and
drop the purchased item safely when the backpack is full. Goblin Shield keeps
per-item eleven-hit charge, its 16 random effects, one-eighth maximum-health
energy shielding, and bounded healing; Special Knuckles restores its 50 percent
paralysis and one-tenth maximum-health physical shield. Both original icons,
save behavior, purchase windows, and bilingual UTF-8 strings are checked.

Hybrid now uses the separate legacy Dangerous Bomb at each phase threshold
instead of a standard bomb. It first performs the ordinary adjacent blast, then
applies a two-tile terrain and item-chain blast while dealing the extra
one-eighth to one-quarter maximum-health damage only to the hero. Normal and
glass walls are included explicitly because the legacy solid-cell distance map
otherwise made its own wall-breaking branch unreachable. Runtime tests cover
near and far non-hero targets, both wall types, flammable terrain, map edges,
the 20-gold value, icon, Hybrid's 200-shield phase transition, and headless
execution safety.

HBB's fourth post-rescue conversation now drops the original non-droppable,
non-throwable commemorative Flag while the first three conversations preserve
their separate lines. The existing fish-cake special loot remains intact. Empty
heap sprites are tolerated during reward placement, and the source flag icon and
bilingual text are covered by the town-NPC reward gate.

The complete Orb of Zot loop is restored. The final Shadow Yog drops the unique
device; while carried it gains one charge per hero turn up to 500, then its USE
throw creates the immobile allied Zot turret. The turret keeps 500 health, 35
defense, depth-scaled accuracy, the 100-200 beam, 10-20 self-damage, mechanical
property, fear and toxic-gas immunity, and returns a zero-charge orb when it shuts
down. It only targets and damages enemy mobs. Breaking the orb instead produces
the Energy Core page for adventure destination 7. Charge now belongs to each orb
and persists, fixing the source's cross-instance static state; occupied cells,
map edges, missing sprites, and failed placement recover safely. The original
item icon and 256x32 turret sheet are verified pixel-for-pixel, and the orb is
again accepted by the Scroll Holder. `:core:verifySpsOrbOfZot` exercises the full
headless chain and is part of `verifySpsRelease`.

The first six physical adventure-journal pages now follow the source acquisition
chain instead of silently changing route bits. Ordinary heroes no longer receive
the adventure journal at creation: Otiluck's journal is sold in the depth-6 SPS
shop as the physical `DolyaSlate`, and picking it up drops the housing contract and Lucky Badge while choosing
one of the three saved home layouts. All three sewer bosses drop Sokoban 1; the
three prison, cave, and city boss variants respectively drop Sokoban 2, 3, and 4;
the depth-11 shop sells the town invitation. Pages use the original pixel, fit in
the Scroll Holder, cost 150, and are consumed only after a successful ADD action.
Completing destinations 0-7 no longer bypasses a still-unbound physical page,
while TEST_TIME continues to open every route directly. Missing heap sprites,
invalid drop cells, saves without a journal, duplicate pages, persistence, and
English/Simplified Chinese UTF-8 resources are covered by
`:core:verifySpsJournalPages`, which is part of the release gate.

The Dolya slate now also restores its original 1,000-point charge store. Main-
dungeon actions before depth 26 add one point, travel requires and consumes 500,
rescuing Otiluke bypasses the minimum, and binding a new page refills the slate
without exceeding its advertised cap. Charge, the original status percentage,
300-gold value, TEST_TIME full charge, and the original 16-by-16 icon are saved
and tested. The challenge journal likewise has its exact `ChallengeBook` entity
and source icon. Ordinary heroes and save loading no longer fabricate it; REN's
first town interaction drops it physically, and map fragments remain unconsumed
until it has been obtained. Existing early-port journal objects remain readable.

## Migration order

1. Content registry, saves, heroes, subclasses, and class skills.
2. Items, recipes, buffs, equipment effects, eggs, and companions.
3. Main dungeon generation, optional routes, fixed maps, rooms, and traps.
4. Mobs, bosses, NPC quests, shops, drops, and progression gates.
5. UI flows, journal/catalog coverage, endings, badges, audio, and visual parity.
6. Deterministic gameplay tests, save/restore tests, desktop smoke tests, and
   Android debug builds.

## Verification

`verifySpsRelease` checks the currently migrated mechanics and resources,
including fixed-seed ordinary-floor BSP and complete-map stress tests.
The fixed-level suite now executes the master-key chest flow rather than only
inspecting item fields: it verifies ordinary gold-key priority, one-use
consumption, and gold/crystal chest opening from a branch. It also executes a
hermit crab's full death path with a valid hero, level, FOV, and actor registry,
then verifies the depth-0 master key on the resulting ground heap.
`tools/audit-sps-port.ps1` currently reports 1,719 exact relative-path matches,
66 case-insensitive class-name adaptations, 131 reviewed adaptations, and zero
candidates requiring review. The reviewed-candidate manifest
records a reason for every exclusion instead of silently dropping it. The audit
measures source coverage against the original local
SPS-PD tree. Both must pass, and the audit must have no unresolved player-visible
entries, before a release may be described as a complete replica.

The final window audit restored five reachable town interactions that had been
collapsed into random speech. DreamPlayer again offers the level-one, 50-base-HP
reset; XixiZero opens the original two-answer Egoal dialog; HateSokoban sells the
Wand of Flock under the strict greater-than-3,000-gold rule; Millilitre exchanges
100 HP for 500-2,999 gold only above 150 HP; and G2159687 sells a current-floor
iron key only above 100 gold. Full-inventory wand and key rewards now fall at the
hero instead of disappearing. The surface exit also restores the original
`WndAscend` confirmation and persists its confirmation flag across saves. All six
windows have English, Simplified Chinese, Traditional Chinese, and Russian UTF-8
resources and are covered by the town NPC verification task.

The title scene now exposes the legacy tutorial through a dedicated Learn route.
It uses the original 48 by 48 fixed map, all eight guide conversations and rewards,
two training mobs, two fire-buff traps, and all 13 fixed item heaps. The hidden
`NEWPLAYER` class starts at 10/50 HP without normal equipment and never appears in
class selection or random choice. Tutorial state uses branch -1 and slot 0, so it
cannot overwrite an ordinary run; hidden classes also no longer increase the eight
ordinary save slots. Finishing the tutorial returns directly to the title scene.
Tutorial transitions intentionally skip `Dungeon.saveAll()`: a rendered desktop
smoke run exposed an `IndexOutOfBoundsException` when Shattered attempted to
serialize normal talent tiers for the hidden, talentless `NEWPLAYER` class.
The tutorial is a badge-driven, non-resumable SPS flow, so suppressing slot-0
game data fixes the crash without fabricating talents or consuming a normal slot.
The smoke run confirms that no `game0` save is created.
The training-mob shield loop and guide relocation bounds include explicit fixes for
legacy missing-brace and edge/overlap bugs.

Framebuffer captures have been checked for the title scene in desktop landscape
and mobile portrait layouts and for the tutorial `GameScene`. The 3-by-3 landscape
buttons and six-row portrait layout do not overlap or truncate the Chinese Learn
label; the tutorial map, hero, and Chinese prompt render without mojibake. The
capture utility is test-only and is not packaged into release builds.

The conch-shell route now creates the legacy `FishingBossLevel` class while retaining
the interim `CrabBossLevel` name for save compatibility. Its prison-tile corridor,
14 special statues, side-water entrance room, pedestal spawn, arena seal, crab king,
lightning shell, and four hermit crabs are covered by deterministic map tests. This
also fixes an earlier port bug which painted the entire corridor as water and used
the beach tileset. Hermit crabs again use the berry loot deck, resist electricity,
and always drop the legacy depth-0 crystal master key; that key uses the exact old
sprite and can replace a golden or crystal chest key on any branch. Runtime tests
cover normal-key priority, cross-branch consumption for both chest types, and the
guaranteed death drop. The shell's old
charge thresholds, damage ranges, consumption, persistence, and blanket buff
immunity are restored. Charging the shell from absorbed servant damage is retained
as an explicit fix for the old source's missing state update.

The first normal run now follows the SPS sequence from the hero, skin, and combat-
style selection into the original three-paragraph `IntroScene`, then descends only
after the story window closes. The first-run flag is cleared before descent so
Shattered's separate tutorial prompts do not leak into the SPS flow. The legacy
`GiftshopScene` and `GiftButton` remain classified as unreachable source prototypes:
the 0.9.8 tree never instantiates the button, its purchase callback never sets an
unlock bit, and no gameplay system reads those unlock flags.

The legacy mechanical determination core is restored to the ordinary artifact
pool. It gains one charge every five turns, reaches 100 after 500 turns, resolves
all ten source outcomes, unlocks the four error items after the chaos outcome,
and exposes the memory-save action at level 10. Its level, charge, partial charge,
and error state persist. The spider queen again has the source 20 percent rare
core reward and its missing beast property. All four item icons are copied from
the source atlas and checked pixel-for-pixel. Error-reward placement now tolerates
a missing heap sprite, preventing crashes during headless or partially restored
game states without changing rendered play.

Both item-driven memory-save routes are now reachable. Using the tutorial pudding
validates Learn, consumes the pudding, saves, and enters `MemorySaveScene`; the
emergency offline device saves and enters the same scene without consuming itself.
The sewer rat boss always exposes the device through special loot and has both its
beast and boss properties. The Spring Festival author NPC returns the 500-gold
Update Plan before Otiluke is rescued and the offline device afterwards. A
headless test covers actions, scene targets, pudding consumption, both NPC reward
states, and the rat-boss reward.

SaidbySun's experimental cloak is reachable again through special loot. One use
consumes one cloak and grants 100 turns each of SPS haste, levitation, and
invisibility; its 50-gold value, stackability, beast-tagged source NPC, bilingual
text, and source icon are verified. Thirteen passive sale souvenirs are also
restored with their exact per-item values and source icons: Apk931, Test Tube Rose,
Broken Hammer, Mix Photo, Magic Breaker, Humming Tool, Mirror Twice, NS Controller,
Sell Permit, Sheep Fur, Simple360, Tissue, and Uncle's Dumbbell. Ten merged town
residents plus the ordinary blacksmith, shopkeeper, mirror image, ordinary sheep,
and all Sokoban sheep now expose their corresponding legacy special loot.

The transition-floor tent itself, rest interaction, anvil, alchemy tile, plant pot,
and required shop adjacency are present. Shop tents choose one of the eleven source
gift residents, including friendship, final rewards, four pet eggs, hatching,
companions, and persistence. Ordinary tents create the two protected depth-85 guards
used by their non-shop source path.

The legacy transmutation well is reachable again from both magic-well room types,
which now choose equally among awareness, health, and transmutation water. It
transforms the source weapon, armor, scroll, potion, ring, wand, artifact, and
Strength Bottle categories; equipment retains levels, curse knowledge, curses,
enchantments or glyphs, and the SPS reinforced flag where the source did. Upgrade
and Magical Infusion scrolls exchange directly, and Strength Bottle becomes Mit
Bottle. Unsupported items are moved only to an in-bounds, traversable, unoccupied
adjacent cell; with no valid destination they remain in place and do not consume
the well. All rerolls are bounded, and missing heap sprites are safe. The dedicated
headless gate verifies room pools, actual well consumption and terrain replacement,
edge cases, and strict bilingual UTF-8 resources.

SPS statue rooms no longer use Shattered's single random statue layout. They now
restore the source's locked room with one weapon statue, one independent
`ArmorStatue`, and two or three loose weapon-or-armor prizes. The armor statue has
the source depth-scaled health, experience, damage, accuracy, armor-based evasion
and blocking, a generated identified glyph armor, elemental property, poison and
toxic-gas resistance, passive wake-up behavior, armor drop, and save state. Item
generation loops are bounded and headless drops tolerate a missing sprite. The
special-room gate executes the layout and validates combat values, armor state,
persistence, and bilingual UTF-8 text.

The ordinary pool and crypt rooms now follow their SPS layouts and reward rules.
Pool interiors remain fully flooded apart from the far pedestal, contain exactly
four ordinary piranhas, add the guaranteed invisibility potion, use the source
one-in-three chest presentation, and select the best of five melee-weapon-or-armor
rolls when no queued prize is used. Crypts again lock the entrance, place two
statues and a tomb holding the best of four armor rolls, have a 40 percent chance
to cover the whole interior with `WeatherOfDead`, and create either two or three
chest rewards with the first represented by a real hidden `Mimic`, or four to six
loose gold heaps. The modern mimic is initialized with only the source gold reward,
without Shattered's extra mimic prize. Finite cell candidate lists replace both
source painters' unbounded placement loops. `:core:verifySpsSpecialRooms` checks
both reward branches, weather coverage, terrain, mob counts, keys, and prizes.

The legacy Dew Rejection challenge now has its own bit (`1024`) instead of
aliasing Shattered's Swarm Intelligence bit (`16`). While active, every active
waterskin ability costs ten additional dew, charged-dew bursts contract from the
surrounding eight cells to the four cardinal cells, and each ordinary starting
hero receives two Dewcatcher seeds. Runtime coverage checks the selection mask,
normal and challenged costs and burst areas, refine threshold, starting grant,
and strict UTF-8 resources. All other legacy primary challenges now use independent
bits where their source meaning differs from Shattered's mechanics and are covered
by the challenge sections below.

Item Phobia is likewise restored on an independent bit (`2048`). Potions take
five turns to drink, reading a scroll deals ten percent of the hero's maximum
health and applies five turns of silence, and ordinary starts receive 1,000
additional gold. Potion timing is evaluated dynamically, correcting the source
implementation's class-load-dependent constant. The runtime gate verifies both
unchallenged and challenged behavior, the real hero damage and buff paths, the
starting grant, selection mask, and strict bilingual UTF-8 resources. A null
guard added to input-hold reset also prevents this and other damage paths from
crashing during headless or partially initialized scene states.

Listless is restored on bit `4096`. Each level now grants only two permanent
maximum health and restores one health while the challenge is active, versus
the normal five-and-five growth. A potion of might and Honey are added to the
ordinary starting inventory. Level-derived base health now has one shared
calculation used by displayed, permanent, life-cost, and test-loadout paths, so
the combined Test Time loadout still reaches exactly 10,000 health. Runtime
coverage performs real normal and challenged level-ups, checks both starting
items, the selection mask, strict bilingual UTF-8 resources, and Test Time
compatibility.

Nightmare Virus is restored on independent bit `8192`. Every eligible monster
death chooses one unoccupied passable cardinal cell and creates a hostile virus
body after a one-turn delay; if no legal cell exists, a Red Dewdrop is left on
the corpse tile. Virus bodies copy one fifth of the hero's maximum health, the
hero's accuracy and evasion, deal between half the hero level and the full hero
level, lose one health each turn, grant no experience, reject every buff, and
release 20 units of Corrupt Gas on death. Virus bodies, split Swarms, MiniSand,
and summoned skeletons cannot recursively spread the challenge. Ordinary starts
receive an UnBlessAnkh. Candidate validation now rejects out-of-map and row-wrap
cells, and headless heap/sprite paths are null-safe. The dedicated runtime gate
checks registry order, start compensation, stats, decay, immunities, generation,
blocked and edge fallback, recursion guards, gas, strict bilingual UTF-8 text,
and the source sprite hash.

Energy Lost is restored on independent bit `16384`. Every positive call through
the hunger satisfaction path retains 40 percent of its energy, matching the
source implementation while leaving negative hunger changes untouched. Wand
maximum charge becomes `initial charges + level / 5`, capped at six; current
charge is clamped immediately when that limit changes. Ordinary starts receive
one additional SPS staple Pasty. Unchallenged games retain Shattered 4.0's
existing wand progression. Runtime coverage verifies both hunger paths, negative
energy, normal and challenged wand progression, the cap and clamp, start food,
selection order, and strict bilingual UTF-8 resources.

The legacy Into Darkness challenge is restored on independent bit `32768`,
separate from Shattered's reduced-vision Darkness challenge. Hero actions advance
the saved SPS clock from 06:00, including exact and multi-day rollover. While the
challenge is active, observation forgets prior `visited` cells but preserves
permanent `mapped` cells from mapping scrolls and night-shadow deaths. Every
non-shop floor maintains exactly one night shadow. It uses the source sprite,
day-dependent health, evasion, accuracy, damage and blocking, attacks only at
night, retreats by day, hides after movement, heals while separated, can cause
terror, and permanently maps its death radius. Ordinary starts receive two known
scrolls of magic mapping. The source's unbounded and malformed respawn loop is
replaced by the level's bounded 30-attempt selector, and exact 1440-minute rollover
now increments the day instead of losing it. Runtime coverage checks persistence,
old-save defaults, map memory, start items, buff attachment, shop and blocked-floor
spawning, combat rules, UTF-8 source text, and the original sprite hash.

The legacy Abrasion challenge is restored on independent bit `65536`. The first
30 source weapon-generator entries start with 100 durability, lose one durability
on each successful hero hit, break safely at zero from either weapon slot, gain
ten durability per upgrade, and preserve their remaining durability in saves.
Old saves derive durability from the weapon's true level, while positive-level
random generation receives the matching bonus. Ordinary starts receive known
upgrade and magical-infusion scrolls. Runtime coverage checks the exact source
whitelist, challenge and attacker guards, warning and break thresholds, both
equipment slots, upgrades, persistence, old-save compatibility, random levels,
starting grants, and strict bilingual UTF-8 text.

The legacy Elemental Storm challenge is restored on independent bit `131072`.
Every Mob attack first deals additional energy damage equal to the deepest floor
divided by five, including the source's zero-damage calls before floor five.
Wand damage received by a Mob is reduced to 80 percent with upward rounding;
other sources and unchallenged combat are unchanged. Ordinary starts receive a
known psionic-blast scroll and shield potion. Runtime coverage checks challenge
ordering, start grants, exact damage source and scaling, the low-depth boundary,
wand-only reduction, and the original bilingual UTF-8 text.

The reachable Chalice of Blood now restores its SPS 0.9.8 exhaustion action.
An equipped, uncursed chalice above level three can spend three levels to grant
100 turns of Blood Angry: movement speed is multiplied by 1.2, hero damage by
1.5, and incoming damage by 0.8 with upward rounding, while health converges on
one third of maximum using the source's two-stage tick. Pricking again uses
fixed `2 * level squared` damage after the source armor roll, spends three turns,
applies level-squared bleeding and upgrades on survival. Its warning retains the
source's separate `3 * level squared` threshold. Regeneration uses the restored
10/8/6/5-turn progression and 20 turns while cursed; artifact recharge no longer
heals directly. The buff duration persists in saves, visuals tolerate missing
sprites, and a dedicated release gate covers actions, combat multipliers, health
convergence, sacrifice, regeneration, sources and exact bilingual UTF-8 text.

Two reachable consumables no longer use placeholder Shattered buffs. The full
moon berry now grants Moon Fury, saved Full Moon Strength and light, with the
source's 50 percent barkskin branch, five-gold value, wall-clock day/night hit
count and repeated triple-damage attacks. The source's detach order deliberately
keeps the base Moon Fury for one final attack after the stored extra-hit counter
expires. Ling's potion now grants only the 200-turn Ling Bless, adding 20 percent
evasion and 0.2 movement speed instead of unrelated fire/toxic affinities. Its
original item sprite was copied from the 0.9.8 atlas. Runtime coverage verifies
combat consumption, persistence, sources, values, exact Chinese text, strict
UTF-8 and the source sprite hash. Headless speed queries also tolerate a missing
hero sprite instead of crashing.

Crom Cruach's charged dispel now uses the legacy Magic Immunity buff rather
than Shattered's much broader MagicImmune state. It preserves the source's
specific immunity set for paralysis, poison and confusion gases, stench,
corruption, electricity, burning, poison, warlocks, eyes, burning fists and
broken robots without disabling rings, artifacts, glyphs or enchantments. The
source integer division for duration is retained, including zero duration below
level ten. The relic gate now checks the exact buff, immunity set, duration,
strict UTF-8 text and isolation from Shattered's equipment-suppression rules.

The reachable Ring of Elements now uses the SPS 0.9.8 rules instead of
Shattered's exponential 17.5-percent resistance. Its complete REDUCE list
shortens negative effects to `max(0.40, (100 - bonus * 2) / 100)`, while the
21-entry IMPROVE list extends beneficial effects to
`min(3.00, (15 + bonus) / 15)`. Legacy wand, damage-type, blob and buff damage
is reduced to `max(0.60, 1 - bonus / 75)`, excluding hunger, with the source's
upward rounding and level-30 caps. Negative ring levels invert all three
effects. The original bilingual text is restored, and the dedicated gate covers
duration integration, SPS enemy mappings, damage classification, caps, cursed
levels and strict UTF-8. Damage math uses double precision so the 60-percent
boundary cannot round 100 damage up to 61 through float error.

Accuracy, Evasion, Furor and Haste now use their SPS 0.9.8 raw ring levels
instead of Shattered's implicit `level + 1` curves. Accuracy applies the source
`0.75^-level` hit factor and grants one weapon or unarmed reach tile per ten
levels, capped at three. Evasion adds up to two armor DEX and six stealth only
through equipped SPS armor. Furor adds one base damage per positive level and
uses the source linear attack-speed curve up to four times speed; negative
levels slow attacks without subtracting damage. Haste uses the matching linear
movement curve up to four times speed. The original Chinese and English text is
restored, and `:core:verifySpsLegacyRings` covers live weapon and unarmed reach,
armor stats, attack delay, damage, movement, negative levels and strict UTF-8.
This gate found and fixed a normal-weapon override which had silently discarded
the restored accuracy-ring reach bonus.

The former Ring of Energy and Ring of Accuracy placeholders for the SPS arcane
and knowledge rings have been removed. Each arcane ring now contributes its raw
level to hero magic skill, capped at 30 per ring. Knowledge restores its 25%
direct-wand critical, `1.2 + 0.06 * level` damage factor, synchronized and saved
extra-drop countdown, source standard/rare reward tables, and ten progression
rolls for bosses. All twelve SPS rings now use the source order and equal
generation weight. The Chinese ring text is copied from 0.9.8; that source has
no English knowledge-ring entry, so the English text is a faithful translation
of the Chinese source and code behavior. `:core:verifySpsMagicKnowledgeRings`
covers live wand damage, magic skill, dual-ring state synchronization, save
round trips, boss drops, pool weights and UTF-8 resources. Bounded drop loops,
empty artifact-pool fallback, missing visual guards, and near-integer critical
damage correction address source crash, hang and floating-point boundaries.

Four more ordinary special rooms now use the source painters. The garden is an
unlocked high-grass room with a central water patch, SPS seedpod or blandfruit
planting, full foliage weather, the pre-depth-25 honeypot, and the April Easter-egg
roll. The library restores its bookshelf wall, corner alchemy pot and energy, and
paired two-or-three scroll and potion reward passes. Storage once again has the
open door, bookshelf divider, two to four skeleton heaps, one chest, and guaranteed
liquid-flame potion instead of Shattered's barricaded honeypot layout. The vault
contains three crystal chests from the SPS wand/ring/artifact pool, one golden key,
and one iron door key; cursed upgradable rewards are normalized as in the source.
Golden keys can open these legacy crystal chests while modern crystal keys remain
compatible, and the actual key-consumption path is covered by the fixed-level gate.
The tent's enhanced plant now retains its flower-pot terrain. All placement rerolls
are bounded, and the special-room gate validates these layouts and rewards.

The missing ordinary-floor quest injection chain has now been restored for both
the city and caves. City floors spawn the SPS 0.9.8 imp on the first reachable
city floor, preserve its demonic property and old save format, use the source
eight-monk or six-golem token goals, and award the source cursed +2 ring. Floor
19 also restores its golden thief. Spawn, reward and drop rerolls are bounded,
and token drops tolerate heaps without sprites.

The first ordinary caves floor now converts one large BSP room into the SPS
blacksmith room instead of exposing Shattered's mine quest. The room has the
source wall shell, visible fire-trap ring, `EMPTY_SP` inner floor, two equipment
heaps, unlocked door, troll blacksmith and troll welder. The blacksmith restores
the 15-dark-gold pickaxe quest and one-use legacy reforge, while the welder
matches armor, weapon, wand and ring adamant components and consumes 50 dark
gold. The Shattered quest implementation remains in source but is not selected
by SPS ordinary-floor generation. Legacy and modern blacksmith saves are
distinguished in the shared save node, including compatibility with old saves
that only contain `reforged`.

Restoring the blacksmith fusion also exposed a Windows case-insensitive filename
collision between the old completed `TriForce` and its `Triforce` piece base.
The piece base now has an independent class name, and the completed Triforce is
again a real item with a saved round trip to the infestation arena and a boss
alive return guard. The original 52x32 two-smith sprite sheet and strict UTF-8
English and Chinese resources are restored. The ordinary-level gate checks the
room geometry, fire traps, equipment, both NPCs, single-spawn lifecycle, legacy
save mode, reforge rules, adamant matching and completed Triforce action.

The old-high-grass terrain now executes its source interaction when stepped on.
It remains standing, refreshes leaves and observation, and grants a Warden four
turns of invisibility. Scene access is guarded so headless restore and test paths
cannot crash while producing the visual feedback.

The SPS mainland guide is reachable again from the current journal's guide tab.
Its 13 pages retain the 0.9.8 order, are always readable as in the source, and use
the original English, Simplified Chinese, Traditional Chinese, and Russian text.
The dedicated `:core:verifySpsStoryGuide` gate compares every migrated title and
body directly with the old UTF-8 resources and verifies the live journal entry.
The current journal item tabs now use a dedicated `SpsCatalog` containing all seven
legacy groups and all 371 entries in their exact 0.9.8 order. Every item is visible
by default, all classes are resolved from a finite legacy package list and instantiated
by `:core:verifySpsCatalog`, and the four catalog translations are decoded as strict
UTF-8. The Shattered catalog remains in source but is no longer the player-facing SPS
list. The creature tab likewise uses `SpsMobCatalog`: its seven source groups contain
113 entries after preserving the old `LinkedHashMap` de-duplication of `TimeKeeper`.
All entries are visible by default and retain source order. `ExBambooMob`, `Shielded`,
`FireSuccubus`, `BombBug`, `Assassin`, and `BambooMob` are restored as real runtime and save types,
are produced by the
legacy exit and tent routes, and reuse their already migrated complete combat bases.
The stone bug also restores its inherited ice, flow-wand, freeze-wand, and ice-enchantment
defenses plus its visible death blast. The assassin once again scales health with the
actual dungeon depth, belongs to the human faction, obeys charm while locked, and no
longer applies the non-source ranged slow effect. Its ordinary rotations, Tengu den,
challenge, chaos, and city summon entries all create the original top-level save type.
The bamboo restores its plant faction, source weakness set, armor special loot, and
all ordinary/challenge/chaos/city generation paths. The inherited evolved-bamboo
rules now use the actual earth damage source and preserve both source reflection and
defense-buff rolls. SPS-PD's shared faction table is active again for orcs, fishers,
elves, dwarves, trolls, demons, goblins, beasts, dragons, plants, machines, undead,
and aliens. Its weakness multiplier once again extends matching status duration by
50 percent; `:core:verifySpsLegacyProperties` executes every faction branch.
The four catalog title locales are strict UTF-8, and `:core:verifySpsMobCatalog`
compares the live list directly with `NewMobCatalog`. The Shattered `Bestiary` remains
in source for compatibility but is no longer the player-facing SPS creature list.

The original `AcidOoze` save type is active again as a permanent, water-removable
effect. It uses the source one-in-six fixed damage roll and otherwise deals one
fifteenth of maximum health capped at 500; the migration-only `SpsAcidOoze` remains
as a compatible subclass. The acid wand correctly applies ordinary timed `Ooze`,
while faction tables and the earth armor use the permanent acid type. The earth
armor also restores immunity to both earth enchantments.

`BrokenRobot` and `BrownBat` are now top-level runtime, catalog, generation, and save
types. The robot restores its magic-machine factions, true light damage, scroll/ore
dual drop, three-item special reward, tower summons, and all ordinary/challenge/chaos
entries. The bat restores its beast faction, original sprite identity, seed special
reward, and all normal entries. Their prior nested implementations remain as save
compatibility bases, and all four player-facing locales are strict UTF-8.

`BanditKing` likewise has its original top-level mob and sprite identities across the
ordinary prison rotation, thief pursuit, thief-boss arena, catalog, and saves. Its elf
faction and source combat profile are restored: direct attacks retain the base one
damage and zero accuracy, while a successful strike applies the lethal countdown and
starts fleeing. The pursuit completion hook and null-safe spork drop are retained as
necessary route and headless fixes. `BlueCat`, whose only old town spawn block is
commented out, is deliberately absent from normal generation but now has its complete
top-level implementation: depth scaling, rapid attacks, Amulet theft, fleeing, gold
shedding, carried-item persistence, and source loot. The old resources only named the
cat, so the missing description and action messages were completed in all four SPS
locales; headless theft suppresses presentation-only logging instead of crashing.

`DemonGoo`, `DemonFlower`, and `DemonRabbit` now likewise use their original top-level
runtime, save, catalog, generation, challenge, and sprite identities. Demon goo retains
its elemental/demonic factions, three-skull special reward, and creates the same
top-level type when it divides. Demon flower restores its plant/demonic factions,
fire weakness, and pill-category special reward without the provisional extra direct
burning-damage multiplier. Demon rabbit restores its orc/demonic factions and Gun D
special reward while retaining the source-equivalent glass-fruit and mending-potion
drop probabilities. The nested implementations remain loadable as compatibility bases,
and all three top-level message sets are present in strict UTF-8 English, Simplified
Chinese, Traditional Chinese, and Russian resources.

The remaining two ordinary halls creatures, `ThiefImp` and `Sufferer`, now also
use their original top-level runtime, save, generation, catalog, challenge, chaos,
and sprite identities. Thief imp no longer carries the erroneous plant faction;
it restores the source berry-pool metadata, blocked-flee response, and invisibility
potion/rage scroll/blood chalice special pool. Sufferer replaces its erroneous orc
tag with the source magic-user and human factions, deals typed dark damage, and
restores its upgrade scroll/red dewdrop/unstable spellbook special pool. Their
nested implementations remain as save compatibility bases, and all four SPS
locales have strict UTF-8 top-level messages.

The seven migrated city creatures now use the original `DragonRider`, `SpiderBot`,
`Musketeer`, `ManySkeleton`, `LevelChecker`, `Greatmoss`, and `RedWraith` runtime,
save, sprite, generation, catalog, challenge, triangle-trial, jungle-room, and summon
identities wherever each source type is reachable. The scavenger restores its beast
faction, legacy meat drop, bug-meat reward, and yellow blood; the musketeer restores
its dwarf faction, Toy Gun reward, and EMP-bola projectile; and the dragon rider
restores its monthly egg reward while its death pool produces real top-level city
types. The adjudicator restores its machine faction, wand weakness, and experience
ore reward. Great moss now uses the complete eight-entry mushroom deck. Chaos wraith
restores psionic-blast immunity and its ranged Wave animation. Huge-skull splits and
deaths create the existing top-level `SommonSkeleton`, whose depth scaling and saved
level are now restored. All seven top-level message sets are strict UTF-8 in the four
SPS locales, while the nested classes remain readable for migration saves.

The legacy environmental-blob family is now restored under its original runtime and
save class names. All seven elemental damage areas retain the source one-to-two-percent
current-health damage, distinct damage types, heap reactions, particles, one-turn decay,
and non-stacking reseed rule; fruits, traps, and mobs now create those real classes.
`CurseWeb` applies `ShadowCurse` while decaying. Soldier skin four again carries the
persistent `NmImbue`, generates `NmGas`, assimilates eligible unequipped items into SPP,
and enters the 720-turn `Nmstop` drain state above the depth threshold. The host is immune
to its own cloud. Dew watering now creates the original `Water` class, and torches recover
their `SET` action and permanent `TorchLight` ground glow. The old single-cell `Portal`
visual/save contract is present while reachable Sokoban teleport state stays in the fixed
levels. `:core:verifySpsLegacyBlobs` covers live damage types, decay, seeding, terrain
growth, nano behavior, torch placement, portal persistence, runtime trap wiring, and
strict UTF-8 English, Simplified Chinese, Traditional Chinese, and Russian resources.

The four SPS cave creatures `GnollShaman`, `SandMob`, `TimeKeeper`, and `IceBug`
now use their original top-level runtime, save, generation, catalog, challenge,
chaos, city-summon, and sprite identities. The shaman restores its orc/magic-user
factions, electricity resistance, three-item special reward, and real shock damage.
The sand creature restores its elemental faction, shock and lightning-wand defenses,
gold special reward, and top-level `SandMob$MiniSand` offspring. The timekeeper restores
its unknown/magic-user factions, three-item special reward, and real energy damage;
its random teleport now safely skips execution when no level exists. The ice climber
restores the source beast faction without the provisional icy tag, its complete ice
defense set, and icecap-seed special reward. This also corrected the holy bomb mapping:
the original unknown, machine, and elemental factions receive heavy damage, while an
ice climber does not qualify merely by name. The four top-level message sets use the
original strict UTF-8 English, Simplified Chinese, Traditional Chinese, and Russian text.

The seven consolidated sewer creatures now likewise use the original top-level
`DustElement`, `RatBoss`, `Shit`, `LiveMoss`, `PatrolUAV`, `Vagrant`, and `ExVagrant`
runtime, save, sprite, ordinary-rotation, catalog, challenge, chaos, triangle-trial,
city-summon, and alternate-generation identities wherever applicable. Dust elemental
restores its elemental faction, wet vulnerability, earth/acid/swamp defenses, norn-stone
reward, and real earth damage. Living moss restores the plant faction, mushroom drop,
and potion/summon reward. Patrol UAV restores the machine faction, lightning defenses,
recharging-scroll/storm-wand reward, and the source electric-shock death field with
safe headless particles. Toilet elf restores its elf faction, depth-scaled accuracy,
and toxic-gas reward. Both vagrants restore the human faction and music-blade reward;
the infected sprite also restores its visible death particles. All seven top-level
message sets are strict UTF-8 in English, Simplified Chinese, Traditional Chinese, and Russian.

The five consolidated prison creatures now use the original top-level `GhostPhoto`,
`GoldCollector`, `FireRabbit`, `TrollWarrior`, and `Zombie` runtime, save, and sprite
identities across ordinary rotations, the ice-ball challenge, chaos, the courage trial,
city death summons, and the creature catalog. The mouldy painting restores its unknown
faction and seed reward. The tax collector restores its goblin faction and the source
100-gold/VIP-card/thieves-armband reward pool. The fire rabbit is again an orc rather
than a provisional fiery creature, with its food reward and complete fire defenses.
The troll restores its faction, dark-enchantment resistance, and five-instrument reward
deck; the zombie restores both fire weaknesses. Migration-only nested classes remain
loadable, and all five top-level message sets are strict UTF-8 in the four SPS locales.

The city fire elemental now also uses its original top-level runtime, save, and sprite
identity in ordinary rotations, challenge and chaos pools, the wisdom trial, city death
summons, the catalog, fiery-faction defenses, and fire armor. It restores the source
depth scaling, elemental/magic-user factions, two-cell attacks, typed fire damage,
burning absorption, frost/chill vulnerability, complete fire defenses, dual ordinary
drop, and firebloom-seed reward. The original grey rat and the dormant demon/lotus
summoner save types are present as well; source analysis found no 0.9.8 generation,
catalog, quest, or room entry for those three, so no new spawn route was invented.

## Legacy faction audit

All twelve SPS-PD 0.9.8 faction properties have now been checked on live mob
instances rather than inferred from filenames. Main and optional bosses, ordinary
mobs, town residents, standalone NPCs, pets, and Boss Rush enemies have their legacy
tags restored. Existing Shattered tags remain for save compatibility. The remaining
108 file-level scanner differences are verified inheritance, adapter, nested-class,
or commented-source cases, not missing runtime properties. `SpsLegacyPropertiesTest`
also guards resistances, immunities, weaknesses, and the 1.5x negative-effect duration.

## Android runtime status

The SDK, Emulator 37.1.11, and API 35 x86_64 and arm64 images are installed under
`G:\Android`. BIOS SVM is enabled, the x86_64 AVD is online through ADB, and debug APKs
are now installed and smoke-tested without clearing saves. The latest exact package,
screenshot, and log result are recorded in the current Android paragraph below.

## Boss Rush combat audit

The nine-stage Boss Rush chain has also been re-audited against the legacy sources.
The shared poison, gas, bleeding, psionic, and per-boss defenses are restored. UGoo now
resummons its four projections at later health breaks after they are cleared, takes zero
damage while they live, reaches the source six-times final speed, and restores their
ranged attacks and fire, slow-gas, and electric fields. UDM300 again emits slow, tar,
and dark gas continuously by phase, applies the matching debuffs, and uses `DungeonBomb`.
UKing uses the source three-turn `AttackUp` instead of a permanent saved bonus. Icecorps
summons the top-level prison `FireRabbit`, exposes the BoxStar opening shield, and accepts
the source ten damage from StoneIce. UTengu teleports only into visible valid cells with
a bounded fallback, and Dragonking once again drops the current-depth legacy skeleton key.

Ordinary main-route floors now use the complete 0.9.8 item-generation path instead
of inheriting Shattered's floor rewards. Their queued supplies are two foods, one
upgrade scroll, the paired stylus and weightstone roll, the legacy strength bottle,
and the Lucky Badge reward. Their map loot is three base random items plus luck
extras, ten dust heaps, three web heaps, and the source 4:1 split between a keyed
locked chest and a disguised monster box. The latter is a persistent `G_MIMIC` heap
which releases the real `MonsterBox` while leaving its reward. The regular-level gate
now runs 200 complete loot generations and covers both advanced-reward branches,
container counts, queued supplies, key pairing, and monster-box save restoration.

Opening either a legacy skeleton heap or hero remains now always summons the original
top-level `RedWraith`, independently of item curses. A migrated Shattered `haunted`
flag no longer adds a second ordinary wraith to these SPS containers. The failure
fallback still takes half the hero's current health, and all container effects remain
safe in headless validation. The ordinary-floor gate opens both container types and
checks the exact runtime mob classes.

The three Triforce trials now also restore the source depth-specific standard-room
painters, which previously fell through to the ordinary seven-room randomizer. Every
courage standard room is a grass tomb with the exact `REMAINS` count and optional
death weather; every power standard room uses the original alternating old-high-grass
bands and rain/sun weather; every wisdom standard room is the bookshelf study with a
random legacy center pedestal, reward, and optional quiet weather. The 250-seed
triangle gate checks each standard room by its actual BSP bounds and covers both
trial-specific weather types.

The branch-based level adapter no longer skips the original trial initialization.
All three trials queue two foods and one upgrade scroll, keep the paired stylus and
weightstone roll, and retain the Lucky Badge rare reward. Courage is forced to the
source dark feeling with three-cell sight, while wisdom uses the legacy `TRAP` feeling
so unpainted space begins as chasm instead of solid wall. The same 250-seed gate checks
these supplies and feelings before building and still requires every route to remain
reachable.

The Triforce enemy roster now uses the source's separate effective depths 31, 32,
and 33 even though the Shattered branch adapter remains anchored at floors 9, 19,
and 24. `DwarfLich`, `Zombie`, `ManySkeleton`, `Greatmoss`, `FireElemental`, and
`PatrolUAV` no longer inherit the anchor depth for health, evasion, accuracy, or
damage. `Brute` now has the source health and combat scaling, 1.5-turn attack delay,
wand weakness, terror immunity, independent gold/ranged-weapon drops, and the
three-turn level-70 `DefenceUp` rage below one-quarter health; Shattered's death
shield remains compiled only for the hidden `ArmoredBrute`. The triangle gate checks
all twelve roster members' source stat ranges and verifies the legacy rage directly.

Challenge-floor keys now retain the source depth identities 90 and 27 through 33.
Challenge branches alone may consume those keys, fixing the generated locked chest
that was previously impossible to open under Shattered's blanket sub-floor key ban;
unrelated branches remain blocked. The 250-seed triangle gate requires every locked
chest to have exactly one matching depth-31, -32, or -33 golden key.

The four ordinary region-challenge rosters now have direct source-stat coverage at
their effective depths 90, 27, 28, and 29. This exposed two remaining Shattered
implementations: `Crab` now restores SPS depth-scaled health, evasion, damage,
accuracy, experience, meat chance, and armor special reward; `Succubus` restores
depth-scaled stats, fixed five-turn blink delay, silence interaction, direct charm
and healing behavior, sleep immunity, independent lullaby/meat drops, and its
dummy-scroll/charm-wand special reward. The 250-seed region gate checks all twelve
resident enemy types rather than only their class names and spawn counts.

The Ice challenge's complete 50-type snowball spawn pool now uses its source
effective depth 30 instead of the Shattered adapter's floor-24 anchor. Depth-scaled
SPS implementations in the sewer, cave, city, halls, and damaged-robot groups all
route their `adj()` values through the branch-aware legacy depth. Shared-name Rat,
Thief, Gnoll, Guard, Bat, Skeleton, Spinner, Warlock, Monk, Golem, Eye, and Scorpio
stats have also been restored from the fixed Shattered values to the source SPS
formulas. Assassin health uses the source's fixed multiplier rather than the port's
incorrect current-floor multiplier. Fiend now records its effective depth so the
infestation arena remains depth 35, Chaos remains depth 85, and the Ice challenge
uses depth 30 across save/load. The challenge gate repeatedly constructs all 50
types and checks every depth-dependent health, defense, accuracy, damage, and armor
range; the fixed-level gate also protects the infestation behavior.

The first shared-name behavior pass now replaces four remaining Shattered combat
paths. Thieves apply the source 20-turn lock and flee instead of stealing equipped
items, Gnolls regain their two-cell attack unless locked, Bats heal for the full
dealt damage unless aged, and Skeleton death bursts use the source 3-8 damage and
apply ten turns of silence. Their SPS primary, secondary, and special loot sources
are restored where applicable. Runtime tests cover the lock/flee transition, Gnoll
range restriction, aged healing suppression, and the silence burst without needing
a rendered scene.

The second shared-name behavior pass restores the city and halls enemies. Warlocks
split melee damage into physical and dark halves, use STRDown shadow bolts, obey
silence, and regain independent potion/wand drops. Monks lose Shattered focus and
parrying, regain 1-in-12 disarming, source immunities, and both ration drops. Golems
lose teleport AI, attack every 1.5 turns, release tar gas after hits above one eighth
of maximum health, and regain the source defenses and ore/gun rewards. Evil Eyes now
fire the immediate ally-piercing 1.6-turn light beam instead of charging a Shattered
deathgaze. Cave Spinners lay short webs under themselves while fleeing rather than
shooting webs, and Scorpios use the source two-cell attack unless locked. English,
Simplified Chinese, Traditional Chinese, and Russian source text is restored and all
four resource files pass strict UTF-8 decoding.

The third shared-name behavior pass restores three remaining enemies. Rats no
longer use Shattered's ratmogrify armor interaction, always absorb one damage,
regain their legacy brick reward, and expose the original group-spawn helpers.
Prison Guards attack every 1.2 turns, use their chain one third of the time only
while unsilenced, lose the incorrect undead property, and restore the adjacent
3-8 death blast, armor reward pool, and dark-enchantment immunities. Fiends obey
silence, apply five-turn STRDown bolts for 20-44 dark damage, convert ShadowCurse
to ten percent maximum-health healing, and turn terror or amok into immediate
maximum-health-scaled damage. Runtime tests cover these rules and their legacy
rewards, defenses, and spawning helpers. English, Simplified Chinese, Traditional
Chinese, and Russian source text is restored for all three enemies.

The fourth shared-name behavior pass restores the sewer Swarm. It now has the
source 60 health, 4-7 damage, one experience, level-10 cap, seed reward, and
30-percent death drop instead of Shattered's healing potion and diminishing
limited-drop counter. Split descendants keep the source experience, inherit
exactly three turns of burning and two turns of poison, and remain excluded from
Nightmare Virus duplication while retaining save compatibility through the
generation field. The Magical Infusion special reward and all four source texts
are restored, with a runtime gate covering stats, damage, inherited effects, and
split-copy handling.

The fifth shared-name pass restores the Sad Ghost's three quest enemies and two
rare regional replacements. Fetid Rat returns to 45 health, beast alignment,
0-2 armor, five-turn ooze, and its source wandering behavior. Gnoll Trickster
returns to 60 health, guaranteed poison darts, locked melee restriction, ranged
line attacks, fixed three-turn fire, combo poison, and retreat only when adjacent.
Great Crab returns to 100 health, source movement cadence, complete alert blocking
for character, wand, and lightning-trap damage, and two guaranteed meat drops in
addition to the inherited crab drop. Albino Rat regains depth-scaled health,
demonic beast properties, sandstorm and corrupt-gas fields, source defenses, meat,
and high-food reward without Shattered bleeding. Acidic Scorpio regains stench,
damage-scaled acid retaliation, source factions and immunity, and its toxic-potion/
acid-wand reward instead of a guaranteed experience potion. Runtime tests cover
their combat rules and English, Simplified Chinese, Traditional Chinese, and
Russian source text is restored.

The sixth shared-name pass restores Giant Piranha and Wraith. Piranhas now use
the source 1.5 speed, five experience, depth-scaled health and combat stats,
guaranteed meat, Huge Shuriken reward, water-only movement, immediate death on
land, and the five explicit source immunities. When a hunting target is lost,
they make at most 100 attempts to choose a reachable water destination, preserving
the old behavior without its possible infinite loop. Shattered's surprise attack,
wide blob immunity, kill badge, and Phantom Piranha replacement are no longer used
by the SPS path, while the hidden class remains compiled. Wraiths regain
depth-scaled health, one experience, the source Magical Infusion/Upgrade scroll
drop pair, four-cell attack range, 1-to-`3 + level` damage, ten-percent linked
vertigo and terror, saved level scaling, and all eleven source immunities. Normal
spawning no longer substitutes Tormented Spirit; edge and headless-scene guards
prevent invalid cells and missing sprites from crashing tests or saves. Runtime
tests cover both enemies, and all English, Simplified Chinese, Traditional Chinese,
and Russian source keys match 0.9.8 under strict UTF-8 decoding.

The seventh shared-name pass restores Mimic, Statue, and Armor Statue together
with the map interaction that creates normal mimics. Main-floor and crypt rewards
now use the appended, save-stable `MIMIC` heap type: opening it pushes an occupant
to a safe adjacent cell, awakens a source-stat Mimic, and transfers the exact heap
contents; fire and frost wake it with their old effects, while explosions open the
container. Standard Mimics regain `(30 + depth) * 4` health, source experience,
accuracy, evasion, damage, psionic immunity, and no Demonic property or automatic
Shattered bonus prize. Shattered's Golden, Crystal, and Ebony subclasses remain
compiled on their separate behavior path. Both statue variants now use legacy
effective depth, 50-plus-depth experience, source defenses and combat rules,
identified non-negative enchanted equipment, poison/toxic-gas resistance, passive
reset, and permanent beckon immunity. Standard Statue no longer becomes an Armored
Statue through the Shattered trinket path. Headless message, drop, sprite, and map-
edge guards prevent test or save crashes. Runtime gates cover map generation,
container save/open behavior, stats, equipment, properties, and all source text.

The eighth shared-name pass restores Crazy Bandit, Senior Monk, and the complete
ordinary-floor mutation route. Bandits now seed the nine surrounding cells with
dark gas, attack at two cells, steal one twentieth of the hero's gold for a shield
worth one fortieth, add two-to-three-turn poison after their skill is active, cap
incoming hits at one sixth maximum health, and reset the skill at both source
health thresholds. Both phase and skill state survive saves. Senior Monks no
longer use Shattered focus: they restore all health below half, gain the source
attack and defense buffs, apply dark burning, use the 32-to-`56 + depth` damage
range, and cap incoming hits. The original nine one-in-eight mutations are now
reachable (Albino, ExVagrant, Bandit, ExBambooMob, Shielded, BombBug, Senior,
Acidic, and FireSuccubus), while Shattered-only rare alternates remain compiled
but are excluded from SPS ordinary rotations. ExBambooMob retains both inherited
and subclass defense-buff and retaliation rolls, as the source call chain does. The shared
guard implementations now use legacy effective depth in branch maps. Shielded
Brutes inherit the source wand weakness, terror immunity, and ranged-weapon side
drop; Bomb Bugs no longer carry the non-source Icy faction. ExVagrants execute
their own 20-point regeneration before the inherited 10-point regeneration,
including the source over-heal boundary, while aging blocks both steps. Runtime
tests cover all routes, combat phases, inheritance, persistence, map-edge gas
seeding, and the four exact Bandit and Senior locale pairs under strict UTF-8.
The common SPS loot gate now preserves the source `maxLvl + 800` threshold rather
than Shattered's `maxLvl + 2`. Legacy secondary drops receive the same two percent
per-point Lucky Badge, Soldier, Superstar, and Afly bonus as primary drops, and
the sewer dual-loot helpers reproduce the source two-roll `if/else if`
probabilities after that bonus.

The remaining legacy dual-loot paths now share one deferred fixed-item/category
implementation. Cave Shamans, Musketeers, Dwarf Liches, Demon Rabbits, Wraiths,
Red Wraiths, Mossy Skeletons, Plague Doctors, and Sewer Hearts all preserve the
source `if/else if` rolls, receive the full luck bonus on both rolls, and create
fixed source items without applying Shattered's item randomization. The five-gun
`GUNWEAPON` category is restored as an appended save-stable generator category.
Boss rewards now use the same luck-adjusted 20-percent rare roll and restore the
source pools: Elder Avatar uses Alien Bag/five guns, Hybrid uses the full egg pool,
King uses Chalice/five Skulls, Lich Dancer uses Glass Totem/five instruments, and
Prison Wander uses Chains/Dungeon Bomb. A duplicate Lich Dancer artifact roll was
removed. Runtime gates cover all probabilities and reward types. Public mob drops
and teleport effects now tolerate missing heap or actor sprites, fixing two
headless/save-transition crashes found by repeated gates.

The main-route trap pass now restores SPS-PD 0.9.8 behavior instead of relying
on same-named Shattered implementations. Lightning, Guardian, Gripping,
Flashing, Weakening, Flock, Summoning, Distortion, Teleportation, Warping,
Cursing, Disarming, Disintegration, Rockfall, Grim, Pitfall, Explosive, Toxic,
Confusion, Bound, Dew, Knowledge, Poison, Spear, and Worn traps use the source
colors, shapes, target areas, depth formulas, status durations, heap reactions,
equipment rules, item relocation, level reset/return behavior, and visual cues.
Pitfalls again open one immediate chasm cell rather than a delayed 3x3 Shattered
sinkhole; the delayed helper remains only for retained cursed-wand compatibility.
Disintegration and Grim traps once again affect only the triggering cell, and
explosive traps use the wall-breaking Dungeon Bomb. Random destination and
large-monster searches are bounded to prevent hangs. Missing actor sprites,
particle parents, and headless scenes are guarded in Guardian, Flock, Wound,
Mob notice, and trap effects. The dedicated runtime gate exercises damage,
statuses, summons, equipment, heap reactions, teleport/reset/return behavior,
single-cell targeting, chasm creation, and wall destruction. Regular and fixed
level gates continue to pass after these changes.

All twelve legacy starting melee weapons now reproduce the source upgrade call
chain at levels zero through two. Beast Knive, Brave Book, Diamond Pickaxe,
Ele Katana, Holy Mace, and Link Sword previously replaced their full damage
formula and therefore omitted the common SPS melee increment; they now apply
only their class-specific increment before the shared tier increment. A dedicated
release gate covers every starting weapon and records Link Sword's actual tier-one
maximum growth as four per level. The item-atlas audit also found that the newly
restored SPS Runic Blade occupied Ling Potion's existing slot. Ling Potion has
been restored from the 0.9.8 atlas, Runic Blade now has an independent adjacent
slot, and both pixel hashes are enforced by release tests and the atlas rebuild
script.

The four main boss timeline gate now exercises Sewer Heart's two-turn beam,
Broken Robot's open-floor piercing beam, King's invulnerable tomb and four-Lich
second phase, and Yog's four-Fist protection, respawn cost, larvae, cleanup, and
exit unlock without a rendered scene. It exposed a real Broken Robot regression:
the port compared the beam's terrain collision cell with the target even though
the source checks whether the beam path passes through the target. The source
path check is restored. Sewer Heart's charge animation also turns toward its
target again. These gates verify gameplay state and rewards; complete rendered
animation and sound timing still requires individual on-device boss fights.

The special-melee audit now covers Fire Cracker and SJRB Music as behavior rather
than class-presence checks. Fire Cracker regains the source `+1/+1` upgrade growth,
floor-wide beckon roll, nine-cell blast, terror roll, and fixed Year Beast hit.
SJRB Music regains the source hero-derived extra-damage roll, two-cell lunge,
adjacent shockwave, and delayed pushing-effect schedule; the port had incorrectly
used the attacker's own damage roll, which changed pet and monster use. Melee Pan's
melee/ranged conversion continues to preserve level, enchantment, reinforcement,
curse knowledge and curse state, with its Holy Stun and Burning forms covered by
runtime gates. Error Weapon completes the behavior audit for all twenty legacy
special-melee classes in the following section.

The Android environment blocker is cleared: BIOS SVM is enabled and the API 35
x86_64 AVD runs as `emulator-5554`. The 2026-09-22 10:10:38 full-gate debug APK is
43,630,454 bytes and installs over the prior build without deleting saves. Its
SHA-256 is `106F2F0F20C7B0DD3606F3795499A6EF5DF15BB230E980071D8AAD10F8D4B269`.
The latest on-device smoke test traversed the title, save selection, save details,
and the retained real depth-zero map after a floor transition. Simplified Chinese,
legacy art, the hero, inventory, quickslots, and map render correctly, with no
fatal exception, ANR, crash event, or out-of-memory error in logcat; the captured
frames are `build/reports/sps-android-smith-imp-smoke.png` and
`build/reports/sps-android-smith-imp-map.png`. Full rendered boss fights and other
long visual/audio sequences remain outstanding and are not treated as complete.

Error Weapon now has a behavior-level gate rather than only an initial-stat and
reward-route assertion. Twenty upgrades exercise its source random accuracy and
delay changes and their save round trip; repeated hits cover normal and boss
percentage damage, Cripple, Bleeding, Vertigo plus Terror, Paralysis, Roots,
healing, Ooze, and Charm. Together with the existing reward, event, town, quest,
skin, and tester gates, all twenty classes in the 0.9.8 special-melee directory
now have runtime coverage for their relevant stats, effects, actions, sources,
or persistent fields.

The prison-boss behavior pass restores several source rules that the earlier
map/stat checks did not exercise. SPS Tengu now pays both the jump action and the
movement action when jumping during pursuit, and regains its light weaknesses and
dark-enchantment resistance. Prison Wander now plants only Firebloom, Icecap,
Sorrowmoss, Blindweed, Stormvine, or Starflower with the exact `8:4:6:4:3:1`
weights, spends the source extra turn after teleporting the hero, and retains the
source negative-time chain animation order. Seeking Bombs count down only when
they move and explode as wall-breaking Dungeon Bombs. Tank movement again leaves
Dark Effect Damage rather than unrelated corrupt gas, with its source light/dark
defenses restored. The new `verifySpsPrisonBossTimeline` gate covers all of these
rules and is part of `verifySpsRelease`.

Headless prison-boss execution exposed save-transition crashes in shared Shattered
paths that assumed sprites, the main camera, or the active scene already existed.
Character movement/death, mob alert indicators, pushing-camera follow, and bomb
particles now skip visuals when those objects are absent while still completing
movement, death, damage, terrain destruction, and actor scheduling. Fixed-level,
legacy-blob, dangerous-bomb, and main-boss timeline regressions pass afterward.

The caves-boss behavior pass now covers all three variants beyond their map and
initial-stat checks. SPS DM-300 uses the source's one-time tower-power flag rather
than multiplying attack by the two living towers and losing all damage when they
die; its inactive-trap healing also restores the source's exclusive random bound.
Hybrid regains TEST_TIME damage, Dark Gas immunity, door opening, and the original
negative-time push for final-phase clones. Spider Queen egg spawning restores the
same door and push sequence. Worker, Mind, Jumper, and Gold spiders again add the
effective caves depth to damage and accuracy, Mind spiders may heal above maximum
health, and egg age survives saves. Hybrid, Queen, and Gold Spider now use base
speed so Cripple and other speed modifiers are no longer bypassed. The new
`verifySpsCavesBossTimeline` gate covers tower persistence, source defenses,
splitting, hatching thresholds, depth scaling, over-healing, speed effects, and
save restoration and is part of `verifySpsRelease`.

The city-boss behavior pass now covers King, Lich Dancer, Elder Avatar, and all
of their encounter actors. King and Lich Dancer regain the source's uncapped
three-point regeneration, while King's summon heal and all city-boss gold rolls
again use the legacy exclusive upper bound. Their Toxic Gas, dark-enchantment,
and Disintegration defenses are restored. Lich Dancer's battery tomb now summons
the original four Many Skeletons rather than Shattered Skeletons, and its Link
Bomb detonates as the wall-breaking Dungeon Bomb. Added Shattered-only actor
properties that changed gas, bleeding, fear, movement, and targeting rules have
been removed from all three encounters.

Elder Avatar once again uses TEST_TIME damage, Mini Bombs, the three legacy armor
exceptions, and the source's zero-extra-time obelisk and reinforcement phases.
Obelisk thresholds advance on the obelisk's own action instead of immediately on
damage, including the source's ability to take lethal damage after the elder is
reduced to 50 HP or less. Hunter reloads use the five-turn Disarm buff, Monk
attacks take a fixed half turn, and Mech receives its shield only once, with that
state now surviving saves. Missing minion gas reactions and elemental/control
immunities are restored. The `verifySpsCityBossTimeline` gate exercises these
rules, all four reinforcement waves, save restoration, and the absence of parent
attack effects that the legacy overrides suppress; it is part of
`verifySpsRelease`.

The halls-boss behavior pass now restores Yog and all four legacy fists beyond
their initial stats. Yog and the fists use the source's half-strength control
resistances rather than Shattered immunities, and Shattered-only `BOSS_MINION`
and `FIERY` properties no longer change their targeting or fire interactions.
Fists and phase teleports prefer hidden open cells, all four health-threshold
teleports consume no extra turn, and the final threshold summons `YearBeast`
rather than the unrelated `YearBeast2` class.

Rotting Fist can again heal 50 points past maximum health in water. Burning and
Pinning Fists fall back to adjacent attacks while silenced; their ranged attacks
use the source direct-damage path, bypass armor, and do not inherit unrelated
parent attack effects. Rotting and Infecting attack callbacks likewise suppress
the parent elemental-storm effect, and Infecting poison uses the source's
exclusive 7-to-9 random bound. Yog restores the source overkill rule, pays the
full 50 HP when resummoning cleared fists, and drops only Elevator plus the
current-depth legacy Skeleton Key on death; Pudding Cup remains available only
through the source special-loot interface. The new `verifySpsHallsBossTimeline`
gate covers these rules, four phases, Year Beast placement, larvae, cleanup,
rewards, and save restoration, and is part of `verifySpsRelease`. Teleport
particles now safely skip rendering when no scene sprite exists.

The sewer-boss behavior pass now covers Goo, Sewer Heart, Plague Doctor, Poison
Goo, Sewer Lasher, and Shadow Rat at the same depth as the other four main-route
boss regions. Goo regains its dark-enchantment resistances, five fire weaknesses,
uncapped three-point water healing, charged-attack reset after a miss, and Copy
Ball special loot. Poison Goo regains its below-100 maximum-health growth in
water, uncapped Roots healing, immediate Hot damage, and dark-enchantment
resistance. Both Goo attack callbacks suppress the parent elemental-storm effect
where the source overrides it.

Sewer Heart's five health transitions and Plague Doctor's three transitions no
longer consume an extra turn. Their beam, gas, combat phases, summoning counters,
and save fields are covered alongside the source's deliberate double parent
attack callback on Sewer Lashers and Shadow Rats. Shadow Rats again die instantly
to the SPS Wand of Light rather than the retained Shattered Prismatic Light wand.
Headless charged-Goo resolution also skips particles when no active scene exists,
fixing a save-transition crash found by the new gate. The
`verifySpsSewerBossTimeline` task is part of `verifySpsRelease`; the full release
gate and Android debug build pass with 156 tasks.

The two early main-route NPC quests have now been compared directly with the
0.9.8 implementations instead of relying on their retained Shattered classes.
The Sad Ghost again appears by the source depth chance, creates the matching
fetid rat, gnoll trickster, or great crab, relocates after reminder dialogue,
and offers exactly one identified artifact, ring, or base-pet egg after the
kill. Its normal artifact table is restored to the source's 18 ordered entries
and weights; retained Shattered-only artifacts no longer enter that table.
Weapon-and-armor ghost rewards from pre-fix saves are migrated to the SPS
three-choice reward without invalidating the run.

The old Wandmaker now appears only on depth 7 and no longer injects Shattered's
mass-grave, ritual, or rot-garden quest rooms. It restores the two source tasks,
placing corpse dust in a hidden skeleton heap or a Rotberry seed on a free cell,
and restores the exact seven-entry battle and utility wand pools, including the
deliberate double Wand of Flow entry. Reward choice also drops the source
Adamant Wand. Placement retries are bounded so malformed maps cannot hang, and
pre-fix ember-quest saves are converted to a freshly dispatchable corpse-dust
task. `verifySpsGhostQuest` and `verifySpsWandmakerQuest` cover generation,
progression, rewards, persistence, migration, and English, Simplified Chinese,
Traditional Chinese, and Russian text; both are part of `verifySpsRelease`.

The caves and city quest pass now isolates the retained Shattered mining and
vault quests from normal SPS room generation. The legacy blacksmith still asks
for 15 dark-gold pieces and offers one source-style reforge; the imp again asks
for six golem or eight monk tokens, including kills on depth 20, and gives the
source +2 cursed ring. Earlier SPS-SPD saves containing either Shattered quest
are migrated to the legacy path without discarding completed shop or reward
progress. Missing Traditional Chinese and Russian blacksmith/reforge strings are
restored, and all four active locales state the correct imp token counts. The new
`verifySpsBlacksmithImpQuest` gate covers rules, rewards, migration, boss-floor
drops, and text. The full release gate and Android debug build pass with 159
tasks; all 207 properties files also pass strict UTF-8 decoding without U+FFFD.

The remaining same-name display and compatibility candidates have now received
a behavior-level pass. Lloyd's Beacon is again the non-equippable, permanently
identified, non-upgradable unique item from 0.9.8, with only set and return
operations. It rejects every adjacent character, boss floors, and depths after
24; saves only its depth and position; and migrates the obsolete artifact level
out of earlier SPS-SPD saves. The three retained Shattered boss upgrade hooks
and all shooting, charging, and targeting text are removed. Same-cell return
still displaces an occupant to a safe adjacent tile, and cross-floor return
clears the modern branch field to prevent an invalid destination.

The legacy fog renderer is restored through the current libGDX backend: it uses
the source four-cell-corner visibility test, fixed visited and mapped colors,
16-pixel scale, and half-tile offset. Dungeon clicks outside the map once again
return no cell, and discovery fades inherit the tilemap's bright-mode tint. The
old-save-only `items.quest.RatSkull` is now a separate unique, identified,
non-upgradable 100-gold item with its original sprite and four source locales;
the unrelated Shattered trinket remains implemented but hidden from SPS runs.
`verifySpsLloydsBeacon` and `verifySpsLegacyDisplay` cover these rules and are
part of `verifySpsRelease`. The source audit now reports 1,721 exact relative
paths, 64 additional same-name matches, 131 reviewed adapters, and zero missing
candidates. This closes the listed file-level candidates, not the remaining
playthrough and behavior audit, so the project is still not marked 100% done.
The full release gate and Android debug build pass with 161 tasks. The resulting
43,628,083-byte APK has SHA-256
`ED6E99B3B1678C65E59B63FBF31C22F381833A615A83059591413B110FB85AA6`.
It was installed over the API 35 emulator while preserving saves; the title,
save detail, and live map render in Simplified Chinese without corruption, the
legacy fog updates correctly, and logcat contains no fatal exception, ANR,
process crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-legacy-fog-smoke.png`, `sps-legacy-fog-save.png`, and
`sps-legacy-fog-live-map.png`.

The same-name scroll audit has restored `items.scrolls.ScrollOfPsionicBlast` as
the ordinary SPS psionic-draw scroll rather than Shattered's exotic attack
scroll. A normal reading now alerts every mob on the floor, counts only
non-NPC mobs, and grants a 30-turn `SuperArcane` buff at that count without
damaging or debuffing the reader or any target. Its empowered reading deals one
maximum-health hit only to mobs in the hero's field of view. The source price,
alchemy value, initials, ordinary-scroll identity, challenge starting item,
gift source, boss immunities, and English, Simplified Chinese, Traditional
Chinese, and Russian text are restored. The retained Shattered exotic class is
still loadable but no longer stands in for the SPS item.

The ordinary scroll generator now uses the exact 14 source classes, order, and
weights, including Magical Infusion, Psionic Draw, Regrowth, and Dummy while
excluding Shattered's Retribution and Transmutation entries. All 14 legacy rune
sprites and the NCOSRANE, NENDIL, and LIBRA labels are present. Obsolete ODAL
labels and duplicate labels in earlier saves are reassigned without losing
known status, preventing a null-image load crash. Single-deck total weights are
also initialized for the retained spellbook and crystal-path consumers, fixing
the artifact-construction crash exposed by fixed-map generation.

`verifySpsPsionicBlast` exercises the live ordinary and empowered effects,
generation table, identification, save migration, source sprite pixels, and
four UTF-8 locales, and is part of `verifySpsRelease`. The source audit now
reports 1,722 exact relative paths, 63 additional same-name matches, 131
reviewed adapters, and zero missing candidates. The full release gate and
Android debug build pass with 162 tasks. The resulting 43,628,443-byte APK has
SHA-256 `F089AD63EF71E8BD56E9827049C0B3D4EA8F855573F8436470368D6464426E5C`.
This remains an incremental behavior-audit milestone, not a 100% completion
claim.

The Blandfruit behavior audit has removed the competing Shattered cooked-fruit
path from normal SPS play. Raw `items.food.Blandfruit` is once again an ordinary
legacy fruit: it is stackable, directly edible, restores 100 food energy, takes
the source three turns to eat, sells for 20 gold, and participates in recipes
which accept the legacy `Fruit` base type. It no longer overrides throwing,
shatters a potion, or creates chunks. The obsolete `Chunks` data class remains
loadable only so saves written by earlier SPS-SPD builds are not corrupted.

Blandfruit plus a valid seed now has exactly one zero-energy recipe and always
produces the separate SPS `items.brewed.Brewed` item. The Shattered
`Blandfruit.CookFruit` recipe has been removed from both the recipe table and
alchemy guide. Earlier SPS-SPD saves containing a potion-infused Blandfruit
retain their potion attribute, glow, action, food value, and round-trip save
data, but no current gameplay path creates another one. The Horn of Plenty also
accepts raw Blandfruit instead of rejecting it. Missing Traditional Chinese and
Russian Brewed strings are restored as strict UTF-8.

The new `verifySpsBlandfruit` gate exercises live satiety, value, fruit typing,
eat time, standard throwing, the unique Brewed recipe, old cooked-save
compatibility, Horn feeding, and English, Simplified Chinese, Traditional
Chinese, and Russian resources. It is part of `verifySpsRelease`; related food,
alchemy, plant, room, and properties gates also pass. The full release gate and
Android debug build now pass with 163 tasks. The resulting 43,628,199-byte APK
has SHA-256
`F812AF11DE23910A7AB32125A5856B518242803626232AE7A88590D3160F3215`.
It was installed over `emulator-5554` while preserving its save. The title,
save list, save details, and live map render in Simplified Chinese without
corruption, and logcat contains no fatal exception, null pointer, ANR, native
crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-blandfruit-smoke.png`, `sps-blandfruit-save.png`,
`sps-blandfruit-map.png`, and `sps-blandfruit-live.png`. This is another
behavior-audit milestone, not a 100% completion claim.

The Horn of Plenty behavior audit has restored the 0.9.8 artifact in place of
Shattered's modern implementation. Its maximum level is again 30, capacity is
fixed at ten charges, and `EAT` is the default action. Eating consumes every
stored charge at once, grants 40 food energy per charge, takes three turns, and
counts as a meal only at three charges or more. Normal SPS play no longer
exposes the modern snack action. At level zero the horn gains 0.25 charge
progress per turn and at level 30 it gains 0.70, with 80 progress per charge;
the display thresholds are again 3, 7, and 10. A cursed or full horn discards
partial progress as in the source.

Food upgrades now use the source `hornValue` table, including the legacy food,
fruit, vegetable, meat, water, brewed, holiday, and complete-food exceptions.
`STORE` and `FEED` are restored: feeding food upgrades the horn directly up to
level 30, while feeding the artifact to its user grants the source `Feed` buff
for three turns per level, costs one turn, and resets its level. The Shattered
hero-experience charging hook is removed. The retained hidden Shattered class
spell may still call the compatibility eating effect, but it has no normal SPS
entry point.

Earlier SPS-SPD saves from the accidental ten-level implementation migrate by
scaling their level by three and converting obsolete stored food energy at 100
points per level. Original 0.9.8 thirty-level saves have no obsolete marker and
are not rescaled. The `verifySpsHornOfPlenty` gate covers actions, capacity,
time charging, curse/full behavior, every current food value, full-charge
eating, meal accounting, `Feed`, both save paths, and strict UTF-8 English,
Simplified Chinese, Traditional Chinese, and Russian text. It is included in
`verifySpsRelease`.

The full release gate and Android debug build now pass with 164 tasks. The APK
is 43,628,674 bytes with SHA-256
`D692FFFF42B9B3DDA5BDB473291883FB3D82884CE02858145BEB2C59D7616464`.
It was installed over `emulator-5554` while preserving the existing save. The
title, save list, save detail, live map, and inventory render in Simplified
Chinese without corruption; logcat contains no fatal exception, null pointer,
ANR, native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-horn-smoke.png`, `sps-horn-save.png`,
`sps-horn-detail.png`, `sps-horn-map.png`, and `sps-horn-live.png`. This remains
an incremental behavior-audit milestone and is not a 100% completion claim.

The Alchemist's Toolkit has now been restored from Shattered's warm-up and
energy-crystal implementation to its 0.9.8 potion-order game. Each toolkit
chooses three distinct ordinary potions while excluding Experience, Strength,
Might, and Overhealing. While equipped and uncursed below level ten, `BREW`
accepts identified potion classes without consuming the bottles. Three guesses
are scored as three points per correct position and one per correct potion in
the wrong position; a perfect nine-point guess becomes level ten. The best
guess, right/wrong counts, pending guess, hidden combination, and seed-efficiency
state all round-trip through saves.

`COOKING` remains available as the portable alchemy entry, with ingredient
capacity increasing from three to four at level five and to five at level ten.
When the upgraded toolkit is unequipped, `CREATE` spends one turn, creates one
random item per level, and consumes the toolkit. The old passive seed threshold
logic is restored. Shattered's energize action, warm-up delay, artifact energy,
experience charging hook, and four active-locale descriptions are removed from
normal SPS play. The current alchemy scene compatibility methods remain but
provide no toolkit energy, so the retained hidden Shattered class spell can
still load safely.

Earlier SPS-SPD saves without the legacy combination fields retain a newly
generated safe combination instead of being cleared. Custom toolkit actions no
longer call an absent `GameScene` cell selector in headless/load contexts, and
item creation tolerates a heap whose sprite has not yet been built. The new
`verifySpsAlchemistsToolkit` gate covers combination exclusions, action states,
scoring, level cap, slots, seed efficiency, exhausted creation, save migration,
absence of modern energy behavior, and strict UTF-8 English, Simplified Chinese,
Traditional Chinese, and Russian resources.

The full release gate and Android debug build now pass with 165 tasks. The APK
is 43,629,703 bytes with SHA-256
`2B144706AC476E3691BBD4A4864457CBF38B267427FF3EE99B569ACFB34C1F96`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, save detail, live map, and inventory render in Simplified Chinese
without corruption, and logcat contains no fatal exception, null pointer, ANR,
native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-alchemist-toolkit-smoke.png`,
`sps-alchemist-toolkit-save.png`, `sps-alchemist-toolkit-detail.png`,
`sps-alchemist-toolkit-map.png`, and `sps-alchemist-toolkit-live.png`. This is
still an incremental behavior-audit milestone, not a 100% completion claim.

The Cape of Thorns behavior audit has restored the SPS-PD 0.9.8 artifact in
place of Shattered's modern implementation. `NEEDLING` is again the default
action and appears only while the uncursed cape is equipped above level one.
Using it consumes one artifact level, takes one turn, and applies Needling for
ten turns per pre-use level. The modern external artifact-charging hook has
been removed from normal SPS behavior.

Damage charging again uses `damage * (0.7 + level * 0.1)`. At 100 charge the
cape clears its charge, activates for `10 + level` turns, and grants
`level * 10` physical shield. While active it randomly deflects zero through
the full incoming damage, reflects the deflected amount even to a non-adjacent
attacker, and gains that amount as artifact experience with the source
`(level + 1) * 5` threshold and level-ten cap. Environmental damage now safely
handles a missing attacker, and headless/load contexts safely handle missing
sprites. Detaching the passive state clears both charge and active duration.

High grass once again reads the cape's passive state and performs the source
independent seed roll for an uncursed levelled cape, scaling from 1/15 at level
one to 1/6 at level ten. English, Simplified Chinese, Traditional Chinese, and
Russian action and description text are restored as strict UTF-8. The new
`verifySpsCapeOfThorns` gate covers action visibility and exhaustion, Needling
duration, level-zero and level-ten charge formulas, full-charge shield and
duration, ranged reflection, null attackers, experience growth and cap,
detach/reset, save data, high-grass odds, and four active locales. It is part
of `verifySpsRelease`.

The full release gate and Android debug build now pass with 166 tasks. The APK
is 43,629,762 bytes with SHA-256
`07194191F96BC735A8654218D3DF9D87ACB0B7DE5682513C1EB8A2D46464BE5C`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, save detail, live map, and inventory render in Simplified Chinese
without corruption, and logcat contains no fatal exception, null pointer, ANR,
native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-cape-smoke.png`, `sps-cape-save.png`,
`sps-cape-detail.png`, `sps-cape-map.png`, and `sps-cape-live.png`. This remains
an incremental behavior-audit milestone and is not a 100% completion claim.

The Cloak of Shadows behavior audit has restored the SPS-PD 0.9.8 artifact in
place of Shattered's modern implementation. `STEALTH` is again the default
action. The cloak starts with three charge and a three-point capacity, expands
to ten through upgrades, and can begin stealth only while equipped with more
than one charge. A cursed cloak may still enter ordinary stealth, matching the
source. Starting or manually ending stealth takes one turn; the first action
uses one charge and subsequent drain occurs every five turns. Experience again
uses the source hero-level difference and `(level + 1) * 50` threshold.

Passive charging now follows the legacy level-based timing, from roughly 47
turns per point at level zero to 30 turns per point at level ten, and Shattered's
external artifact-energy hook no longer changes normal SPS behavior. At level
four or higher an uncursed cloak exposes `SHADOW`: it spends three artifact
levels and applies `ForeverShadow` for ten turns per pre-use level. General
invisibility duration is restored from 20 to 15 turns, and Forever Shadow again
uses its blessing icon, localized name, and remaining-duration description.
Removing an actively stealthing cloak now clears its invisibility instead of
leaving a permanent hidden state.

New saves use the source `stealthed` flag, while early SPS-SPD nested-buff saves
and older cooldown-based cloak saves remain loadable. Missing sprites are safe
in headless/load execution. Shattered's Light Cloak backpack activation path is
retained in source but excluded from normal SPS flow. English, Simplified
Chinese, Traditional Chinese, and Russian strings are strict UTF-8. The new
`verifySpsCloakOfShadows` gate covers actions, drain timing, charging, growth,
Shadow exhaustion, invisibility cleanup, compatibility saves, and four active
locales, and is part of `verifySpsRelease`.

The full release gate and Android debug build now pass with 167 tasks. The APK
is 43,629,728 bytes with SHA-256
`B7B112C0D00FECD9AED0FC9497652B13BC7E9D535BCCD7C6002AFE6E54A8BFA1`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, save detail, live map, and inventory render in Simplified Chinese
without corruption, and logcat contains no fatal exception, null pointer, ANR,
native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-cloak-smoke.png`, `sps-cloak-save.png`,
`sps-cloak-detail.png`, `sps-cloak-map.png`, and `sps-cloak-live.png`. The map
image also confirms the legacy lava-ring room and HUD render correctly. This
remains an incremental behavior-audit milestone and is not a 100% completion
claim.

The Dried Rose behavior audit has replaced Shattered's modern rose flow with
the SPS-PD 0.9.8 rules. Before the sad-ghost quest is complete the rose cannot
be equipped. Afterwards it exposes the source summon and outfit actions, while
Shattered's remote `DIRECT` action and ghost-health status are absent from the
normal SPS flow. The rose starts full at 200 charge and passively gains 0.4
partial charge per turn whether or not an earlier ghost is alive. Shattered's
regeneration, Ring of Energy, magic-immunity, ghost-healing, and external
artifact-energy modifiers no longer alter that formula. A cursed equipped rose
again has the source one-percent-per-turn chance to create a Red Wraith.

Summoning consumes the full 200 charge and one turn. Ordinary heroes receive
the source sad ghost with `20 + 10 * rose level` health, 10 accuracy, 5 evasion,
0-5 unarmed damage, one point of decay while the rose remains equipped, and
five points while it is absent. The Leader subclass receives the restored
Super Ghost with `40 + 15 * rose level` health, 25 accuracy, 10 evasion, 0-10
unarmed damage, no equipped decay, doubled weapon maximum damage, and doubled
armor minimum block. The normal and enhanced ghosts use their separate legacy
sprites. Both retain the source equipment effects and reject all direct buffs.

Ghost equipment strength is again the fixed source value of 30, and outfit
selection once more requires fully identified, non-unique, uncursed equipment.
An unequipped rose above level zero exposes `SOULBLESS`; exhausting it takes one
turn, raises the persistent pet level by integer `rose level / 2`, refreshes an
active pet, and consumes the rose. Ghost death now preserves the intended 20%
Wraith Breath roll and guaranteed petal: this fixes the 0.9.8 typo that assigned
the second loot probability to the first field. Summon and cursed-spawn scans
are bounds-safe, custom actions work without a render scene or hero sprite, and
early SPS-SPD `ghostID` saves remain readable without writing that
Shattered-only field into new saves.

English, Simplified Chinese, Traditional Chinese, and Russian action, Super
Ghost, equipment, and error strings are strict UTF-8. The new
`verifySpsDriedRose` gate covers quest gating, the 200-point capacity, the exact
0.4 recharge formula, disabled external charging, fixed strength, Soul Bless,
both ghost stat and decay profiles, persistence, and four active locales. It is
part of `verifySpsRelease`; the ghost-quest, class-skill, base-pet, and catalog
gates also pass.

The full release gate and Android debug build now pass with 168 tasks: 129
executed and 39 up-to-date. The APK is 43,628,702 bytes with SHA-256
`FC604DCD28972D3C2EDE70A5D00381AAFDD97A810C9FCABFF28143E0EB18087C`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, save detail, legacy lava-ring map, and inventory render in Simplified
Chinese without corruption; the existing run resumes and logcat contains no
fatal exception, null pointer, ANR, native crash, or out-of-memory event.
Evidence is stored in `build/reports/sps-driedrose-smoke.png`,
`sps-driedrose-save.png`, `sps-driedrose-detail.png`,
`sps-driedrose-map.png`, and `sps-driedrose-live.png`. This remains an
incremental behavior-audit milestone and is not a 100% completion claim.

The Ethereal Chains audit restores the missing SPS-PD 0.9.8 `LOCKED`
exhaustion action at artifact level two and above. A selected visible creature
receives Locked, Silent, Slow, and 90% AttackDown for four turns per pre-use
artifact level; the chains then lose one level and the hero spends one turn.
Selection is bounds-safe and a missing hero sprite no longer crashes the
effect. The existing modern pull implementation remains as the engine-safe
carrier for the source cast behavior.

Passive recharge again ignores Shattered's regeneration, Ring of Energy,
magic-immunity, and external artifact-energy modifiers. Empty level-zero chains
gain one link per 30 turns using the source missing-charge formula. Defeated
enemy progress again adds `level portion * 10` partial charge, and artifact
growth uses the source strict `100 + level * 50` threshold rather than the
modern doubled threshold. Four-language `LOCKED` text is strict UTF-8. The new
`verifySpsEtherealChains` gate covers actions, four debuffs, duration, level
exhaustion, turn cost, passive/external charging, kill growth, and localization;
the Fly Chains, class-skill, and catalog gates remain green.

The full release gate and Android debug build now pass with 169 tasks: 130
executed and 39 up-to-date. The APK is 43,629,605 bytes with SHA-256
`EDCE348D57E5CFD8C773336EE2A0FB71579292B7B5B385CBAF1883E379DF2A0B`.
It was installed over `emulator-5554` without deleting its save; the existing
run resumes on the legacy lava-ring map in Simplified Chinese, and logcat has no
fatal exception, null pointer, ANR, native crash, or out-of-memory event. The
final map evidence is `build/reports/sps-chains-map.png`. This remains an
incremental behavior-audit milestone and is not a 100% completion claim.

The Master Thieves' Armband audit now restores the SPS-PD 0.9.8 artifact rather
than Shattered's modern robbery system. It starts at level zero with one charge
slot, caps at level five and six slots, and shows `STEAL` only while equipped,
charged, and uncursed. An adjacent Mob yields its `SupercreateLoot` result on
the first theft and Stone Ore on every later theft. Shopkeepers and non-hostile
Mobs remain valid source targets as in the uncommented 0.9.8 code. A null legacy
loot result safely falls back to Stone Ore, target selection is bounds-safe,
and missing sprites no longer make the action crash.

Each theft consumes one charge and one growth point. Growth again uses the
source reset threshold `exp >= artifact level`, including the first theft's
zero-to-one upgrade, and the artifact capacity rises by one per level. Passive
time charging adds one partial point per turn and grants one charge at 400.
Enemy deaths add the current artifact level and retain the source strict
`partial > 400` threshold. The misplaced Shattered experience-percentage
hook, Ring of Energy scaling, external artifact charging, surprise bonuses,
random loot chance, debuffs, repeat-loot suppression, and normal shop-steal UI
have been removed from the active SPS path. A cursed equipped armband retains
its one-in-five-per-turn gold loss.

The unequipped level-two action `GOLDTOUCH` is restored. It applies Gold Touch
for five turns per pre-use artifact level, spends one turn, and exhausts one
artifact level without changing the existing capacity, matching the source.
The save loader preserves the 0.9.8 `partialCharge` field, restores upgraded
charge without the base-class clipping bug, and safely maps early SPS-SPD
level-six-to-ten armbands onto the source level-five cap. The obsolete
`StolenTracker` type remains loadable for development-save compatibility but
no longer suppresses normal monster drops.

English, Simplified Chinese, Traditional Chinese, and Russian source action and
description strings are strict UTF-8. The new
`verifySpsMasterThievesArmband` gate covers action visibility, status,
Gold Touch duration and exhaustion, first and repeated loot, null-loot safety,
growth, both recharge paths, disabled external/shop charging, save migration,
integration hooks, and four locales. It is part of `verifySpsRelease`; the
mob-rotation, class-skill, and catalog gates also remain green.

The full release gate, desktop ZIP, and Android debug build pass with 176 tasks:
137 executed and 39 up-to-date. The desktop archive is 86,802,058 bytes with
SHA-256 `28685536ED3341BFB591E07088777B428E2A8860360D5D799DD40BE6C0C250CD`;
it was actually launched and remained alive without an exception before the
smoke process was closed. The APK is 43,629,359 bytes with SHA-256
`97B096F63E78E335F04FDE13103114A5948E95598A7FF0197FD10591A816327B`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, detail, and existing legacy lava-ring run render in Simplified
Chinese; the process remains alive and logcat contains no fatal exception, null
pointer, ANR, native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-armband-smoke.png`, `sps-armband-save.png`,
`sps-armband-detail.png`, and `sps-armband-map.png`. This remains an
incremental behavior-audit milestone and is not a 100% completion claim.

The Sandals of Nature audit now restores the SPS-PD 0.9.8 artifact progression
instead of Shattered's modern seed-effect cycle. The artifact again caps at
level ten. Each level requires `level + 1` distinct seed types and clears the
recorded seed set after upgrading. Its four source icon stages and
`desc_0` through `desc_3` descriptions are restored. Trampling high grass adds
`round((HT - charge) * (0.01 + artifact level * 0.01))` charge using the raw
artifact level, without Shattered's extra level offset.

The equipped `ROOT` action consumes all stored charge and applies five turns of
Roots. Earthroot now has a separate legacy `MagicPlantArmor` buff: it absorbs
about half of incoming physical damage, spends durability by the amount
absorbed, and collapses when the hero moves. The buff is integrated into the
hero defense path. An unequipped, uncursed artifact above level zero exposes
the restored exhaustion action, scatters `40 * artifact level` applications of
legacy Water across valid map cells, spends two turns, and consumes the
artifact. A cursed artifact cannot accept seeds but may still use existing
charge for rooting, matching the source. External artifact charging is disabled.

Early SPS-SPD saves containing `Class[] seeds` and `cur_seed_effect` remain
readable. The modern `SpiritForm` carrier state and target selector remain in
source for compatibility but are hidden from the normal SPS route. English,
Simplified Chinese, Traditional Chinese, and Russian resources are strict
UTF-8. The new `verifySpsSandalsOfNature` gate covers progression, charge,
rooting, exhaustion, Earthroot armor, persistence, hidden modern actions, and
all four locales. It is part of `verifySpsRelease`; the enhanced-plant,
class-skill, and catalog gates also pass.

The complete serial release gate passes with 130 actionable tasks: 124 executed
and 6 up-to-date. The subsequent desktop and Android build passes with 52
actionable tasks: 10 executed and 42 up-to-date. The desktop archive is
86,806,282 bytes with SHA-256
`975DF92484EF8BFF5D7A59DBA7EC138F4C2E107979E3994DACC3BDEDE5C5561B`;
the desktop client was launched through the project runtime, remained
responsive, and produced no startup exception before the smoke process was
closed. The APK is 43,629,851 bytes with SHA-256
`B7C6CF0647C9DC4D645B1EE0E54334BAFCB0BECD4F664820B21C99FBDD62994B`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, save detail, and existing legacy lava-ring run render in Simplified
Chinese; the process remains alive and logcat contains no fatal exception, null
pointer, ANR, native crash, or out-of-memory event. All 207 runtime properties
files pass strict UTF-8 decoding and contain no replacement character. Android
evidence is stored in `build/reports/sps-sandals-smoke.png`,
`sps-sandals-save.png`, `sps-sandals-map.png`, and `sps-sandals-live.png`.
This remains an incremental behavior-audit milestone and is not a 100%
completion claim.

The Talisman of Foresight audit replaces Shattered's normal cone-scanning flow
with SPS-PD 0.9.8 behavior. `SCRY` is now available only while the artifact is
equipped, uncursed, outside the four Sokoban maps, and exactly full at 100
charge. It immediately empties the charge, refreshes every secret terrain cell,
reveals currently visible secret graphics, and grants the source two-turn
Awareness effect. It does not use a target selector, distance-based cost,
scanned-cell experience, temporary per-creature markers, or artifact-use talent
hooks in the normal SPS route. The modern selector and awareness carrier types
remain loadable for hidden Shattered compatibility consumers.

The level-three `NOTICE` exhaustion action is restored. It spends two artifact
levels and one hero turn, then applies Notice for ten turns per pre-use artifact
level. Passive time charging again adds `0.04 + level * 0.006` each turn and
uses the source strict `partialCharge > 1` conversion. Discovering any secret
restores `2 + level / 3` charge, awards one growth point, and upgrades after
every four discoveries. Ring of Energy, regeneration state, magic immunity,
and external artifact charging no longer modify these rules. A cursed talisman
still blocks accidental discovery even under magic immunity.

The passive warning again checks visible non-door secrets within three cells,
interrupts the hero once, and keeps its indicator for three clear checks. Bounds
and missing-level guards prevent invalid-load crashes. Existing warning saves,
the standard artifact level/experience/charge fields, and the retained modern
awareness classes remain readable. English, Simplified Chinese, Traditional
Chinese, and Russian source strings are strict UTF-8. The new
`verifySpsTalismanOfForesight` gate covers actions, Sokoban exclusion, Scry,
Notice, warning decay, curse behavior, both recharge paths, growth, persistence,
integration hooks, and all four locales; it is part of `verifySpsRelease`.

The complete serial release gate passes with 131 actionable tasks: 125 executed
and 6 up-to-date. The desktop and Android build passes with 52 actionable tasks:
14 executed and 38 up-to-date. The desktop archive is 86,808,092 bytes with
SHA-256 `FBD3AFC81D8AE1F1EBBEF0A4BEC46D9490F5D87AFA460B85CEA3A2535C2566BA`;
the desktop client started, remained responsive, and exited cleanly with a
successful Gradle run. The APK is 43,630,350 bytes with SHA-256
`D374CEA144936D8911CAE1DEF74550262FBDB7B340CCB8E1FDD58EA6802589CB`.
It was installed over `emulator-5554` without deleting its save. The title,
save flow, and existing legacy lava-ring run render in Simplified Chinese; the
process remains alive and logcat contains no fatal exception, null pointer, ANR,
native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-talisman-smoke.png`, `sps-talisman-save.png`, and
`sps-talisman-live.png`. This remains an incremental behavior-audit milestone
and is not a 100% completion claim.

The Timekeeper's Hourglass audit now restores the SPS-PD 0.9.8 timing model.
The equipped, uncursed artifact exposes `ACTIVATE` with any positive charge,
but still rejects activation at one charge. Stasis consumes one charge, advances
the hero and the stasis carrier by exactly four turns, refunds four turns of
non-starving hunger, and uses the retained invisibility carrier plus explicit
damage and negative-buff guards to provide the source invulnerability. Time
freeze no longer prepays charge: it spends one charge per four hero turns and
one additional charge when the effect ends. Delayed trap and plant activation
continues to use the current engine's safe scheduling implementation.

The unequipped, uncursed level-five `RESTART` exhaustion action is restored. It
resets the artifact to level zero, immediately synchronizes its capacity to five,
removes only keys for the current depth, and rebuilds that depth through
`InterlevelScene.Mode.RESET`. Passive charging again uses
`1 / (60 - (chargeCap - charge) * 2)`. Regeneration settings, Ring of Energy,
magic immunity, external artifact charging, and Shattered artifact-use talents
do not alter the normal SPS path. Sand bags only upgrade a non-cursed hourglass
below level five and again have a value of 10.

The loader derives capacity from `5 + level` before restoring charge, clamps
invalid values safely, accepts early SPS-SPD `turnsToCost` freeze saves, and no
longer fails when a freeze bundle omits its delayed-press array. Active-effect
attachment now rolls back cleanly on failure. Stasis and freeze detachment are
idempotent, preventing repeated invisibility removal, charge loss, delayed
terrain activation, or turn advancement. Missing levels and sprites are guarded.
`TimeOclock` is a separate artifact implementation and is unaffected by this
change. English, Simplified Chinese, Traditional Chinese, and Russian source
strings remain strict UTF-8.

The new `verifySpsTimekeepersHourglass` gate covers action visibility, four-turn
stasis, four-turn freeze charging, repeated-detach safety, depth reset, passive
charging, sand bags, persistence, old-save migration, disabled Shattered hooks,
and all four locales. It is part of `verifySpsRelease`. The complete serial gate
passes with 132 actionable tasks: 126 executed and 6 up-to-date. The desktop and
Android build passes with 52 actionable tasks: 13 executed and 39 up-to-date.

The desktop archive is 86,806,714 bytes with SHA-256
`841CB10C6F0B9874BB9CDF4265DA5319A785D43292B2DF67EAFFD63F68E13D16`;
the client started, remained responsive, and exited cleanly through its window
close event with a successful Gradle run. The APK is 43,630,197 bytes with
SHA-256 `1D4E41B213AB107E79D7692942F3D33C02FCCC4E178326A337CD81D05F895808`.
It was installed over `emulator-5554` without deleting its save. The title,
save list, save detail, and existing legacy lava-ring run render in Simplified
Chinese. The process remains alive and logcat contains no fatal exception, null
pointer, ANR, native crash, or out-of-memory event. All 207 runtime properties
files pass strict UTF-8 decoding and contain no replacement character. Evidence
is stored in `build/reports/sps-hourglass-smoke.png`,
`sps-hourglass-save.png`, `sps-hourglass-live.png`, and
`sps-hourglass-map.png`. This remains an incremental behavior-audit milestone
and is not a 100% completion claim.

The Unstable Spellbook audit restores the SPS-PD 0.9.8 progression and
exhaustion loop. Its capacity starts at two and follows the source upgrade
sequence through eight at level ten. Upgrading consumes only high-energy dew,
requires strictly more than `(level + 1) * 100`, costs two turns, and uses the
restored four-locale feedback and dew requirement text. Equipped, uncursed
books spend one charge to draw from the 14-class SPS scroll deck. Identify,
remove-curse, and mapping reroll half the time, teleportation is excluded on
boss floors, and a bounded retry prevents malformed decks from hanging.
`Random.Int(15) < level` selects the ordinary effect; all other rolls use the
restored empowered entry point. Generated casts are anonymous, do not consume
inventory scrolls, do not identify runes, and do not trigger Shattered scroll
talents.

The level-four unequipped `SONG` exhaustion action grants the source attack,
defense, arcane, and targeting buffs, permanently adds attack and defense skill
at level eight, and at level ten also adds magic skill, invisibility, and haste.
It consumes the old book and drops a new level-zero spellbook. Passive charging
again uses `1 / (150 - (chargeCap - charge) * 15)` and ignores Ring of Energy,
external artifact charging, regeneration state, and magic immunity. Loading
clamps charge against the capacity derived from the restored level, accepts the
legacy `partialCharge` field, and retains a generated compatibility scroll list
when a modern `scrolls` field is absent.

The scroll audit also restores SPS behavior reached through the spellbook:
lullaby applies the source attack and armor penalties; rage applies silence and
opens mimic heaps; recharging grants arcane power and shocks visible enemies;
terror adds haste and shadow curse before its empowered paralysis/countdown;
ordinary mirror image creates three copies; ordinary and empowered mapping once
again differ on secret discovery; and remove curse cleans the full inventory,
reverses negative levels, and marks visible enemies with the source light
effect. The delayed mirror generator stops when no legal cells remain, avoiding
the source infinite retry. Empty-map and missing-sprite paths are guarded.

The new `verifySpsUnstableSpellbook` gate covers actions, exact capacity and dew
boundaries, ordinary/empowered dispatch, all 14 empowered scroll entry points,
level 4/8/10 song effects, replacement, charging, disabled external charging,
save compatibility, scroll parity guards, and English, Simplified Chinese,
Traditional Chinese, and Russian resources. It is part of `verifySpsRelease`.
The complete serial gate passes with 133 actionable tasks: 127 executed and 6
up-to-date. The final desktop and Android build passes with 54 actionable tasks:
11 executed and 43 up-to-date.

The desktop archive is 86,817,926 bytes with SHA-256
`1529C357908A868DDDB26D440A8DE1FE4E77FE4A76FFA78B247400249BAADA5A`;
the client started, remained responsive, and exited cleanly through its window
close event. The APK is 43,632,732 bytes with SHA-256
`188E41041C76906D2AEB6B41F4332ADFCB05BE2189C9C79D8580EAD24F3046E2`.
It was installed over `emulator-5554` without deleting `game1/depth1.dat`.
The title and all eight legacy hero choices render correctly in Simplified
Chinese; process 3711 remained alive and its log contained no fatal exception,
null pointer, ANR, native crash, or out-of-memory event. All 207 runtime
properties files pass strict UTF-8 decoding and contain no replacement
character. Evidence is stored in `build/reports/sps-spellbook-smoke.png`,
`sps-spellbook-save.png`, and `sps-spellbook-live.png`. This remains an
incremental behavior-audit milestone and is not a 100% completion claim.

The Eye of Skadi audit replaces the incorrect Talisman of Foresight wrapper
with the SPS-PD 0.9.8 artifact. It has a ten-level cap, 100 charge, the original
`CURSE`, ore `ADD`, and exhaustion `BLAST` actions, and passive charge gain of
`1 + level` partial points per turn with ten points per charge. Curse now applies
poison, SPS frostbite, 80 percent armor break, and chill to an explored target.
Blast damages every living monster for one quarter to one half of its current
health, freezes survivors, and consumes one artifact level without spending a
hero turn. Stone Ore gives one offering point and Norn Stone gives five; the
strict `consumed points > level + 1` boundary and one-upgrade-per-offering rule
are retained.

The source's static offering counter is intentionally migrated to a per-item
saved field so multiple eyes no longer share progress. Old `partialCharge`,
`charge`, and `consumedpts` fields and the original class name remain readable.
Invalid target cells, missing levels and sprites, empty monster sets, and
one-health damage ranges are guarded. The original icon is imported without
resampling, with SHA-256
`2301EC3D3ACCFC4244E9049BF8C01267BD04FA11A3F2234DDF79D7599D10B157`.
English, Simplified Chinese, Traditional Chinese, and Russian strings are
strict UTF-8.

The Noomlin Crown audit removes the invented Master Thieves' Armband behavior.
It is again the powerless SPS keepsake: level cap one, an empty passive buff,
no charge or levy action, and value 100. Its special-shop and Adventure Journal
sources remain active, old saves have a class alias, and its original icon hash
is `0D1FB5652FB2E62F62AF83458F9F2C558C96FC527D115FC9AB3154A0DE587B87`.
The original English and Simplified Chinese copy is restored, with matching
Traditional Chinese and Russian coverage.

`verifySpsEyeOfSkadi` and `verifySpsNoomlinCrown` cover behavior, failure
boundaries, independent persistence, sources, class aliases, locale keys, and
pixel-identical sprites. Both are part of `verifySpsRelease`. The final serial
gate passes with 135 actionable tasks: 129 executed and 6 up-to-date. The final
desktop and Android build passes with 52 actionable tasks: 12 executed and 40
up-to-date.

The desktop archive is 86,830,385 bytes with SHA-256
`F26191D7D2DE4EE7D7A74DD63E4EFD37C9E977704817B834A1A6AAA93A43C88A`;
the client started, remained responsive, and exited cleanly through its window
close event. The APK is 43,634,593 bytes with SHA-256
`1FEBE502F22486212004DBA92521554E7CF46ED83865F75CB0353B02DCD07C71`.
It was installed over `emulator-5554` without changing
`game1/depth1.dat`. Process 5629 remained alive, the title rendered correctly
in Simplified Chinese, and the process log contained no fatal exception, null
pointer, ANR, native crash, or out-of-memory event. Evidence is stored in
`build/reports/sps-artifacts-smoke.png`. This remains an incremental
behavior-audit milestone and is not a 100% completion claim.

The SPS medicine family has now been audited directly against 0.9.8 rather
than accepted on class-name coverage. The shared pill action once again blocks
eating under `Locked`, gives Followers the source ten-percent non-consumption
chance, records food statistics and badges, and uses the legacy one-turn eating
flow. Blue Milk, Death Cap, Earthstar, Golden Jelly, Jack-o'-Lantern, Pixie
Parasol, Green Spore, Foamed Beverage, Recover Pill, and the six combat pills
now apply the source floor-wide targets, exact buff classes, levels, durations,
self-damage, cleansing, healing, and class/subclass additions. Both time blocks
grant 400 turns of SPS haste and drop the correct hourglass sand bag or watch
spring. Ling Potion and Realgar Wine retain their original effects and values.

`BerryRegeneration` again exposes the old readable level and reads the legacy
`regenleft` save field while writing both old and new fields. Simplified Chinese
and English medicine names, descriptions, and recipes have been restored from
0.9.8; the available original Traditional Chinese and Russian entries are also
present, and all 207 property files pass strict UTF-8 validation. Nine original
medicine icons occupy a new 16-pixel atlas row. The runtime texture-film height
and all static checks now use 992 pixels instead of the stale 976-pixel value,
and each 16 by 16 icon is protected by an ARGB SHA-256 check.

`verifySpsMedicineEffects`, `verifySpsAlchemy`, `verifySpsSkinOneInteractions`,
`verifySpsSkinTwoWarrior`, `verifySpsRobotDmt`, and `verifySpsContent` pass after
this audit. This is still an incremental behavior-audit milestone and is not a
100% completion claim.

The special-route persistence audit now covers Bone, Conch Shell, Ancient
Coin, Boss Rush, Pot Key, Triforce, Treasure Map, Adventure Journal, Challenge
Journal, and Elevator transitions. The six return-point item families read the
original `depth` and `pos` fields, prefer the newer branch-aware fields when
both exist, and write both formats. This keeps SPS-PD 0.9.8 saves readable
without losing branch-aware SPS-SPD return data. Special transitions capture
an active legacy pet before validating or starting the transition, preserving
its type, current health, and reward cooldown in the Soul Lamp as the source
flow requires.

Ordinary stairs, falls, returns, resurrection, and level resets intentionally
do not capture the pet. `LegacyPet` is a directable ally, so Shattered's
existing hold/restore path carries the same live instance to an adjacent cell
on the destination floor and clears only its obsolete defend position. A new
headless transition case verifies a pet even when it starts far from the hero,
including identity, health, reward cooldown, placement, and command cleanup.
`verifySpsBossKeys`, `verifySpsPocketBallFull`, and the affected route gates
pass. This remains an incremental behavior-audit milestone, not a 100%
completion claim.

The legacy bag and combat-buff persistence pass fixes several runtime gaps.
`WandHolster` now starts the charge loop for contained wands when collected and
stops it when detached, without importing Shattered's faster holster charging
or thrown-weapon behavior. `GrowSeed` is again a turn-by-turn parasite rather
than a one-shot flavour buff: every tick damages its host, heals adjacent
characters, decrements its own duration, and reads the original `left` field.
`EnergyArmor` reads legacy `level` shielding, while `ArmorBreak`, `AttackDown`,
`AttackUp`, and `DefenceUp` read and dual-write the original `left` duration.
Focused bag, medicine, rock-code, consumable-buff, class-skill, ammunition,
enchantment, and sewer-boss gates pass.

The three large Sokoban maps now have dynamic parity coverage in addition to
cell-for-cell layout checks. Blocked ordinary and diagonal pushes consume the
source turn; black sheep no longer activate the unsupported change-sheep trap;
and their fleecing-trap search retains the source's asymmetric five-cell edge
rule. Portal switches update their assigned destination immediately, used
switches become empty, ordinary sheep transform correctly, reset removes the
first-visit bonus pool, and current state survives a save/load cycle. The
current fields take priority, while the original `heapstogen`, `heapgenspots`,
`teleportspots`, `portswitchspots`, `destinationspots`, `teleportassign`,
`destinationassign`, and `prizeNo` fields are readable and dual-written.

The fixed-route reward audit also closes three progression bugs. Dragon Cave
now follows the source `first` split: the first visit has the shadow-dragon egg,
400-799 gold, and upgrade-scroll chance, while completed revisits have no egg
or scroll and only 1-99 gold. Defeating the Spring Festival year beast now
completes journal destination 6 and still drops the guaranteed Year Pet egg.
`AlienBag` reads the original camel-case `partialCharge`, dual-writes it with
the current lower-case field, and prefers current data when both exist.
`verifySpsFixedLevels`, `verifySpsSkinOneInteractions`, the affected start-tool
gates, and strict UTF-8 content validation pass. This remains an incremental
behavior-audit milestone and is not a 100% completion claim.

The full release gate also exposed two stale test assumptions after the item
atlas grew to 256 by 992 pixels. All affected sprite tests now validate the
actual atlas height while retaining their per-cell pixel hashes. The chapter
shop still adds the source's fixed stack of five Magic Hands, but its random
ranged-weapon slot can independently select another stack because Magic Hand
is part of the original seven-entry ranged pool. The focused assertion now
requires at least five instead of incorrectly requiring the total to equal
five; the game generation code remains unchanged.

After these gate-only corrections, `verifySpsRelease` passes completely with
137 actionable tasks: 131 executed and 6 up-to-date. The run includes strict
UTF-8 validation, the 2,000-map regular-level sweep, the fixed and transition
level suites, gameplay systems, save migration, resources, and original sprite
hashes. This is a verified audit baseline, not a 100% completion claim.

The first Sokoban tutorial map now has the same old-save bridge as the three
large puzzles. It dual-writes and restores the original `heapstogen`,
`heapgenspots`, `teleportspots`, `portswitchspots`, `destinationspots`,
`teleportassign`, `destinationassign`, and `prizeNo` fields. Current scalar
fields take priority, old padded arrays are accepted, and remaining key/towel
state is exported for 0.9.8 readers.

The Spring Festival shops again follow the source lifecycle. They are empty
while the level is being built, roll their jewelry and supply stock on the
first occupied cell, and after a load refill only a sold-out stock cell. The
trigger flag intentionally remains transient as it was in 0.9.8. Legacy
`mineDepth`, `storespots`, and `bombpots` are preserved, with invalid or absent
spot arrays safely falling back to the two canonical cells. Focused fixed-level
coverage includes delayed stock, sold-slot reload replenishment, legacy fields,
and the existing Year Beast completion flow.

Boss Rush restoration now accepts 0.9.8 level saves that contain only the old
unused `stairs` field. When `arena_exit` is absent or invalid, the real locked
or unlocked exit is recovered from the saved terrain instead of defaulting to
cell zero. When `boss_stage` is absent, the surviving Dragon King or ultimate
boss class recovers stages zero through eight. Completion also recognizes an
already unlocked exit or completed journal route, and the current save writes
`stairs` alongside `arena_exit`. A stage-three UDM300 legacy checkpoint is
covered by a full level bundle round trip.

Safe Level now preserves the source first-visit reward split. Its three layouts
still generate 25-49 gold on the initial visit, while a completed destination-0
journal makes later visits generate only 1-9 gold. The per-level first-visit
state is persisted in `first_visit`, so saving and loading cannot silently
change the reward tier. Fixed-level coverage exercises all three initial
layouts and eight deterministic revisit seeds.

The current tree passes the complete `verifySpsRelease` gate with 137
actionable tasks: 131 executed and 6 up-to-date. This run occurred after the
Safe Level correction and includes strict UTF-8 validation, 2,000 generated
ordinary maps, fixed and transition levels, gameplay behavior, save migration,
resources, and source-sprite hashes. It remains an audit baseline rather than a
100% completion claim.

The remaining meaningful legacy `first` branches in fixed levels have now been
audited. Room of Zot revisit coverage confirms that completed destination 20
produces only 1-9 gold and never repeats the Lucky Badge or upgrade scrolls.
Sokoban Castle had one real mismatch: completed revisits still used the
first-visit 400-799 gold range. They now use the source's 300-499 range and no
longer produce first-visit upgrade scrolls or bonus prizes; the initial visit
continues to use 400-799 gold. The Teleport and Puzzles Sokoban maps correctly
use 300-499 gold on both visits while limiting their bonus prize pools to the
first visit.

Boss Rush now has an end-to-end death-chain test rather than only sequence and
stat assertions. Dragon King and all eight ultimate bosses execute their real
`die()` paths in order, advance stages zero through nine, and finish with no
stage boss left, journal destination 21 completed, and the real arena exit
unlocked. The source's boss-defeated banner and sound now fire at every stage
handoff instead of only after the ninth boss. Headless/save-transition paths
safely skip the visual notification when no game scene exists. Completed saves
also retain stage nine rather than being incorrectly clamped back to stage
eight, and the complete state is covered by a full level-bundle round trip.

That execution exposed a shared drop-path crash: creating a new heap called
`ShatteredPixelDungeon.scene()` even when `Game.instance` did not exist. Heap
data is now still created during headless or transition-time deaths, while map
press handling remains limited to an active game scene. The focused fixed-level
gate passes with the complete nine-death chain.

After the completed-stage persistence correction, the complete serial
`verifySpsRelease` gate passes again with 137 actionable tasks: 131 executed and
6 up-to-date. The desktop and Android build passes with 52 actionable tasks: 9
executed and 43 up-to-date. The desktop ZIP is 86,863,770 bytes with SHA-256
`EAC8FC41E7FB19462BC4C50FE77A6010FE36F8E48EFC56B9B13BE2ACCCBAC5C3`.
The debug APK is 43,638,558 bytes with SHA-256
`A89E07B27413B454917BAC873966695FEFCA40DCDCAAEB8032D39B22E6631AEF`.

The APK was installed over `emulator-5554` without changing the existing
orphaned `game1/depth1.dat` file: its size remained 3,373 bytes and its Unix
timestamp remained 1,790,036,527. Process 7116 remained alive, the title and
eight-class selection screens rendered Simplified Chinese without replacement
characters, and logcat contained no fatal exception, ANR, native crash, null
pointer, or out-of-memory error. The emulator has no complete save metadata, so
no new run was created over that orphaned level file. Screenshots are stored at
`build/reports/sps-bossrush-final-smoke.png` and
`build/reports/sps-bossrush-saves.png`. This remains an audit milestone, not a
100% completion claim.

原野霸主路线现已从布局检查扩展为真实交互门禁。英雄踏入主战区会按 0.9.8 规则在外部战区随机生成
不可见的豺狼王，同时避免占用已有角色；75%、50%、25% 三次阶段切换不再错误额外吞掉一个首领回合。
豺狼王恢复暗属性附魔免疫及仪式面具特殊奖励接口，死亡金币由错误的 1000 至 1500 修正为源码的
1000 至 1499，并在无物品精灵时安全完成精金戒指、金币和豺狼人衣物掉落。异界日志入口的击杀现在既
完成目的地 14，也同步旧版全局击杀状态，藏宝图入口不会再把同一首领误判为未击杀。专项测试真实执行
踏入战区、三次阶段切换、缺失首领坏档恢复、死亡、掉落、日志奖励和解锁。

Zot 监牢也已补上真实战斗与存档覆盖。帕兰提尔读取并双写 0.9.8 的 `depth`、`pos` 返回点，当前字段
存在时仍优先；Zot 恢复暗属性与灵能震爆免疫、麻痹回合额外 5 点回复、自动药剂存在时每回合 1 点回复，
并补回英简繁俄四语 `pain` 台词。旧版监牢固定使用有效深度 99，而不是入口锚点 14；魔眼现按 99 层计算
生命、闪避和命中，施法耗时 2 回合、光束伤害 20 至 50，并移除从破碎 Evil Eye 误继承的额外生肉掉落；
Zot 虚像恢复 149 命中、最高 209 伤害及电击抗性。真实死亡测试确认虚像和魔眼全部清除、灵魂收集石
掉落、监牢解锁、缺失 Zot 坏档补回及完成态存档往返。

上述修正后的 `verifySpsRelease` 已完整通过，共 137 个可执行任务，其中 131 个执行、6 个命中缓存；
严格 UTF-8、中英文键一致性、2000 张普通地图、固定地图、玩法、存档迁移、资源与原始像素哈希均通过。
这仍是行为审计里程碑，不代表整个项目已经达到 100%。

## Functional completion baseline (2026-09-23)

The acceptance target is now functional SPS-PD 0.9.8 gameplay rather than
pixel-perfect or text-perfect reproduction. Under that target, the port is at a
release-candidate baseline: the main route, fixed and generated maps, reachable
side routes, eight legacy heroes, combat systems, equipment, pets, quests,
bosses, rewards, endings, and save migration all have automated coverage.
Shattered-only heroes and equipment remain in source but stay hidden from the
normal selection, generation, shop, and catalog flows.

The final depth audit kept physical depth for save addressing, keys, branch
return points, and level transitions, while legacy combat and restriction rules
continue to use effective SPS depth. It also fixed the Chaos and New Room signs,
which previously displayed an unrelated main-route tip based on their anchor
depth. Their dedicated messages and strict UTF-8 resources are restored in
English, Simplified Chinese, Traditional Chinese, and Russian.

The final `verifySpsRelease` run passed all 140 actionable tasks (134 executed,
6 up-to-date). Desktop and Android packaging passed all 52 tasks (13 executed,
39 up-to-date). The desktop ZIP is 86,877,816 bytes with SHA-256
`29F21145FD35D428B92A25129BF56122A3508B8FAF49F9AD5D55CE7119B205A5`.
The debug APK is 43,642,441 bytes with SHA-256
`00EBBDBCD3D5E1D8FF3CADEE9A47DB044597C2037621499F9248332028123FCC`.

The APK was installed over `emulator-5554`. Before and after installation,
`game1/depth1.dat` remained 3,373 bytes, Unix timestamp 1,790,036,527, and
SHA-256 `cbc2cbd73c88a10e2983a2e9055d1bca059dfab55618c4a1e61463e8c0cf3f18`.
The title and eight-hero selection screens render correctly in Simplified
Chinese, process 3141 remains alive, and the device log contains no fatal
exception, ANR, native crash, null pointer, or out-of-memory error. Final
screenshots are `build/reports/sps-final-smoke.png` and
`build/reports/sps-final-classes.png`.

Desktop OpenGL smoke coverage now also captures the title screen, a live
tutorial map, and the alchemy scene. All three rendered successfully and exited
cleanly. The smoke process explicitly uses UTF-8 for file, stdout, and stderr
encoding, so its Chinese tutorial log is no longer corrupted by the Windows
default console encoding. The requirement-by-requirement evidence is collected
in `docs/sps-completion-audit.md`.

After all source, build-script, and documentation changes, the combined final
run of `verifySpsRelease desktop:distZip android:assembleDebug` passed 187 tasks
(137 executed, 50 up-to-date). Artifact hashes, strict UTF-8 checks, the Android
save fingerprint, process health, and device error log were then rechecked and
remained clean.
