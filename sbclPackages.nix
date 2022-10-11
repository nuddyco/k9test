{ nixpkgs }:
let
  pkgs_x86_64  = import nixpkgs { system = "x86_64-linux"; };
  pkgs_i686    = import nixpkgs { system = "i686-linux"; };
  pkgs_aarch64 = import nixpkgs { system = "aarch64-linux"; };
in
{
  recurseIntoAttrs = true;
  x86_64  = pkgs_x86_64.lispPackages_new.sbclPackages;
  i686    = pkgs_x86_64.lispPackages_new.sbclPackages;
  aarch64 = pkgs_x86_64.lispPackages_new.sbclPackages;
}
