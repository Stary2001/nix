{stdenv, pkgs} : stdenv.mkDerivation {
  name = "boop";
  buildInputs = [
    (pkgs.python39.withPackages (pythonPackages: with pythonPackages; [
      pyserial
      requests
    ]))
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${./light_to_influx.py} $out/bin/light_to_influx.py
    chmod +x $out/bin/light_to_influx.py
  '';
}
