# [ATIS](ATIS.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) to create an [ATIS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.Atis.html) radio frequency at each blue airbase.
- Place aircraft with name of **ATIS_[airbase callsign]** (*ATIS_Kobuleti*, for example) to get subtitles
  - Uses [MOOSE sound files](https://github.com/FlightControl-Master/MOOSE_SOUND/releases)
- Frequency is **VHF + `frequency_add`** (*Kobuleti=133MHz, ATIS=133.25MHz*, for example)

Configuration settings:
```lua
local config = ATIS_CONFIG or {
  frequency_add = 250000 -- in Hz
}
```

---

# [Briefing Addons](https://github.com/chump29/DCS_Mod/tree/master/Briefing%20Addons)
Adds the following to the briefings:
- Times in Zulu and local
- Long date
- Current time
- Sunrise/sunset times
- METAR
- Dynamic Case I/II/III
- Flight category
- Temperature (*C & F*)
- QNH (*inHg & mmHg & hPa*)
- Magnetic variation
- Cloud base rounded to 100ft/30m (*ft & m*)
- Wind (*blows FROM*)
- CDU wind (*when in A-10*)
- Turbulence (*kts & mps*)

*Install to:*
- `[DCS Directory]\MissionEditor\modules\me_autobriefing.lua`
- `[DCS Directory]\MissionEditor\modules\Mission\Airdrome.lua`
- `[DCS Directory]\MissionEditor\modules\Mission\AirdromeData.lua`
- `[DCS Directory]\Scripts\UI\autobriefingUtils.lua`
- `[DCS Directory]\Scripts\UI\BriefingDialog.lua`
- `[DCS Directory]\Scripts\briefing_addons.lua`
- `[DCS Directory]\Scripts\theatre_data.lua`
- `[DCS Directory]\Scripts\unit_converter.lua`
- `[DCS Directory]\Scripts\utils_common.lua`
- `[DCS Directory]\Scripts\wxDCS.lua`

**_or use latest OvGME package from [Releases](https://github.com/chump29/DCS_Mod/releases)_**

---

# [Carrier Stuff](Carrier_Stuff.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) to add the following to a carrier:
- [CSAR](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RescueHelo.html) (*non-rescue, hot start*)
- [Tanker](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Texaco, in-air start*)
- [AWACS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Overlord, in-air start*)

Configuration settings:
```lua
local config = CARRIER_STUFF_CONFIG or {
  carrierUnitName = "Carrier",
  tanker = {
    radio = 243, -- in MHz
    speed = 200, -- in kts
    tacan = {
      channel = 79, -- Y
      id = "TEX"
    }
  },
  awacs = {
    altitude = 20000, -- in ft
    radio = 255, -- in MHz
    tacan = {
      channel = 55, -- Y
      id = "WAX"
    }
  }
}
```

---

# [Crash Crew](Crash_Crew.lua)
Uses [MiST](https://github.com/mrSkortch/MissionScriptingTools/releases) to add a crash crew to crashed player planes/helicopters/ground units.

*NOTE: Must include `sound` file via trigger in editor*

Configuration settings:
```lua
local config = CRASH_CREW_CONFIG or {
  maxCrews = 10,
  minTime = 60, -- in seconds
  maxTime = 120, -- in seconds
  useFlares = true,
  useSmoke = true,
  useIllumination = true,
  sound = "l10n/DEFAULT/siren.ogg",
  message = true,
  units = {
    land = {
      type = "HEMTT TFFT",
      livery = ""
    },
    water = {
      type  = "speedboat",
      livery = ""
    }
  },
  debug = false
}
```

---

# [Fire Support](Fire_Support.lua)
Will call in `arty` or `smoke` by placing a marker with appropriate text.

Configuration Settings:
```lua
local config = FIRE_SUPPORT_CONFIG or {
  diameter = 75, -- in meters
  power = 68, -- kg of TNT
  preWaitArty = 10, -- in seconds
  preWaitSmoke = 5,
  postWaitArty = 30,
  postWaitSmoke = 10,
  rounds = 6, -- number of shots
  smokeColor = "Random" -- "Green", "Red", "White", "Orange", "Blue", "Random"
}
```

---

# [JTAC Priority](JTAC_Priority.lua)
Replaces `findNearestVisibleEnemy` in JTAC script to target red ground units with priority *(highest to lowest)*:
- SAM
- AAA
- Tank
- Armed ground unit
- Unarmed ground unit

Original JTAC script ***must*** include the following methods:
- alreadyTarget
- isVehicle
- isInfantry
- getDistance

*NOTE: Works with [CTLD](https://github.com/ciribob/DCS-CTLD) and [Through The Inferno](https://throughtheinferno.com/single-player-missions/)*

Configuration settings:
```lua
local config = JTAC_PRIORITY_CONFIG or {
  maxDistance = 5000, -- in m
  debug = false
}
```

---

# [Logger](logger.lua) <sup>*[module]*</sup>
Serialize/pretty print LUA objects to a file.
- `fileName` sets output file name *(default: logger.lua)*
- `useDesktopPath` tries to write to Desktop instead of current directory  *(default: true)*
- Usage is ***logger.log(object, name)***
  - where *name* is optional

*Install to:*
- `[DCS Directory]\Scripts\logger.lua`

---

# [Map Stuff](Map_Stuff.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) to add the following to a map:
- Announce when a player joins/dies/crashes
- Blue airfield data
  - [Pseudo ATC](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.PseudoATC.html)
  - Imports [ATIS](ATIS.lua) data, if available

*NOTE: Must include squelch `sound` file via trigger in editor, if desired*

Configuration settings:
```lua
local config = MAP_STUFF_CONIFG or {
  announcements = false,
  atc = true,
  markers = true,
  sound = "l10n/DEFAULT/static-short.ogg",
  startingId = 10000
}
```

---

# [Radio Tower](Radio_Tower.lua)
Creates a radio tower static object and transmission from zone with matching `name`. Handles multiple towers/stations. When destroyed, stops transmitting.

*NOTE: Must include `sound` file via trigger in editor*

Configuration settings:
```lua
local config = RADIO_TOWER_CONFIG or {
  towers = {
    {
      name = "Music", -- zone
      stations = {
        {
          name = "Radio X",
          sound = "Radio X.ogg", -- mp3/ogg
          frequency = 40, -- in MHz
          modulation = 1, -- 0=AM, 1=FM
          power = 1000, -- in W
          loop = true
        },
        {
          name = "V-Rock",
          sound = "VROCK.ogg",
          frequency = 41,
          modulation = 1,
          power = 1000,
          loop = true
        }
      }
    }
  },
  marks = {
    show = true, -- show on F10 map
    coalition = 1 -- 0=ALL, 1=BLUE, 2=RED
  },
  messages = false -- show status messages
}
```
