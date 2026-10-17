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
      name = "ClassicGleepStreamlined";
	  # ClassicPlatinumStreamlined | ClassicGleepStreamlined
	  # ClassicYorhaStreamlined | ClassicCherryStreamlined
    };
    iconTheme = {
      name = "RetroismIcons";
    };
    gtk4.theme = config.gtk.theme;
  };

  xdg.configFile."gtk-4.0/settings.ini".force = true;

  qt = {
    enable = true;
    # gtk2 platform pulls qt6Packages.qt6gtk2, removed upstream (relies on gtk2)
    platformTheme.name = "gtk3";
    style = {
      name = "Dracula";
      package = pkgs.dracula-qt5-theme;
    };
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
    gtk.enable = true;
    x11.enable = false;
  };
}
