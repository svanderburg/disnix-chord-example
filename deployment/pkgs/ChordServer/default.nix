{stdenv, lib, jdk, openchord}:

stdenv.mkDerivation {
  name = "ChordServer";
  src = ../../../src/ChordServer;
  buildInputs = [ jdk ];
  buildPhase = ''
    javac -classpath .:$(echo ${openchord}/share/java/*.jar) ChordServer.java
  '';
  installPhase = ''
    mkdir -p $out/share/java
    mv ChordServer.class $out/share/java
    mkdir -p $out/bin
    cat > $out/bin/chord-server <<EOF
    #! ${stdenv.shell} -e

    exec ${jdk}/bin/java -classpath $out/share/java:$(echo ${openchord}/share/java/*.jar) ChordServer "\$@"
    EOF
    chmod +x $out/bin/chord-server
  '';
  meta = {
    license = lib.licenses.gpl2Plus;
  };
}
