#!/usr/bin/env python3

import subprocess
from pathlib import Path


def realpath(p, **kwargs):
    return str(p.resolve(**kwargs))


def ln(src: Path, dst: Path):

    if dst.exists():
        if dst.samefile(src):
            return
        raise Exception(f"target {dst} already exists and does not point"
                        f" to {src} !!")
    subprocess.check_call(["ln", "-s", realpath(src, strict=True),
                           realpath(dst)])


def setup_vim():
    VIM_PLUG_URL = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    vim_dir = Path('vim/vim')
    vim_dir.mkdir(exist_ok=True)
    ln(vim_dir, Path.home() / ".vim")
    subprocess.check_call(["curl", "-fLo", str(vim_dir / "autoload/plug.vim"),
                           "--create-dirs", VIM_PLUG_URL])
    ln(Path('vim') / "vimrc", Path.home() / ".vimrc")


SYMLINKS = {
    'zsh': [('zshrc.local', Path.home() / '.zshrc.local'),
            ('zshrc', Path.home() / '.zshrc')],
    'git': [('gitconfig', Path.home() / '.gitconfig')],
    'tmux': [('tmux.conf', Path.home() / '.tmux.conf')],
    'nix': [('config.nix', Path.home() / '.nixpkgs/config.nix')]
}


def main():
    setup_vim()
    for app, links in SYMLINKS.items():
        for src, dst in links:
            ln(Path(app) / src, dst)


if __name__ == '__main__':
    main()
