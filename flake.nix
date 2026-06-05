{
  description = "qmark: a local terminal question helper backed by Ollama";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f system nixpkgs.legacyPackages.${system}
        );
    in
    {
      packages = forAllSystems (system: pkgs:
        let
          qmark = pkgs.stdenvNoCC.mkDerivation {
            pname = "qmark";
            version = "0.1.0";
            src = self;

            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              install -Dm755 "$src/qmark" "$out/bin/qmark"
              runHook postInstall
            '';

            meta = {
              description = "A local terminal question helper backed by Ollama";
              homepage = "https://github.com/bwilson/qmark";
              license = pkgs.lib.licenses.mit;
              mainProgram = "qmark";
              platforms = systems;
            };
          };
        in
        {
          inherit qmark;
          default = qmark;
        });

      overlays.default = final: prev: {
        qmark = self.packages.${prev.system}.default;
      };

      apps = forAllSystems (system: pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/qmark";
        };
      });

      devShells = forAllSystems (system: pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.python3
            pkgs.ollama
          ];
        };
      });

      checks = forAllSystems (system: pkgs: {
        pycompile = pkgs.runCommand "qmark-pycompile" {
          nativeBuildInputs = [ pkgs.python3 ];
          src = self;
        } ''
          export PYTHONPYCACHEPREFIX="$TMPDIR/pycache"
          python -m py_compile "$src/qmark"
          touch "$out"
        '';
      });
    };
}
