{ system, distribution, invDistribution, pkgs
, stateDir ? "/var"
, runtimeDir ? "${stateDir}/run"
, logDir ? "${stateDir}/log"
, tmpDir ? (if stateDir == "/var" then "/tmp" else "${stateDir}/tmp")
, forceDisableUserChange ? false
, processManager ? "systemd"
}:

let
  processType = import ../../../nix-processmgmt/nixproc/derive-dysnomia-process-type.nix {
    inherit processManager;
  };

  customPkgs = import ../top-level/all-packages.nix {
    inherit system pkgs stateDir logDir runtimeDir tmpDir forceDisableUserChange processManager;
  };

  portsConfiguration = if builtins.pathExists ./ports.nix then import ./ports.nix else {};
in
rec {
  ChordBootstrapNode = rec {
    name = "ChordBootstrapNode";
    pkg = customPkgs.ChordBootstrapNode { inherit port; };
    port = portsConfiguration.ports.ChordBootstrapNode or 0;
    portAssign = "private";
    type = processType;
  };

  ChordNode1 = rec {
    name = "ChordNode1";
    pkg = customPkgs.ChordNode { inherit port; };
    port = portsConfiguration.ports.ChordNode1 or 0;
    portAssign = "private";
    type = processType;
    dependsOn = {
      inherit ChordBootstrapNode;
    };
  };

  ChordNode2 = rec {
    name = "ChordNode2";
    pkg = customPkgs.ChordNode { inherit port; };
    port = portsConfiguration.ports.ChordNode2 or 0;
    portAssign = "private";
    type = processType;
    dependsOn = {
      inherit ChordBootstrapNode;
    };
  };

  ChordNode3 = rec {
    name = "ChordNode3";
    pkg = customPkgs.ChordNode { inherit port; };
    port = portsConfiguration.ports.ChordNode3 or 0;
    portAssign = "private";
    type = processType;
    dependsOn = {
      inherit ChordBootstrapNode;
    };
  };

  openchord = {
    name = "openchord";
    pkg = customPkgs.openchord;
    type = "package";
  };
}
