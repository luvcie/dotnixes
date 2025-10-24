{
  pkgs,
  config,
  ...
}: {
  gtk = {
    enable = true;
    font = {
      name = "Sans";
      size = 11;
    };
    theme = {
      name = "ClassicPlatinumStreamlined";
    };
    iconTheme = {
      name = "RetroismIcons";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "Dracula";
      package = pkgs.dracula-qt5-theme;
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
    gtk.enable = true;
    x11.enable = false;
  };
}
