let
  # Most common packages for developpement
  baseDevel = pkgs: with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.fr
    cmakeWithGui
    gnumake
    ninja
    gcc
    gdb
    binutils
    nasm
    openjdk
    git
    python36
    python36Packages.pip
    python36Packages.virtualenv
    imagemagick
    nix-prefetch-scripts
    nix-repl
  ];

  # X11 packages
  desktopPkgs = pkgs: with pkgs; [
    libreoffice
    inkscape
    graphviz
    gitg
    vlc
  ];

  version = "1.2";
in
{
  packageOverrides = pkgs: rec {
    common_pkgs = pkgs.buildEnv {
      name = "common-pkgs-${version}";
      paths = baseDevel pkgs ++ desktopPkgs pkgs;
      meta = {
        description = "Common packages for desktop usage";
      };
    };

  };
}
