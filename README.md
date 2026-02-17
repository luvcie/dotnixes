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

### yggdrasil
encrypted ipv6 mesh network (200::/7) in rootless podman with a socks5 proxy sidecar.

- config: `modules/yggdrasil.nix`
- private key: sops-managed (`yggdrasil_private_key` in vault)
- container images: nix-built (official docker image stuck on 0.4.2)
- socks proxy: `proxmox-lab.tail5296cb.ts.net:1080`

#### browsing yggdrasil sites in a browser
in browser proxy settings, set **only** the socks host:
- socks host: `proxmox-lab.tail5296cb.ts.net`, port `1080`, socks v5
- check "proxy DNS when using SOCKS v5"
- leave http/ssl/ftp proxy fields **empty**

site directory and service list: https://yggdrasil-network.github.io/services.html

#### managing the service
```bash
# check status
systemctl --user status yggdrasil
systemctl --user status yggdrasil-proxy

# restart
systemctl --user restart yggdrasil
```

### proxmox
secure hypervisor access via tailscale.
- url: `https://proxmox-lab.tail5296cb.ts.net:8006`
- certs: automated via tailscale-certs + proxmox-cert-sync

### funkwhale
federated music server (ActivityPub). shares libraries with friends.
- url: `https://funkwhale.luvcie.love`
- config: `modules/funkwhale.nix`
- data: `~/funkwhale/data/`
- music mount: `/mnt/media/music` (read-only, same as navidrome)

#### admin
```bash
# create admin account
podman exec -it funkwhale manage createsuperuser
```

#### importing music
funkwhale does not auto-scan, must import manually via the container shell.

1. create a library in the web ui (your profile > libraries)
2. copy the library UUID from the url
3. run the import:
```bash
podman exec funkwhale sh -c "manage import_files <library-uuid> /music --recursive --in-place --noinput" 2>/dev/null
```
`2>/dev/null` hides django deprecation warnings.

### caddy (TLS reverse proxy)
caddy terminates TLS for internal services using tailscale certs. currently proxies CouchDB.

- https endpoint: `https://proxmox-lab.tail5296cb.ts.net:5443`
- config: `modules/caddy.nix`
- data: `~/caddy/data/`
- image: `docker.io/library/caddy:2`
- certs: tailscale certs from `~/.tailscale-certs/` (auto-renewed daily by tailscale-certs service)

#### managing the service
```bash
systemctl --user status caddy
systemctl --user restart caddy
curl -k https://proxmox-lab.tail5296cb.ts.net:5443/
```

### couchdb (obsidian livesync)
self-hosted CouchDB for real-time obsidian vault sync via the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin. tailscale-only, behind caddy for TLS.

- url: `https://proxmox-lab.tail5296cb.ts.net:5443`
- fauxton dashboard: `https://proxmox-lab.tail5296cb.ts.net:5443/_utils`
- local (no TLS): `http://localhost:5984`
- config: `modules/couchdb.nix`
- data: `~/couchdb/data/`
- credentials: sops-managed (`couchdb_username`, `couchdb_password`)
- image: `docker.io/library/couchdb:3`

#### obsidian plugin setup (new device)

**important**: set up one device at a time. the first device creates the database and encryption salt, the second device must pull from it, not create its own.

1. install [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) from community plugins
2. open the plugin settings and configure the remote:
   - URI: `https://proxmox-lab.tail5296cb.ts.net:5443`
   - username/password: from sops vault (`sops vault/encrypted-sops-secrets.yaml`)
   - database name: use the same name on all devices (e.g. `obsidianlucy`)
   - encryption passphrase: use the same passphrase on all devices
3. set sync mode to **LiveSync** under "Sync Settings"
4. **for the first device**: just enable — it will create the database and push
5. **for additional devices**: after entering the same settings, use **"Rebuild everything → Fetch from Remote"** to pull existing data. this ensures the device picks up the existing PBKDF2 salt instead of generating a new one
6. **AFTER EVERY SETUP OR REBUILD: GO TO SYNC SETTINGS AND SET THE SYNC MODE TO "LIVESYNC".** it resets to on-demand/periodic after rebuilds and will NOT sync in real-time until you change it back, do this on every device.

**do NOT run the "Self-hosted LiveSync config doctor" on a new device.** the doctor changes settings (chunk size, case sensitivity, etc.) and then prompts you to overwrite the server with the current device's data. on a new/empty device this wipes the remote database clean and breaks sync for all other devices. only use the doctor on your primary device if you know what each setting does.

#### troubleshooting sync

- **nothing syncs**: check that the sync mode is set to LiveSync (not periodic/on-demand). the plugin doesn't auto-start syncing after initial setup
- **`Decryption with HKDF failed`**: the encryption salt doesn't match between devices. this happens when both devices were set up independently. fix: disable plugin on all devices, nuke the remote db (`curl -sk -X DELETE https://proxmox-lab.tail5296cb.ts.net:5443/obsidianlucy -u user:pass`), then set up from scratch — first device pushes, second device fetches
- **`Load failed` on specific notes**: stale data in the local IndexedDB cache from a previous broken setup. use "Rebuild: Fetch everything from remote" to fix
- **404 errors in dev console**: normal. PouchDB checks for checkpoint documents that don't exist yet on a fresh setup. the plugin logs `The above 404 is totally normal` right after
- **dev console access**: desktop `Ctrl+Shift+I` / mac `Cmd+Option+I`
- the device must be on **tailscale** to reach the server

#### managing the service
```bash
systemctl --user status couchdb
systemctl --user restart couchdb
curl -u user:pass http://localhost:5984/
```

#### known issues (if modifying `modules/couchdb.nix`)
- **no `:ro` on ini mounts**: the couchdb entrypoint runs `chmod`/`chown` on everything under `/opt/couchdb/etc/` with `set -e` — a read-only mount causes a silent exit 1 with zero logs
- **`[admins]` section format**: the entrypoint greps for `\[admins\]\n[^;]\w+` — the admin username **must** be on the very next line after `[admins]`, no blank lines allowed
- **put credentials in the ini, not env vars**: `COUCHDB_USER`/`COUCHDB_PASSWORD` env vars are processed by the entrypoint, but `require_valid_user = true` in a custom ini triggers CouchDB's preflight check *before* the entrypoint injects the admin. define them under `[admins]` in the ini instead
- **sops template permissions**: sops-nix renders templates as `0400` by default. couchdb runs as a non-root user inside the container. use `mode = "0444"` on the template
- **debugging silent crashes**: override entrypoint with `bash -c 'bash -x /docker-entrypoint.sh /opt/couchdb/bin/couchdb'` to trace

### copyparty
file server with sops-managed accounts.
- url: `https://files.luvcie.love`
- edit passwords: `sops vault/encrypted-sops-secrets.yaml`
