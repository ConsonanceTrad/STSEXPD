param(
    [string]$LegacyAtlas = (Join-Path $PSScriptRoot '..\..\SPS-PD-0.9.8\SPS-PD-0.9.8\assets\items.png'),
	[string]$ShatteredAtlas = (Join-Path $PSScriptRoot '..\..\shattered-pixel-dungeon-4.0.0\core\src\main\assets\sprites\items.png'),
    [string]$TargetAtlas = (Join-Path $PSScriptRoot '..\core\src\main\assets\sprites\items.png')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$LegacyAtlas = (Resolve-Path -LiteralPath $LegacyAtlas).Path
$ShatteredAtlas = (Resolve-Path -LiteralPath $ShatteredAtlas).Path
$TargetAtlas = (Resolve-Path -LiteralPath $TargetAtlas).Path
$targetDirectory = Split-Path -Parent $TargetAtlas
$temporaryAtlas = Join-Path $targetDirectory 'items.sps-atlas.tmp.png'

$source = [System.Drawing.Bitmap]::FromFile($LegacyAtlas)
$baseline = [System.Drawing.Bitmap]::FromFile($ShatteredAtlas)
$current = [System.Drawing.Bitmap]::FromFile($TargetAtlas)
$targetHeight = 992
$updated = New-Object System.Drawing.Bitmap 256, $targetHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($updated)
try {
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
	# Copy exact ARGB values. Drawing through GDI+ normalizes transparent pixels and
	# breaks the pixel-identical legacy sprite checks on every repeated run.
	for ($y = 0; $y -lt [Math]::Min($current.Height, $targetHeight); $y++) {
		for ($x = 0; $x -lt $current.Width; $x++) {
			$updated.SetPixel($x, $y, $current.GetPixel($x, $y))
		}
	}

	# Restore four Shattered wand slots that were briefly used by an earlier version of this script.
	foreach ($left in 16, 32, 48, 64) {
		for ($y = 208; $y -lt 224; $y++) {
			for ($x = $left; $x -lt $left + 16; $x++) {
				$updated.SetPixel($x, $y, $baseline.GetPixel($x, $y))
			}
		}
	}

    # Legacy atlas uses 20 columns. These SPS sprites are packed into row 34
    # of Shattered's 16-column atlas in the same order as ItemSpriteSheet.
    $copies = @(
        @{ SourceX = 176; SourceY = 480; TargetX = 0;  TargetY = 528 }, # BuildBomb
        @{ SourceX = 272; SourceY = 480; TargetX = 16; TargetY = 528 }, # HugeBomb
        @{ SourceX = 80;  SourceY = 96;  TargetX = 32; TargetY = 528 }, # SpAmmo
        @{ SourceX = 224; SourceY = 32;  TargetX = 48; TargetY = 528 }, # Elemental dust heap
        @{ SourceX = 240; SourceY = 32;  TargetX = 64; TargetY = 528 }, # Monster web heap
        @{ SourceX = 0;   SourceY = 64;  TargetX = 80; TargetY = 528 }  # Towel
		@{ SourceX = 192; SourceY = 32;  TargetX = 160; TargetY = 528 } # Palantir
		@{ SourceX = 288; SourceY = 368; TargetX = 176; TargetY = 528 } # DoorBlock
		@{ SourceX = 304; SourceY = 400; TargetX = 192; TargetY = 528 } # PlantPotBlock
		@{ SourceX = 192; SourceY = 48;  TargetX = 208; TargetY = 528 } # ShoppingCart
		@{ SourceX = 208; SourceY = 32;  TargetX = 224; TargetY = 528 } # OrbOfZot
		@{ SourceX = 64;  SourceY = 80;  TargetX = 192; TargetY = 576 } # SoulCollect / PocketBallFull
		@{ SourceX = 240; SourceY = 448; TargetX = 64;  TargetY = 608 } # RustybladeCat
		@{ SourceX = 304; SourceY = 240; TargetX = 112; TargetY = 576 } # ShitBall
		@{ SourceX = 256; SourceY = 32;  TargetX = 128; TargetY = 576 } # SaveYourLife
		@{ SourceX = 48;  SourceY = 224; TargetX = 144; TargetY = 576 } # SJRBMusic
		@{ SourceX = 96;  SourceY = 208; TargetX = 160; TargetY = 576 } # Spork
		@{ SourceX = 64;  SourceY = 432; TargetX = 64;  TargetY = 736 } # Porksoup
		@{ SourceX = 80;  SourceY = 432; TargetX = 80;  TargetY = 736 } # Meatroll
		@{ SourceX = 96;  SourceY = 432; TargetX = 96;  TargetY = 736 } # Vegetablekebab
		@{ SourceX = 0;   SourceY = 448; TargetX = 112; TargetY = 736 } # NutCookie
		@{ SourceX = 16;  SourceY = 448; TargetX = 128; TargetY = 736 } # MixPizza
		@{ SourceX = 32;  SourceY = 448; TargetX = 144; TargetY = 736 } # RiceGruel
		@{ SourceX = 48;  SourceY = 448; TargetX = 160; TargetY = 736 } # FruitCandy
		@{ SourceX = 64;  SourceY = 448; TargetX = 176; TargetY = 736 } # MoonCake
		@{ SourceX = 32;  SourceY = 352; TargetX = 192; TargetY = 736 } # BlindFruit
		@{ SourceX = 240; SourceY = 224; TargetX = 208; TargetY = 736 } # EmpBola
		@{ SourceX = 32;  SourceY = 96;  TargetX = 128; TargetY = 128 } # Shovel
		@{ SourceX = 48;  SourceY = 96;  TargetX = 144; TargetY = 128 } # GunOfSoldier
		@{ SourceX = 32;  SourceY = 128; TargetX = 160; TargetY = 128 } # SoldierAmmo
		@{ SourceX = 192; SourceY = 464; TargetX = 176; TargetY = 128 } # FireBomb
		@{ SourceX = 208; SourceY = 464; TargetX = 192; TargetY = 128 } # IceBomb
		@{ SourceX = 256; SourceY = 464; TargetX = 208; TargetY = 128 } # StormBomb
		@{ SourceX = 16;  SourceY = 128; TargetX = 0;   TargetY = 624 } # GunAmmo
		@{ SourceX = 144; SourceY = 176; TargetX = 16;  TargetY = 624 } # Sling
		@{ SourceX = 240; SourceY = 176; TargetX = 32;  TargetY = 624 } # GunA
		@{ SourceX = 256; SourceY = 176; TargetX = 48;  TargetY = 624 } # GunB
		@{ SourceX = 272; SourceY = 176; TargetX = 64;  TargetY = 624 } # GunC
		@{ SourceX = 288; SourceY = 176; TargetX = 80;  TargetY = 624 } # GunD
		@{ SourceX = 304; SourceY = 176; TargetX = 96;  TargetY = 624 } # GunE
		@{ SourceX = 288; SourceY = 240; TargetX = 112; TargetY = 624 } # ToyGun
		@{ SourceX = 144; SourceY = 128; TargetX = 128; TargetY = 624 } # LegacyArrow
		@{ SourceX = 240; SourceY = 208; TargetX = 144; TargetY = 624 } # WoodenBow
		@{ SourceX = 256; SourceY = 208; TargetX = 160; TargetY = 624 } # StoneBow
		@{ SourceX = 272; SourceY = 208; TargetX = 176; TargetY = 624 } # MetalBow
		@{ SourceX = 288; SourceY = 208; TargetX = 192; TargetY = 624 } # AlloyBow
		@{ SourceX = 304; SourceY = 208; TargetX = 208; TargetY = 624 } # PVCBow
		@{ SourceX = 144; SourceY = 96;  TargetX = 224; TargetY = 624 } # ManyKnive
		@{ SourceX = 176; SourceY = 224; TargetX = 240; TargetY = 624 } # ThrowingKnife
		@{ SourceX = 0;   SourceY = 256; TargetX = 0;   TargetY = 672; Width = 240 } # Legacy wand row (15 slots)
		@{ SourceX = 0;   SourceY = 128; TargetX = 0;   TargetY = 672 } # WandOfMagicMissile
		@{ SourceX = 48;  SourceY = 128; TargetX = 48;  TargetY = 672 } # WandOfFlow
		@{ SourceX = 160; SourceY = 80;  TargetX = 80;  TargetY = 672 } # WandOfDisintegration
		@{ SourceX = 160; SourceY = 80;  TargetX = 112; TargetY = 672 } # WandOfBlood
		@{ SourceX = 144; SourceY = 128; TargetX = 144; TargetY = 672 } # WandOfLightning
		@{ SourceX = 208; SourceY = 128; TargetX = 208; TargetY = 672 } # WandOfTCloud
		@{ SourceX = 240; SourceY = 128; TargetX = 224; TargetY = 672 } # WandOfError
		@{ SourceX = 64;  SourceY = 96;  TargetX = 0;   TargetY = 192 } # FaithSign
		@{ SourceX = 80;  SourceY = 96;  TargetX = 16;  TargetY = 192 } # BigBattery
		@{ SourceX = 160; SourceY = 192; TargetX = 32;  TargetY = 192 } # WoodenStaff
		@{ SourceX = 240; SourceY = 192; TargetX = 48;  TargetY = 192 } # TrickSand
		@{ SourceX = 80;  SourceY = 48;  TargetX = 64;  TargetY = 192 } # AttackShoes
		@{ SourceX = 96;  SourceY = 96;  TargetX = 80;  TargetY = 192 } # AttackShield
		@{ SourceX = 112; SourceY = 96;  TargetX = 96;  TargetY = 192 } # CannonOfMage
		@{ SourceX = 128; SourceY = 96;  TargetX = 112; TargetY = 192 } # LinkSword
		@{ SourceX = 160; SourceY = 96;  TargetX = 128; TargetY = 192 } # BShovel
		@{ SourceX = 176; SourceY = 96;  TargetX = 144; TargetY = 192 } # MKbox
		@{ SourceX = 208; SourceY = 96;  TargetX = 160; TargetY = 192 } # DiamondPickaxe
		@{ SourceX = 224; SourceY = 96;  TargetX = 176; TargetY = 192 } # HolyMace
		@{ SourceX = 144; SourceY = 80;  TargetX = 192; TargetY = 192 } # BraveBook
		@{ SourceX = 16;  SourceY = 32;  TargetX = 208; TargetY = 192 } # PixelTorch
		@{ SourceX = 64;  SourceY = 288; TargetX = 224; TargetY = 192 } # TimeOclock
		@{ SourceX = 176; SourceY = 288; TargetX = 240; TargetY = 192 } # AlienBag
		@{ SourceX = 160; SourceY = 224; TargetX = 0;  TargetY = 752 } # Wave
		@{ SourceX = 256; SourceY = 224; TargetX = 16; TargetY = 752 } # Skull
		@{ SourceX = 224; SourceY = 464; TargetX = 32; TargetY = 752 } # EarthBomb
		@{ SourceX = 240; SourceY = 464; TargetX = 48; TargetY = 752 } # DarkBomb
		@{ SourceX = 32;  SourceY = 432; TargetX = 64;  TargetY = 752 } # Chickennugget
		@{ SourceX = 112; SourceY = 464; TargetX = 80;  TargetY = 752 } # Foamedbeverage
		@{ SourceX = 192; SourceY = 432; TargetX = 96;  TargetY = 752 } # Fruitsalad
		@{ SourceX = 0;   SourceY = 432; TargetX = 112; TargetY = 752 } # Hamburger
		@{ SourceX = 128; SourceY = 432; TargetX = 128; TargetY = 752 } # Herbmeat
		@{ SourceX = 48;  SourceY = 432; TargetX = 144; TargetY = 752 } # Honeymeat
		@{ SourceX = 80;  SourceY = 448; TargetX = 160; TargetY = 752 } # Honeyrice
		@{ SourceX = 144; SourceY = 432; TargetX = 176; TargetY = 752 } # Icecream
		@{ SourceX = 240; SourceY = 432; TargetX = 192; TargetY = 752 } # PerfectFood
		@{ SourceX = 176; SourceY = 432; TargetX = 208; TargetY = 752 } # Ricefood
		@{ SourceX = 160; SourceY = 432; TargetX = 224; TargetY = 752 } # Vegetablesoup
		@{ SourceX = 0;   SourceY = 64;  TargetX = 240; TargetY = 752 } # HoneyGel
		@{ SourceX = 32;  SourceY = 64;  TargetX = 0;   TargetY = 768 } # Gel
		@{ SourceX = 128; SourceY = 448; TargetX = 16;  TargetY = 768 } # HoneyWater
		@{ SourceX = 272; SourceY = 432; TargetX = 32;  TargetY = 768 } # Chocolate
		@{ SourceX = 288; SourceY = 432; TargetX = 48;  TargetY = 768 } # FoodFans
		@{ SourceX = 256; SourceY = 432; TargetX = 64;  TargetY = 768 } # Frenchfries
		@{ SourceX = 0;   SourceY = 80;  TargetX = 80;  TargetY = 768 } # StrBottle
		@{ SourceX = 256; SourceY = 96;  TargetX = 96;  TargetY = 768 } # DemoScroll
		@{ SourceX = 224; SourceY = 128; TargetX = 112; TargetY = 768 } # BaseArmor
		@{ SourceX = 272; SourceY = 96;  TargetX = 128; TargetY = 768 } # GnollMark
		@{ SourceX = 288; SourceY = 96;  TargetX = 144; TargetY = 768 } # UndeadBook
		@{ SourceX = 304; SourceY = 96;  TargetX = 160; TargetY = 768 } # TaurcenBow
		@{ SourceX = 192; SourceY = 192; TargetX = 176; TargetY = 768 } # HolyWater
		@{ SourceX = 16;  SourceY = 112; TargetX = 192; TargetY = 768 } # MechPocket
		@{ SourceX = 48;  SourceY = 128; TargetX = 208; TargetY = 768 } # GrassBook
		@{ SourceX = 112; SourceY = 192; TargetX = 224; TargetY = 768 } # LifeArmor
		@{ SourceX = 144; SourceY = 112; TargetX = 0;   TargetY = 784 } # HealBag
		@{ SourceX = 160; SourceY = 112; TargetX = 16;  TargetY = 784 } # RangeBag
		@{ SourceX = 176; SourceY = 112; TargetX = 32;  TargetY = 784 } # DanceLion
		@{ SourceX = 48;  SourceY = 240; TargetX = 48;  TargetY = 784 } # Whisk
		@{ SourceX = 256; SourceY = 304; TargetX = 64;  TargetY = 784 } # SavageHelmet
		@{ SourceX = 288; SourceY = 304; TargetX = 80;  TargetY = 784 } # HorseTotem
		@{ SourceX = 272; SourceY = 128; TargetX = 0;   TargetY = 800 } # TestWeapon
		@{ SourceX = 288; SourceY = 128; TargetX = 16;  TargetY = 800 } # TestArmor
		@{ SourceX = 304; SourceY = 128; TargetX = 32;  TargetY = 800 } # WandOfTest
		@{ SourceX = 304; SourceY = 112; TargetX = 48;  TargetY = 800 } # RewardPaper
		@{ SourceX = 80;  SourceY = 112; TargetX = 64;  TargetY = 800 } # ElfBow
		@{ SourceX = 96;  SourceY = 112; TargetX = 80;  TargetY = 800 } # DemonBlade
		@{ SourceX = 240; SourceY = 112; TargetX = 96;  TargetY = 800 } # NeedPaper
		@{ SourceX = 128; SourceY = 128; TargetX = 112; TargetY = 800 } # PPC
		@{ SourceX = 144; SourceY = 128; TargetX = 128; TargetY = 800 } # MindArrow
		@{ SourceX = 176; SourceY = 128; TargetX = 144; TargetY = 800 } # LeaderFlag
		@{ SourceX = 144; SourceY = 112; TargetX = 160; TargetY = 800 } # NmHealBag
		@{ SourceX = 112; SourceY = 112; TargetX = 176; TargetY = 800 } # DiceTower
		@{ SourceX = 288; SourceY = 400; TargetX = 192; TargetY = 800 } # WaterBlock
		@{ SourceX = 48;  SourceY = 544; TargetX = 208; TargetY = 800 } # BottleFire
		@{ SourceX = 0;   SourceY = 544; TargetX = 224; TargetY = 800 } # HoneyArrow
		@{ SourceX = 16;  SourceY = 512; TargetX = 240; TargetY = 800 } # LynnDoll
		@{ SourceX = 224; SourceY = 112; TargetX = 0;  TargetY = 816 } # SeriousPunch
		@{ SourceX = 96;  SourceY = 48;  TargetX = 16; TargetY = 816 } # Ankhshield
		@{ SourceX = 256; SourceY = 112; TargetX = 32; TargetY = 816 } # PPC2
		@{ SourceX = 256; SourceY = 240; TargetX = 48; TargetY = 816 } # EleKatana
		@{ SourceX = 272; SourceY = 240; TargetX = 64; TargetY = 816 } # ShootGun
		@{ SourceX = 240; SourceY = 32;  TargetX = 80; TargetY = 816 } # Weightstone
		@{ SourceX = 32;  SourceY = 128; TargetX = 96; TargetY = 816 } # ShootAmmo
		@{ SourceX = 48;  SourceY = 128; TargetX = 112; TargetY = 816 } # ShootEndAmmo
		@{ SourceX = 304; SourceY = 0;   TargetX = 128; TargetY = 816 } # ChangeEquip
		@{ SourceX = 64;  SourceY = 496; TargetX = 144; TargetY = 816 } # FishBone
		@{ SourceX = 0;   SourceY = 512; TargetX = 160; TargetY = 816 } # GhostGirlRose
		@{ SourceX = 48;  SourceY = 496; TargetX = 176; TargetY = 816 } # RainShield
		@{ SourceX = 16;  SourceY = 496; TargetX = 192; TargetY = 816 } # CursePhone
		@{ SourceX = 16;  SourceY = 528; TargetX = 208; TargetY = 816 } # AFlySock
		@{ SourceX = 176; SourceY = 432; TargetX = 224; TargetY = 816 } # MeleePan and RangePan
		@{ SourceX = 144; SourceY = 528; TargetX = 240; TargetY = 816 } # XiXiBox
		@{ SourceX = 0;   SourceY = 128; TargetX = 0;   TargetY = 832 } # MegaCannon
		@{ SourceX = 16;  SourceY = 128; TargetX = 16;  TargetY = 832 } # MegaAmmoSmall
		@{ SourceX = 32;  SourceY = 128; TargetX = 32;  TargetY = 832 } # MegaAmmoMedium
		@{ SourceX = 48;  SourceY = 128; TargetX = 48;  TargetY = 832 } # MegaAmmoLarge
		@{ SourceX = 80;  SourceY = 48;  TargetX = 64;  TargetY = 832 } # RockManJumpshoes
		@{ SourceX = 32;  SourceY = 480; TargetX = 80;  TargetY = 832 } # RenBArmor
		@{ SourceX = 48;  SourceY = 480; TargetX = 96;  TargetY = 832 } # BunnyDagger
		@{ SourceX = 32;  SourceY = 240; TargetX = 112; TargetY = 832 } # NinjaFan
		@{ SourceX = 160; SourceY = 480; TargetX = 128; TargetY = 832 } # MiniBomb
		@{ SourceX = 208; SourceY = 400; TargetX = 144; TargetY = 832 } # FishPetFood
		@{ SourceX = 224; SourceY = 400; TargetX = 160; TargetY = 832 } # FishCracker
		@{ SourceX = 272; SourceY = 400; TargetX = 176; TargetY = 832 } # Honey
		@{ SourceX = 304; SourceY = 432; TargetX = 192; TargetY = 832 } # ZongZi
		@{ SourceX = 96;  SourceY = 448; TargetX = 208; TargetY = 832 } # NutCake
		@{ SourceX = 144; SourceY = 448; TargetX = 224; TargetY = 832 } # YearFood
		@{ SourceX = 80;  SourceY = 80;  TargetX = 240; TargetY = 832 } # DolyaSlate
		@{ SourceX = 176; SourceY = 80;  TargetX = 0;   TargetY = 656 } # ChallengeBook
		@{ SourceX = 16;  SourceY = 240; TargetX = 208; TargetY = 944 } # GoblinShield
		@{ SourceX = 160; SourceY = 240; TargetX = 224; TargetY = 944 } # SpKnuckles
		@{ SourceX = 80;  SourceY = 400; TargetX = 0;   TargetY = 848 } # Pasty
		@{ SourceX = 176; SourceY = 400; TargetX = 16;  TargetY = 848 } # Spring assorted
		@{ SourceX = 48;  SourceY = 400; TargetX = 32;  TargetY = 848 } # Knowledge food
		@{ SourceX = 128; SourceY = 400; TargetX = 48;  TargetY = 848 } # Easter egg
		@{ SourceX = 96;  SourceY = 400; TargetX = 64;  TargetY = 848 } # Pumpkin pie
		@{ SourceX = 112; SourceY = 400; TargetX = 80;  TargetY = 848 } # Turkey meat
		@{ SourceX = 144; SourceY = 400; TargetX = 96;  TargetY = 848 } # Candy cane
		@{ SourceX = 112; SourceY = 208; TargetX = 112; TargetY = 848 } # Brick food
		@{ SourceX = 64;  SourceY = 400; TargetX = 128; TargetY = 848 } # Jelly sword
		@{ SourceX = 160; SourceY = 448; TargetX = 144; TargetY = 848 } # Garbage
		@{ SourceX = 0; SourceY = 352; TargetX = 0; TargetY = 864; Width = 256 } # Legacy seeds 0-15
		@{ SourceX = 256; SourceY = 352; TargetX = 0; TargetY = 880; Width = 32 } # Legacy seeds 16-17
		@{ SourceX = 208; SourceY = 128; TargetX = 32; TargetY = 880 } # ErrorW
		@{ SourceX = 224; SourceY = 128; TargetX = 48; TargetY = 880 } # ErrorArmor
		@{ SourceX = 256; SourceY = 128; TargetX = 64; TargetY = 880 } # ErrorAmmo
		@{ SourceX = 112; SourceY = 288; TargetX = 80; TargetY = 880 } # RobotDMT
		@{ SourceX = 96; SourceY = 528; TargetX = 96; TargetY = 880 } # TestCloak
		@{ SourceX = 0;   SourceY = 496; TargetX = 112; TargetY = 880 } # Apk931
		@{ SourceX = 0;   SourceY = 528; TargetX = 128; TargetY = 880 } # BottleFlower
		@{ SourceX = 128; SourceY = 544; TargetX = 144; TargetY = 880 } # BrokenHammer
		@{ SourceX = 112; SourceY = 528; TargetX = 160; TargetY = 880 } # CrossPhoto
		@{ SourceX = 112; SourceY = 224; TargetX = 176; TargetY = 880 } # DwarfHammer
		@{ SourceX = 112; SourceY = 544; TargetX = 192; TargetY = 880 } # HummingTool
		@{ SourceX = 96;  SourceY = 544; TargetX = 208; TargetY = 880 } # Mirror2
		@{ SourceX = 80;  SourceY = 528; TargetX = 224; TargetY = 880 } # NouthSouth
		@{ SourceX = 80;  SourceY = 544; TargetX = 240; TargetY = 880 } # SellPermit
		@{ SourceX = 32;  SourceY = 496; TargetX = 160; TargetY = 848 } # SheepFur
		@{ SourceX = 128; SourceY = 528; TargetX = 176; TargetY = 848 } # Simple360
		@{ SourceX = 32;  SourceY = 544; TargetX = 192; TargetY = 848 } # Tissue
		@{ SourceX = 64;  SourceY = 544; TargetX = 208; TargetY = 848 } # UncleDumbbell
		@{ SourceX = 16;  SourceY = 544; TargetX = 224; TargetY = 848 } # ApostleBox
		@{ SourceX = 240; SourceY = 256; TargetX = 240; TargetY = 848 } # MoneyBook
		@{ SourceX = 16;  SourceY = 320; TargetX = 0;  TargetY = 896 } # CocoCatEgg
		@{ SourceX = 176; SourceY = 320; TargetX = 16; TargetY = 896 } # VelociroosterEgg
		@{ SourceX = 304; SourceY = 320; TargetX = 32; TargetY = 896 } # HaroEgg
		@{ SourceX = 160; SourceY = 336; TargetX = 48; TargetY = 896 } # PigpetEgg
		@{ SourceX = 160; SourceY = 320; TargetX = 64; TargetY = 896 } # EasterEgg and MiniBunny
		@{ SourceX = 80;  SourceY = 496; TargetX = 80; TargetY = 896 } # LingHeart
		@{ SourceX = 176; SourceY = 240; TargetX = 96; TargetY = 896 } # Pumpkin
		@{ SourceX = 240; SourceY = 320; TargetX = 112; TargetY = 896 } # ButterflypetEgg
		@{ SourceX = 0;   SourceY = 464; TargetX = 0;   TargetY = 976 } # JackOLantern
		@{ SourceX = 16;  SourceY = 464; TargetX = 16;  TargetY = 976 } # Earthstar
		@{ SourceX = 32;  SourceY = 464; TargetX = 32;  TargetY = 976 } # GreenSpore
		@{ SourceX = 48;  SourceY = 464; TargetX = 48;  TargetY = 976 } # DeathCap
		@{ SourceX = 64;  SourceY = 464; TargetX = 64;  TargetY = 976 } # PixieParasol
		@{ SourceX = 80;  SourceY = 464; TargetX = 80;  TargetY = 976 } # GoldenJelly
		@{ SourceX = 96;  SourceY = 464; TargetX = 96;  TargetY = 976 } # BlueMilk
		@{ SourceX = 128; SourceY = 464; TargetX = 112; TargetY = 976 } # GreatPill
		@{ SourceX = 144; SourceY = 464; TargetX = 128; TargetY = 976 } # RealgarWine
		@{ SourceX = 256; SourceY = 320; TargetX = 128; TargetY = 896 } # ChocoboEgg
		@{ SourceX = 0;   SourceY = 336; TargetX = 144; TargetY = 896 } # DaturaEgg
		@{ SourceX = 16;  SourceY = 336; TargetX = 160; TargetY = 896 } # DogpetEgg
		@{ SourceX = 32;  SourceY = 336; TargetX = 176; TargetY = 896 } # DwarfBoyEgg
		@{ SourceX = 48;  SourceY = 336; TargetX = 192; TargetY = 896 } # FlyEgg
		@{ SourceX = 64;  SourceY = 336; TargetX = 208; TargetY = 896 } # FoxHelperEgg
		@{ SourceX = 80;  SourceY = 336; TargetX = 224; TargetY = 896 } # FrogpetEgg
		@{ SourceX = 96;  SourceY = 336; TargetX = 240; TargetY = 896 } # GentleCrabEgg
		@{ SourceX = 112; SourceY = 336; TargetX = 0;   TargetY = 912 } # KodoraEgg
		@{ SourceX = 128; SourceY = 336; TargetX = 16;  TargetY = 912 } # LitDemonEgg
		@{ SourceX = 144; SourceY = 336; TargetX = 32;  TargetY = 912 } # MonkeyEgg
		@{ SourceX = 176; SourceY = 336; TargetX = 48;  TargetY = 912 } # RibbonRatEgg
		@{ SourceX = 192; SourceY = 336; TargetX = 64;  TargetY = 912 } # SnakeEgg
		@{ SourceX = 208; SourceY = 336; TargetX = 80;  TargetY = 912 } # SpiderpetEgg
		@{ SourceX = 224; SourceY = 336; TargetX = 96;  TargetY = 912 } # StarKidEgg
		@{ SourceX = 240; SourceY = 336; TargetX = 112; TargetY = 912 } # StoneEgg
		@{ SourceX = 96;  SourceY = 320; TargetX = 128; TargetY = 912 } # BlueDragonEgg
		@{ SourceX = 48;  SourceY = 320; TargetX = 144; TargetY = 912 } # BlueGirlEgg
		@{ SourceX = 192; SourceY = 320; TargetX = 160; TargetY = 912 } # BugDragonEgg
		@{ SourceX = 224; SourceY = 320; TargetX = 176; TargetY = 912 } # GoldDragonEgg
		@{ SourceX = 128; SourceY = 320; TargetX = 192; TargetY = 912 } # GreenDragonEgg
		@{ SourceX = 64;  SourceY = 320; TargetX = 208; TargetY = 912 } # LeryFireEgg
		@{ SourceX = 208; SourceY = 320; TargetX = 224; TargetY = 912 } # LightDragonEgg
		@{ SourceX = 80;  SourceY = 320; TargetX = 240; TargetY = 912 } # RedDragonEgg
		@{ SourceX = 32;  SourceY = 320; TargetX = 0;   TargetY = 928 } # ScorpionEgg
		@{ SourceX = 112; SourceY = 320; TargetX = 16;  TargetY = 928 } # VioletDragonEgg
		@{ SourceX = 304; SourceY = 336; TargetX = 32;  TargetY = 928 } # VIPcard
		@{ SourceX = 16;  SourceY = 224; TargetX = 208; TargetY = 928 } # HookHam
		@{ SourceX = 32;  SourceY = 224; TargetX = 224; TargetY = 928 } # Lollipop
		@{ SourceX = 96;  SourceY = 224; TargetX = 240; TargetY = 928 } # Tree
		@{ SourceX = 64;  SourceY = 240; TargetX = 0;   TargetY = 944 } # PaperFan
		@{ SourceX = 144; SourceY = 192; TargetX = 16;  TargetY = 944 } # MiniMoai
		@{ SourceX = 224; SourceY = 240; TargetX = 32;  TargetY = 944 } # DragonBoat
		@{ SourceX = 144; SourceY = 208; TargetX = 48;  TargetY = 944 } # Goei
		@{ SourceX = 0;   SourceY = 224; TargetX = 64;  TargetY = 944 } # TekkoKagi
		@{ SourceX = 160; SourceY = 224; TargetX = 80;  TargetY = 944 } # WraithBreath
		@{ SourceX = 224; SourceY = 192; TargetX = 96;  TargetY = 944 } # StoneCross
		@{ SourceX = 256; SourceY = 192; TargetX = 112; TargetY = 944 } # MirrorDoll
		@{ SourceX = 288; SourceY = 192; TargetX = 128; TargetY = 944 } # HandLight
		@{ SourceX = 304; SourceY = 192; TargetX = 144; TargetY = 944 } # CurseBox
		@{ SourceX = 176; SourceY = 208; TargetX = 160; TargetY = 944 } # SmallChakram
		@{ SourceX = 208; SourceY = 208; TargetX = 176; TargetY = 944 } # HugeShuriken
		@{ SourceX = 224; SourceY = 208; TargetX = 192; TargetY = 944 } # Tamahawk
		@{ SourceX = 192; SourceY = 80;  TargetX = 240; TargetY = 944 } # Flag
		@{ SourceX = 288; SourceY = 320; TargetX = 0;   TargetY = 960 } # TenguKey
		@{ SourceX = 128; SourceY = 208; TargetX = 16;  TargetY = 960 } # MagicHand
		@{ SourceX = 176; SourceY = 64;  TargetX = 32;  TargetY = 960 } # RiceBall
		@{ SourceX = 96;  SourceY = 496; TargetX = 48;  TargetY = 960 } # LingPotion
		@{ SourceX = 144; SourceY = 224; TargetX = 64;  TargetY = 960 } # RunicBlade
		@{ SourceX = 128; SourceY = 288; TargetX = 80;  TargetY = 960 } # EyeOfSkadi
		@{ SourceX = 304; SourceY = 288; TargetX = 96;  TargetY = 960 } # NoomlinCrown
    )
    foreach ($copy in $copies) {
		$width = if ($copy.ContainsKey('Width')) { $copy.Width } else { 16 }
		for ($y = 0; $y -lt 16; $y++) {
			for ($x = 0; $x -lt $width; $x++) {
                $updated.SetPixel($copy.TargetX + $x, $copy.TargetY + $y,
                    $source.GetPixel($copy.SourceX + $x, $copy.SourceY + $y))
            }
        }
    }

	$armorSources = @(
		@(0,144), @(0,176), @(0,160), @(16,144), @(16,176), @(16,160),
		@(32,144), @(32,176), @(32,160), @(48,144), @(48,176), @(48,160),
		@(64,144), @(64,176), @(64,160), @(80,144), @(80,176), @(80,160),
		@(96,144), @(112,144), @(128,144), @(144,144),
		@(96,160), @(112,160), @(128,160), @(144,160)
	)
	for ($slot = 0; $slot -lt $armorSources.Count; $slot++) {
		for ($y = 0; $y -lt 16; $y++) {
			for ($x = 0; $x -lt 16; $x++) {
				$updated.SetPixel(($slot % 16) * 16 + $x, 688 + [Math]::Floor($slot / 16) * 16 + $y,
					$source.GetPixel($armorSources[$slot][0] + $x, $armorSources[$slot][1] + $y))
			}
		}
	}

	$meleeSources = @(
		@(160,160), @(240,160), @(160,144), @(240,144),
		@(176,144), @(256,160), @(176,160), @(256,144),
		@(272,144), @(192,144), @(272,160), @(192,160),
		@(208,160), @(208,144), @(288,160), @(288,144),
		@(224,144), @(304,160), @(304,144), @(224,160)
	)
	for ($slot = 0; $slot -lt $meleeSources.Count; $slot++) {
		for ($y = 0; $y -lt 16; $y++) {
			for ($x = 0; $x -lt 16; $x++) {
				$updated.SetPixel(($slot % 16) * 16 + $x, 720 + [Math]::Floor($slot / 16) * 16 + $y,
					$source.GetPixel($meleeSources[$slot][0] + $x, $meleeSources[$slot][1] + $y))
			}
		}
	}
} finally {
    $graphics.Dispose()
	$current.Dispose()
	$baseline.Dispose()
	$source.Dispose()
}

try {
    $updated.Save($temporaryAtlas, [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $updated.Dispose()
}
Move-Item -LiteralPath $temporaryAtlas -Destination $TargetAtlas -Force
