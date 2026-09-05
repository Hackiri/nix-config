# Discover complete host definitions and validate their metadata.
{
  hostsDir,
  defaultUsername,
}: let
  assertMsg = condition: message:
    if condition
    then true
    else throw message;
  knownKeys = [
    "type"
    "system"
    "device"
    "username"
  ];
  requiredKeys = [
    "type"
    "system"
    "device"
  ];
  supportedTypes = [
    "darwin"
    "nixos"
  ];
  supportedSystems = [
    "aarch64-darwin"
    "x86_64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
  supportedDevices = [
    "desktop"
    "laptop"
    "server"
    "vm"
  ];
  commaList = values: builtins.concatStringsSep ", " values;

  validateMeta = name: meta: let
    prefix = "Host '${name}' metadata";
    keys =
      if builtins.isAttrs meta
      then builtins.attrNames meta
      else [];
    unknownKeys = builtins.filter (key: !(builtins.elem key knownKeys)) keys;
    missingKeys = builtins.filter (key: !(builtins.hasAttr key meta)) requiredKeys;
    systemMatchesType =
      if meta.type == "darwin"
      then builtins.match ".*-darwin" meta.system != null
      else builtins.match ".*-linux" meta.system != null;
  in
    assert assertMsg
    (builtins.stringLength name <= 63 && builtins.match "[a-z0-9]([a-z0-9-]*[a-z0-9])?" name != null)
    "${prefix} host directory name must be a lower-case hostname label";
    assert assertMsg (builtins.isAttrs meta) "${prefix} must evaluate to an attrset";
    assert assertMsg (unknownKeys == []) "${prefix} has unknown keys: ${commaList unknownKeys}";
    assert assertMsg (missingKeys == []) "${prefix} is missing required keys: ${commaList missingKeys}";
    assert assertMsg (builtins.isString meta.type) "${prefix} 'type' must be a string";
    assert assertMsg (builtins.isString meta.system) "${prefix} 'system' must be a string";
    assert assertMsg (builtins.isString meta.device) "${prefix} 'device' must be a string";
    assert assertMsg (!(meta ? username) || builtins.isString meta.username) "${prefix} 'username' must be a string";
    assert assertMsg (builtins.elem meta.type supportedTypes) "${prefix} type must be one of: ${commaList supportedTypes}";
    assert assertMsg (builtins.elem meta.system supportedSystems) "${prefix} system must be one of: ${commaList supportedSystems}";
    assert assertMsg (builtins.elem meta.device supportedDevices) "${prefix} device must be one of: ${commaList supportedDevices}";
    assert assertMsg systemMatchesType "${prefix} type '${meta.type}' is inconsistent with system '${meta.system}'";
      meta
      // {
        inherit name;
        username = meta.username or defaultUsername;
        configuration =
          if meta.type == "darwin"
          then "darwinConfigurations"
          else "nixosConfigurations";
      };

  entries = builtins.readDir hostsDir;
  isCompleteHost = name: let
    hostDir = hostsDir + "/${name}";
  in
    entries.${name}
    == "directory"
    && builtins.pathExists (hostDir + "/meta.nix")
    && builtins.pathExists (hostDir + "/configuration.nix")
    && builtins.pathExists (hostDir + "/home.nix");
  eligibleNames = builtins.filter isCompleteHost (builtins.attrNames entries);
in
  builtins.listToAttrs (
    map (name: {
      inherit name;
      value = validateMeta name (import (hostsDir + "/${name}/meta.nix"));
    })
    eligibleNames
  )
