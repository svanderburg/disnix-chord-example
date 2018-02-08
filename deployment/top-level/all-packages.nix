{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
    ChordServer = callPackage ../pkgs/ChordServer { };

    ChordBootstrapNode = callPackage ../pkgs/ChordBootstrapNode { };

    ChordNode = callPackage ../pkgs/ChordNode { };

    openchord = callPackage ../pkgs/openchord { };
  };
in
self
