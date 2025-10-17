# NixOS Configuration

My NixOS configuration files.

```
                         .       .
                        / `.   .' \
                .---.  <    > <    >  .---.
                |    \  \ - ~ ~ - /  /    |
                 ~-..-~             ~-..-~
            \~~~\.'                    `./~~~/
  .-~~^-.    \__/                        \__/
.'  O    \     /               /       \  \
(_____,    `._.'               |         }  \/~~~/
`----.          /       }     |        /    \__/
      `-.      |       /      |       /      `. ,~~|
          ~-.__|      /_ - ~ ^|      /- _      `..-'   f: f:
               |     /        |     /     ~-.     `-. _||_||_
               |_____|        |_____|         ~ - . _ _ _ _ _>
```

---

## Quick Start

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

## Additional Commands

Launch Steam games with GameMode:
```bash
gamemoderun %command%
```