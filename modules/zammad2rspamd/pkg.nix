{ pkgs ? import <nixpkgs> {} }:

let
  src = pkgs.fetchFromGitLab {
    domain = "git.darmstadt.ccc.de";
    owner = "tomh";
    repo = "zammad2rspamd";
    rev = "6693e1afa288efaaf601f637995bd30c36cc2d7d";
    hash = "sha256-jf+H7Oymeaz7CTmVEWBdfwqTNzaFMazmgLzLYRkmYzM=";
  };

  customWritePython3Bin = pkgs.writers.makePythonWriter pkgs.python3 pkgs.python3Packages.flake8 {
    flake8 = {
      ignore = [ "E265" ];
    };
  };
in
customWritePython3Bin "/bin/zammad2rspamd" {
  libraries = [ pkgs.python3Packages.requests ];
  doCheck = false;
} (builtins.readFile "${src}/zammad2rspamd.py")
