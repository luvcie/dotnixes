{
  pkgs,
  lib,
  config,
  ...
}: let
  homepageDir = "${config.home.homeDirectory}/homepage";
  configDir = "${homepageDir}/config";
  imagesDir = "${homepageDir}/images";
in {
  # minimalist settings
  home.file."${configDir}/settings.yaml".text = ''
    title: luvcie lab
    theme: dark
    background:
      image: /images/bg.png
      opacity: 100
      brightness: 100
    layout:
      Services:
        style: row
        columns: 2
      Infrastructure:
        style: row
        columns: 4
      Development:
        style: row
        columns: 4
      Social:
        style: row
        columns: 4
      Logging:
        style: row
        columns: 4
      Entertainment:
        style: row
        columns: 4
  '';

  # services template to inject the proxmox token
  sops.templates."services.yaml" = {
    path = "${configDir}/services.yaml";
    content = ''
      - Services:
          - Copyparty:
              icon: copyparty.png
              href: https://files.luvcie.love
              description: file stash
          - Plex:
              icon: plex.png
              href: https://plex.luvcie.love
              description: media server
      - Infrastructure:
          - Portainer:
              icon: portainer.png
              href: http://proxmox-lab.tail5296cb.ts.net:9000
              description: container management
          - Yggdrasil:
              icon: /images/yggdrasil.png
              href: "http://[21e:e795:8e82:a9e2:ff48:952d:55f2:f0bb]/"
              description: network map
          - i2pd:
              icon: i2pd.png
              href: http://proxmox-lab.tail5296cb.ts.net:7070
              description: i2p router console
          - Proxmox:
              icon: proxmox.png
              href: https://proxmox-lab.tail5296cb.ts.net:8006
              description: hypervisor
          - Sunshine:
              icon: /images/sunshine.png
              href: https://proxmox-lab.tail5296cb.ts.net:47990
              description: game streaming
    '';
  };

  # bookmarks with custom abbreviations
  home.file."${configDir}/bookmarks.yaml".text = ''
    - development:
        - github:
            - icon: github.png
              href: https://github.com
        - gitlab:
            - icon: gitlab.png
              href: https://gitlab.com
        - codeberg:
            - icon: codeberg.png
              href: https://codeberg.org
        - exploit-db:
            - abbr: EDB
              href: https://exploit-db.com
        - tailscale:
            - icon: tailscale.png
              href: https://login.tailscale.com/admin/machines
    - social:
        - uboachan:
            - abbr: UB
              href: https://uboachan.net
        - lainchan:
            - abbr: LC
              href: https://lainchan.org
        - mastodon:
            - icon: mastodon.png
              href: https://mastodon.social
        - bluesky:
            - icon: bluesky.png
              href: https://bsky.app
    - logging:
        - letterboxd:
            - abbr: LB
              href: https://letterboxd.com
        - anilist:
            - abbr: AL
              href: https://anilist.co
        - vndb:
            - abbr: VN
              href: https://vndb.org
        - hardcover:
            - abbr: HC
              href: https://hardcover.app
    - entertainment:
        - youtube:
            - icon: youtube.png
              href: https://youtube.com
        - yume 2kki:
            - abbr: 2K
              href: https://ynoproject.net/2kki/
        - tetr.io:
            - abbr: TR
              href: https://tetr.io
        - jstris:
            - abbr: JS
              href: https://jstris.jezevec10.com/
  '';

  home.file."homepage/images/sunshine.png".source = pkgs.fetchurl {
    url = "https://docs.lizardbyte.dev/projects/sunshine/latest/sunshine.png";
    sha256 = "115n80fx5q7wgvqj8rzhz4h8l81b149d2ixqnc0ir9rvnzxjcack";
  };

  # generate a solid color pixel to force the background color natively
  home.file."homepage/images/bg.png".source = pkgs.runCommand "bg.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    convert -size 1x1 xc:"#09090b" $out
  '';

  # widgets with back-to-portfolio link
  home.file."${configDir}/widgets.yaml" = {
    force = true;
    text = ''
      - logo:
          href: https://test.luvcie.love
      - datetime:
          text_size: xl
          format:
            hour: numeric
            minute: numeric
            timeZoneName: short
            timeZone: Europe/Paris
          locale: fr-FR
      - datetime:
          text_size: xl
          format:
            hour: numeric
            minute: numeric
            timeZoneName: short
            timeZone: America/Chicago
          locale: en-US
      - resources:
          cpu: true
          memory: true
          disk: /
      - openmeteo:
          label: Paris
          latitude: 48.8566
          longitude: 2.3522
          units: metric
          cache: 15
      - search:
          provider: duckduckgo
          target: _blank
    '';
  };

  # style the logo widget as a back button
  home.file."${configDir}/custom.css" = {
    force = true;
    text = ''
      .information-widget-logo.widget-container {
        padding: 0.4rem 0.8rem !important;
        border: 1px solid rgba(63, 63, 70, 0.5) !important;
        border-radius: 0.5rem !important;
        transition: border-color 0.2s !important;
      }
      .information-widget-logo.widget-container:hover {
        border-color: rgba(236, 72, 153, 0.3) !important;
      }
      .information-widget-logo.widget-container > * {
        display: none !important;
      }
      .information-widget-logo.widget-container::before {
        content: "\2190  portfolio";
        font-size: 0.75rem;
        font-family: monospace;
        color: #a1a1aa;
        letter-spacing: 0.05em;
      }
      .information-widget-logo.widget-container:hover::before {
        color: #ec4899;
      }
    '';
  };

  home.file."${configDir}/custom.js" = {
    force = true;
    text = "";
  };

  # systemd service for homepage
  systemd.user.services.homepage = {
    Unit = {
      Description = "homepage dashboard container";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop homepage"
        "-${pkgs.podman}/bin/podman rm homepage"
      ];
      # added host-gateway to allow isolated container to reach host services safely
      ExecStart = "${pkgs.podman}/bin/podman run --name homepage -p 3000:3000 " +
        "--add-host host.containers.internal:host-gateway " +
        "-v /nix/store:/nix/store:ro " +
        "-v ${config.xdg.configHome}/sops-nix/secrets/rendered/services.yaml:/app/config/services.yaml:ro " +
        "-v ${configDir}:/app/config:Z " +
        "-v ${homepageDir}/images:/app/public/images:Z " +
        "-e HOMEPAGE_ALLOWED_HOSTS=home.luvcie.love " +
        "ghcr.io/gethomepage/homepage:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop homepage";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}