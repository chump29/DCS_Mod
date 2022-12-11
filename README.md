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

# [AWACS & Wingman Addons](https://github.com/chump29/DCS_Mod/tree/master/AWAC%20%26%20Wingman%20Addons)
- AWACS picture calls
  - Rounds bearing to nearest 10°
  - Sorts groups nearest to farthest from player
  - Eliminates repeated groups if BRA within 10°/2nm/1000ft
```lua
local config = {
  maxDistance = 185200 -- in m (100nm)
}
```

- Wingman calls
  - Eliminates repeated group calls for radar/contact/tally/nails/spike/mudspike

```lua
local config = {
  minRange = 3704, -- in m (2nm)
  maxRange = 277800, -- in m (150nm)
  degreesBetweenSameCall = 30,
  distanceBetweenSameCall = 9260, -- in m (5nm)
  timeBetweenSameCall = 60 -- in seconds
}
```

*Install to:*
- `[DCS Directory]\Scripts\Speech\common.lua`
- `[DCS Directory]\Scripts\Speech\NATO.lua`

*NOTE: For NATO only.*

---

# [Briefing Addons](https://github.com/chump29/DCS_Mod/tree/master/Briefing%20Addons)
Adds the following to the generated briefings:
- METAR
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
- `[DCS Directory]\Scripts\METAR.lua`
- `[DCS Directory]\Scripts\utils_common.lua`

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

# [Logger](logger.lua)
Writes LUA objects to a file. Tries to find user's desktop folder.
- `fileName` sets output file name
- Usage is ***logger.log(object, name)***
  - where *name* is optional

*Install to:*
- `[DCS Directory]\Scripts\logger.lua`

---

# [Map Stuff](Map_Stuff.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) and [MiST](https://github.com/mrSkortch/MissionScriptingTools/releases) to add the following to a map:
- Announce when a player joins/dies/crashes
- Blue airfield data
  - [Pseudo ATC](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.PseudoATC.html)
  - Imports [ATIS](ATIS.lua) data, if available

*NOTE: Must include `sound` file via trigger in editor*

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
  enableMarks = true, -- show on F10 map
  messages = false -- show status messages
}
```
