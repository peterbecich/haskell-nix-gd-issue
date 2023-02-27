{
  # This is a template created by `hix init`
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
      flake-utils.lib.eachSystem supportedSystems (system:
      let
        overlays = [ haskellNix.overlay
          (final: prev: {
            hixProject =
              final.haskell-nix.hix.project {
                src = ./.;
                evalSystem = "x86_64-linux";
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.hixProject.flake {};
      in flake // {
        legacyPackages = pkgs;

        packages.default = flake.packages."hello:exe:hello";

        devShells.default = pkgs.hixProject.shellFor {

          # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          buildInputs = with pkgs; [

            pkg-config
            # these appear to be dependencies of
            # https://hackage.haskell.org/package/gd-3000.7.3

            gd

            brotli
            unzip
            openssl
            zlib
            libjpeg
            libffi
            libpng
            libtiff
            freetype
            expat
            fontconfig

            libwebp
            bzip2_1_1
            libavif
            libheif
            libvmaf
            xorg.libXpm
            libimagequant
            autoconf
            automake

            xz
            lzlib
            xml2
            libdeflate
            libaom
            libjxl
            libyuv
            dav1d
            libvmaf

          ];


          packages = ps: with ps; [ ];
          tools = {
            cabal = "latest";
          };
        };
      });

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    allow-import-from-derivation = "true";
  };
}
