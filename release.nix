{ nixpkgs ? <nixpkgs>
, disnix_chord_example ? {outPath = ./.; rev = 1234;}
, nix-processmgmt ? { outPath = ../nix-processmgmt; rev = 1234; }
, officialRelease ? false
, systems ? [ "i686-linux" "x86_64-linux" ]
}:

let
  pkgs = import nixpkgs {};

  disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
    inherit nixpkgs;
  };

  version = builtins.readFile ./version;

  jobs = rec {
    tarball = disnixos.sourceTarball {
      name = "disnix-chord-example-tarball";
      src = disnix_chord_example;
      inherit officialRelease version;
    };

    builds = pkgs.lib.genAttrs systems (system:
      let
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs system;
        };
      in
      disnixos.buildManifest {
        name = "disnix-chord-example";
        inherit tarball version;
        servicesFile = "deployment/DistributedDeployment/services.nix";
        networkFile = "deployment/DistributedDeployment/network.nix";
        distributionFile = "deployment/DistributedDeployment/distribution.nix";
        extraParams = {
          inherit nix-processmgmt;
        };
      });

    tests =
      let
        manifest = builtins.getAttr (builtins.currentSystem) builds;
      in
      disnixos.disnixTest {
        name = "disnix-chord-example-test";
        inherit tarball manifest;
        networkFile = "deployment/DistributedDeployment/network.nix";
        testScript = ''
          test1Profile = test1.succeed(
              "${pkgs.libxml2}/bin/xmllint --xpath \"/manifest/profiles/profile[@name='test1']/text()\" ${manifest}/manifest.xml"
          )
          test1.succeed("sleep 10")
          test1.succeed(
              "((echo 'joinN -port 9000 -bootstrap test2:8001'; sleep 10; echo 'refsN'; echo 'exit'; echo 'y') | {}/bin/openchord-console > out) &".format(
                  test1Profile[:-1]
              )
          )
          test1.succeed("sleep 30")
          test1.succeed("[ $(grep -c 'ocsocket://test' out) -eq 6 ]")
        '';
      };
  };
in
jobs
