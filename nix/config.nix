let
  # Most common packages for developpement
  baseDevel = pkgs: with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.fr
    cmakeWithGui
    cabal-install
    cabal2nix
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
    python36Packages.pew
    python36Packages.virtualenv
    pkgconfig
    imagemagick
    nix-prefetch-scripts
    nix-repl
    stack
    unzip
    valgrind
    z3
    zip
  ];

  # X11 packages
  desktopPkgs = pkgs: with pkgs; [
    evince
    dmenu2
    libreoffice
    inkscape
    graphviz
    gitAndTools.qgit
    gtkwave
    vlc
    xorg.xmessage
    xterm
  ];
in
{
  packageOverrides = pkgs: {
    common_pkgs = pkgs.buildEnv rec {
      name = "common-pkgs-${meta.version}";
      paths = baseDevel pkgs ++ desktopPkgs pkgs;
      meta = {
        version = "1.4.0";
        description = "Common packages for desktop usage";
      };
    };

    qt59ct = pkgs.libsForQt59.callPackage <nixpkgs/pkgs/tools/misc/qt5ct> {};
  };
}
