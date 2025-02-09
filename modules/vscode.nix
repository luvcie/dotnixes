{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-extensions; [
      ms-vsliveshare.vsliveshare
      vscodevim.vim
      xaver.clang-format
      continue.continue
      eg2.vscode-npm-script
      bbenoist.nix
      haskell.haskell
      ms-vscode.cpptools
      ms-dotnettools.csharp
      yoavbls.pretty-ts-errors
      yzhang.markdown-all-in-one
      shardulm94.trailing-spaces
      tomoki1207.pdf
      eamodio.gitlens
      usernamehw.errorlens
      streetsidesoftware.code-spell-checker
      esbenp.prettier-vscode
    ];

    userSettings = {
      "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.wordWrap" = "wordWrapColumn";
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = "active";
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "boundary";
      "git.confirmSync" = false;
      "git.autofetch" = true;
      "window.menuBarVisibility" = "toggle";
      "window.zoomLevel" = 1;
      "workbench.startupEditor" = "none";
      "explorer.confirmDelete" = false;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "[nix]" = {
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
      };
      "[markdown]" = {
        "editor.wordWrap" = "on";
        "editor.quickSuggestions" = {
          "comments" = "on";
          "strings" = "on";
          "other" = "on";
        };
      };
    };
  };
}
