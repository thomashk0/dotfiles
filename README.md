# Personal dotfiles collection

## Installation

First, get all git submodules:

```bash
$ git submodule init --update
```

Then, run the install script (**warning:** it requires Python 3.6+):

```bash
$ ./install.py
```

## Update Zsh config

A script in `zsh` directory fetches the last version from GRML repository.

```bash
$ (cd zsh && ./update.sh)
```
