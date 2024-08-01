{ config, lib, pkgs, ... }:

let
  patchedTcpdump = pkgs.tcpdump.overrideAttrs (oldAttrs: {
    buildInputs = [ (pkgs.libpcap.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "the-tcpdump-group";
        repo = "libpcap";
        rev = "09230c1db65fcc5c274e4de3e42c7fb7bc1051e6";
        sha256 = "sha256-O/ZFsfJ11XE42diKixQJs6jSYDPp9csSz+o/AOr/8ZI=";
      };
      version = "1.10.4-unstable-2024-06-23";

      preConfigure = ''
        ./autogen.sh
      '';

      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.autoconf ];
      patches =  [
        # Add support for B.A.T.M.A.N. Advanced
        ( pkgs.fetchpatch2 {
          url = "https://github.com/the-tcpdump-group/libpcap/commit/62133cbf5d032f73ba7821517daae05834f9dbff.patch";
          sha256 = "sha256-oMndIyIzzzEAH5l2+z6rFGjHBb0T4XtM3DCg4wTOTHc= ";
        })
      ];
     })) ];
  });

  removeTcpdump = pkg: pkg != pkgs.tcpdump;

in
{
  environment.systemPackages = with pkgs; lib.filter removeTcpdump [
    patchedTcpdump
  ];
}
