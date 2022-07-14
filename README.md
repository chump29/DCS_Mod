# <u>ATIS</u>
Uses **MOOSE** to create an [ATIS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.Atis.html) radio frequency at each blue airbase.
- Place aircraft with name of **ATIS_[airbase callsign]** (*ATIS_Kobuleti*, for example) to get subtitles
  - Uses MOOSE sound files
- Frequency is **VHF + modifier** (*Kobuleti=133MHz, ATIS=133.25MHz*, for example)
  - Can be changed by modifying `frequency_add` variable

# <u>Briefing Addons</u>
Adds the following to the generated briefings:
- Temperature (*F & C*)
- QNH (*inHg & hPa*)
- Magnetic declination
- Cloud base (*ft & m*)
- A-10 CDU wind data

*Install to:*
- `[DCS Directory]\MissionEditor\modules\me_autobriefing.lua`
- `[DCS Directory]\Scripts\UI\BriefingDialog.lua`
- `[DCS Directory]\Scripts\briefing_addons.lua`

# <u>Carrier_Stuff</u>
Uses **MOOSE** and **MiST** to add the following to a carrier:
- [CSAR](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RescueHelo.html) (*non-rescue, hot start*)
- [Tanker](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Texaco, 243MHz, 200kts, 79Y, in-air*)
- [AWACS](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html) (*Darkstar, 255MHz, 20,000ft, 55Y, in-air*)

Set carrier unit name by modifying `carrier_unit_name` variable

# <u>GCI</u>
Uses **MiST** to add F10 data to blue flights:
- Flight path history
  - Based on altitude
    - < 1000ft: ![Green](https://via.placeholder.com/15/00ff00/00ff00.png) Green
    - < 2500ft: ![Yellow](https://via.placeholder.com/15/ffff00/ffff00.png) Yellow
    - \>= 2500ft: ![Red](https://via.placeholder.com/15/ff0000/ff0000.png) Red
  - Turning on *Show All Routes* helps draw in real-time
- Group velocity/name/altitude/speed/heading

Configuration settings:
```lua
  local config = {
    offsetUp = 800,
    offsetRight = 400,
    greenHeight = 1000, -- 305m
    yellowHeight = 2500, -- 762m
    maxHistory = 3, -- 30s
    debug = false
  }
```

# <u>Map_Stuff</u>
Uses **MOOSE** and **MiST** to add the following to a map:
- Announce when a player joins/dies/crashes
- Blue airfield data
  - [Pseudo ATC](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.PseudoATC.html)
  - Imports [ATIS](https://github.com/chump29/DCS_Mod/edit/master/README.md#atis) data, if available

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
