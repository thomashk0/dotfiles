# XMonad Windows Manager Config

## Dependencies

- Archlinux: `xorg-xmessage`
- Debian 11+: `sudo apt install libx11-dev libxrandr-dev libxss-dev libxft-dev`

## Install with nix

In the current directory, run:

```console
$ nix-env -i -f default.nix
```
## Install with stack

```console
$ stack install
```

The executable will be placed into `~/.local/bin/mywm`.

## Overview

* The config designed to replace Xcfe's windows manager (xfwm4)
* Run the executable ``mywm`` to replace the current windows manager
* The default mod key is WIN
* Press ``MOD+h`` to display a list of bindings
* **Warning** : be sure the directory `~/.xmonad` exists (required for `Prompt.*` modules)
