{
  # parse json files with // comment support
  fromJsonFile = filepath: let
    fileContent = builtins.readFile filepath;
    lines = builtins.split "\n" fileContent;
    filterComments = line:
      if builtins.isString line
      then let
        trimmed = builtins.replaceStrings [" " "\t"] ["" ""] line;
      in !(builtins.match "//.*" trimmed != null)
      else true;
    filteredLines = builtins.filter filterComments lines;
    cleanContent = builtins.concatStringsSep "\n" (builtins.filter builtins.isString filteredLines);
  in
    builtins.fromJSON cleanContent;
}
