#!/usr/bin/env python3

import subprocess
import logging
from pathlib import Path

logging.basicConfig(level=logging.DEBUG, format="[%(levelname)s] %(message)s")
logger = logging.getLogger("install.py")


def realpath(p: Path, **kwargs) -> str:
    return str(p.resolve(**kwargs))


def ln(src: Path, dst: Path):
    if dst.exists():
        if dst.samefile(src):
            logger.info(f"Symlink to {dst} already valid, skipping")
        else:
            logger.warning(
                f"Target {dst} already exists and does not point to {src} !!"
            )
    logger.info(f"Creating symlink {src} -> {dst}")
    subprocess.check_call(["ln", "-s", realpath(src, strict=True), realpath(dst)])


def setup_vim():
    VIM_PLUG_URL = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    vim_dir = Path("vim/vim")
    vim_dir.mkdir(exist_ok=True)
    ln(vim_dir, Path.home() / ".vim")
    plug_file = vim_dir / "autoload/plug.vim"
    if not plug_file.exists():
        subprocess.check_call(
            ["curl", "-fLo", str(plug_file), "--create-dirs", VIM_PLUG_URL]
        )
    else:
        logger.warning(
            f"file {plug_file} already there. Delete it and re-run"
            " this script if you want to force the update."
        )

    ln(Path("vim") / "vimrc", Path.home() / ".vimrc")


def setup_emacs():
    src = Path.cwd() / "emacs"
    dst = Path.home() / ".emacs.d"
    dst.mkdir(exist_ok=True)
    ln(src / "init.el", dst / "init.el")
    ln(src / "sanemacs.el", dst / "sanemacs.el")


def setup_tmux():
    ln(Path("tmux/tmux.conf"), Path.home() / ".tmux.conf")


def setup_git():
    ln(Path("git/gitconfig"), Path.home() / ".gitconfig")


def setup_zsh():
    raise NotImplemented("todo")


def setup_nix_config():
    nix_usr_dir = Path.home() / ".nixpkgs" / "config.nix"
    nix_overlay_dir = Path.home() / ".config" / "nixpkgs"
    nix_overlay_dir.mkdir(exist_ok=True)

    nix_usr_dir.parents[0].mkdir(exist_ok=True)
    ln(Path.cwd() / "nix" / "config.nix", nix_usr_dir)
    ln(Path.cwd() / "nix" / "overlays", nix_overlay_dir / "overlays")


def setup_xfce4_term():
    dst = Path.home() / ".local" / "share" / "xfce4" / "terminal" / "colorschemes"
    dst.mkdir(exist_ok=True, parents=True)
    ln(
        Path.cwd() / "xfce4-terminal" / "base16-monokai.theme",
        dst / "base16-monokai.theme",
    )


def setup_fish():
    src = Path.cwd() / "fish"
    dst = Path.home() / ".config" / "fish"
    dst.mkdir(exist_ok=True, parents=True)
    (dst / "functions").mkdir(exist_ok=True, parents=True)
    ln(src / "config.fish", dst / "config.fish")
    ln(src / "functions" / "fish_prompt.fish", dst / "functions" / "fish_prompt.fish")


def setup_nvim():
    dst = Path.home() / ".config" / "nvim"
    dst.mkdir(exist_ok=True, parents=True)
    ln(Path.cwd() / "nvim" / "init.vim", dst / "init.vim")


def main():
    ln(Path.cwd(), Path.home() / ".dotfiles")
    setup_vim()
    setup_emacs()
    setup_xfce4_term()
    setup_tmux()
    setup_git()


if __name__ == "__main__":
    main()
