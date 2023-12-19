{
  inputs = {
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          devenv-up = self.devShells.${system}.default.config.procfileScript;
        };

        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              pre-commit = {

                hooks = {
                  checkmake.enable = true;
                  markdownlint.enable = true;
                  nixpkgs-fmt.enable = true;
                  yamllint.enable = true;


                };

                settings = {
                  yamllint.relaxed = true;
                };
              };
              # https://devenv.sh/reference/options/
              packages = with pkgs;[
                gnumake
                tectonic
              ];
            }
          ];
        };
      });
}

