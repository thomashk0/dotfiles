export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:$PATH"

# ===
# Oh-my-Zsh configuration
#
# See: ~/.oh-my-zsh/templates/zshrc.zsh-template for the options availables.
# ===

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="re5et"

# _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# This makes repository status check for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git aliases fzf)

source $ZSH/oh-my-zsh.sh

# ===
# User customization
# ===

export EDITOR=vim

function nix-search() {
    cat $HOME/.cache/nix/pkgs.txt | fzf
}

function load-nix() {
    if [[ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]]; then
        . $HOME/.nix-profile/etc/profile.d/nix.sh
    fi;
}

function nix-fetchpkgs {
    nix-env -qaP '*' > $HOME/.cache/nix/pkgs.txt
}

# Example aliases
alias zshconfig="${EDITOR} ~/.zshrc"

# Enable Nix, if available
if [ -e ${HOME}/.nix-profile/etc/profile.d/nix.sh ]; then 
    . ${HOME}/.nix-profile/etc/profile.d/nix.sh; 
fi

# Enable zoxide (autojump-like directory navigation), if available.
if [ -x "$(command -v zoxide)" ]; then
    eval "$(zoxide init zsh)"
fi

# Use GPG Agent for SSH, this is required for using Yubikey.
# IMPORTANT: I often need to issue the command:
#   $ gpg-connect-agent updatestartuptty /bye
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
