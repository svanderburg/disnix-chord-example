{stdenv, createManagedProcess, ChordServer}:
{port, instanceSuffix ? ""}:

let
  instanceName = "ChordBootstrapNode${instanceSuffix}";

  ChordBootstrapNode = stdenv.mkDerivation {
    name = instanceName;
    buildCommand = ''
      mkdir -p $out/bin
      cat > $out/bin/chord-node <<EOF
      #! ${stdenv.shell} -e
      exec ${ChordServer}/bin/chord-server "\$(hostname)" "${toString port}"
      EOF
      chmod +x $out/bin/chord-node
  '';
};
in
createManagedProcess {
  name = instanceName;
  description = "Chord Bootstrap Node";
  foregroundProcess = "${ChordBootstrapNode}/bin/chord-node";
  inherit instanceName;

  overrides = {
    sysvinit = {
      runlevels = [ 3 4 5 ];
    };
    systemd = {
      Service.Restart = "always";
    };
  };
}
