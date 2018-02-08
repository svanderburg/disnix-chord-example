{stdenv, fetchurl, ant, jdk, unzip}:

stdenv.mkDerivation {
  name = "openchord";
  src = fetchurl {
    url = mirror://sourceforge/open-chord/open-chord_1.0.5.zip;
    sha256 = "1mg43ichz9hg16p6jsd1yj49213c12cx1swhk0b28d4x6lcfjpsv";
  };
  buildInputs = [ ant jdk unzip ];
  unpackPhase = ''
    mkdir openchord
    cd openchord
    unzip $src
  '';
  buildPhase = ''
    sed -i -e 's|<javac|<javac encoding="ISO-8859-1" |' build.xml
    ant clean
    ant compile
    ant dist
  '';
  installPhase = ''
    mkdir -p $out/share/java
    cp dist/*.jar $out/share/java

    mkdir -p $out/bin
    cat > $out/bin/openchord-console <<EOF
    #! ${stdenv.shell} -e
    ${jdk}/bin/java -jar $(echo $out/share/java/*.jar) "\$@"
    EOF
    chmod +x $out/bin/openchord-console

    mkdir -p $out/share/doc/openchord
    cp -av docs/* $out/share/doc/openchord
  '';
  meta = {
    description = "A Java implementation of the Chord Distributed Hash Table (DHT)";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };
}
