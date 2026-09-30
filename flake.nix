{
  description = "Clippy Pet: an unofficial animated paperclip pet for the ChatGPT desktop app and Codex CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      version = lib.removeSuffix "\n" (builtins.readFile ./VERSION);

      # Only the runtime payload enters the store; the ~19 MB of source frames
      # and QA evidence in this repository stay out of it.
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./VERSION
          ./pet.json
          ./spritesheet.webp
          ./LICENSE
          ./NOTICE.md
          ./packaging/bin/clippy-pet
          ./packaging/share/man/man1/clippy-pet.1
          ./packaging/share/applications/io.github.adammatthewsteinberger.clippy_pet.desktop
          ./packaging/share/metainfo/io.github.adammatthewsteinberger.clippy_pet.metainfo.xml
          ./packaging/share/icons/hicolor/256x256/apps/io.github.adammatthewsteinberger.clippy_pet.png
        ];
      };
    in
    {
      packages = forAllSystems (pkgs: {
        clippy-pet = pkgs.stdenvNoCC.mkDerivation {
          pname = "clippy-pet";
          inherit version src;

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            runHook preInstall
            install -Dm644 pet.json         $out/share/clippy-pet/pet.json
            install -Dm644 spritesheet.webp $out/share/clippy-pet/spritesheet.webp
            install -Dm644 NOTICE.md        $out/share/doc/clippy-pet/NOTICE.md
            install -Dm644 LICENSE          $out/share/licenses/clippy-pet/LICENSE
            install -Dm644 packaging/share/man/man1/clippy-pet.1 $out/share/man/man1/clippy-pet.1
            for f in \
              share/applications/io.github.adammatthewsteinberger.clippy_pet.desktop \
              share/metainfo/io.github.adammatthewsteinberger.clippy_pet.metainfo.xml \
              share/icons/hicolor/256x256/apps/io.github.adammatthewsteinberger.clippy_pet.png; do
              install -Dm644 "packaging/$f" "$out/$f"
            done
            sed -e "s/@VERSION@/${version}/" -e "s#@DATADIR@#$out/share/clippy-pet#" \
              packaging/bin/clippy-pet > clippy-pet
            install -Dm755 clippy-pet $out/bin/clippy-pet
            runHook postInstall
          '';

          meta = {
            description = "Unofficial animated paperclip pet for the ChatGPT desktop app and Codex CLI";
            longDescription = ''
              Clippy Pet is a Codex-compatible v2 pet: a pet.json manifest and a
              1536x2288 WebP sprite atlas with nine animations and sixteen look
              directions, plus a POSIX sh CLI that copies them into
              ''${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/. It is not affiliated
              with or endorsed by Microsoft or OpenAI.
            '';
            homepage = "https://adammatthewsteinberger.github.io/clippy-pet/";
            changelog = "https://github.com/adammatthewsteinberger/clippy-pet/blob/main/CHANGELOG.md";
            license = lib.licenses.mit;
            mainProgram = "clippy-pet";
            platforms = lib.platforms.unix;
          };
        };
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.clippy-pet;
      });

      # Declarative install: Home Manager places the two pet files in
      # <home>/<codexHome>/pets/clippy-pet/ as store-backed files it manages.
      homeManagerModules = rec {
        clippy-pet = { config, lib, pkgs, ... }:
          let cfg = config.programs.clippy-pet;
          in {
            options.programs.clippy-pet = {
              enable = lib.mkEnableOption "the Clippy Pet Codex pet";
              package = lib.mkOption {
                type = lib.types.package;
                default = self.packages.${pkgs.stdenv.hostPlatform.system}.clippy-pet;
                defaultText = lib.literalExpression "clippy-pet.packages.\${system}.clippy-pet";
                description = "The Clippy Pet package to install from.";
              };
              codexHome = lib.mkOption {
                type = lib.types.str;
                default = ".codex";
                example = ".config/codex";
                description = ''
                  Codex home directory, relative to your home directory. If you set
                  CODEX_HOME in your shell, set this to the same location: flakes
                  evaluate purely, so the module cannot read environment variables.
                '';
              };
              installCli = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Also put the clippy-pet CLI (status, path, version) on your PATH.";
              };
            };

            config = lib.mkIf cfg.enable {
              home.file."${cfg.codexHome}/pets/clippy-pet/pet.json".source =
                "${cfg.package}/share/clippy-pet/pet.json";
              home.file."${cfg.codexHome}/pets/clippy-pet/spritesheet.webp".source =
                "${cfg.package}/share/clippy-pet/spritesheet.webp";
              home.packages = lib.mkIf cfg.installCli [ cfg.package ];
            };
          };
        default = clippy-pet;
      };

      checks = forAllSystems (pkgs:
        let
          pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.clippy-pet;
          hmConfig = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              self.homeManagerModules.default
              {
                home = {
                  username = "tester";
                  homeDirectory = "/home/tester";
                  stateVersion = "26.05";
                };
                programs.clippy-pet.enable = true;
              }
            ];
          };
          # Every file Home Manager would place, as "<target> -> <source>".
          managedFiles = lib.concatMapStringsSep "\n"
            (f: "${f.target} -> ${f.source}")
            (lib.attrValues hmConfig.config.home.file);
        in
        {
          # The packaged CLI installs a byte-identical pet into a scratch CODEX_HOME.
          cli-install = pkgs.runCommand "clippy-pet-cli-install" { } ''
            export HOME=$TMPDIR/home CODEX_HOME=$TMPDIR/codex
            ${pkg}/bin/clippy-pet version | grep -qx "clippy-pet ${version}"
            ${pkg}/bin/clippy-pet install --quiet
            ${pkg}/bin/clippy-pet status
            cmp ${./pet.json}         $CODEX_HOME/pets/clippy-pet/pet.json
            cmp ${./spritesheet.webp} $CODEX_HOME/pets/clippy-pet/spritesheet.webp
            touch $out
          '';

          # The Home Manager module targets <home>/.codex/pets/clippy-pet/ by default.
          home-manager-module = pkgs.runCommand "clippy-pet-home-manager-module" {
            passAsFile = [ "managedFiles" ];
            inherit managedFiles;
          } ''
            grep -qxF ".codex/pets/clippy-pet/pet.json -> ${pkg}/share/clippy-pet/pet.json" "$managedFilesPath"
            grep -qxF ".codex/pets/clippy-pet/spritesheet.webp -> ${pkg}/share/clippy-pet/spritesheet.webp" "$managedFilesPath"
            cmp ${./spritesheet.webp} ${pkg}/share/clippy-pet/spritesheet.webp
            touch $out
          '';
        });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
