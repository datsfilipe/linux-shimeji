{
  description = "Linux Shimeji - Desktop mascot application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; }; 
        
        defaultShimejis = {
          "little-ghost" = {
            archive = ./hk-imgs/little-ghost.zip;
            license = ./hk-imgs/originallicense.txt;
          };
          "little-ghost-polite" = {
            archive = ./hk-imgs/little-ghost-polite.zip;
            license = ./hk-imgs/licence.txt;
          };
        };
        
        mkShimeji = { variant ? null }: pkgs.stdenv.mkDerivation {
          pname = "linux-shimeji";
          version = "2.2.2";
          
          src = ./.;
          
          nativeBuildInputs = with pkgs; [ 
            ant 
            makeWrapper
            openjdk8-bootstrap
            unzip
          ];
          
          buildInputs = with pkgs; [
            xorg.libX11
            xorg.libXrender
            openjdk8-bootstrap
            coreutils
          ];

          buildPhase = ''
            mkdir -p classes
            mkdir -p $out/share/shimeji/img
            cp -r img/* $out/share/shimeji/img/
            ant -Dant.build.javac.source=1.8 -Dant.build.javac.target=1.8 jar

            ${if variant != null then ''
              mkdir -p shimeji-extract
              cd shimeji-extract
              ${pkgs.unzip}/bin/unzip ${defaultShimejis.${variant}.archive}
              find . -type f -name "*.png" -exec install -D {} $out/share/shimeji/img/{} \;
              cp ${defaultShimejis.${variant}.license} $out/share/shimeji/img/
              cd ..
            '' else ""}
          '';
          
          installPhase = ''
            mkdir -p $out/{bin,lib,share/shimeji}
            cp Shimeji.jar $out/lib/
            cp -r lib $out/lib/
            cp -r conf $out/share/shimeji/
            ${if variant == null then "mkdir -p $out/share/shimeji/img" else ""}

            makeWrapper ${pkgs.openjdk8-bootstrap}/bin/java $out/bin/shimeji \
              --add-flags "-Djava.util.logging.config.file=$out/share/shimeji/conf/logging.properties" \
              --add-flags "-Xmx1000m" \
              --add-flags "-classpath" \
              --add-flags "$out/lib/Shimeji.jar:$out/lib/lib/*:$out/share/shimeji/conf:$out/share/shimeji/img" \
              --add-flags "com.group_finity.mascot.Main" \
              --set CLASSPATH "$out/lib/Shimeji.jar:$out/lib/lib/*" \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
                pkgs.xorg.libX11
                pkgs.xorg.libXrender
                pkgs.openjdk8-bootstrap
                "${pkgs.openjdk8-bootstrap}/lib/openjdk/jre/lib/${pkgs.stdenv.hostPlatform.linuxArch}"
                "${pkgs.openjdk8-bootstrap}/lib/openjdk/jre/lib/${pkgs.stdenv.hostPlatform.linuxArch}/server"
              ]}" \
              --run "cd $out/share/shimeji"
          '';
          
          meta = with pkgs.lib; {
            description = "This is a Linux version of the popular desktop mascot program, Shimeji";
            homepage = "https://github.com/datsfilipe/linux-shimeji";
            license = [ licenses.mit licenses.zlib ];
            maintainers = with maintainers; [ "datsfilipe <datsfilipe.foss@proton.me>" ];
            platforms = platforms.linux;
          };
        };
      in {
        packages = {
          default = mkShimeji {};
          little-ghost = mkShimeji { variant = "little-ghost"; };
          little-ghost-polite = mkShimeji { variant = "little-ghost-polite"; };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            openjdk8-bootstrap
            ant
          ];
          
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.xorg.libX11
            pkgs.xorg.libXrender
            pkgs.openjdk8-bootstrap
          ];
        };
      }
    );
}
