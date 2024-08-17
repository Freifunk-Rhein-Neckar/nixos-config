{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [
    (pkgs.callPackage "${(import ./nix/sources.nix).agenix}/pkgs/agenix.nix" {})
    colmena
    niv
    (pkgs.callPackage "${(import ./nix/sources.nix).niv-updater}/pkgs/niv-updater.nix" {})
  ];
}
