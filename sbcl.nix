{
  nixpkgs ? <nixpkgs>
, sbcl-src
}:

let
  pkgs          = import nixpkgs {};
  x86_64-linux  = import nixpkgs { system = "x86_64-linux"; };
  aarch64-linux = import nixpkgs { system = "aarch64-linux"; };
  patched       = pkg: pkg.overrideAttrs(o: { src = sbcl-src; });
in

pkgs.lib.recurseIntoAttrs {
  x86_64-linux  = with  x86_64-linux.lispPackages_new; lispPackagesFor "${patched  x86_64-linux.sbcl}/bin/sbcl --script";
  aarch64-linux = with aarch64-linux.lispPackages_new; lispPackagesFor "${patched aarch64-linux.sbcl}/bin/sbcl --script";
}
