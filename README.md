# pulse

**pulse** is a clientside mod for [TF|2 + Northstar](https://github.com/R2Northstar/Northstar) letting you view killstats collected by [the Tone API](https://toneapi.github.io/ToneAPI_webclient/) using the otherwise non-functional `Stats` tab.

## Currently, features include:
- mostly functional `Overview` tab,
- functional `Time` tab,
- Pilot weapon data displayed in `Pilot Weapons` tab,
- Titan kills displayed in `Titans` tab,
- functional `Maps` tab,
- real-time updates.

Want to know what we have planned for future updates? See [here.](https://github.com/ToneAPI/pulse/projects?query=is%3Aopen)

Found a bug? Make an issue on GitHub [here.](https://github.com/ToneAPI/pulse/issues/new)

<details>
<summary>Features, more in-depth:</summary>

### `Overview`
- Most Kills - shows the weapon with most accumulated kills.
- Nemesis Weapon - shows the weapon that has killed you the most.
- Most Effective - shows weapon with the highest K/D ratio.
- Kill/Death Ratio - shows the overall K/D ratio of player compared to global K/D.
- Kills as Pilot - shows general kill data for player as Pilot, visualised in the table below:

  |        Name        | Description                                                                                                                                                                        |
  |--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
  | Pilots             |Shows **ALL KILLS** accumulated by player as Pilot. Differentiating Pilot and Titan kills will come in a later Tone API update.|
  | Titans             |Non-functional, see line above.|
  | AI kills           |Non-functional, Tone API does not collect AI kill data.|
  | Pilot melee kills  |Shows only melee kills accumulated by player as Pilot.|
  | Pilot executions   |Shows only executions accumulated by player as Pilot.|

- Kills as Titan - shows general kill data for player as Titan, visualised in the table below:

  |        Name        | Description                                          |
  |--------------------|------------------------------------------------------|
  | Pilots             |Shows **ALL KILLS** accumulated by player as Titan. Differentiating Pilot and Titan kills will come in a later Tone API update.|
  | Titans             |Non-functional, see line above.|
  | Titan executions   |Shows only executions accumulated by player as Titan.|
  | Pilots meleed      |Shows only melee kills accumulated by player as Titan.|
  | Pilot roadkills    |Shows only roadkills accumulated by player as Titan.|

- Upper statbox values have been zeroed out, these don't yet work and are set to 0 to avoid confusion.

### `Time`

- Kills by Class shows kills by Pilot and Titan on a piechart.
- Kills by Titan shows kills by all Titan classes on a piechart.
- Kills by Gamemode shows kills on each gamemode played on a piechart.

### `Pilot Weapons`

- shows total accumulated kills per weapon under Total Kills.
- shows deaths with given weapon equipped under Deaths with Weapon.

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

## DISCLAIMERS

The Tone API is NOT used by every server, view a list of supported servers [here.](https://toneapi.ovh/v2/client/servers)
**pulse** is very much a W.I.P as of right now, features may be missing/nonfunctional.

As of v2.1.0, **pulse** requires [loeb](https://github.com/okvdai/loeb)

## CHANGELOG

<details>
  <summary> pulse v2.0.0 "Demeter" </summary>

  - Switched to Thunderstore template on the GitHub site for easier development.
  - General code rewrite - lots of improvements for easier development. Rewrite includes:
    - common code file, for better code readability and ease of development,
    - new parser, allowing for better expandability and faster data processing (and much simpler implementation, unlike the hellspawn that was the previous `getFromToneAPI` function),
    - new request function, more compact and simple than previous iterations,
    - other functions that simplify the code and make it easier to read / develop
  - Localisation, currently available in:
    - English,
    - French,
    - German,
    - Italian,
    - Polish. (Northstar isn't translated into Polish, but the game supports it.)
  - Locking the Stats tab, avoiding situations where you could click too fast and see no stats. Also prevents the game from showing stats when the API is unreachable.
</details>

<details>
  <summary> pulse v2.1.0  </summary>

  - Changed endpoint
  - Lots of bug fixes
  - Uses new experimental loeb library
</details>
