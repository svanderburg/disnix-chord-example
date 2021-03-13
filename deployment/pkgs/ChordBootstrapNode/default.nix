{stdenv, createManagedProcess, ChordServer}:
{port, instanceSuffix ? "", instanceName ? "ChordBootstrapNode${instanceSuffix}"}:

let
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
  inherit instanceName;

  description = "Chord Bootstrap Node";
  foregroundProcess = "${ChordBootstrapNode}/bin/chord-node";

  overrides = {
    sysvinit = {
      runlevels = [ 3 4 5 ];
    };
    systemd = {
      Service.Restart = "always";
    };
  };
}
