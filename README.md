# Row Your Boat

Source code and files for the [Row Your Boat Oblivion Remastered
mod](https://www.nexusmods.com/oblivionremastered/mods/4273).

[YouTube video](https://youtu.be/SE55cqIZNp4)

## Scripts

For convienence of editing and viewing. All scripts contained within `RowYourBoat.esp` have been extracted out into the
`Scripts` and `ResultScripts` folders. `Scripts` are top-level scripts attached to Objects, Quests, or Spell Effects
within the plugin, while `ResultScripts` are short snippets attached to specific stages in the `RYB` quest. The main
script `RYBQuestScript.psc` got too long and had to be split up, so I put common functions, initialization, and isolated
blocks of code into [Stage Functions](https://cs.uesp.net/wiki/Category:Stage_Functions) on the `RYB` quest. These need
to be kept quite short since result scripts have a small max limit.

I use the `.psc` extension for better code highlighting, but these technically aren't Papyrus files since these are
OBScript files.

## ESP

I'm checking in any changes I make to the `.esp` plugin here, but it's a binary format not easily readable on git
hosting sites. I eventually would like to setup [Spriggit](https://github.com/Mutagen-Modding/Spriggit) for this.

## Other files

- `SyncMap`: config for [UE4SS TesSyncMapInjector](https://www.nexusmods.com/oblivionremastered/mods/1272)
- `MagicLoader`: config for [MagicLoader 2](https://www.nexusmods.com/oblivionremastered/mods/1966)
- `Docs`: source for in-game manual and the Nexus Mods mod description