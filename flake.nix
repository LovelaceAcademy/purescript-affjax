{
  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      purs-nix.url = "github:LovelaceAcademy/purs-nix";
      utils.url = "github:ursi/flake-utils";
      npmlock2nix.url = "github:nix-community/npmlock2nix";
      npmlock2nix.flake = false;
    };

  outputs = { utils, npmlock2nix, ... }@inputs:
    utils.apply-systems
      {
        inherit inputs;
        # restricted by npmlock2nix, see nix-community/npmlock2nix#159
        systems = [ "x86_64-linux" ];
        overlays = [
          (final: prev:
            { npmlock2nix = import npmlock2nix { pkgs = prev; }; }
          )
        ];
      }
      ({ purs-nix, pkgs, ... }:
        let
          node_modules = pkgs.npmlock2nix.node_modules
            {
              src = ./.;
            } + /node_modules;
          package =
            with purs-nix.ps-pkgs;
            {
              version = "12.0.0";
              dependencies =
                [
                  aff
                  argonaut-core
                  arraybuffer-types
                  foreign
                  form-urlencoded
                  http-methods
                  integers
                  math
                  media-types
                  nullable
                  refs
                  unsafe-coerce
                  web-xhr
                ];
              foreign."Affjax" = { inherit node_modules; };
            };
        in
        {
          packages.default =
            purs-nix.build
              {
                name = "lovelaceAcademy.affjax";
                src.path = ./.;
                info = package;
              };
        }
      );
}
