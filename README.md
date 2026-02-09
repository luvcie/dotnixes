# NixOS Configuration

My NixOS configuration files.

```
            lucie@T495
            OS NixOS
   (\ /)    Kernel 6.12.55
   ( . .)   Shell zsh
   c(")(")  WM wlroots wm
```
---

## NH - Nix Helper

**nh** is a Nix helper tool that provides prettier output, automatic garbage collection, and better UX than raw nix commands.

### Most Common Commands

Rebuild home configuration:
```bash
nh home switch .
```

Rebuild system configuration:
```bash
nh os switch
```

Update flake inputs and rebuild:
```bash
nh home switch . --update
```

Clean old generations and garbage collect:
```bash
nh clean all
```

Search for packages:
```bash
nh search <package-name>
```

---

## Quick Start (Traditional Commands)

Apply system configuration:
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

Apply user configuration:
```bash
home-manager switch --flake .#<user>
```

## Configuration Structure

- `configuration.nix` - System-wide NixOS configuration
- `home.nix` - User-specific home-manager configuration
- `flake.nix` - Flake definition with inputs and outputs
- `hardware-configuration.nix` - Hardware-specific settings
- `modules/` - Modular configuration components

## System Administration

### System Updates & Maintenance

Update flake inputs:
```bash
nix flake update
```

Rebuild and switch system configuration:
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

Test configuration without switching:
```bash
sudo nixos-rebuild test --flake .#<hostname>
```

Rebuild configuration without switching (bootable):
```bash
sudo nixos-rebuild boot --flake .#<hostname>
```

List system generations:
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Rollback to previous generation:
```bash
sudo nixos-rebuild switch --rollback
```

### Garbage Collection & Storage

System-wide garbage collection:
```bash
sudo nix-collect-garbage -d
```

User garbage collection:
```bash
nix-collect-garbage -d
```

Delete generations older than 30 days:
```bash
sudo nix-collect-garbage --delete-older-than 30d
```

Optimize nix store:
```bash
sudo nix-store --optimize
```

Check disk usage:
```bash
nix path-info -Sh /run/current-system
```

### Package Management

Search for packages:
```bash
nix search nixpkgs <package-name>
```

Install package temporarily:
```bash
nix shell nixpkgs#<package-name>
```

Run package without installing:
```bash
nix run nixpkgs#<package-name>
```

Check package dependencies:
```bash
nix-store --query --references /run/current-system
```

### Home Manager

Switch home configuration:
```bash
home-manager switch --flake .#<user>
```

List home generations:
```bash
home-manager generations
```

Check home-manager news:
```bash
home-manager news --flake .#<user>
```

Rollback home configuration:
```bash
home-manager switch --rollback
```

### Development & Debugging

Enter development shell:
```bash
nix develop
```

Check flake configuration:
```bash
nix flake check
```

Show flake metadata:
```bash
nix flake metadata
```

Debug build issues:
```bash
nix log /nix/store/<derivation-path>
```

Show package information:
```bash
nix show-derivation nixpkgs#<package-name>
```

### System Information

Show current system closure size:
```bash
nix path-info -Sh /run/current-system
```

List all installed packages:
```bash
nix-env -qa
```

Check service status:
```bash
systemctl status <service-name>
```

View system logs:
```bash
journalctl -u <service-name>
```

## Git Workflow

Stage and commit changes:
```bash
git add .
git commit -m "description of changes"
```

Amend last commit:
```bash
git commit --amend
```

Reset to last commit:
```bash
git reset --hard
```

Reset to previous commit:
```bash
git reset --hard HEAD~1
```

Stash uncommitted changes:
```bash
git stash
```

Restore specific file:
```bash
git restore <file>
```

## Running External Binaries

NixOS cannot run dynamically linked executables intended for generic Linux environments out of the box. This configuration includes `nix-ld` to provide compatibility.

### Basic External Binaries

Most external binaries should work automatically with nix-ld enabled:
```bash
./some-external-binary
```

### Adding Libraries for Complex Binaries

Configure additional libraries in system configuration:
```nix
programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    curl
    zlib
    # Add other libraries as needed
  ];
};
```

### Using nix-alien for Complex Cases

For binaries requiring more complex setup:
```bash
# Install nix-alien
nix shell nixpkgs#nix-alien

# Run external binary through nix-alien
nix-alien ./external-binary
```

### FHS Environment for Standard Linux Software

Create temporary standard Linux filesystem environment:
```bash
nix shell --impure nixpkgs#fhs --command bash
# Run your binary inside this environment
```

## Additional Commands

Launch Steam games with GameMode:
```bash
gamemoderun %command%
```

---

## Lab Services

### i2pd
i2p router in rootless podman with `--network=host`.

- web console: `http://proxmox-lab.tail5296cb.ts.net:7070`
- http proxy: `proxmox-lab.tail5296cb.ts.net:4444`
- socks proxy: `proxmox-lab.tail5296cb.ts.net:4447`
- sam bridge: `proxmox-lab.tail5296cb.ts.net:7656`
- i2pcontrol api: `https://127.0.0.1:7650` (localhost only)
- p2p port: `31000` (tcp/udp, forwarded on the router)
- config: `modules/i2pd.nix`
- data: `~/i2pd/`

#### browsing .i2p sites in firefox
in `about:config` set these:
- `network.proxy.allow_hijacking_localhost` to `true`
- `keyword.enabled` to `false`
- `network.dns.blockDotOnion` to `false`

then in firefox settings, network settings, manual proxy configuration:
- http proxy: `proxmox-lab.tail5296cb.ts.net`, port `4444`
- check "also use this proxy for HTTPS"
- check "proxy DNS when using SOCKS v5"


#### i2pcontrol api
for monitoring/automation, default password is `itoopie`, change it before using.

```bash
# get a token
curl -sk -X POST https://127.0.0.1:7650 \
  -d '{"id":1,"jsonrpc":"2.0","method":"Authenticate","params":{"API":1,"Password":"itoopie"},"Token":""}'

# query router info (use the token from above)
curl -sk -X POST https://127.0.0.1:7650 \
  -d '{"id":2,"jsonrpc":"2.0","method":"RouterInfo","params":{
    "i2p.router.status":"",
    "i2p.router.net.status":"",
    "i2p.router.net.tunnels.participating":"",
    "i2p.router.netdb.knownpeers":"",
    "i2p.router.uptime":"",
    "i2p.router.net.bw.inbound.1s":"",
    "i2p.router.net.bw.outbound.1s":""
  },"Token":"<TOKEN>"}'
```

methods: `Authenticate`, `RouterInfo`, `RouterManager`, `NetworkSetting`.

#### torrents (biglybt etc)
1. enable i2p support in the client
2. set i2p router host to `proxmox-lab.tail5296cb.ts.net`
3. set sam port to `7656`

#### networking stuff
- `--network=host` because pasta caused i2pd to report symmetric NAT
- i2pd auto-detects external ip through peer testing
- port 31000 forwarded on the router (NAT/PAT) and allowed through ufw

### proxmox
secure hypervisor access via tailscale.
- url: `https://proxmox-lab.tail5296cb.ts.net:8006`
- certs: automated via tailscale-certs + proxmox-cert-sync

### copyparty
file server with sops-managed accounts.
- url: `https://files.luvcie.love`
- edit passwords: `sops vault/encrypted-sops-secrets.yaml`
