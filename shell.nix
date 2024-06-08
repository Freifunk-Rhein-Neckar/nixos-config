{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [
    niv
    colmena
    (pkgs.callPackage "${(import ./nix/sources.nix).agenix}/pkgs/agenix.nix" {})
  ];
}
