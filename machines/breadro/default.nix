{
  modulesPath,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernel.sysctl = {
      "kernel.dmesg_restrict" = 1;
    };
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  environment.enableAllTerminfo = true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  services ={
    openssh.enable = true;
    qemuGuest.enable = true;
  };

  users.users = {
    excalibur = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNbARwJPNYn4MUPHvy7JRR7B+Yh2t50K7xUbMvdf58U1IPYOfDB818atx0MoJvvMro7H3NXateXMnFW6h111FkeTN4e6pLePIOCIyX20S9U6rq85T81ePTi9ied6SP6IEpyGEdWO73eiXbZAOj9VPnXOir3tvrKRNISz3mHp163NT7HMHRJjZ+9xCUhqPzw0VrKD3fTbrljdKk8Rfpd0wDvv2Nb6DA+nfvYME3w1ICU73Y4oP2x+Sx6epqr/FXk6vBsrKdyxPEALirCtct8LYYrt1KxTI2yfodr9kiOFgPIMwzuKPRixV2S15Eh5NwL5Hi6+RNQRXu82V8osSFUC0OypFplmTrY5yAHzDQB5DOYWlRG4KeKACd/tB2HMuW46qWIxngXYR2WSoAHFDdSuKj+fTsb21uQ+LvoQU6mnfUyYDokHuDPMi4iUlgFpcmyeNq1Dm7OD0LWLRbIdpJYgtd4aT9uT3XIQ8Ic8X/sZuNTv1jGLDhZMdV/awHtfDggtE= excalibur@yuntian"
      ];
    };
  };

  networking = {
    hostName = "breadro";
  };

  nix = {
    gc = {
      automatic = true;
      persistent = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = lib.mkBefore [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      http2 = false;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  system.stateVersion = "24.11";
}
