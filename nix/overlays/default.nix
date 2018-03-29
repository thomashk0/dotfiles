self: super:
{
  # Bump jabref to the last version
  # NOTE: needs a openjfx runtime dependency, not supported by Nix...
  jabref = super.jabref.overrideAttrs (old: rec {
    version = "4.1";
    name = "jabref-${version}";
    src =  super.fetchurl {
      url = "https://github.com/JabRef/jabref/releases/download/v${version}/JabRef-${version}.jar";
      sha256 = "1fad3c16lkm56y80rfxs33fws7vyd11iljzvcilcakh2vj81cxj8";
    };
    # NOTE: tiny fix of the path to jabref icon
    installPhase = ''
      mkdir -p $out/bin $out/share/java $out/share/icons

      cp -r ${old.desktopItem}/share/applications $out/share/

      jar xf $src icons/jabref.svg
      cp icons/jabref.svg $out/share/icons/jabref.svg
      ln -s $src $out/share/java/jabref-${version}.jar
      makeWrapper ${self.jre}/bin/java $out/bin/jabref \
        --add-flags "-jar $out/share/java/jabref-${version}.jar"
    '';
  });
}
