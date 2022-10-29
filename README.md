# [ATIS](ATIS.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) to create an [ATIS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.Atis.html) radio frequency at each blue airbase.
- Place aircraft with name of **ATIS_[airbase callsign]** (*ATIS_Kobuleti*, for example) to get subtitles
  - Uses [MOOSE sound files](https://github.com/FlightControl-Master/MOOSE_SOUND/releases)
- Frequency is **VHF + modifier** (*Kobuleti=133MHz, ATIS=133.25MHz*, for example)
  - Can be changed by modifying `frequency_add` variable

---

# [Briefing Addons](https://github.com/chump29/DCS_Mod/tree/master/Briefing%20Addons)
Adds the following to the generated briefings:
- METAR
- Temperature (*C & F*)
- QNH (*inHg & mmHg & hPa*)
- Magnetic variation
- Cloud base (*ft & m*)
- Wind (*blows FROM*)
- A-10 CDU wind
- Turbulence (*kts & mps*)

*Install to:*
- `[DCS Directory]\MissionEditor\modules\me_autobriefing.lua`
- `[DCS Directory]\MissionEditor\modules\Mission\Airdrome.lua`
- `[DCS Directory]\MissionEditor\modules\Mission\AirdromeData.lua`
- `[DCS Directory]\Scripts\UI\BriefingDialog.lua`
- `[DCS Directory]\Scripts\briefing_addons.lua`
- `[DCS Directory]\Scripts\metar.lua`
- `[DCS Directory]\Scripts\utils_common.lua`

---

# [Carrier Stuff](Carrier_Stuff.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) to add the following to a carrier:
- [CSAR](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RescueHelo.html) (*non-rescue, hot start*)
- [Tanker](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Texaco, in-air start*)
- [AWACS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Overlord, in-air start*)

Configuration settings:
```lua
  local config = {
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
  local config = {
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

# [GCI](GCI.lua)
***NOTE: This is a proof-of-concept!***

Uses [MiST](https://github.com/mrSkortch/MissionScriptingTools/releases) to add F10 data to blue flights:
- Unit flight path history
  - Color-coded based on altitude
    - < 1000ft: ![Green](https://via.placeholder.com/15/00ff00/00ff00.png)
    - < 2500ft: ![Yellow](https://via.placeholder.com/15/ffff00/ffff00.png)
    - \>= 2500ft: ![Red](https://via.placeholder.com/15/ff0000/ff0000.png)
  - *NOTE: Turning on **Show All Routes** helps draw in real-time*
- Group name/altitude/speed/heading

Configuration settings:
```lua
  local config = {
    offsetUp = 800,
    offsetRight = 400,
    greenHeight = 1000, -- in ft
    yellowHeight = 2500, -- in ft
    maxHistory = 3, -- 30s
    fontColor = {0, 0, 1, 1}, -- RGBA
    fontSize = 10,
    backgroundColor = {0, 0, 0, 0.1}, -- RGBA
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
  local config = {
    maxDistance = 5000, -- in m
    debug = false
  }
```

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
local config = {
  announcements = false,
  atc = true,
  markers = true,
  sound = "l10n/DEFAULT/static-short.ogg",
  startingId = 10000
}
```

---

# [Radio Tower](Radio_Tower.lua)
Creates a radio tower static object and transmission from zones with matching `name`. Handles multiple stations per tower. When destroyed, stops transmitting.

*NOTE: Must include `sound` file via trigger in editor*

Configuration settings:
```lua
  local config = {
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
