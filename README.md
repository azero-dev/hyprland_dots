# Hyprland dots

These are my dots for Hyprland and Waybar. Uploaded here to keep them archived, and in case anyone else finds them useful.

There is a custom module for managing Bluetooth, which uses [rofi-bluetooth](https://github.com/nickclyde/rofi-bluetooth/blob/master/rofi-bluetooth) created by **Nick Clyde (clydedroid)**.

I usually prefer to use webapps rather than install them, so certain commands open these web apps. To manage webapps, I use Linux Mint's [Webapp Manager](https://github.com/linuxmint/webapp-manager).

## Secondary monitor management

Management is handled by [**ddcutils**](https://www.ddcutil.com/). If you need to use another command, replace it in:

- hypr/config/keybinds.conf: To control brightness with keybinds.
- waybar/modules/secmonitor.sh: to display the curren brightness percentage.

## Keybinds

List of all keybinds, divided into different tables according to concepts/functionality.

| Keybind     | Consequences for humanity |
| ----------- | ------------------------- |
| main CTRL F | Firefox                   |
| main CTRL T | Telegram                  |
| main CTRL O | Obsidian                  |
| main CTRL R | Ranger                    |
| main CTRL Y | Yazi                      |
| main CTRL G | Gedit                     |
| main CTRL Q | Qwen                      |
| main CTRL S | Spotify                   |
| main ALT M  | Thunderbird               |

| Keybind  | The Matrix has you    |
| -------- | --------------------- |
| main C   | close active window   |
| main Q\* | close active window   |
| main Z   | terminal              |
| main X   | nvim                  |
| main A   | file manager          |
| main V   | float window          |
| main F   | full screen           |
| main M   | group windows         |
| main N   | split direction       |
| main O   | reload waybar         |
| main B   | bluetooth management  |
| main S   | power menu            |
| main TAB | change grouped window |

| Keybind         | Media and monitor control       |
| --------------- | ------------------------------- |
| main ALT COMMA  | turn on second monitor          |
| main ALT PERIOD | turn off second monitor         |
| main ALT HOME   | increase sec monitor brightness |
| main ALT END    | decrease sec monitor brightness |
| main ALT L      | lock screen                     |
| main ALT SPACE  | pause track                     |
| main ALT RIGHT  | next track                      |
| main ALT LEFT   | previous track                  |
| main ALT UP     | volume up                       |
| main ALT DOWN   | volume down                     |
| main ALT PRIOR  | brightness up                   |
| main ALT NEXT   | brightness down                 |

| Keybind                 | Window actions                 |
| ----------------------- | ------------------------------ |
| main HJKL               | move focus                     |
| main SHIFT HJKL         | move window                    |
| main 1234567890         | switch workspace               |
| main ctrl 1234567890    | move window + switch workspace |
| main SHIFT 1234567890   | move window silently           |
| main COMMA/PERIOD/SLASH | scroll workspace               |

| Keybind           | Scratchpads                |
| ----------------- | -------------------------- |
| main EQUAL        | special workspace          |
| main SPACE\*      | special workspace          |
| main MINUS        | send to special workspace  |
| main F1           | special scratchpad         |
| main CRTL SPACE\* | special scratchpad         |
| main SHIFT F1     | send to special scratchpad |

\*Alternatives for same functionality
