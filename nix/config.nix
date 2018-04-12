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
    dlang_pkgs = pkgs.buildEnv {
      name = "dlang-pkgs-1.0.0";
      paths = with pkgs; [ dmd ldc dub ];
      meta = {
        description = "Basic tools for working with the D language";
      };
    };
    common_pkgs = pkgs.buildEnv {
      name = "common-pkgs-${version}";
      paths = baseDevel pkgs ++ desktopPkgs pkgs;
      meta = {
        description = "Common packages for desktop usage";
      };
    };
    qt59ct = pkgs.libsForQt59.callPackage <nixpkgs/pkgs/tools/misc/qt5ct> {};
  };
}
