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
    ./test-account.nix
    ./hesk.nix
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

  security.acme = {
    defaults.email = "breadro.com@outlook.com";
    acceptTerms = true;
    certs."_".domain = "breadro.com";
  };

  services ={
    openssh.enable = true;
    qemuGuest.enable = true;
    fail2ban.enable = true;
    nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedZstdSettings = true;
      recommendedProxySettings = true;
      virtualHosts = let
        https = host: host // {
          enableACME = true;
          forceSSL = true;
          kTLS = true;
        };
        http = host: host // {
          rejectSSL = true;
        };
      in {
        "_" = https {
          locations = {
            "/" = {
              return = "404";
            };
          };
        };
        "dl.breadro.com" = https {
          serverAliases = [
            "dl-cdn.breadro.com"
          ];
          locations = {
            "/" = {
              root = "/srv/dl";
              basicAuth = {
                breadro = "toastro";
              };
              extraConfig = ''
                autoindex on;
              '';
            };
          };
        };
      };
    };
    
    samba-wsdd = {
      enable = true;
      openFirewall = true;
      interface = "10.1.0.1";
    };
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "invalid users" = [
            "root"
          ];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          security = "user";
          workgroup = "WORKGROUP";
          "server string" = "breadro";
          "netbios name" = "breadro";
          # "use sendfile" = "yes";
          # "max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = [
            "10.1.0."
            "127.0.0.1"
            "localhost"
          ];
          "hosts deny" = [
            "0.0.0.0/0"
          ];
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        dl = {
          path = "/srv/dl";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force group" = "users";
          "acl allow execute always" = "yes";
        };
      };
    };
  };

  users.users = {
    excalibur = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "nginx"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNbARwJPNYn4MUPHvy7JRR7B+Yh2t50K7xUbMvdf58U1IPYOfDB818atx0MoJvvMro7H3NXateXMnFW6h111FkeTN4e6pLePIOCIyX20S9U6rq85T81ePTi9ied6SP6IEpyGEdWO73eiXbZAOj9VPnXOir3tvrKRNISz3mHp163NT7HMHRJjZ+9xCUhqPzw0VrKD3fTbrljdKk8Rfpd0wDvv2Nb6DA+nfvYME3w1ICU73Y4oP2x+Sx6epqr/FXk6vBsrKdyxPEALirCtct8LYYrt1KxTI2yfodr9kiOFgPIMwzuKPRixV2S15Eh5NwL5Hi6+RNQRXu82V8osSFUC0OypFplmTrY5yAHzDQB5DOYWlRG4KeKACd/tB2HMuW46qWIxngXYR2WSoAHFDdSuKj+fTsb21uQ+LvoQU6mnfUyYDokHuDPMi4iUlgFpcmyeNq1Dm7OD0LWLRbIdpJYgtd4aT9uT3XIQ8Ic8X/sZuNTv1jGLDhZMdV/awHtfDggtE= excalibur@yuntian"
      ];
    };
    bread = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "nginx"
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

  networking = {
    nftables.enable = true;
    firewall = {
      allowedUDPPorts = [
        51820 # WireGuard
      ];
      allowedTCPPorts = [
        80 # nginx
        443 # nginx
      ];
    };
    useNetworkd = true;
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.1.0.1/24" "fdbe::1/64" ];
        listenPort = 51820;
        mtu = 1280;
        privateKeyFile = "/var/lib/wireguard/wg0.key";
        peers = [
          {
            publicKey = "T8RsOpzg6HInLTcQA9uev95KPZohQ2GE7JZv84Q2QTk="; #Excalibur
            allowedIPs = [ 
              "10.1.0.2/32"
              "fdbe::2/128"
            ];
          }
          {
            publicKey = "LL+UbTvE6JbIFX8SCp9upjaKqZGnho6uSZ8bVQ41ZG8="; # Bread
            allowedIPs = [ 
              "10.1.0.3/32"
              "fdbe::3/128"
            ];
          }
          {
            publicKey = "5FmrArolI4v240v5MnMA7XmYXjSFDmIhtT3GmmxKwiY="; # BreadRO
            allowedIPs = [ 
              "10.1.0.4/32"
              "fdbe::4/128"
            ];
          }
        ];
      };
    };
  };

  systemd.network = {
    enable = true;
    config.networkConfig = {
      SpeedMeter = true;
    };
    networks = {
      "01-lo" = {
        matchConfig.Name = "lo";
        networkConfig = {
          LinkLocalAddressing = "ipv6";
          Address = "127.0.0.1/8";
        };
      };
      "50-ens5" = {
        matchConfig.Name = "ens5";
        networkConfig = {
          DHCP = "ipv4";
          LinkLocalAddressing = "ipv6";
          # Get IPv6 config from Debian: /usr/lib/systemd/system/networking.service
          Address = "2402:4e00:1420:1400:6c26:d174:a00e:0/128";
          Gateway = "fe80::feee:ffff:feff:ffff";
        };
      };
    };
  };

  time.timeZone = "Asia/Shanghai";
  system.stateVersion = "24.11";
}
