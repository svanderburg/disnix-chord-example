{stdenv, createManagedProcess, ChordServer}:
{port, instanceSuffix ? "", instanceName ? "ChordNode${instanceSuffix}"}:
{ChordBootstrapNode}:

let
  ChordNode = stdenv.mkDerivation {
    name = instanceName;
    buildCommand = ''
      mkdir -p $out/bin
      cat > $out/bin/chord-node <<EOF
      #! ${stdenv.shell} -e
      exec ${ChordServer}/bin/chord-server "\$(hostname)" "${toString port}" "${ChordBootstrapNode.target.properties.hostname}" "${toString ChordBootstrapNode.port}"
      EOF
      chmod +x $out/bin/chord-node
    '';
  };
in
createManagedProcess {
  inherit instanceName;

  description = "Chord Node";
  foregroundProcess = "${ChordNode}/bin/chord-node";

  overrides = {
    sysvinit = {
      runlevels = [ 3 4 5 ];
    };
    systemd = {
      Service.Restart = "always";
    };
  };
}
