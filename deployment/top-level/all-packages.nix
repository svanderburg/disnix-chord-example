{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
, stateDir
, logDir
, runtimeDir
, tmpDir
, forceDisableUserChange
, processManager
, nix-processmgmt
}:

let
  createManagedProcess = import "${nix-processmgmt}/nixproc/create-managed-process/agnostic/create-managed-process-universal.nix" {
    inherit pkgs stateDir runtimeDir logDir tmpDir forceDisableUserChange processManager;
  };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
    ChordServer = callPackage ../pkgs/ChordServer { };

    ChordBootstrapNode = callPackage ../pkgs/ChordBootstrapNode {
      inherit createManagedProcess;
    };

    ChordNode = callPackage ../pkgs/ChordNode {
      inherit createManagedProcess;
    };

    openchord = callPackage ../pkgs/openchord { };
  };
in
self
