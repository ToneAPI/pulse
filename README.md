# Pulse

Pulse is a clientside mod for [TF|2 + Northstar](https://github.com/R2Northstar/Northstar) letting you view killstats collected by [the Tone API](https://toneapi.github.io/ToneAPI_webclient/) using the otherwise non-functional `Stats` tab.

## Currently, features include:
- mostly functional `Overview` tab,
- Pilot weapon kills displayed in `Pilot Weapons` tab
- Titan kills displayed in `Titans` tab,
- functional `Maps` tab,
- real-time updates.

Want to know what we have planned for future updates? See [here.](https://github.com/ToneAPI/pulse/projects?query=is%3Aopen)

Found a bug? Make an issue on Github [here.](https://github.com/ToneAPI/pulse/issues/new)

<details>
<summary>Features, more in-depth:</summary>

### `Overview`
- Most Kills - shows the weapon with most accumulated kills.
- Nemesis Weapon - shows the weapon that has killed you the most.
- Most Effective - shows weapon with the highest K/D ratio.
- Kill/Death Ratio - shows the overall K/D ratio of player. (the two line graphs "Lifetime Avg." and "Lifetime Avg. vs. Players" don't work.)
- Kills as Pilot - shows general kill data for player as Pilot, visualised in the table below:

  |        Name        | Description                                                                                                                                                                        |
  |--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
  | Pilots             |Shows **ALL KILLS ACCUMULATED BY PLAYER.**<sup>1</sup> This includes Titan kills and kills as Titans, we will display them in their respective tab with an upcoming Tone API update.|
  | Titans             |Non-functional, see <sup>1</sup>.|
  | AI kills           |Non-functional, Tone API does not collect AI kill data.|
  | Pilot melee kills  |Shows only melee kills accumulated by player as Pilot.|
  | Pilot executions   |Shows only executions accumulated by player as Pilot.|
  
- Kills as Titan - shows general kill data for player as Titan, visualised in the table below:

  |        Name        | Description                                          |
  |--------------------|------------------------------------------------------|
  | Pilots             |Non-functional, see <sup>1</sup>.|
  | Titans             |Non-functional, see <sup>1</sup>.|
  | Titan executions   |Shows only executions accumulated by player as Titan.|
  | Pilots meleed      |Shows only melee kills accumulated by player as Titan.|
  | Pilot roadkills    |Shows only roadkills accumulated by player as Titan.|

- Upper statbox values have been zeroed out, these don't yet work and are set to 0 to avoid confusion.

### `Pilot Weapons`

- shows total accumulated kills per weapon under Total Kills.

### `Titans`

- shows total accumulated kills per Titan under Total Kills.

### `Maps`

- Player Map Stats - shows general data for player on chosen map, visualised in the table below:

  |          Name         | Description                                                      |
  |-----------------------|-------------------------------------------------------           |
  | Kills on Map          |Shows all kills accumulated by player on chosen map.|
  | Deaths on Map         |Shows all deaths accumulated by player on chosen map.|
  | Total Shot Distance   |Shows total distance of kills accumulated by player on chosen map.|
  | Maximum Shot Distance |Shows highest distance kill by player on chosen map.|

- Kills by Gamemode - piechart showing all kills (in percent) on chosen map by gamemode.
</details>

## DISCLAIMER

The Tone API is NOT used by every server, view a list of supported servers [here.](https://tone.sleepycat.date/v2/client/servers)

Pulse is very much a W.I.P as of right now, features may be missing/nonfunctional.
