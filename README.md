# nixos-breadro

BreadRO deployment via NixOS

## Usage

### Test locally

```bash
HOST=breadro
rm -f $HOST.qcow2 && NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild build-vm --flake .#$HOST --impure
QEMU_NET_OPTS="hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80" ./result/bin/run-$HOST-vm
chromium --host-resolver-rules="MAP cs.$HOST.com 127.0.0.1" http://cs.$HOST.com:8080
```

### Deploy

```bash
$ nixos-rebuild --fast --use-remote-sudo --flake . --target-host <device ip> switch
```
