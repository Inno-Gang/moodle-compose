# moodle-compose
Script that just generates docker-compose file after you answer some
configuration questions.

## Demo
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./demo.gif">
  <source media="(prefers-color-scheme: light)" srcset="./demo.gif">
  <img width="1400" alt="Demo of the moodle-compose.sh script" src="./demo.gif">
</picture>

## Usage
1. Install [gum](https://github.com/charmbracelet/gum#installation)
2. Run script `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Inno-Gang/moodle-compose/main/moodle-compose.sh)"`
3. Use generated `docker-compose.yaml` to run Moodle

## Credits
Thanks to [charmbracelet](https://github.com/charmbracelet)
for awesome CLI/TUI tools!
