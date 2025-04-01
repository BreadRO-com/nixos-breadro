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
      nixpkgs,
      disko,
      ...
    }: let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      hesk = pkgs.callPackage ./packages/hesk {};
    in {
      nixosConfigurations.breadro = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };
        modules = [ ./machines/breadro ];
      };
      packages."${system}" = {
        default = hesk;
        hesk = hesk;
      };
    };
}
