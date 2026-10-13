{
  description = "xgammon — classic X11 backgammon, packaged for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
            }
          )
        );
    in
    {
      # `nix build` / `nix build .#xgammon`
      packages = forAllSystems (pkgs: {
        default = import ./package.nix { inherit pkgs; };
        xgammon = import ./package.nix { inherit pkgs; };
      });

      # `nix run github:USER/xgammon-nix`
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/xgammon";
        };
      });

      # `imports = [ inputs.xgammon.nixosModules.default ];`
      nixosModules.default = import ./xgammon.nix;

      # `nixpkgs.overlays = [ inputs.xgammon.overlays.default ];`
      overlays.default = final: _prev: {
        xgammon = import ./package.nix { pkgs = final; };
      };

      # Exposed so CI and users can `nix flake check`
      checks = forAllSystems (pkgs: {
        default = import ./package.nix { inherit pkgs; };
      });
    };
}
