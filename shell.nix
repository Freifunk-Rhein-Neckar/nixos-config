let
  sources = import ./npins;
  pkgs = (import sources.nixpkgs { inherit sources; config = {}; });
in pkgs.mkShell {
  buildInputs = with pkgs; [
    (callPackage "${sources.agenix}/pkgs/agenix.nix" {})
    (callPackage "${sources.colmena}/package.nix" {})
    npins
    (callPackage "${sources.npins-updater}/pkgs/npins-updater.nix" {})
    attic-client
    nebula
    (callPackage "${sources.nebula-cert-generator}" {})
  ];
}
