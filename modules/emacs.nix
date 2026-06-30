{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk; # wayland-native (pure-GTK) build
  };

  # for doom: search deps (`doom doctor` wants these) + the `doom` cli on PATH
  home.packages = with pkgs; [ripgrep fd];
  home.sessionPath = ["$HOME/.config/emacs/bin"];
}
