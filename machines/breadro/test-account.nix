{ options
, lib
, ...}:
lib.mkIf (options ? virtualisation.memorySize) {
  users.users = {
    nixos = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      password = "nixos";
    };
  };
}
