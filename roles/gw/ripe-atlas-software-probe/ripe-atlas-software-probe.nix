{ lib
, fetchFromGitHub
, stdenv
, unzip
, autoconf269
# , libtool_1_5
, libtool
, automake
, libevent
# , openssl_1_1
, openssl
}:

stdenv.mkDerivation rec {
  pname = "ripe-atlas-software-probe";
  version = "5080";

  src = fetchFromGitHub {
    repo = "ripe-atlas-software-probe";
    #owner = "RIPE-NCC";
    # rev = "v${version}";
    #rev = "67b0736887d33d1c42557e7c7694cbd4e5d8e6ee";
    #sha256 = "sha256-0HeD8zaqzlfLCm0/nhJFgYeC2oV21oXYCR9M37aUoEU=";

    owner = "herbetom";
    rev = "2e61f6fc5e0a611ac28be56a5a995e2787a197a8";
    sha256 = "sha256-3BCvjPN4/23Wj1iXcPynL9gpRkaUUBRXD5ApFVAj2S0=";

    fetchSubmodules = true;
  };

  configurePhase = ''
    pwd
    ls -lah
    ls -lah probe-busybox
    cd probe-busybox
    cd libevent-2.1.11-stable
    autoreconf --install
    ./configure
  '';

  buildPhase = ''
    echo "################################################################################# Building libevent ..."
    pwd
    # ls -lah
    # cd probe-busybox/libevent-2.1.11-stable
    make
    echo "################################################################################# Finished Building libevent ..."

    cd ..
    echo "################################################################################# Building ripe-atlas-software-probe ..."
    make
    echo "################################################################################# Finished Building ripe-atlas-software-probe ..."
  '';

#  installPhase = ''
#    # echo "Skipping install"
#    make install
#    mkdir -p "$sta_atlas_local/bb-13.3"

#    # Add any custom install commands here if needed
#  '';



  #sourceRoot = ".";

  nativeBuildInputs = [
    autoconf269
    libtool
    automake
    libevent
    # openssl_1_1
    openssl
  ];
  #nativeBuildInputs = [ unzip ];

  # buildPhase = ''
  #   mkdir -p $out
  #   cp -r * $out
  # '';
}
