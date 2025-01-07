{
  lib,
  pkgs,
  config,
  ...
}: let
  _convertValue = path: v:
    if builtins.isAttrs v
    then
      builtins.concatMap (k:
        _convertValue (
          if path == ""
          then k
          else path + "." + k
        )
        v.${k}) (builtins.attrNames v)
    else [[path (builtins.toString v)]];

  convertValue = v: let
    pairs = _convertValue "" v;
  in [(map builtins.head pairs) (map (p: builtins.head (builtins.tail p)) pairs)];

  keyNames = v: builtins.head (convertValue v);
  valueNames = v: builtins.head (builtins.tail (convertValue v));
in
  template: data: let
    var_names = builtins.map (x: "{{ " + x + " }}") (keyNames data);
    values = valueNames data;
    processed_text = builtins.replaceStrings var_names values (builtins.readFile template);
  in
    assert lib.asserts.assertMsg (builtins.length (builtins.split "[{][{][[:space:]].+[[:space:]][}][}]" processed_text) == 1) "Not all variables were processed in file ${template}"; processed_text
