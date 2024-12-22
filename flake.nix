{
  description = "nullreff's Nixos system & home manager config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      system = "x86_64-linux";

      pkgs = import inputs.nixpkgs {
        inherit overlays system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations = pkgs.mkHomeConfigurations { };
      nixosConfigurations = pkgs.mkNixosConfigurations { };

      out = { inherit pkgs overlays; };

      packages.${system} = {
        inherit (pkgs) bazecor metals metals-updater;
      };
    };
}
