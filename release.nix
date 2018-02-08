{ nixpkgs ? <nixpkgs>
, disnix_chord_example ? {outPath = ./.; rev = 1234;}
, officialRelease ? false
, systems ? [ "i686-linux" "x86_64-linux" ]
}:

let
  pkgs = import nixpkgs {};

  jobs = rec {
    tarball =
      let
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs;
        };
      in
      disnixos.sourceTarball {
        name = "disnix-chord-example-tarball";
        version = builtins.readFile ./version;
        src = disnix_chord_example;
        inherit officialRelease;
      };

    builds = pkgs.lib.genAttrs systems (system:
      let
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs system;
        };
      in
      disnixos.buildManifest {
        name = "disnix-chord-example";
        version = builtins.readFile ./version;
        inherit tarball;
        servicesFile = "deployment/DistributedDeployment/services.nix";
        networkFile = "deployment/DistributedDeployment/network.nix";
        distributionFile = "deployment/DistributedDeployment/distribution.nix";
      });

    tests =
      let
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs;
        };

        customPkgs = import ./deployment/top-level/all-packages.nix {
          pkgs = import nixpkgs {};
        };

        inherit (customPkgs) openchord;
        manifest = builtins.getAttr (builtins.currentSystem) builds;
      in
      disnixos.disnixTest {
        name = "disnix-chord-example-test";
        inherit tarball manifest;
        networkFile = "deployment/DistributedDeployment/network.nix";
        testScript = ''
          $test1->mustSucceed("sleep 10");
          $test1->mustSucceed("((echo 'joinN -port 9000 -bootstrap test2:8001'; sleep 10; echo 'refsN'; echo 'exit'; echo 'y') | ${openchord}/bin/openchord-console > out) &");
          $test1->mustSucceed("sleep 30");
          $test1->mustSucceed("[ \$(grep -c 'ocsocket://test' out) -eq 6 ]");
        '';
      };
  };
in
jobs
