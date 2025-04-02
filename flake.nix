{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      disko,
      ...
    }: let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      hesk = pkgs.callPackage ./packages/hesk {};
    in {
      nixosConfigurations.breadro = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system pkgs; };
        modules = [ ./machines/breadro ];
      };
      packages."${system}" = {
        default = hesk;
        hesk = hesk;
        hesk-zh_cmn_hans = pkgs.callPackage ./packages/hesk-zh_cmn_hans {};
      };
    };
}
