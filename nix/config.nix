let
  # Most common packages for developpement
  baseDevel = pkgs: with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.fr
    cmake
    gnumake
    ninja
    gcc
    gdb
    binutils
    nasm
    openjdk
    git
    gitAndTools.qgit
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
    vlc
  ];
in
{
  packageOverrides = pkgs: with pkgs; rec {
    commonPkgs = buildEnv {
      name = "commonPkgs";
      paths = baseDevel pkgs ++ desktopPkgs pkgs;
      meta = {
        description = "Common packages for desktop usage";
      };
    };

  };
}
