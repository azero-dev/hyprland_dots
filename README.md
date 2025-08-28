# hyprland dots

These are my dots for Hyprland and Wayland. Uploaded here to keep them archived, and in case anyone else finds them useful.

There is a custom module for managing Bluetooth, which uses a script created by **Nick Clyde (clydedroid)**.

This is designed for MY desktop, so if you use it, you will need to adapt it. For example, I use MControlCenter for MSI, but you may not need it.

## Secondary monitor management
The secondary monitor module may not work with your device. Management is handled by **ddcutils**. If you need to use another command, replace it in:
- hypr/config/keybinds.conf: To control brightness with keybinds.
- waybar/modules/secmonitor.sh: to display the curren brightness percentage.

## Keybinds usage
List of all keybinds, divided into different tables according to concepts/functionality.

The submenu is for extra, less frequently used functions. This separates them from the main functions. In addition, when you lock the desktop with the submenu, the keyboard will also be locked (unless you press **ESC**). Extra security ;)

| Keybind     | Consequences for humanity |
| ----------- | ------------------------- |
| main CTRL F | Firefox                   |
| main CTRL T | Telegram                  |
| main CTRL O | Obsidian                  |
| main CTRL R | Ranger                    |
| main CTRL G | Gedit                     |
| main CTRL Q | Qwen                      |
| main CTRL S | Spotify                   |
| main CTRL C | ChatGPT                   |

| Keybind         | The matrix has you      |
| --------------- | ----------------------- |
| main Z          | terminal                |
| main X          | nvim                    |
| main A          | file manager            |
| main Q          | close                   |
| main V          | float window            |
| main F          | full screen             |
| main M          | group windows           |
| main N          | split direction         |
| main O          | reload waybar           |
| main B          | bluetooth management    |
| main S          | power menu              |
| main TAB        | change grouped window   |
| main ALT COMMA  | turn on second monitor  |
| main ALT PERIOD | turn off second monitor |

| Keybind                 |                                |
| ----------------------- | ------------------------------ |
| main HJKL               | move focus                     |
| main SHIFT HJKL         | move window                    |
| main 1234567890         | switch workspace               |
| main ctrl 1234567890    | move window + switch workspace |
| main SHIFT 1234567890   | move window silently           |
| main COMMA/PERIOD/SLASH | scroll workspace               |

| Keybind          |                            |
| ---------------- | -------------------------- |
| main EQUAL       | special workspace          |
| main SPACE*      | special workspace          |
| main MINUS       | send to special workspace  |
| main F1          | special scratchpad         |
| main CRTL SPACE* | special scratchpad         |
| main SHIFT F1    | send to special scratchpad |
\*Alternatives for same functionality

| Keybind     |                 |
| ----------- | --------------- |
| main CTRL U | Submap apps     |
| T           | Twitch          |
| L           | lock screen     |
| SPACE       | pause track     |
| RIGHT       | next track      |
| LEFT        | previous track  |
| UP          | volume up       |
| DOWN        | volume down     |
| PRIOR       | brightness up   |
| NEXT        | brightness down |
