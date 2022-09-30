{ nixpkgs }:
let pkgs = import nixpkgs {}; in
pkgs.lispPackages_new.sbclPackages
