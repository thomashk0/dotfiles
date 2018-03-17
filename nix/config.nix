{
    packageOverrides = pkgs: with pkgs; rec {
      commonPkgs = buildEnv {
        name = "commonPkgs";
        meta = {
          description = "Common packages for desktop usage";
        };
        paths = [
          cmake
          libreoffice
          gcc
          openjdk
          python36
          python36Packages.pip
          python36Packages.virtualenv
          nix-prefetch-scripts
          nix-repl
        ];
      };
    };
}
