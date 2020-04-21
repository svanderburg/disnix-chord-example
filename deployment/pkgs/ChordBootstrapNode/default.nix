/*{stdenv, ChordServer}:
{port}:

stdenv.mkDerivation {
  name = "ChordBootstrapNode";
  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/chord-node <<EOF
    #! ${stdenv.shell} -e
    ${ChordServer}/bin/chord-server "\$(hostname)" "${toString port}"
    EOF
    chmod +x $out/bin/chord-node

    # Restart the job when it accidentally terminates
    mkdir -p $out/etc
    cat > $out/etc/systemd-config <<EOF
    Restart=always
    EOF
  '';
}*/

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
