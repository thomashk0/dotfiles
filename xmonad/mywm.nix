{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, ansi-wl-pprint, base, containers, stdenv
      , xmonad, xmonad-contrib
      }:
      mkDerivation {
        pname = "mywm";
        version = "0.2.7.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        postInstall = ''
          mkdir -p $out/share/applications
          substituteAll ${./mywm.desktop} $out/share/applications/mywm.desktop
        '';
        executableHaskellDepends = [
          ansi-wl-pprint base containers xmonad xmonad-contrib
        ];
        homepage = "http://github.com/thomashk0/tree/master/dotfiles/xmonad/README.md";
        description = "A simple XMonad configuration";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
