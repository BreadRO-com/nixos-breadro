# nixos-breadro

BreadRO deployment via NixOS

## Usage

```bash
$ nixos-rebuild --fast --use-remote-sudo --flake . --target-host <device ip> switch
```