{
  # https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays
  recursiveMerge = attrList:
    let
      f = attrPath:
        builtins.zipAttrsWith (n: values:
          if builtins.tail values == [ ]
          then builtins.head values
          else if builtins.all builtins.isList values
          then builtins.unique (builtins.concatLists values)
          else if builtins.all builtins.isAttrs values
          then f (attrPath ++ [ n ]) values
          else builtins.last values
        );
    in
    f [ ] attrList;

  mkSystemdStartupService = pkgs: { dependencies ? [ ], systemdDependencies ? [ ], name, script, busName ? "none", disablePartOf ? false, disableWantedBy ? false, disableAfter ? false, disableRequisite ? false, type ? "none" }:
    let
      bashScript = pkgs.writeShellScriptBin name script;
    in
    {
      enable = true;
      wantedBy = if disableWantedBy then [ ] else ([ "graphical-session.target" ] ++ systemdDependencies);
      partOf = if disablePartOf then [ ] else ([ "graphical-session.target" ] ++ systemdDependencies);
      after = if disableAfter then [ ] else ([ "graphical-session.target" ] ++ systemdDependencies);
      requisite = if disableRequisite then [ ] else ([ "graphical-session.target" ] ++ systemdDependencies);
      path = dependencies;
      description = "${name}: autostarted on DE start";
      serviceConfig =
        {
          ExecStart = "${bashScript}/bin/${name}";
          RestartSec = 1;
        } // (if busName == "none" then { } else {
          BusName = busName;
        }) // (if type == "none" then { } else {
          Type = type;
        });
    };
}
