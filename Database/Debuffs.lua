-- ZenPlates: Debuff Duration Database
-- Built-in database of common debuff durations for WoW 3.3.5a
-- Note: Durations may not be 100% accurate for all ranks/talents

local _, ZenPlates = ...
ZenPlates.DebuffDB = {}

local DB = ZenPlates.DebuffDB

-- Death Knight
DB["Chains of Ice"] = 8
DB["Frost Fever"] = 21
DB["Blood Plague"] = 21
DB["Strangulate"] = 5
DB["Mind Freeze"] = 4

-- Druid
DB["Moonfire"] = 12
DB["Insect Swarm"] = 12
DB["Faerie Fire"] = 40
DB["Entangling Roots"] = 27
DB["Cyclone"] = 6
DB["Rake"] = 9
DB["Rip"] = 12
DB["Lacerate"] = 15
DB["Pounce"] = 3

-- Hunter
DB["Serpent Sting"] = 15
DB["Hunter's Mark"] = 120
DB["Viper Sting"] = 8
DB["Wyvern Sting"] = 12
DB["Freezing Trap Effect"] = 18
DB["Immolation Trap"] = 15
DB["Wing Clip"] = 10
DB["Concussive Shot"] = 4

-- Mage
DB["Fireball"] = 8
DB["Frostbolt"] = 9
DB["Frost Nova"] = 8
DB["Polymorph"] = 50
DB["Slow"] = 15
DB["Ignite"] = 4
DB["Living Bomb"] = 12

-- Paladin
DB["Hammer of Justice"] = 6
DB["Repentance"] = 60
DB["Turn Evil"] = 20
DB["Holy Wrath"] = 3

-- Priest
DB["Shadow Word: Pain"] = 18
DB["Vampiric Touch"] = 15
DB["Devouring Plague"] = 24
DB["Psychic Scream"] = 8
DB["Mind Control"] = 60
DB["Shackle Undead"] = 50
DB["Silence"] = 5

-- Rogue
DB["Rupture"] = 16
DB["Garrote"] = 18
DB["Deadly Poison"] = 12
DB["Wound Poison"] = 15
DB["Blind"] = 10
DB["Sap"] = 60
DB["Cheap Shot"] = 4
DB["Kidney Shot"] = 6
DB["Gouge"] = 4

-- Shaman
DB["Flame Shock"] = 18
DB["Frost Shock"] = 8
DB["Earth Shock"] = 2
DB["Stormstrike"] = 12
DB["Hex"] = 50

-- Warlock
DB["Corruption"] = 18
DB["Curse of Agony"] = 24
DB["Curse of Doom"] = 60
DB["Curse of Elements"] = 300
DB["Curse of Weakness"] = 120
DB["Curse of Tongues"] = 30
DB["Immolate"] = 15
DB["Unstable Affliction"] = 18
DB["Haunt"] = 12
DB["Seed of Corruption"] = 18
DB["Fear"] = 20
DB["Howl of Terror"] = 8
DB["Death Coil"] = 3
DB["Banish"] = 30

-- Warrior
DB["Rend"] = 15
DB["Hamstring"] = 15
DB["Thunder Clap"] = 30
DB["Demoralizing Shout"] = 30
DB["Sunder Armor"] = 30
DB["Mortal Strike"] = 10
DB["Intimidating Shout"] = 8
DB["Concussion Blow"] = 5

-- Shared/Other
DB["Sapped Soul"] = 10

-- Function to get debuff duration
function ZenPlates:GetDebuffDuration(debuffName)
    return DB[debuffName] or 0
end
