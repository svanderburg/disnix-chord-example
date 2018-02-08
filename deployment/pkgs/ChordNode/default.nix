{stdenv, ChordServer}:
{port}:
{ChordBootstrapNode}:

stdenv.mkDerivation {
  name = "ChordNode";
  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/chord-node <<EOF
    #! ${stdenv.shell} -e
    ${ChordServer}/bin/chord-server "\$(hostname)" "${toString port}" "${ChordBootstrapNode.target.properties.hostname}" "${toString ChordBootstrapNode.port}"
    EOF
    chmod +x $out/bin/chord-node

    # Restart the job when it accidentally terminates
    mkdir -p $out/etc
    cat > $out/etc/systemd-config <<EOF
    Restart=always
    EOF
  '';
}
