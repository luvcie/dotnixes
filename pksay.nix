{
  config,
  pkgs,
  ...
}: {
  system.activationScripts = {
    printMessage = ''
      phrases_file=${./egregore.txt}

      random_line=$(shuf -n 1 $phrases_file)

      ${pkgs.pokemonsay}/bin/pokemonsay "$random_line"
    '';
  };
}
