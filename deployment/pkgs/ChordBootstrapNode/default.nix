{stdenv, ChordServer}:
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
}
