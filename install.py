#!/usr/bin/env python3

import subprocess
import logging
from pathlib import Path

logging.basicConfig(
        level=logging.DEBUG,
        format="[%(levelname)s] %(message)s")
logger = logging.getLogger('install.py')

def realpath(p, **kwargs):
    return str(p.resolve(**kwargs))


def ln(src: Path, dst: Path):
    if dst.exists():
        if dst.samefile(src):
            logger.info(f"Symlink to {dst} already valid, skipping")
            return
        raise Exception(f"target {dst} already exists and does not point"
                        f" to {src} !!")
    logger.info(f"Creating symlink {src} -> {dst}")
    subprocess.check_call(["ln", "-s", realpath(src, strict=True),
                           realpath(dst)])


def setup_vim():
    VIM_PLUG_URL = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    vim_dir = Path('vim/vim')
    vim_dir.mkdir(exist_ok=True)
    ln(vim_dir, Path.home() / ".vim")
    plug_file = vim_dir / "autoload/plug.vim"
    if not plug_file.exists():
        subprocess.check_call(
                ["curl", "-fLo", str(plug_file), "--create-dirs", VIM_PLUG_URL])
    else:
        logger.warning(
                f"file {plug_file} already there. Delete it and rerun"
                "this script if you want to force the update.")

    ln(Path('vim') / "vimrc", Path.home() / ".vimrc")


SYMLINKS = {
    'zsh': [('zshrc.local', Path.home() / '.zshrc.local'),
            ('zshrc', Path.home() / '.zshrc')],
    'git': [('gitconfig', Path.home() / '.gitconfig')],
    'tmux': [('tmux.conf', Path.home() / '.tmux.conf')],
    'nix': [('config.nix', Path.home() / '.nixpkgs/config.nix')],
}


def main():
    ln(Path.cwd(), Path.home() / '.dotfiles')
    setup_vim()
    for app, links in SYMLINKS.items():
        for src, dst in links:
            ln(Path(app) / src, dst)


if __name__ == '__main__':
    main()
