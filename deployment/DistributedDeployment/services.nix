{ system, distribution, invDistribution, pkgs
, stateDir ? "/var"
, runtimeDir ? "${stateDir}/run"
, logDir ? "${stateDir}/log"
, tmpDir ? (if stateDir == "/var" then "/tmp" else "${stateDir}/tmp")
, forceDisableUserChange ? false
, processManager ? "systemd"
, nix-processmgmt ? ../../../nix-processmgmt
}:

let
  processType = import "${nix-processmgmt}/nixproc/derive-dysnomia-process-type.nix" {
    inherit processManager;
  };

  customPkgs = import ../top-level/all-packages.nix {
    inherit system pkgs stateDir logDir runtimeDir tmpDir forceDisableUserChange processManager nix-processmgmt;
  };

  ids = if builtins.pathExists ./ids.nix then (import ./ids.nix).ids else {};
in
rec {
  ChordBootstrapNode = rec {
    name = "ChordBootstrapNode";
    port = ids.ports.ChordBootstrapNode or 0;
    pkg = customPkgs.ChordBootstrapNode { inherit port; };
    type = processType;
    requiresUniqueIdsFor = [ "ports" ];
  };

  ChordNode1 = rec {
    name = "ChordNode1";
    port = ids.ports.ChordNode1 or 0;
    pkg = customPkgs.ChordNode {
      inherit port;
      instanceSuffix = "1";
    };
    type = processType;
    dependsOn = {
      inherit ChordBootstrapNode;
    };
    requiresUniqueIdsFor = [ "ports" ];
  };

  ChordNode2 = rec {
    name = "ChordNode2";
    port = ids.ports.ChordNode2 or 0;
    pkg = customPkgs.ChordNode {
      inherit port;
      instanceSuffix = "2";
    };
    type = processType;
    dependsOn = {
      inherit ChordBootstrapNode;
    };
    requiresUniqueIdsFor = [ "ports" ];
  };

  ChordNode3 = rec {
    name = "ChordNode3";
    port = ids.ports.ChordNode3 or 0;
    pkg = customPkgs.ChordNode {
      inherit port;
      instanceSuffix = "3";
    };
    type = processType;
    dependsOn = {
      inherit ChordBootstrapNode;
    };
    requiresUniqueIdsFor = [ "ports" ];
  };

  openchord = {
    name = "openchord";
    pkg = customPkgs.openchord;
    type = "package";
  };
}
