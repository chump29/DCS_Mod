# <u>ATIS</u>
Uses [MOOSE](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.Atis.html) to create ATIS radio frequency at each blue airbase.
- Place aircraft with name of **ATIS_[airbase callsign]** (*ATIS_Kobuleti*, for example) to get subtitles
  - Uses MOOSE sound files
- Frequency is **VHF + modifier** (*Kobuleti=133MHz, ATIS=133.25MHz*, for example)
  - Can be changed by modifying `frequency_add` variable
