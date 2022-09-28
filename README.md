# [ATIS](ATIS.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) to create an [ATIS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.Atis.html) radio frequency at each blue airbase.
- Place aircraft with name of **ATIS_[airbase callsign]** (*ATIS_Kobuleti*, for example) to get subtitles
  - Uses [MOOSE sound files](https://github.com/FlightControl-Master/MOOSE_SOUND/releases)
- Frequency is **VHF + modifier** (*Kobuleti=133MHz, ATIS=133.25MHz*, for example)
  - Can be changed by modifying `frequency_add` variable

---

# [Briefing Addons](https://github.com/chump29/DCS_Mod/tree/master/Briefing%20Addons)
Adds the following to the generated briefings:
- Temperature (*F & C*)
- QNH (*inHg & hPa*)
- Magnetic declination
  - Based on year
- Cloud base (*ft & m*)
- A-10 CDU wind data

*Install to:*
- `[DCS Directory]\MissionEditor\modules\me_autobriefing.lua`
- `[DCS Directory]\Scripts\UI\BriefingDialog.lua`
- `[DCS Directory]\Scripts\briefing_addons.lua`

---

# [Carrier Stuff](Carrier_Stuff.lua)
Uses [MOOSE](https://github.com/FlightControl-Master/MOOSE/releases) and [MiST](https://github.com/mrSkortch/MissionScriptingTools/releases) to add the following to a carrier:
- [CSAR](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RescueHelo.html) (*non-rescue, hot start*)
- [Tanker](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Texaco, 243MHz, 200kts, 79Y, in-air*)
- [AWACS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Darkstar, 255MHz, 20,000ft, 55Y, in-air*)

Set carrier unit name by modifying the `carrierUnitName` variable

---

# [Crash Crew](Crash_Crew.lua)
Uses [MiST](https://github.com/mrSkortch/MissionScriptingTools/releases) to add a crash crew to crashed player planes/helicopters/ground units.

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

*NOTE: Works with [CTLD](https://github.com/ciribob/DCS-CTLD)*

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
Creates a radio tower static object and transmission from zones with matching `name`. When destroyed, stops transmission.

Configuration settings:
```lua
  local config = {
    stations = {
      {
        name = "Radio1", -- zone
        music = "Radio1.ogg", -- mp3/ogg
        frequency = 40, -- in MHz
        modulation = 1, -- 0=AM, 1=FM
        power = 1000, -- in W
        loop = true
      },
      {
        name = "Radio2",
        music = "Radio2.mp3",
        frequency = .6,
        modulation = 0,
        power = 1000,
        loop = true
      }
    },
    debug = false
  }
```
