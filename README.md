This is a Lua script that implements Discord Rich Presence directly into Sonic Racing Crossworlds, which allows other players to see:
- When you're in menus.
- What map you're currently racing on.
- What character your playing.
- What game mode your playing.

This uses GhostyPool's DiscordRPC Lua library, located here: https://github.com/GhostyPool/DiscordRPC-Lua

**Installation**

This mod requires UE4SS to be installed; you must download the experimental build of UE4SS on their github page or the Pre-compiled version of UE4SS in the Crossworld Hub discord.
After downloading UE4SS, place the contents of UE4SS in: `<BaseDir>\UNION\Binaries\Win64`

If UE4SS' dwmapi.dll not present in the Win64 folder, you have installed UE4SS wrong.
If you downloaded experimental-latest from the UE4SS github page, you must open up `UE4SS-settings.ini` which will be located in your new ue4ss folder, and **change the Major and Minor to 5 and 4**.

In your UE4SS folder, you should have a mods folder, place the UnionDiscord folder inside of the Mods folder.
After placing this folder, you can launch the game.

UnionDiscord comes with a `settings.lua` file that you can adjust. This allows you to adjust systems related to async updates or enable the Miku Miku Mode.
The `settings.lua` file is located in `<BaseDir>\UNION\Binaries\Win64\ue4ss\Mods\UnionDiscord\Scripts`
